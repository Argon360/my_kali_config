#!/usr/bin/env python3
"""
wiki_crawler.py

Wikipedia link-path finder with LLM-powered detailed explanations.

New features in this file:
 - extract anchor text + one-sentence snippet for each hop (using MediaWiki parse+HTML)
 - build structured payload from crawl trace
 - call a generic LLM endpoint (Gemini/OpenAI/other) to produce a rich explanation
 - fallback to the built-in lightweight explanation if no LLM configured
 - interactive behavior preserved; explanation always printed; interactive prompt asks about saving

Dependencies:
  pip3 install requests networkx matplotlib beautifulsoup4
"""

import argparse
import os
import requests
import time
from collections import deque
from heapq import heappush, heappop
import difflib
import networkx as nx
import matplotlib.pyplot as plt
import math
import sys
from bs4 import BeautifulSoup
from typing import Optional, Dict, List

API_ENDPOINT = "https://en.wikipedia.org/w/api.php"
DEFAULT_USER_AGENT = "WikiCrawlerBot/1.0 (example@example.com) Python/requests"

# --- LLM integration configuration (set these environment variables) ---
# Example:
#   export LLM_API_URL="https://api.your-llm-provider.example/v1/generate"
#   export LLM_API_KEY="sk-xxxxxxxx"
LLM_API_URL = os.getenv("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent")      # REQUIRED for LLM calls
LLM_API_KEY = os.getenv("AIzaSyDXaq56qXm7bZw704xMeg2pa4KKmQ-nnKM")      # REQUIRED for LLM calls
LLM_MAX_TOKENS = int(os.getenv("LLM_MAX_TOKENS") or "900")
LLM_TEMPERATURE = float(os.getenv("LLM_TEMPERATURE") or "0.15")

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
# Crawler class
# ---------------------------
class WikipediaAPIError(Exception):
    pass

class WikiCrawler:
    def __init__(self, session=None, user_agent=None, sleep_between_requests=0.12, verbose=False):
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

    # --- title resolution, random page, links, linkshere (unchanged) ---
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
    # Search algorithms (unchanged)
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
    # Built-in lightweight explanation (keeps existing behavior)
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
    # Extract anchor text + source snippet using parse & BeautifulSoup
    # ------------------------------
    def extract_anchor_snippet(self, source_title: str, target_title: str, max_chars: int = 250) -> Dict[str, Optional[str]]:
        """
        Return:
          { "anchor_text": str or None,
            "source_snippet": one-sentence snippet containing the anchor (or short paragraph) or None }
        """
        # Resolve canonical titles
        src = self.resolve_title(source_title)
        tgt = self.resolve_title(target_title)
        if not src or not tgt:
            return {"anchor_text": None, "source_snippet": None}

        # fetch HTML for the source article (action=parse & prop=text)
        params = {
            "action": "parse",
            "page": src,
            "prop": "text",
            "formatversion": 2
        }
        try:
            j = self._api_get(params)
            time.sleep(self.sleep)
        except Exception as e:
            self.log("Failed to fetch parse text for", src, e)
            return {"anchor_text": None, "source_snippet": None}

        html = j.get("parse", {}).get("text", "")
        if not html:
            return {"anchor_text": None, "source_snippet": None}

        soup = BeautifulSoup(html, "html.parser")
        # target URL fragment to find in href: /wiki/Target_Title (replace spaces)
        tgt_fragment = "/wiki/" + tgt.replace(" ", "_")
        # attempt to find the <a> tag whose href starts with tgt_fragment (exact match preferred)
        a_tag = None
        # first try exact href match (without fragment or query)
        for a in soup.find_all("a", href=True):
            href = a["href"]
            if href.split("#")[0] == tgt_fragment or href.split("?")[0] == tgt_fragment:
                a_tag = a
                break
        # fallback: contains '/wiki/Target_' substring
        if not a_tag:
            for a in soup.find_all("a", href=True):
                if tgt_fragment in a["href"]:
                    a_tag = a
                    break
        # fallback: match by title attribute
        if not a_tag:
            for a in soup.find_all("a", title=True):
                if a.get("title") == tgt:
                    a_tag = a
                    break

        if not a_tag:
            # no anchor found
            return {"anchor_text": None, "source_snippet": None}

        anchor_text = a_tag.get_text(strip=True) or None

        # get parent paragraph or parent section
        parent = a_tag
        for _ in range(4):
            if parent is None:
                break
            if parent.name in ("p", "li", "div", "td", "section"):
                break
            parent = parent.parent

        snippet = None
        if parent:
            text = parent.get_text(" ", strip=True)
            # try to split into sentences and pick the sentence containing the anchor_text (or target)
            if anchor_text and anchor_text in text:
                # simple sentence split by ., ?, !
                sentences = [s.strip() for s in text.replace("\n"," ").split('.') if s.strip()]
                found = None
                for sent in sentences:
                    if anchor_text and anchor_text in sent:
                        found = sent
                        break
                    if tgt in sent:
                        found = sent
                        break
                if found:
                    snippet = found.strip()
                else:
                    snippet = (text.strip()[:max_chars] + "...") if len(text) > max_chars else text.strip()
            else:
                # fallback to the whole parent text trimmed
                snippet = (text.strip()[:max_chars] + "...") if len(text) > max_chars else text.strip()
        else:
            snippet = None

        return {"anchor_text": anchor_text, "source_snippet": snippet}

    # ------------------------------
    # LLM payload builder and caller
    # ------------------------------
    def build_llm_payload(self, crawl_summary: Dict, steps: List[Dict], max_tokens: int = LLM_MAX_TOKENS, temperature: float = LLM_TEMPERATURE) -> Dict:
        """
        Build a compact payload (system + user) that an LLM can digest.
        The exact payload format depends on the provider; here we return a generic dict:
          { system_prompt, user_prompt, max_tokens, temperature }
        You may need to adapt call_llm_generate() to the provider's API.
        """
        system = ("You are a technical explainer. Given a short crawl summary and for each hop a tiny "
                  "anchor snippet and metadata, produce a clear step-by-step explanation describing why "
                  "each hop was chosen (referencing the anchor/snippet), note the role of any heuristic, "
                  "and provide a final assessment with confidence and suggestions.")
        lines = []
        lines.append("CRAWL SUMMARY")
        lines.append(f"- Strategy: {crawl_summary.get('strategy')}")
        lines.append(f"- Start: {crawl_summary.get('start')}")
        lines.append(f"- Target: {crawl_summary.get('target')}")
        lines.append(f"- Total hops: {crawl_summary.get('hops')}")
        lines.append(f"- Pages visited: {crawl_summary.get('visited_count')}")
        lines.append(f"- Time taken (s): {crawl_summary.get('elapsed_seconds'):.2f}")
        lines.append("")
        lines.append("PATH & DECISIONS (compact)")
        for s in steps:
            lines.append(f"STEP {s['i']}: {s['A']} -> {s['B']}")
            lines.append(f" - anchor_text: \"{(s.get('anchor_text') or '')[:120]}\"")
            lines.append(f" - source_snippet: \"{(s.get('source_snippet') or '')[:220]}\"")
            lines.append(f" - method: {s.get('method')}")
            lines.append(f" - depth_at_enqueue: {s.get('depth')}")
            lines.append(f" - heuristic_score: {s.get('score')}")
            # include small list of top neighbors if present
            if s.get('other_top_neighbors'):
                tops = ", ".join(s.get('other_top_neighbors')[:6])
                lines.append(f" - other_top_neighbors: {tops}")
            lines.append("")
        lines.append("INSTRUCTIONS:")
        lines.append("1) For each step, explain concisely (2-6 sentences) why this hop was reasonable, referencing anchor_text/snippet.")
        lines.append("2) If heuristic used, explain its role and whether it seems appropriate.")
        lines.append("3) Finish with a short assessment: overall confidence (low/medium/high), whether a shorter path likely exists, and 2 brief suggestions to improve search.")
        user_prompt = "\n".join(lines)

        return {
            "system_prompt": system,
            "user_prompt": user_prompt,
            "max_tokens": max_tokens,
            "temperature": temperature
        }

    def call_llm_generate(self, payload: Dict) -> Optional[str]:
        """
        Generic LLM call. Requires LLM_API_URL and LLM_API_KEY set in env.
        You may adapt this to the provider of your choice (Gemini, OpenAI, etc).
        For Gemini / Google Generative API you'll likely need a different JSON shape and auth.
        Here we implement a simple POST expecting a JSON response containing 'output' or 'choices'.
        """
        if not LLM_API_URL or not LLM_API_KEY:
            self.log("LLM not configured (LLM_API_URL/LLM_API_KEY). Skipping LLM explanation.")
            return None

        headers = {
            "Authorization": f"Bearer {LLM_API_KEY}",
            "Content-Type": "application/json"
        }
        body = {
            "system": payload.get("system_prompt"),
            "prompt": payload.get("user_prompt"),
            "max_tokens": payload.get("max_tokens"),
            "temperature": payload.get("temperature")
        }
        # NOTE: adapt below to your provider's request format.
        try:
            resp = requests.post(LLM_API_URL, headers=headers, json=body, timeout=120)
            resp.raise_for_status()
            j = resp.json()
            # try common shapes:
            if isinstance(j, dict):
                if "output" in j and isinstance(j["output"], str):
                    return j["output"]
                if "choices" in j and isinstance(j["choices"], list) and len(j["choices"]) > 0:
                    # OpenAI-like
                    text = j["choices"][0].get("text") or j["choices"][0].get("message", {}).get("content")
                    if text:
                        return text
                if "result" in j and isinstance(j["result"], dict):
                    # some providers use result->content
                    r = j["result"]
                    if isinstance(r.get("output_text"), str):
                        return r["output_text"]
                    if isinstance(r.get("content"), str):
                        return r["content"]
            # fallback: raw text
            return resp.text
        except Exception as e:
            self.log("LLM call failed:", e)
            return None

    # ------------------------------
    # High-level helper to produce LLM-powered explanation
    # ------------------------------
    def produce_rich_explanation(self, path: List[str], strategy: str, visited_count: int, elapsed_seconds: float, max_neighbors_sample: int = 6) -> str:
        """
        For each hop A->B extract anchor snippet, sample top neighbors (if available), build payload, call LLM.
        Returns the LLM text if available, otherwise returns the built-in lightweight explanation.
        """
        # build crawl_summary & steps
        crawl_summary = {
            "strategy": strategy,
            "start": path[0] if path else None,
            "target": path[-1] if path else None,
            "hops": len(path) - 1 if path else 0,
            "visited_count": visited_count,
            "elapsed_seconds": elapsed_seconds
        }
        steps = []
        for i in range(len(path)-1):
            A = path[i]
            B = path[i+1]
            meta = self.decision_info.get((A, B)) or self.decision_info.get((B, A)) or {}
            # sample other top neighbors from cached get_links (if available)
            neighbors = list(self.link_cache.get(A, []))
            # compute heuristic scores if present/possible
            other_top = []
            if neighbors:
                # compute title scores quickly relative to B
                scored = []
                for n in neighbors:
                    if n == B:
                        continue
                    sc = self._title_score(n, B)
                    scored.append((sc, n))
                scored.sort(reverse=True, key=lambda x: x[0])
                other_top = [n for _, n in scored[:max_neighbors_sample]]
            snippet_info = self.extract_anchor_snippet(A, B)
            steps.append({
                "i": i+1,
                "A": A,
                "B": B,
                "anchor_text": snippet_info.get("anchor_text"),
                "source_snippet": snippet_info.get("source_snippet"),
                "method": meta.get("method"),
                "depth": meta.get("depth"),
                "score": meta.get("score"),
                "other_top_neighbors": other_top
            })

        payload = self.build_llm_payload(crawl_summary, steps)
        llm_text = self.call_llm_generate(payload)
        if llm_text:
            return llm_text
        else:
            # fallback: return built-in explanation plus step snippets
            built = self.explain_path(path)
            extra_lines = ["\n--- Anchor snippets (best-effort) ---"]
            for s in steps:
                extra_lines.append(f"{s['i']}. {s['A']} -> {s['B']}")
                extra_lines.append(f"   anchor_text: {s.get('anchor_text')}")
                extra_lines.append(f"   snippet: {s.get('source_snippet')}\n")
            return built + "\n" + "\n".join(extra_lines)

    # ------------------------------
    # Flowchart drawing: keep existing mindmap + pruned modes
    # (omitted here for brevity in this snippet — you can reuse your previous draw_flowchart)
    # For brevity we include a simple wrapper that calls your prior draw_flowchart implementation
    # ------------------------------
    def draw_flowchart(self, *args, **kwargs):
        # For clarity, assume earlier draw_flowchart implementation is present in your file.
        # If not, re-add the draw_flowchart implementation from previous script version.
        return NotImplementedError("draw_flowchart should be implemented or re-used from your existing file.")

# ---------------------------
# Interactive collector (core options only)
# ---------------------------
def interactive_collect_core():
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

    want_flowchart = ask_yes_no("Save flowchart PNG after run?", default=False)
    flowchart = ""
    flowchart_mode = "mindmap"
    hide_nonpath_labels = True
    if want_flowchart:
        flowchart = ask("Flowchart output filepath", default="./flowchart.png")
        def fc_mode_validator(s):
            s = s.lower()
            if s not in ("path-only","path-neighbors","pruned","mindmap","full"):
                raise ValueError("Choose one of: path-only, path-neighbors, pruned, mindmap, full")
            return s
        flowchart_mode = ask("Flowchart mode (path-only | path-neighbors | pruned | mindmap | full)", default="mindmap", validator=fc_mode_validator)
        hide_nonpath_labels = ask_yes_no("Hide labels for non-path nodes to reduce clutter?", default=True)

    explain = True  # always print explanation
    explain_file = ""
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
# CLI and run logic (simplified)
# ---------------------------
def main():
    parser = argparse.ArgumentParser(description="Find link path between two Wikipedia pages (bfs, best, bidi).")
    parser.add_argument("--start", help="Start page title (quote if contains spaces).")
    parser.add_argument("--target", help="Target page title (quote if contains spaces).")
    parser.add_argument("--random-start", action="store_true", help="Pick a random start page instead of --start.")
    parser.add_argument("--strategy", choices=["bfs", "best", "bidi"], default="bidi", help="Search strategy: bfs|best|bidi.")
    parser.add_argument("--max-depth", type=int, default=6, help="Maximum clicks (depth) to attempt (default: 6).")
    parser.add_argument("--max-visited", type=int, default=50000, help="Safety cap on pages to visit.")
    parser.add_argument("--max-branch", type=int, default=50, help="For best-first: max neighbors to enqueue per expanded page.")
    parser.add_argument("--user-agent", help="Custom User-Agent header.")
    parser.add_argument("--sleep", type=float, default=0.12, help="Seconds to sleep between API requests.")
    parser.add_argument("--verbose", action="store_true", help="Show detailed crawl progress.")
    parser.add_argument("--flowchart", help="If set, save a PNG flowchart of the crawl to this filepath (e.g. ./graph.png).")
    parser.add_argument("--flowchart-mode", choices=["path-only","path-neighbors","pruned","mindmap","full"], default="mindmap", help="Controls how much detail the flowchart shows.")
    parser.add_argument("--hide-nonpath-labels", action="store_true", help="Hide labels for non-path nodes in the flowchart to reduce clutter.")
    parser.add_argument("--explain-file", help="If set, save the textual explanation to this file path.")
    interactive_mode = (len(sys.argv) == 1)

    if interactive_mode:
        try:
            conf = interactive_collect_core()
        except SystemExit:
            return
        start_title = conf["start_title"]
        random_start = conf["random_start"]
        target_title = conf["target_title"]
        strategy = conf["strategy"]
        flowchart = conf["flowchart"]
        flowchart_mode = conf["flowchart_mode"]
        hide_nonpath_labels = conf["hide_nonpath_labels"]
        explain = conf["explain"]
        explain_file = conf["explain_file"]

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
        explain = True

    crawler = WikiCrawler(user_agent=user_agent, sleep_between_requests=sleep, verbose=verbose)

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

        t0 = time.time()
        if strategy == "bfs":
            path = crawler.find_path_bfs(resolved_start, resolved_target, max_depth=max_depth, max_visited=max_visited)
        elif strategy == "best":
            path = crawler.find_path_best_first(resolved_start, resolved_target, max_depth=max_depth, max_visited=max_visited, max_branch=max_branch)
        else:
            path = crawler.find_path_bidi(resolved_start, resolved_target, max_depth=max_depth, max_visited=max_visited)
        elapsed = time.time() - t0

        visited_count = sum(1 for _ in crawler.crawl_graph.nodes)  # rough
        if path:
            print("\n=== PATH FOUND ===")
            for i, t in enumerate(path):
                print(f"{i:2d}. {t}")
            print(f"Total clicks: {len(path)-1}")
        else:
            print("\nNo path found within depth", max_depth)

        # Produce LLM-powered rich explanation if LLM configured; else fallback to builtin + snippets
        rich = crawler.produce_rich_explanation(path or [], strategy, visited_count, elapsed)
        print("\n--- Explanation (rich) ---\n")
        print(rich)

        # saving behavior same as before (CLI explain-file or interactive prompt)
        if explain_file:
            try:
                os.makedirs(os.path.dirname(os.path.abspath(explain_file)), exist_ok=True)
            except Exception:
                pass
            with open(explain_file, "w", encoding="utf-8") as f:
                f.write(rich)
            print(f"\nExplanation saved to: {explain_file}")
        elif interactive_mode:
            if ask_yes_no("Do you want to save the explanation to a file?", default=True):
                ef = ask("Explanation filepath", default="./explanation.txt")
                try:
                    os.makedirs(os.path.dirname(os.path.abspath(ef)), exist_ok=True)
                except Exception:
                    pass
                with open(ef, "w", encoding="utf-8") as f:
                    f.write(rich)
                print(f"Explanation saved to: {ef}")

        # Flowchart: call existing draw_flowchart if implemented in your file
        if flowchart:
            try:
                # If you have a draw_flowchart implementation, call it with the path.
                # e.g., crawler.draw_flowchart(flowchart, highlight_path=path, max_nodes=800, mode=flowchart_mode, hide_nonpath_labels=hide_nonpath_labels)
                print("Flowchart save requested, but draw_flowchart is a placeholder in this file.")
            except Exception as e:
                print("Failed to draw flowchart:", e)

    except ValueError as ve:
        print("Error:", ve)

if __name__ == "__main__":
    main()
