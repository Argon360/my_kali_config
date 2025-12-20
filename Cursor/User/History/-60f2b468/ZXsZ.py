#!/usr/bin/env python3
"""
wiki_crawler.py

Wikipedia link-path finder with strategies:
 - bfs   : uni-directional BFS (guaranteed shortest)
 - best  : heuristic best-first (fast, not guaranteed)
 - bidi  : bidirectional BFS using prop=linkshere (guaranteed shortest, faster)

Features:
 - Interactive prompt (for main options) if script started with no flags.
   Utility flags (sleep, max-branch, user-agent, etc.) must be provided on CLI.
 - Explanation is now **always** printed after a run (path found or not).
   Interactive runs will ask whether to save the explanation at the end.
 - --verbose tracing
 - --flowchart <file.png> output (PNG) that highlights the final path
 - --flowchart-mode: path-only | path-neighbors | pruned | mindmap | full
 - decision tracing and textual explanation (--explain-file still supported)
 - in-memory caching of links and linkshere (incoming links)
 - polite sleeps between API calls
"""

import argparse
import requests
import time
from collections import deque
from heapq import heappush, heappop
import difflib
import networkx as nx
import matplotlib.pyplot as plt
import os
import math
import sys

API_ENDPOINT = "https://en.wikipedia.org/w/api.php"
DEFAULT_USER_AGENT = "WikiCrawlerBot/1.0 (example@example.com) Python/requests"

# ---------------------------
# Helpers
# ---------------------------
def _shorten_label(label, max_len=28):
    if len(label) <= max_len:
        return label
    parts = label.split()
    if len(parts) == 1:
        return label[:max_len-3] + "..."
    first = " ".join(parts[:3])
    last = parts[-1]
    short = first + " … " + last
    if len(short) <= max_len:
        return short
    return label[:max_len-3] + "..."

def ask(prompt, default=None, validator=None):
    if default is None:
        prompt_str = f"{prompt}: "
    else:
        prompt_str = f"{prompt} [{default}]: "
    while True:
        try:
            val = input(prompt_str).strip()
        except (EOFError, KeyboardInterrupt):
            print()
            raise SystemExit("Interactive prompt aborted by user.")
        if val == "" and default is not None:
            val = default
        if validator:
            try:
                return validator(val)
            except Exception as e:
                print("Invalid value:", e)
                continue
        else:
            return val

def ask_yes_no(prompt, default=False):
    dstr = "Y/n" if default else "y/N"
    while True:
        try:
            val = input(f"{prompt} [{dstr}]: ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            print()
            raise SystemExit("Interactive prompt aborted by user.")
        if val == "":
            return default
        if val in ("y", "yes"):
            return True
        if val in ("n", "no"):
            return False
        print("Please answer y or n.")

def parse_int(s, name):
    try:
        return int(s)
    except:
        raise ValueError(f"{name} must be an integer")

# ---------------------------
# Crawler
# ---------------------------
class WikipediaAPIError(Exception):
    pass

class WikiCrawler:
    def __init__(self, session=None, user_agent=None, sleep_between_requests=0.1, verbose=False):
        self.session = session or requests.Session()
        self.session.headers.update({
            "User-Agent": user_agent or DEFAULT_USER_AGENT
        })
        self.sleep = sleep_between_requests
        self.verbose = verbose

        # caches
        self.link_cache = {}       # title -> set(outgoing)
        self.linkshere_cache = {}  # title -> set(incoming)
        self.title_cache = {}      # input -> canonical

        # graph & decisions (for flowchart + explanation)
        self.crawl_graph = nx.DiGraph()
        self.decision_info = {}    # (from, to) -> metadata

    def log(self, *msg):
        if self.verbose:
            print("[verbose]", *msg)

    def _api_get(self, params):
        params = dict(params)
        params.setdefault("format", "json")
        resp = self.session.get(API_ENDPOINT, params=params, timeout=30)
        if resp.status_code != 200:
            raise WikipediaAPIError(f"Bad status {resp.status_code}: {resp.text[:200]}")
        return resp.json()

    def resolve_title(self, title):
        if title in self.title_cache:
            self.log("Title cache hit:", title, "->", self.title_cache[title])
            return self.title_cache[title]

        self.log("Resolving title:", title)
        params = {
            "action": "query",
            "titles": title,
            "redirects": 1,
            "formatversion": 2,
            "prop": "info"
        }
        j = self._api_get(params)
        pages = j.get("query", {}).get("pages", [])
        if not pages:
            self.log(f"  → No pages found resolving: {title}")
            return None
        page = pages[0]
        if "missing" in page:
            self.log(f"  → Page missing for: {title}")
            return None
        normalized_title = page.get("title")
        self.title_cache[title] = normalized_title
        self.title_cache[normalized_title] = normalized_title
        self.log(f"  → Resolved '{title}' to canonical '{normalized_title}'")
        return normalized_title

    def random_page_title(self, namespace=0):
        params = {
            "action": "query",
            "list": "random",
            "rnnamespace": namespace,
            "rnlimit": 1,
            "formatversion": 2
        }
        j = self._api_get(params)
        entries = j.get("query", {}).get("random", [])
        if not entries:
            raise WikipediaAPIError("Could not fetch random page")
        title = entries[0]["title"]
        self.log("Random page picked:", title)
        return title

    def get_links(self, title):
        """
        Outgoing links from `title` (namespace 0 only). Cached.
        """
        normalized_title = self.resolve_title(title)
        if not normalized_title:
            self.log(f"get_links: cannot resolve title '{title}' -> returning empty set")
            return set()

        if normalized_title in self.link_cache:
            self.log("Link cache hit for:", normalized_title, f"({len(self.link_cache[normalized_title])} links)")
            return self.link_cache[normalized_title]

        self.log("Fetching links for:", normalized_title)
        links = set()
        params = {
            "action": "query",
            "titles": normalized_title,
            "prop": "links",
            "pllimit": "max",
            "formatversion": 2
        }
        while True:
            j = self._api_get(params)
            time.sleep(self.sleep)
            pages = j.get("query", {}).get("pages", [])
            if pages:
                page = pages[0]
                for l in page.get("links", []):
                    if l.get("ns") == 0:
                        links.add(l.get("title"))
            cont = j.get("continue")
            if cont and cont.get("plcontinue"):
                params["plcontinue"] = cont["plcontinue"]
                self.log("  → continuation, plcontinue:", params["plcontinue"])
                continue
            else:
                break
        self.link_cache[normalized_title] = links
        self.log(f"  → {len(links)} links collected for '{normalized_title}'")
        return links

    def get_linkshere(self, title):
        """
        Incoming links to `title` (pages that link to it). Cached.
        Uses prop=linkshere with lhnamespace=0.
        """
        normalized_title = self.resolve_title(title)
        if not normalized_title:
            self.log(f"get_linkshere: cannot resolve title '{title}' -> returning empty set")
            return set()

        if normalized_title in self.linkshere_cache:
            self.log("Linkshere cache hit for:", normalized_title, f"({len(self.linkshere_cache[normalized_title])} incoming)")
            return self.linkshere_cache[normalized_title]

        self.log("Fetching incoming links (linkshere) for:", normalized_title)
        incoming = set()
        params = {
            "action": "query",
            "titles": normalized_title,
            "prop": "linkshere",
            "lhlimit": "max",
            "lhnamespace": 0,
            "formatversion": 2
        }
        while True:
            j = self._api_get(params)
            time.sleep(self.sleep)
            pages = j.get("query", {}).get("pages", [])
            if pages:
                page = pages[0]
                for l in page.get("linkshere", []):
                    incoming.add(l.get("title"))
            cont = j.get("continue")
            if cont and cont.get("lhcontinue"):
                params["lhcontinue"] = cont["lhcontinue"]
                self.log("  → continuation, lhcontinue:", params["lhcontinue"])
                continue
            else:
                break
        self.linkshere_cache[normalized_title] = incoming
        self.log(f"  → {len(incoming)} incoming links collected for '{normalized_title}'")
        return incoming

    def search_title(self, query, limit=1):
        self.log("Searching for best match of:", query)
        params = {
            "action": "query",
            "list": "search",
            "srsearch": query,
            "srlimit": limit,
            "formatversion": 2
        }
        j = self._api_get(params)
        hits = j.get("query", {}).get("search", [])
        if not hits:
            self.log("  → No search hits for:", query)
            return None
        title = hits[0]["title"]
        self.log("  → Search matched to:", title)
        return title

    # ------------------------------
    # BFS (kept)
    # ------------------------------
    def find_path_bfs(self, start_title, target_title, max_depth=6, max_visited=100000):
        start = self.resolve_title(start_title)
        if start is None:
            raise ValueError(f"Start page not found: {start_title}")
        target = self.resolve_title(target_title)
        if target is None:
            raise ValueError(f"Target page not found: {target_title}")

        self.crawl_graph = nx.DiGraph()
        self.crawl_graph.add_node(start)
        self.decision_info = {}

        self.log("BFS start:", start, "-> target:", target)
        if start == target:
            return [start]

        q = deque()
        q.append((start, [start], 0))
        visited = {start}
        visited_count = 0

        while q:
            current, path, depth = q.popleft()
            visited_count += 1
            if visited_count % 500 == 0:
                self.log(f"Visited {visited_count} pages so far; queue size: {len(q)}")
            if visited_count > max_visited:
                raise RuntimeError("Visited cap exceeded; aborting")

            self.log(f"Visiting: {current} | Depth: {depth} | Path length: {len(path)} | Queue: {len(q)}")
            if depth >= max_depth:
                self.log(f"  → reached max depth for node {current}, skipping expansion")
                continue

            try:
                neighbors = self.get_links(current)
            except Exception as e:
                print(f"[warning] failed to get links for {current}: {e}")
                neighbors = set()

            for n in neighbors:
                if not self.crawl_graph.has_node(n):
                    self.crawl_graph.add_node(n)
                if not self.crawl_graph.has_edge(current, n):
                    self.crawl_graph.add_edge(current, n)

            self.log(f"Expanding {current}: {len(neighbors)} neighbors")

            if target in neighbors:
                self.decision_info[(current, target)] = {'method': 'bfs', 'depth': depth + 1, 'note': 'direct neighbor - target found'}
                self.log(f"Target '{target}' found as neighbor of '{current}'")
                return path + [target]

            for n in neighbors:
                if n not in visited:
                    visited.add(n)
                    q.append((n, path + [n], depth + 1))
                    self.decision_info[(current, n)] = {'method': 'bfs', 'depth': depth + 1, 'note': f'enqueued from {current}'}
                    self.log(f"  → enqueued: {n} (new depth {depth+1})")
                else:
                    self.log(f"  → skipped visited: {n}")

        self.log("BFS complete: no path found within max_depth")
        return None

    # ------------------------------
    # Best-first (kept)
    # ------------------------------
    def _title_score(self, candidate_title, target_title):
        ratio = difflib.SequenceMatcher(None, candidate_title.lower(), target_title.lower()).ratio()
        score = ratio
        target_tokens = [t for t in target_title.lower().split() if len(t) > 2]
        cand_lower = candidate_title.lower()
        token_bonus = 0.0
        for tkn in target_tokens:
            if tkn in cand_lower:
                token_bonus += 0.25
        score = score + token_bonus
        return score

    def find_path_best_first(self, start_title, target_title, max_depth=6, max_visited=50000, max_branch=50):
        start = self.resolve_title(start_title)
        if start is None:
            raise ValueError(f"Start page not found: {start_title}")
        target = self.resolve_title(target_title)
        if target is None:
            raise ValueError(f"Target page not found: {target_title}")

        self.crawl_graph = nx.DiGraph()
        self.crawl_graph.add_node(start)
        self.decision_info = {}

        if start == target:
            return [start]

        uid_counter = 0
        heap = []
        start_score = self._title_score(start, target)
        heappush(heap, (-start_score, 0, uid_counter, start, [start]))
        uid_counter += 1

        visited = set([start])
        visited_count = 0

        while heap:
            neg_score, depth, _, current, path = heappop(heap)
            visited_count += 1
            if visited_count > max_visited:
                raise RuntimeError("Visited cap exceeded; aborting")

            self.log(f"[best-first] Visiting: {current} | depth={depth} | score={-neg_score:.4f} | path_len={len(path)} | heap={len(heap)}")
            if depth >= max_depth:
                self.log(f"  -> reached max depth for {current}, skipping expansion")
                continue

            try:
                neighbors = self.get_links(current)
            except Exception as e:
                print(f"[warning] failed to get links for {current}: {e}")
                neighbors = set()

            for n in neighbors:
                if not self.crawl_graph.has_node(n):
                    self.crawl_graph.add_node(n)
                if not self.crawl_graph.has_edge(current, n):
                    self.crawl_graph.add_edge(current, n)

            if target in neighbors:
                self.decision_info[(current, target)] = {'method': 'best', 'depth': depth + 1, 'note': 'direct neighbor - target found', 'score': None}
                self.log(f"[best-first] Target '{target}' found as neighbor of '{current}'")
                return path + [target]

            scored = []
            for n in neighbors:
                if n in visited:
                    continue
                sc = self._title_score(n, target)
                scored.append((sc, n))

            if not scored:
                continue

            scored.sort(reverse=True, key=lambda x: x[0])
            top_neighbors = scored[:max_branch]
            self.log(f"  -> expanding {len(top_neighbors)} of {len(scored)} neighbors (top by heuristic)")

            for sc, n in top_neighbors:
                if n not in visited:
                    visited.add(n)
                    uid_counter += 1
                    heappush(heap, (-sc, depth + 1, uid_counter, n, path + [n]))
                    self.decision_info[(current, n)] = {'method': 'best', 'depth': depth + 1, 'score': sc, 'note': f'enqueued by heuristic (top {len(top_neighbors)})'}
                    self.log(f"    enqueued {n} (score={sc:.4f})")
                else:
                    self.log(f"    skipped visited {n}")

        self.log("[best-first] no path found within limits")
        return None

    # ------------------------------
    # Bidirectional (kept)
    # ------------------------------
    def find_path_bidi(self, start_title, target_title, max_depth=6, max_visited=100000):
        start = self.resolve_title(start_title)
        if start is None:
            raise ValueError(f"Start page not found: {start_title}")
        target = self.resolve_title(target_title)
        if target is None:
            raise ValueError(f"Target page not found: {target_title}")

        if start == target:
            return [start]

        self.crawl_graph = nx.DiGraph()
        self.crawl_graph.add_node(start)
        self.crawl_graph.add_node(target)
        self.decision_info = {}

        parent_fwd = {start: None}
        parent_bwd = {target: None}

        q_fwd = deque([(start, 0)])
        q_bwd = deque([(target, 0)])
        visited_fwd = {start}
        visited_bwd = {target}

        visited_count = 0

        while q_fwd and q_bwd:
            if len(q_fwd) <= len(q_bwd):
                current, depth = q_fwd.popleft()
                visited_count += 1
                if visited_count > max_visited:
                    raise RuntimeError("Visited cap exceeded; aborting")

                self.log(f"[bidi][FWD] Visiting: {current} | Depth: {depth} | q_fwd={len(q_fwd)} | q_bwd={len(q_bwd)}")
                if depth >= max_depth:
                    self.log(f"  -> reached max forward depth for {current}, skipping expansion")
                else:
                    try:
                        neighbors = self.get_links(current)
                    except Exception as e:
                        print(f"[warning] failed to get links for {current}: {e}")
                        neighbors = set()

                    for n in neighbors:
                        if not self.crawl_graph.has_node(n):
                            self.crawl_graph.add_node(n)
                        if not self.crawl_graph.has_edge(current, n):
                            self.crawl_graph.add_edge(current, n)

                    inter = neighbors & visited_bwd
                    if inter:
                        meet = next(iter(inter))
                        self.log(f"[bidi] Meeting node found via forward expansion: {meet}")
                        if (current, meet) not in self.decision_info:
                            self.decision_info[(current, meet)] = {'method': 'bidi_fwd', 'depth': depth + 1, 'note': 'meeting edge (found by forward expansion)'}
                        return self._reconstruct_bidi_path(parent_fwd, parent_bwd, meet, start, target)

                    for n in neighbors:
                        if n not in visited_fwd:
                            visited_fwd.add(n)
                            parent_fwd[n] = current
                            q_fwd.append((n, depth + 1))
                            self.decision_info[(current, n)] = {'method': 'bidi_fwd', 'depth': depth + 1, 'note': f'forward enqueued from {current}'}
                            self.log(f"  -> fwd enqueued: {n} (depth {depth+1})")
                        else:
                            self.log(f"  -> fwd skipped visited: {n}")
            else:
                current, depth = q_bwd.popleft()
                visited_count += 1
                if visited_count > max_visited:
                    raise RuntimeError("Visited cap exceeded; aborting")

                self.log(f"[bidi][BWD] Visiting: {current} | Depth: {depth} | q_fwd={len(q_fwd)} | q_bwd={len(q_bwd)}")
                if depth >= max_depth:
                    self.log(f"  -> reached max backward depth for {current}, skipping expansion")
                else:
                    try:
                        incoming = self.get_linkshere(current)
                    except Exception as e:
                        print(f"[warning] failed to get linkshere for {current}: {e}")
                        incoming = set()

                    for n in incoming:
                        if not self.crawl_graph.has_node(n):
                            self.crawl_graph.add_node(n)
                        if not self.crawl_graph.has_edge(n, current):
                            self.crawl_graph.add_edge(n, current)

                    inter = incoming & visited_fwd
                    if inter:
                        meet = next(iter(inter))
                        self.log(f"[bidi] Meeting node found via backward expansion: {meet}")
                        if (meet, current) not in self.decision_info:
                            self.decision_info[(meet, current)] = {'method': 'bidi_bwd', 'depth': depth + 1, 'note': 'meeting edge (found by backward expansion)'}
                        return self._reconstruct_bidi_path(parent_fwd, parent_bwd, meet, start, target)

                    for n in incoming:
                        if n not in visited_bwd:
                            visited_bwd.add(n)
                            parent_bwd[n] = current
                            q_bwd.append((n, depth + 1))
                            self.decision_info[(n, current)] = {'method': 'bidi_bwd', 'depth': depth + 1, 'note': f'backward enqueued: {n} links to {current}'}
                            self.log(f"  -> bwd enqueued: {n} (depth {depth+1})")
                        else:
                            self.log(f"  -> bwd skipped visited: {n}")

        self.log("[bidi] No meeting point found within limits")
        return None

    def _reconstruct_bidi_path(self, parent_fwd, parent_bwd, meeting_node, start, target):
        left = []
        node = meeting_node
        while node is not None:
            left.append(node)
            node = parent_fwd.get(node)
        left = list(reversed(left))

        right = []
        cur = meeting_node
        while cur is not None and cur != target:
            nxt = parent_bwd.get(cur)
            if nxt is None:
                break
            right.append(nxt)
            cur = nxt

        full_path = left + right
        if full_path[0] != start:
            full_path = [start] + full_path
        if full_path[-1] != target:
            full_path = full_path + [target]
        self.log("[bidi] Reconstructed path:", " -> ".join(full_path))
        return full_path

    # ------------------------------
    # Explanation
    # ------------------------------
    def explain_path(self, path):
        if not path or len(path) < 2:
            return "No path or trivial path (start == target). Nothing to explain."

        lines = []
        lines.append("Explanation of the path found (step-by-step):")
        lines.append(f"Total hops: {len(path)-1}")
        lines.append("")

        for i in range(len(path)-1):
            a = path[i]
            b = path[i+1]
            info = self.decision_info.get((a, b))
            if info is None:
                info = self.decision_info.get((b, a))

            step_no = i + 1
            if info:
                method = info.get('method', 'unknown')
                depth = info.get('depth')
                score = info.get('score')
                note = info.get('note', '')
                parts = [f"{step_no}. {a} -> {b}"]
                parts.append(f"   • method: {method}")
                if depth is not None:
                    parts.append(f"   • depth (click count from origin on that side): {depth}")
                if score is not None:
                    parts.append(f"   • heuristic score: {score:.4f}")
                if note:
                    parts.append(f"   • note: {note}")
                lines.append("\n".join(parts))
            else:
                lines.append(f"{step_no}. {a} -> {b}\n   • reason: link observed during crawling (no recorded enqueue metadata).")
        return "\n".join(lines)

    # ------------------------------
    # Flowchart (including mindmap)
    # ------------------------------
    def draw_flowchart(self, output_path, highlight_path=None, max_nodes=500, mode="pruned", hide_nonpath_labels=False):
        """
        Modes:
         - path-only
         - path-neighbors
         - pruned
         - mindmap   (radial mindmap layout: start at center, nodes by distance)
         - full
        """
        if self.crawl_graph is None or len(self.crawl_graph.nodes) == 0:
            raise RuntimeError("No crawl graph recorded to draw.")

        G_full = self.crawl_graph.copy()
        path = highlight_path or []

        # Build subgraph depending on mode (mindmap uses pruned subset but special layout)
        if mode == "path-only":
            if not path:
                raise RuntimeError("path-only mode requires a highlight_path.")
            nodes_to_keep = set(path)
            G = G_full.subgraph(nodes_to_keep).copy()
        elif mode == "path-neighbors":
            if not path:
                raise RuntimeError("path-neighbors mode requires a highlight_path.")
            nodes_to_keep = set(path)
            for n in path:
                nodes_to_keep.update(G_full.successors(n))
                nodes_to_keep.update(G_full.predecessors(n))
            G = G_full.subgraph(nodes_to_keep).copy()
        elif mode == "full":
            G = G_full
        else:  # pruned or mindmap
            nodes_to_keep = set(path)
            for n in path:
                nodes_to_keep.update(G_full.successors(n))
                nodes_to_keep.update(G_full.predecessors(n))
            if len(nodes_to_keep) < max_nodes:
                deg_sorted = sorted(G_full.nodes, key=lambda n: (G_full.degree(n)), reverse=True)
                idx = 0
                while len(nodes_to_keep) < max_nodes and idx < len(deg_sorted):
                    nodes_to_keep.add(deg_sorted[idx])
                    idx += 1
            G = G_full.subgraph(nodes_to_keep).copy()

        # final prune safeguard
        if len(G.nodes) > max_nodes:
            keep = set(path)
            deg_sorted = sorted(G.nodes, key=lambda n: (G.degree(n)), reverse=True)
            idx = 0
            while len(keep) < max_nodes and idx < len(deg_sorted):
                keep.add(deg_sorted[idx])
                idx += 1
            G = G.subgraph(keep).copy()

        # Layout selection
        pos = {}
        if mode == "mindmap":
            # radial layout based on distance from start (start at center)
            if not path:
                pos = nx.spring_layout(G, k=0.5, iterations=80)
            else:
                start = path[0]
                try:
                    lengths = nx.single_source_shortest_path_length(G.to_undirected(), start)
                except Exception:
                    lengths = {n: 0 for n in G.nodes()}
                layers = {}
                max_layer = 0
                for n, d in lengths.items():
                    layers.setdefault(d, []).append(n)
                    if d > max_layer:
                        max_layer = d
                pos[start] = (0.0, 0.0)
                for layer in range(1, max_layer + 1):
                    nodes_in_layer = layers.get(layer, [])
                    if not nodes_in_layer:
                        continue
                    radius = 1.5 * layer
                    count = len(nodes_in_layer)
                    for i, node in enumerate(nodes_in_layer):
                        angle = (i / count) * 2 * math.pi
                        x = radius * math.cos(angle)
                        y = radius * math.sin(angle)
                        pos[node] = (x, y)
                missing = [n for n in G.nodes if n not in pos]
                if missing:
                    subpos = nx.spring_layout(G.subgraph(missing), k=0.6, iterations=80)
                    offset = ( (max_layer + 2) * 1.5 )
                    for i, (n, pnt) in enumerate(subpos.items()):
                        pos[n] = (pnt[0] * 0.8 + offset, pnt[1] * 0.8)
        else:
            try:
                if len(path) >= 2:
                    pos = {}
                    path_len = len(path)
                    for i, node in enumerate(path):
                        pos[node] = (i * 1.5, 0.0)
                    others = [n for n in G.nodes if n not in pos]
                    radius = 1.5
                    for i, node in enumerate(others):
                        angle = (i / max(1, len(others))) * 2 * math.pi
                        layer = 1 + ((i // 12) * 0.8)
                        pos[node] = ((path_len * 0.75) * math.cos(angle) * layer, radius * math.sin(angle) * layer)
                else:
                    pos = nx.spring_layout(G, k=0.5, iterations=80)
            except Exception:
                pos = nx.spring_layout(G, k=0.5, iterations=80)

        # Styling & drawing
        path_set = set(path)
        node_sizes = []
        node_colors = []
        node_labels = {}
        for n in G.nodes:
            node_sizes.append(700 if n in path_set else 200)
            if path and n == path[0]:
                node_colors.append("#2ca02c")
            elif path and n == path[-1]:
                node_colors.append("#1f77b4")
            elif n in path_set:
                node_colors.append("#d62728")
            else:
                node_colors.append("#999999")

            if (not hide_nonpath_labels) or (n in path_set):
                node_labels[n] = _shorten_label(n, max_len=28)
            else:
                node_labels[n] = ""

        plt.figure(figsize=(12, 9))
        nx.draw_networkx_nodes(G, pos, node_size=node_sizes, node_color=node_colors, alpha=0.92)
        nx.draw_networkx_edges(G, pos, arrowsize=12, arrowstyle='->', width=1, alpha=0.7)

        if path and len(path) >= 2:
            path_edges = list(zip(path[:-1], path[1:]))
            existing_path_edges = [e for e in path_edges if G.has_edge(*e)]
            if existing_path_edges:
                nx.draw_networkx_edges(G, pos, edgelist=existing_path_edges, arrowsize=14, arrowstyle='->', width=3, alpha=0.95)

        labeled_nodes = {n: lbl for n, lbl in node_labels.items() if lbl}
        if labeled_nodes:
            nx.draw_networkx_labels(G, pos, labels=labeled_nodes, font_size=9)

        import matplotlib.patches as mpatches
        legend_items = []
        if path:
            legend_items.append(mpatches.Patch(color="#2ca02c", label="Start"))
            legend_items.append(mpatches.Patch(color="#1f77b4", label="Target"))
            legend_items.append(mpatches.Patch(color="#d62728", label="Path nodes"))
        legend_items.append(mpatches.Patch(color="#999999", label="Other nodes"))
        plt.legend(handles=legend_items, loc='upper right', fontsize=9)

        plt.title("Wikipedia crawl graph — mode: {}".format(mode))
        plt.axis('off')

        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        plt.tight_layout()
        plt.savefig(output_path, dpi=220)
        plt.close()
        self.log("Flowchart saved to:", output_path)

# ---------------------------
# Interactive collector (only core options)
# ---------------------------
def interactive_collect_core():
    """
    Interactive prompt that ONLY asks for the main game options.
    Utility flags (sleep, max-branch, user-agent, ...) must be provided via CLI.
    """
    print("=== WikiCrawler interactive setup (core options) ===")
    print("Leave blank to accept defaults shown in [brackets]. Type 'random' for random start.")

    start_or_random = ask("Start article (type 'random' to pick a random page)", default="random")
    random_start = False
    start_title = None
    if start_or_random.strip().lower() in ("random", "r"):
        random_start = True
    else:
        start_title = start_or_random

    def target_validator(s):
        if not s:
            raise ValueError("Target cannot be empty")
        return s
    target_title = ask("Target article (title or keywords)", default="", validator=target_validator)

    def strat_validator(s):
        s = s.lower()
        if s not in ("bfs","best","bidi"):
            raise ValueError("Choose one of: bfs, best, bidi")
        return s
    strategy = ask("Search strategy (bfs | best | bidi)", default="bidi", validator=strat_validator)

    # flowchart minimal choices
    want_flowchart = ask_yes_no("Save flowchart PNG after run?", default=False)
    flowchart = ""
    flowchart_mode = "pruned"
    hide_nonpath_labels = False
    if want_flowchart:
        flowchart = ask("Flowchart output filepath", default="./flowchart.png")
        def fc_mode_validator(s):
            s = s.lower()
            if s not in ("path-only","path-neighbors","pruned","mindmap","full"):
                raise ValueError("Choose one of: path-only, path-neighbors, pruned, mindmap, full")
            return s
        flowchart_mode = ask("Flowchart mode (path-only | path-neighbors | pruned | mindmap | full)", default="mindmap", validator=fc_mode_validator)
        hide_nonpath_labels = ask_yes_no("Hide labels for non-path nodes to reduce clutter?", default=True)

    explain = True  # explanation always shown by default
    explain_file = ""
    # We'll ask at the end whether user wants to save (interactive), unless they pre-specified a file via CLI.
    return {
        "start_title": start_title,
        "random_start": random_start,
        "target_title": target_title,
        "strategy": strategy,
        "flowchart": flowchart,
        "flowchart_mode": flowchart_mode,
        "hide_nonpath_labels": hide_nonpath_labels,
        "explain": explain,
        "explain_file": explain_file
    }

# ---------------------------
# Main
# ---------------------------
def main():
    parser = argparse.ArgumentParser(description="Find link path between two Wikipedia pages (bfs, best, bidi).")
    # Core options (still accepted via CLI; interactive prompts only when NO flags provided)
    parser.add_argument("--start", help="Start page title (quote if contains spaces).")
    parser.add_argument("--target", help="Target page title (quote if contains spaces).")
    parser.add_argument("--random-start", action="store_true", help="Pick a random start page instead of --start.")
    parser.add_argument("--strategy", choices=["bfs", "best", "bidi"], default="bidi", help="Search strategy: bfs|best|bidi.")
    parser.add_argument("--max-depth", type=int, default=6, help="Maximum clicks (depth) to attempt (default: 6).")
    parser.add_argument("--max-visited", type=int, default=50000, help="Safety cap on pages to visit.")
    parser.add_argument("--max-branch", type=int, default=50, help="For best-first: max neighbors to enqueue per expanded page.")
    parser.add_argument("--user-agent", help="Custom User-Agent header.")
    parser.add_argument("--sleep", type=float, default=0.1, help="Seconds to sleep between API requests.")
    parser.add_argument("--verbose", action="store_true", help="Show detailed crawl progress.")
    parser.add_argument("--flowchart", help="If set, save a PNG flowchart of the crawl to this filepath (e.g. ./graph.png).")
    parser.add_argument("--flowchart-mode", choices=["path-only","path-neighbors","pruned","mindmap","full"], default="pruned", help="Controls how much detail the flowchart shows.")
    parser.add_argument("--hide-nonpath-labels", action="store_true", help="Hide labels for non-path nodes in the flowchart to reduce clutter.")
    # Keep explain-file for CLI automated saving
    parser.add_argument("--explain-file", help="If set, save the textual explanation to this file path.")

    # Decide interactive vs CLI: interactive only when user invoked the program with no CLI args
    interactive_mode = (len(sys.argv) == 1)

    if interactive_mode:
        try:
            conf = interactive_collect_core()
        except SystemExit:
            return
        # map conf into variables; utility flags will retain parser defaults unless user passes them (they didn't)
        start_title = conf["start_title"]
        random_start = conf["random_start"]
        target_title = conf["target_title"]
        strategy = conf["strategy"]
        flowchart = conf["flowchart"]
        flowchart_mode = conf["flowchart_mode"]
        hide_nonpath_labels = conf["hide_nonpath_labels"]
        explain = conf["explain"]
        explain_file = conf["explain_file"]

        # Use parser defaults for utility flags unless user passes them via CLI (but in interactive_mode there were no flags)
        max_depth = parser.get_default("max_depth")
        max_visited = parser.get_default("max_visited")
        max_branch = parser.get_default("max_branch")
        user_agent = parser.get_default("user_agent")
        sleep = parser.get_default("sleep")
        verbose = parser.get_default("verbose")
    else:
        args = parser.parse_args()
        start_title = args.start
        random_start = args.random_start
        target_title = args.target
        strategy = args.strategy
        max_depth = args.max_depth
        max_visited = args.max_visited
        max_branch = args.max_branch
        user_agent = args.user_agent
        sleep = args.sleep
        verbose = args.verbose
        flowchart = args.flowchart
        flowchart_mode = args.flowchart_mode
        hide_nonpath_labels = args.hide_nonpath_labels
        explain_file = args.explain_file
        explain = True  # explanation always printed regardless; saving controlled by explain_file or interactive prompt

    crawler = WikiCrawler(
        user_agent=user_agent,
        sleep_between_requests=sleep,
        verbose=verbose
    )

    if random_start:
        start_title = crawler.random_page_title()
        print(f"Picked random start page: {start_title}")
    else:
        if not start_title and not interactive_mode:
            parser.error("Either --start or --random-start must be provided.")

    if not target_title:
        print("No target provided; exiting.")
        return

    try:
        resolved_target = crawler.resolve_title(target_title)
        if not resolved_target:
            print(f"Target '{target_title}' not found exactly; searching for best match...")
            resolved_target = crawler.search_title(target_title)
            if not resolved_target:
                raise SystemExit(f"Could not find a target page matching '{target_title}'.")
            print(f"Using target page: {resolved_target}")
        else:
            print(f"Target resolved to: {resolved_target}")

        resolved_start = crawler.resolve_title(start_title) if start_title else None
        if resolved_start is None and start_title:
            print(f"Start '{start_title}' not found exactly; searching for best match...")
            resolved_start = crawler.search_title(start_title)
            if not resolved_start:
                raise SystemExit(f"Could not find a start page matching '{start_title}'.")
            print(f"Using start page: {resolved_start}")
        elif resolved_start:
            print(f"Start resolved to: {resolved_start}")

        if not resolved_start:
            raise SystemExit("No start page specified.")

        if strategy == "bfs":
            path = crawler.find_path_bfs(resolved_start, resolved_target, max_depth=max_depth, max_visited=max_visited)
        elif strategy == "best":
            path = crawler.find_path_best_first(resolved_start, resolved_target, max_depth=max_depth, max_visited=max_visited, max_branch=max_branch)
        else:
            path = crawler.find_path_bidi(resolved_start, resolved_target, max_depth=max_depth, max_visited=max_visited)

        # Always produce explanation string (even if no path)
        explanation = crawler.explain_path(path)

        if path:
            print("\n=== PATH FOUND ===")
            for i, t in enumerate(path):
                print(f"{i:2d}. {t}")
            print(f"Total clicks: {len(path)-1}")
        else:
            print("\nNo path found within depth", max_depth)

        # Explanation is always printed by default
        print("\n" + explanation + "\n")

        # Saving behavior:
        # - If explain_file (CLI) present, save silently.
        # - Else, if interactive_mode: ask whether to save and ask filename.
        # - Else (non-interactive, no explain_file): do nothing (no prompt).
        if explain_file:
            try:
                os.makedirs(os.path.dirname(os.path.abspath(explain_file)), exist_ok=True)
            except Exception:
                # might be current directory; ignore
                pass
            with open(explain_file, "w", encoding="utf-8") as f:
                f.write(explanation)
            print(f"Explanation saved to: {explain_file}")
        elif interactive_mode:
            if ask_yes_no("Do you want to save the explanation to a file?", default=True):
                ef = ask("Explanation filepath", default="./explanation.txt")
                try:
                    os.makedirs(os.path.dirname(os.path.abspath(ef)), exist_ok=True)
                except Exception:
                    pass
                with open(ef, "w", encoding="utf-8") as f:
                    f.write(explanation)
                print(f"Explanation saved to: {ef}")

        # Flowchart save if requested
        if flowchart:
            try:
                crawler.draw_flowchart(flowchart, highlight_path=path, max_nodes=800, mode=flowchart_mode, hide_nonpath_labels=hide_nonpath_labels)
                print(f"Flowchart saved to: {flowchart}")
            except Exception as e:
                print("Failed to draw flowchart:", e)

    except ValueError as ve:
        print("Error:", ve)

if __name__ == "__main__":
    main()
