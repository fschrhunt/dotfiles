#!/usr/bin/env python3
"""Apply the shared native-agent policy without replacing local settings.

Built-in web search and fetch are off in both agents: `search`, reached through tap, replaces
them. Also wires the worktree Bash hook (~/.agents/hooks/worktree) into Claude Code and Codex, drops
retired hooks, such as ask's title hook: current ask has no `title` command and exits 2, which would
block every Bash call, and shares OpenCode's model favorites. Other hooks and settings are left alone,
so running this again changes nothing. `update` runs it daily after pulling the dotfiles.
"""

import json
import os
from pathlib import Path
import re

home = Path(os.environ.get("HOME", str(Path.home())))


def wire_bash_hooks(hooks, commands, retired=()):
    """Ensure the PreToolUse Bash group in a hooks table runs each command, dropping retired ones."""
    groups = hooks.setdefault("PreToolUse", [])
    bash = next((g for g in groups if g.get("matcher") == "Bash"), None)
    if bash is None:
        bash = {"matcher": "Bash", "hooks": []}
        groups.append(bash)
    entries = [h for h in bash.setdefault("hooks", []) if not h.get("command", "").endswith(retired)]
    for command in commands:
        if not any(h.get("command") == command for h in entries):
            entries.append({"type": "command", "command": command})
    bash["hooks"] = entries


claude = home / ".claude/settings.json"
claude.parent.mkdir(parents=True, exist_ok=True)
settings = json.loads(claude.read_text()) if claude.exists() else {}
permissions = settings.setdefault("permissions", {})
if not isinstance(permissions, dict):
    raise SystemExit(f"Expected {claude} permissions to be an object")
denied = permissions.setdefault("deny", [])
if not isinstance(denied, list):
    raise SystemExit(f"Expected {claude} permissions.deny to be an array")
for tool in ("Agent", "WebSearch", "WebFetch"):
    if tool not in denied:
        denied.append(tool)
settings["outputStyle"] = "agent"
# Fullscreen rendering: click to place the cursor in the prompt, mouse selection and scrolling.
settings["tui"] = "fullscreen"
wire_bash_hooks(
    settings.setdefault("hooks", {}),
    [str(home / ".claude/hooks/worktree")],
    retired=(
        "/.claude/hooks/ask-title",
        "/.claude/hooks/branch-name-check",
        "ask title --hook",
        "ask.v1 title --hook",
    ),
)
claude.write_text(json.dumps(settings, indent=2, ensure_ascii=False) + "\n")

codex_hooks = home / ".codex/hooks.json"
codex_hooks.parent.mkdir(parents=True, exist_ok=True)
config =json.loads(codex_hooks.read_text()) if codex_hooks.exists() else {}
wire_bash_hooks(config.setdefault("hooks", {}), [str(home / ".codex/hooks/worktree")])
codex_hooks.write_text(json.dumps(config, indent=2, ensure_ascii=False) + "\n")

codex = home / ".codex/config.toml"
codex.parent.mkdir(parents=True, exist_ok=True)
text = codex.read_text() if codex.exists() else ""
headers = list(re.finditer(r"(?m)^\[([^]]+)\]\s*$", text))
agents = next((header for header in headers if header.group(1) == "agents"), None)
if agents:
    next_header = next((header for header in headers if header.start() > agents.start()), None)
    end = next_header.start() if next_header else len(text)
    section = text[agents.end():end]
    enabled = re.search(r"(?m)^enabled[ \t]*=[ \t]*(?:true|false)[ \t]*$", section)
    if enabled:
        section = section[:enabled.start()] + "enabled = false" + section[enabled.end():]
    else:
        section = "\nenabled = false" + section
    text = text[:agents.end()] + section + text[end:]
else:
    child = next((header for header in headers if header.group(1).startswith("agents.")), None)
    insertion = child.start() if child else len(text)
    prefix = text[:insertion].rstrip()
    suffix = text[insertion:]
    block = "[agents]\nenabled = false\n\n"
    text = (prefix + "\n\n" if prefix else "") + block + suffix
# web_search is a top-level key, so it must come before the first table.
first_table = re.search(r"(?m)^\[", text)
top = text[:first_table.start()] if first_table else text
setting = re.search(r"(?m)^web_search[ \t]*=.*$", top)
if setting:
    text = text[:setting.start()] + 'web_search = "disabled"' + text[setting.end():]
else:
    text = 'web_search = "disabled"\n' + text
codex.write_text(text)

# OpenCode's model favorites are shared through ~/.local/share/opencode/model-favorites.json, which is
# authoritative. Only the "favorite" array in this machine's state is replaced; "recent" and "variant"
# are per-machine usage and stay as they are.
favorites = home / ".local/share/opencode/model-favorites.json"
if favorites.exists():
    state = home / ".local/state/opencode/model.json"
    data = json.loads(state.read_text()) if state.exists() else {}
    data["favorite"] = json.loads(favorites.read_text())
    state.parent.mkdir(parents=True, exist_ok=True)
    temp = state.with_name(state.name + ".tmp")
    temp.write_text(json.dumps(data, separators=(",", ":")) + "\n")
    temp.replace(state)
