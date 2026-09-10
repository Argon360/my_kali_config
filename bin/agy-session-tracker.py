#!/usr/bin/env python3
"""
agy-session-tracker.py
Automatically discovers, names, tracks, and manages Antigravity (AGY) sessions
in ~/Documents/agy_sessions/.
"""

import os
import sys
import json
import re
import shutil
import subprocess
import argparse
from datetime import datetime

HOME = os.path.expanduser("~")
BRAIN_DIR = os.path.join(HOME, ".gemini", "antigravity-cli", "brain")
CONV_DIR = os.path.join(HOME, ".gemini", "antigravity-cli", "conversations")
DOCS_SESSIONS_DIR = os.path.join(HOME, "Documents", "agy_sessions")
LAUNCHERS_DIR = os.path.join(DOCS_SESSIONS_DIR, "launchers")
REGISTRY_FILE = os.path.join(DOCS_SESSIONS_DIR, "sessions.json")
MARKDOWN_FILE = os.path.join(DOCS_SESSIONS_DIR, "sessions.md")
CURRENT_FILE = os.path.join(DOCS_SESSIONS_DIR, "current_session.txt")

UUID_REGEX = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', re.IGNORECASE)

def ensure_dirs():
    os.makedirs(DOCS_SESSIONS_DIR, exist_ok=True)
    os.makedirs(LAUNCHERS_DIR, exist_ok=True)

def load_registry():
    ensure_dirs()
    if os.path.exists(REGISTRY_FILE):
        try:
            with open(REGISTRY_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_registry(registry):
    ensure_dirs()
    with open(REGISTRY_FILE, "w", encoding="utf-8") as f:
        json.dump(registry, f, indent=2, ensure_ascii=False)

def clean_slug(text, max_len=35):
    # Remove user passwords or tokens if detected
    text = re.sub(r'([a-zA-Z0-9]{6,}\s+(is my root password|password))', '', text, flags=re.IGNORECASE)
    # Remove special chars and convert spaces to hyphens
    slug = re.sub(r'[^a-zA-Z0-9\s_-]', '', text)
    slug = re.sub(r'[\s_]+', '-', slug).strip('-').lower()
    if not slug:
        return ""
    return slug[:max_len].rstrip('-')

def extract_session_info(session_id):
    session_dir = os.path.join(BRAIN_DIR, session_id)
    transcript_file = os.path.join(session_dir, ".system_generated", "logs", "transcript.jsonl")
    
    first_prompt = ""
    created_at = ""
    workspace = ""
    step_count = 0
    mtime = 0

    if os.path.exists(session_dir):
        mtime = os.path.getmtime(session_dir)

    if os.path.exists(transcript_file):
        mtime = max(mtime, os.path.getmtime(transcript_file))
        try:
            with open(transcript_file, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    step_count += 1
                    if not first_prompt and step_count <= 5:
                        try:
                            obj = json.loads(line)
                            if not created_at and obj.get("created_at"):
                                created_at = obj.get("created_at")
                            if obj.get("type") == "USER_INPUT" and obj.get("content"):
                                content = obj.get("content")
                                m = re.search(r"<USER_REQUEST>\s*(.*?)\s*</USER_REQUEST>", content, re.DOTALL)
                                if m:
                                    first_prompt = m.group(1).strip()
                                else:
                                    # Strip XML tags
                                    clean = re.sub(r'<[^>]+>', '', content).strip()
                                    if clean:
                                        first_prompt = clean.splitlines()[0]
                        except Exception:
                            pass
                    
                    if not workspace and step_count <= 25:
                        # Check for workspace hints
                        m_ws = re.search(r'"(?:DirectoryPath|SearchDirectory|TargetFile|Cwd)":\s*"([^"]+)"', line)
                        if m_ws:
                            path = m_ws.group(1).strip()
                            if path.startswith("/home/"):
                                parts = path.split("/")
                                if len(parts) >= 4:
                                    workspace = "/".join(parts[:4])
                                else:
                                    workspace = path
        except Exception:
            pass

    if not created_at and mtime > 0:
        created_at = datetime.fromtimestamp(mtime).strftime("%Y-%m-%dT%H:%M:%SZ")

    return {
        "id": session_id,
        "first_prompt": first_prompt or "Interactive Session",
        "created_at": created_at,
        "workspace": workspace,
        "step_count": step_count,
        "last_mtime": mtime
    }

def sync_sessions():
    ensure_dirs()
    registry = load_registry()
    found_ids = set()

    # Scan brain dir
    if os.path.isdir(BRAIN_DIR):
        for entry in os.listdir(BRAIN_DIR):
            if UUID_REGEX.match(entry) and os.path.isdir(os.path.join(BRAIN_DIR, entry)):
                found_ids.add(entry)

    # Scan conversations dir
    if os.path.isdir(CONV_DIR):
        for entry in os.listdir(CONV_DIR):
            if entry.endswith(".db"):
                base_id = entry[:-3]
                if UUID_REGEX.match(base_id):
                    found_ids.add(base_id)

    used_names = set()
    for sid, data in registry.items():
        if sid in found_ids and data.get("name"):
            used_names.add(data["name"])

    # Update or add sessions
    for sid in found_ids:
        info = extract_session_info(sid)
        if sid in registry:
            # Preserve existing user-defined name
            existing = registry[sid]
            name = existing.get("name")
            if not name:
                slug = clean_slug(info["first_prompt"]) or f"session-{sid[:8]}"
                name = slug
                i = 2
                while name in used_names:
                    name = f"{slug}-{i}"
                    i += 1
                used_names.add(name)
            
            existing["name"] = name
            existing["step_count"] = max(existing.get("step_count", 0), info["step_count"])
            existing["last_mtime"] = max(existing.get("last_mtime", 0), info["last_mtime"])
            if info["first_prompt"] and existing.get("first_prompt") in ("", "Interactive Session"):
                existing["first_prompt"] = info["first_prompt"]
            if info["workspace"] and not existing.get("workspace"):
                existing["workspace"] = info["workspace"]
            registry[sid] = existing
        else:
            slug = clean_slug(info["first_prompt"]) or f"session-{sid[:8]}"
            name = slug
            i = 2
            while name in used_names:
                name = f"{slug}-{i}"
                i += 1
            used_names.add(name)

            registry[sid] = {
                "id": sid,
                "name": name,
                "created_at": info["created_at"],
                "last_mtime": info["last_mtime"],
                "workspace": info["workspace"],
                "first_prompt": info["first_prompt"],
                "step_count": info["step_count"],
                "resume_cmd": f"agy --conversation {sid}"
            }

    save_registry(registry)
    generate_markdown(registry)
    generate_launchers(registry)
    update_current_session(registry)
    return registry

def generate_markdown(registry):
    sorted_sessions = sorted(
        registry.values(),
        key=lambda x: x.get("last_mtime", 0),
        reverse=True
    )

    lines = [
        "# Antigravity (AGY) Sessions Registry",
        "",
        "> Automatically synchronized from `~/.gemini/antigravity-cli/`",
        f"> Last Updated: `{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}`",
        "",
        "## Quick Resume by Name",
        "```bash",
        "# Using session name directly:",
        "agys <name>",
        "",
        "# Or using the launcher script:",
        "~/Documents/agy_sessions/launchers/<name>.sh",
        "```",
        "",
        "## Active Sessions",
        "",
        "| Name | Session ID | Created | Workspace | Initial Prompt | Resume Command |",
        "| :--- | :--- | :--- | :--- | :--- | :--- |",
    ]

    for s in sorted_sessions:
        name = s.get("name", "unnamed")
        sid = s.get("id", "")
        created = s.get("created_at", "")[:16].replace("T", " ")
        ws = s.get("workspace", "")
        ws_display = os.path.basename(ws) if ws else "-"
        prompt = s.get("first_prompt", "-").replace("|", "\\|").replace("\n", " ")
        if len(prompt) > 45:
            prompt = prompt[:42] + "..."
        cmd = f"`agy --conversation {sid}`"
        lines.append(f"| **`{name}`** | `{sid[:8]}...` | {created} | `{ws_display}` | {prompt} | {cmd} |")

    lines.append("")
    with open(MARKDOWN_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

def generate_launchers(registry):
    # Create or update launcher scripts in launchers/
    for sid, s in registry.items():
        name = s.get("name")
        if not name:
            continue
        launcher_path = os.path.join(LAUNCHERS_DIR, f"{name}.sh")
        script_content = f"""#!/usr/bin/env bash
# ==============================================================================
# AGY Session Launcher: {name}
# Session ID: {sid}
# Created: {s.get('created_at', '')}
# Prompt: {s.get('first_prompt', '')}
# ==============================================================================

exec agy --conversation "{sid}" "$@"
"""
        with open(launcher_path, "w", encoding="utf-8") as f:
            f.write(script_content)
        os.chmod(launcher_path, 0o755)

def update_current_session(registry):
    if not registry:
        return
    sorted_sessions = sorted(
        registry.values(),
        key=lambda x: x.get("last_mtime", 0),
        reverse=True
    )
    latest = sorted_sessions[0]
    with open(CURRENT_FILE, "w", encoding="utf-8") as f:
        f.write(f"ID: {latest.get('id')}\n")
        f.write(f"NAME: {latest.get('name')}\n")
        f.write(f"RESUME: agy --conversation {latest.get('id')}\n")

def list_sessions(registry):
    sorted_sessions = sorted(
        registry.values(),
        key=lambda x: x.get("last_mtime", 0),
        reverse=True
    )
    if not sorted_sessions:
        print("\033[1;33m[!] No AGY sessions recorded yet.\033[0m")
        return

    print("\033[1;34m╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════╗\033[0m")
    print("\033[1;34m║                                          ANTIGRAVITY (AGY) SESSIONS                                           ║\033[0m")
    print("\033[1;34m╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════╝\033[0m")
    print(f"\033[1;30mStored in: {DOCS_SESSIONS_DIR}\033[0m\n")
    
    header = f"{'NAME':<24} {'SESSION ID':<38} {'DATE':<17} {'PROMPT'}"
    print(f"\033[1;36m{header}\033[0m")
    print("\033[1;30m" + "-" * 105 + "\033[0m")

    for s in sorted_sessions:
        name = s.get("name", "unnamed")[:22]
        sid = s.get("id", "")
        created = s.get("created_at", "")[:16].replace("T", " ")
        prompt = s.get("first_prompt", "")[:35].replace("\n", " ")
        print(f"\033[1;32m{name:<24}\033[0m \033[0;37m{sid:<38}\033[0m \033[0;34m{created:<17}\033[0m \033[0;33m{prompt}\033[0m")

def interactive_picker(registry):
    sorted_sessions = sorted(
        registry.values(),
        key=lambda x: x.get("last_mtime", 0),
        reverse=True
    )
    if not sorted_sessions:
        print("\033[1;33m[!] No AGY sessions found.\033[0m")
        return

    # Check for fzf
    if shutil.which("fzf"):
        lines = []
        for s in sorted_sessions:
            name = s.get("name", "unnamed")
            sid = s.get("id", "")
            created = s.get("created_at", "")[:16].replace("T", " ")
            prompt = s.get("first_prompt", "").replace("\n", " ")
            lines.append(f"{name}\t{sid}\t{created}\t{prompt}")

        fzf_input = "\n".join(lines)
        fzf_cmd = [
            "fzf",
            "--height=50%",
            "--layout=reverse",
            "--border",
            "--inline-info",
            "--delimiter=\t",
            "--with-nth=1,3,4",
            "--prompt=󰍉 AGY Session > ",
            "--header=Select session to resume (Enter to launch, ESC to cancel):",
            "--preview=echo -e '\033[1;34mSession Details:\033[0m\nName: {1}\nID: {2}\nDate: {3}\nPrompt:\n{4}\n\nResume Command:\nagy --conversation {2}'",
            "--preview-window=right:45%:wrap"
        ]
        p = subprocess.Popen(fzf_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        out, _ = p.communicate(input=fzf_input)
        if p.returncode == 0 and out.strip():
            selected_sid = out.strip().split("\t")[1]
            print(f"\033[1;32m[+] Resuming AGY Session:\033[0m {selected_sid}")
            os.execvp("agy", ["agy", "--conversation", selected_sid])
    else:
        # Fallback simple terminal selector
        list_sessions(registry)
        choice = input("\nEnter Session Name or ID to resume: ").strip()
        if choice:
            resume_session(registry, choice)

def resume_session(registry, identifier):
    target_id = None
    identifier_lower = identifier.lower()

    # Search by exact name
    for sid, s in registry.items():
        if s.get("name", "").lower() == identifier_lower:
            target_id = sid
            break

    # Search by ID prefix or exact ID
    if not target_id:
        for sid in registry.keys():
            if sid.lower().startswith(identifier_lower):
                target_id = sid
                break

    # Search by partial name
    if not target_id:
        for sid, s in registry.items():
            if identifier_lower in s.get("name", "").lower():
                target_id = sid
                break

    if target_id:
        print(f"\033[1;32m[+] Resuming AGY Session:\033[0m {target_id}")
        os.execvp("agy", ["agy", "--conversation", target_id])
    else:
        print(f"\033[1;31m[-] Error:\033[0m No session found matching '{identifier}'")
        sys.exit(1)

def rename_session(registry, identifier, new_name):
    target_id = None
    identifier_lower = identifier.lower()

    for sid, s in registry.items():
        if s.get("name", "").lower() == identifier_lower or sid.lower().startswith(identifier_lower):
            target_id = sid
            break

    if not target_id:
        print(f"\033[1;31m[-] Error:\033[0m No session found matching '{identifier}'")
        sys.exit(1)

    clean_name = clean_slug(new_name) or new_name.strip()
    old_name = registry[target_id].get("name", "")
    registry[target_id]["name"] = clean_name
    save_registry(registry)
    
    # Remove old launcher if name changed
    if old_name and old_name != clean_name:
        old_launcher = os.path.join(LAUNCHERS_DIR, f"{old_name}.sh")
        if os.path.exists(old_launcher):
            os.remove(old_launcher)

    generate_markdown(registry)
    generate_launchers(registry)
    print(f"\033[1;32m[+] Successfully renamed session:\033[0m {target_id}")
    print(f"    \033[1;30mOld Name:\033[0m {old_name} -> \033[1;32mNew Name:\033[0m {clean_name}")
    print(f"    \033[1;30mLauncher:\033[0m {os.path.join(LAUNCHERS_DIR, f'{clean_name}.sh')}")

def main():
    parser = argparse.ArgumentParser(description="Antigravity (AGY) Session Tracker & Launcher")
    parser.add_argument("-i", "--interactive", action="store_true", help="Launch interactive FZF session picker")
    parser.add_argument("-s", "--sync", action="store_true", help="Synchronize sessions to Documents folder")
    parser.add_argument("-l", "--list", action="store_true", help="List all sessions")
    parser.add_argument("command", nargs="?", help="Action: [resume|name|sync] or session name/ID to resume directly")
    parser.add_argument("args", nargs="*", help="Arguments for command")

    args = parser.parse_args()

    # Always sync first
    registry = sync_sessions()

    if args.interactive:
        interactive_picker(registry)
        return

    if args.sync and not args.command:
        print(f"\033[1;32m[+] Synchronized {len(registry)} AGY sessions to:\033[0m {DOCS_SESSIONS_DIR}")
        return

    if args.command == "name" or args.command == "rename":
        if len(args.args) < 2:
            print("Usage: agys rename <id_or_current_name> <new_name>")
            sys.exit(1)
        rename_session(registry, args.args[0], args.args[1])
        return

    if args.command == "resume":
        if not args.args:
            print("Usage: agys resume <name_or_id>")
            sys.exit(1)
        resume_session(registry, args.args[0])
        return

    if args.command and not args.command.startswith("-"):
        # Direct session resume by name or ID
        resume_session(registry, args.command)
        return

    # Default to listing
    list_sessions(registry)

if __name__ == "__main__":
    main()
