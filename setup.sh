#!/usr/bin/env bash
#
# devrig workspace setup.
# Personalizes a freshly scaffolded workspace (removes devrig's own template
# files, generates a project README), clones your project repos (from
# devrig.toml), and installs the AI tooling (semble, rtk, graphify, MCP config,
# protected-branch git hooks).
# Idempotent — safe to re-run at any time to update everything.
#
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# --- 0. Interactive config wizard (first run only) -----------------------------
# Only runs when devrig.toml still has the shipped example values (name=acme)
# AND we're attached to a terminal. Otherwise setup.sh expects devrig.toml to
# already be filled in (by hand, or by an AI agent per the README's kickstart
# prompt).

ask_yes_no() {
  local prompt="$1" default="$2" ans hint
  if [ "$default" = true ]; then hint="Y/n"; else hint="y/N"; fi
  read -r -p "$prompt [$hint]: " ans
  case "$ans" in
    [Yy]*) echo true ;;
    [Nn]*) echo false ;;
    *) echo "$default" ;;
  esac
}

# Numbered single-choice prompt. Prints the menu to stderr, returns the chosen
# option text on stdout (so it's safe to capture with `x=$(ask_choice ...)`).
ask_choice() {
  local prompt="$1"; shift
  local -a opts=("$@")
  echo "$prompt" >&2
  local i=1 o
  for o in "${opts[@]}"; do
    printf '  %d) %s\n' "$i" "$o" >&2
    i=$((i + 1))
  done
  local ans idx
  read -r -p "Enter a number [1]: " ans
  case "$ans" in
    ''|*[!0-9]*) ans=1 ;;
  esac
  idx=$((ans - 1))
  if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#opts[@]}" ]; then idx=0; fi
  echo "${opts[$idx]}"
}

# Writes devrig.toml from the current in-memory config values. Values are
# handed to python3 via env vars (not argv), so nothing needs shell-argv
# escaping; python does its own TOML string escaping.
write_config_file() {
  local repos_joined="" r
  for r in ${REPOS[@]+"${REPOS[@]}"}; do
    repos_joined="${repos_joined}${r}"$'\n'
  done

  DEVRIG_PROJECT_NAME="$PROJECT_NAME" \
  DEVRIG_PROJECT_DESCRIPTION="$PROJECT_DESCRIPTION" \
  DEVRIG_GITHUB_ORG="$GITHUB_ORG" \
  DEVRIG_REPOS="$repos_joined" \
  DEVRIG_ISSUE_TRACKER="$ISSUE_TRACKER" \
  DEVRIG_TICKET_PREFIX="$TICKET_PREFIX" \
  DEVRIG_DEFAULT_BRANCH="$DEFAULT_BRANCH" \
  DEVRIG_ENABLE_SEMBLE="$ENABLE_SEMBLE" \
  DEVRIG_ENABLE_RTK="$ENABLE_RTK" \
  DEVRIG_ENABLE_GRAPHIFY="$ENABLE_GRAPHIFY" \
  DEVRIG_ENABLE_GIT_HOOKS="$ENABLE_GIT_HOOKS" \
  python3 - "$WORKSPACE_DIR/devrig.toml" <<'PY'
import os, sys

def esc(s):
    return s.replace("\\", "\\\\").replace('"', '\\"')

path = sys.argv[1]
env = os.environ
repos = [r for r in env.get("DEVRIG_REPOS", "").split("\n") if r]
repos_toml = ", ".join(f'"{esc(r)}"' for r in repos)

content = f'''# devrig configuration
#
# Edit these values for your project, then run ./setup.sh — or just run
# ./setup.sh first and answer its prompts; it writes this file for you.

[project]
name = "{esc(env["DEVRIG_PROJECT_NAME"])}"              # short lowercase name; names the generated .code-workspace file
description = "{esc(env["DEVRIG_PROJECT_DESCRIPTION"])}"  # one-line project description, used in the generated README
github_org = "{esc(env["DEVRIG_GITHUB_ORG"])}"          # GitHub org (or username) that owns your repos
repos = [{repos_toml}]  # repos setup.sh clones side-by-side; use [] for none
issue_tracker = "{esc(env["DEVRIG_ISSUE_TRACKER"])}"    # linear | jira | other — controls which tracker MCP server gets wired up
ticket_prefix = "{esc(env["DEVRIG_TICKET_PREFIX"])}"    # ticket prefix, e.g. AC-123
default_branch = "{esc(env["DEVRIG_DEFAULT_BRANCH"])}"  # protected default branch of your repos

[features]
semble = {env["DEVRIG_ENABLE_SEMBLE"]}         # semantic code search, wired to agents via MCP
rtk = {env["DEVRIG_ENABLE_RTK"]}               # token-optimizing command proxy for Claude Code
graphify = {env["DEVRIG_ENABLE_GRAPHIFY"]}     # per-repo knowledge graph agents query before grepping
git_hooks = {env["DEVRIG_ENABLE_GIT_HOOKS"]}   # block direct commits/pushes to protected branches
'''

with open(path, "w") as f:
    f.write(content)
PY
}

prompt_for_config() {
  echo >&2
  info "First run — let's configure this workspace. Press Enter to accept the default in [brackets]."
  echo >&2

  local ans

  read -r -p "Project name (short, lowercase — names the .code-workspace file) [${PROJECT_NAME}]: " ans
  PROJECT_NAME="${ans:-$PROJECT_NAME}"

  read -r -p "One-line project description (used in the generated README, blank to skip): " ans
  PROJECT_DESCRIPTION="${ans:-$PROJECT_DESCRIPTION}"

  read -r -p "GitHub org or username that owns your repos [${GITHUB_ORG}]: " ans
  GITHUB_ORG="${ans:-$GITHUB_ORG}"

  read -r -p "Repos to clone side-by-side — paste names separated by spaces or commas (blank for none): " ans
  if [ -n "$ans" ]; then
    local -a pasted cleaned
    IFS=', ' read -r -a pasted <<< "$ans"
    cleaned=()
    for r in "${pasted[@]}"; do [ -n "$r" ] && cleaned+=("$r"); done
    REPOS=(${cleaned[@]+"${cleaned[@]}"})
  else
    REPOS=()
  fi

  echo >&2
  local tracker_label
  tracker_label=$(ask_choice "Which issue tracker do you use?" "Linear" "Jira" "Other / none (I'll wire it up myself)")
  case "$tracker_label" in
    Linear) ISSUE_TRACKER=linear ;;
    Jira) ISSUE_TRACKER=jira ;;
    *) ISSUE_TRACKER=other ;;
  esac
  echo >&2

  read -r -p "Ticket prefix, e.g. AC [${TICKET_PREFIX}]: " ans
  TICKET_PREFIX="${ans:-$TICKET_PREFIX}"

  read -r -p "Default (protected) branch [${DEFAULT_BRANCH}]: " ans
  DEFAULT_BRANCH="${ans:-$DEFAULT_BRANCH}"

  echo >&2
  ENABLE_SEMBLE=$(ask_yes_no "Enable semble (semantic code search)?" true)
  ENABLE_RTK=$(ask_yes_no "Enable rtk (token-optimizing proxy for Claude Code)?" true)
  ENABLE_GRAPHIFY=$(ask_yes_no "Enable graphify (per-repo knowledge graph for agents)?" true)
  ENABLE_GIT_HOOKS=$(ask_yes_no "Enable protected-branch git hooks?" true)

  write_config_file
  echo >&2
  info "Saved to devrig.toml — edit that file by hand anytime to change these values."
}

# --- 1. Configuration ---------------------------------------------------------
# devrig.toml is the single source of truth. It's parsed with python3's
# tomllib (stdlib on 3.11+; falls back to the 'tomli' package on older
# Python), which prints shell-safe `KEY='value'` assignments that we eval.

load_config() {
  [ -f "$WORKSPACE_DIR/devrig.toml" ] || fail "devrig.toml not found. This file defines your project (name, org, repos). It ships with the template — restore it from git."

  local py_out
  py_out="$(python3 - "$WORKSPACE_DIR/devrig.toml" <<'PY'
import sys
try:
    import tomllib
except ModuleNotFoundError:
    try:
        import tomli as tomllib
    except ModuleNotFoundError:
        sys.exit("devrig.toml needs Python's tomllib (3.11+) or the 'tomli' package on older Python. Try: pip install tomli")

path = sys.argv[1]
with open(path, "rb") as f:
    cfg = tomllib.load(f)

project = cfg.get("project", {})
features = cfg.get("features", {})

def sh_str(s):
    return "'" + str(s).replace("'", "'\\''") + "'"

def sh_bool(b):
    return "true" if b else "false"

print(f"PROJECT_NAME={sh_str(project.get('name', 'acme'))}")
print(f"PROJECT_DESCRIPTION={sh_str(project.get('description', ''))}")
print(f"GITHUB_ORG={sh_str(project.get('github_org', 'AcmeInc'))}")
repos = project.get("repos", [])
print("REPOS=(" + " ".join(sh_str(r) for r in repos) + ")")
print(f"ISSUE_TRACKER={sh_str(project.get('issue_tracker', 'linear'))}")
print(f"TICKET_PREFIX={sh_str(project.get('ticket_prefix', 'AC'))}")
print(f"DEFAULT_BRANCH={sh_str(project.get('default_branch', 'dev'))}")
print(f"ENABLE_SEMBLE={sh_bool(features.get('semble', True))}")
print(f"ENABLE_RTK={sh_bool(features.get('rtk', True))}")
print(f"ENABLE_GRAPHIFY={sh_bool(features.get('graphify', True))}")
print(f"ENABLE_GIT_HOOKS={sh_bool(features.get('git_hooks', True))}")
PY
)" || fail "Failed to parse devrig.toml — see the error above."

  eval "$py_out"

  if [ "$PROJECT_NAME" = "acme" ] && [ "$GITHUB_ORG" = "AcmeInc" ]; then
    if [ -t 0 ] && [ -t 1 ]; then
      prompt_for_config
    else
      fail "'devrig.toml' still contains the shipped example values. Edit devrig.toml with your project's values, then re-run ./setup.sh — or run ./setup.sh in an interactive terminal to be prompted instead."
    fi
  fi
}

# --- 1b. Personalize the workspace ---------------------------------------------
# A freshly scaffolded workspace still carries the devrig template's own repo
# files: the devrig-branded README, logo assets, translated docs, and the
# CITATION/CONTRIBUTING/LICENSE that belong to the template project — not to
# your workspace. Remove them and generate a project README from devrig.toml
# so the workspace is yours from the first run. Idempotent: a README you have
# edited (or replaced) is never touched again. Skipped inside the devrig
# template repo itself so contributors can run setup.sh without deleting its
# own files.

TEMPLATE_ONLY_FILES=(docs assets CITATION.cff CONTRIBUTING.md LICENSE)

is_devrig_template_repo() {
  git -C "$WORKSPACE_DIR" remote get-url origin 2>/dev/null \
    | grep -qiE 'github\.com[:/]lakpriya1s/devrig(\.git)?/?$'
}

personalize_workspace() {
  if is_devrig_template_repo; then
    info "This is the devrig template repo itself — skipping personalization."
    return 0
  fi

  local removed="" f
  for f in "${TEMPLATE_ONLY_FILES[@]}"; do
    if [ -e "$WORKSPACE_DIR/$f" ]; then
      rm -rf "$WORKSPACE_DIR/$f"
      removed="$removed $f"
    fi
  done
  [ -n "$removed" ] && info "Removed devrig template files:$removed"

  # Replace the README only while it's still the shipped template one.
  if [ ! -f "$WORKSPACE_DIR/README.md" ] || grep -q '^## What is devrig?' "$WORKSPACE_DIR/README.md"; then
    info "Generating project README.md from devrig.toml..."
    write_readme
  fi
}

# Writes a project-specific README.md from the devrig.toml values. Same
# env-var-to-python pattern as write_config_file.
write_readme() {
  local origin_url
  origin_url="$(git -C "$WORKSPACE_DIR" remote get-url origin 2>/dev/null || true)"

  local repos_joined="" r
  for r in ${REPOS[@]+"${REPOS[@]}"}; do
    repos_joined="${repos_joined}${r}"$'\n'
  done

  DEVRIG_PROJECT_NAME="$PROJECT_NAME" \
  DEVRIG_PROJECT_DESCRIPTION="$PROJECT_DESCRIPTION" \
  DEVRIG_GITHUB_ORG="$GITHUB_ORG" \
  DEVRIG_REPOS="$repos_joined" \
  DEVRIG_ISSUE_TRACKER="$ISSUE_TRACKER" \
  DEVRIG_DEFAULT_BRANCH="$DEFAULT_BRANCH" \
  DEVRIG_ENABLE_SEMBLE="$ENABLE_SEMBLE" \
  DEVRIG_ENABLE_RTK="$ENABLE_RTK" \
  DEVRIG_ENABLE_GRAPHIFY="$ENABLE_GRAPHIFY" \
  DEVRIG_ENABLE_GIT_HOOKS="$ENABLE_GIT_HOOKS" \
  DEVRIG_ORIGIN_URL="$origin_url" \
  python3 - "$WORKSPACE_DIR/README.md" <<'PY'
import os, sys

path = sys.argv[1]
env = os.environ
name = env["DEVRIG_PROJECT_NAME"]
desc = env.get("DEVRIG_PROJECT_DESCRIPTION", "").strip()
repos = [r for r in env.get("DEVRIG_REPOS", "").split("\n") if r]
tracker = env["DEVRIG_ISSUE_TRACKER"]
branch = env["DEVRIG_DEFAULT_BRANCH"]
semble = env["DEVRIG_ENABLE_SEMBLE"] == "true"
rtk = env["DEVRIG_ENABLE_RTK"] == "true"
graphify = env["DEVRIG_ENABLE_GRAPHIFY"] == "true"
hooks = env["DEVRIG_ENABLE_GIT_HOOKS"] == "true"
origin = env.get("DEVRIG_ORIGIN_URL", "").strip()

tracker_server = {"linear": "linear", "jira": "atlassian"}.get(tracker)

out = [f"# {name} AI Workspace", ""]
if desc:
    out += [desc, ""]
out += [
    "Multi-repo development workspace — one folder that contains every system",
    "repo plus the AI tooling (workflow skills, semantic code search, token",
    "optimization) used to develop across them. Configured from `devrig.toml`.",
    "",
    "## Getting started",
    "",
    "```bash",
]
if origin:
    tail = origin.rstrip("/").split("/")[-1]
    if tail.endswith(".git"):
        tail = tail[: -len(".git")]
    out += [f"git clone {origin}", f"cd {tail}"]
out += [
    "./setup.sh",
    "```",
    "",
    "`setup.sh` is idempotent — re-run it anytime to update every repo and tool. It:",
    "",
    "1. Checks prerequisites (`git`, `gh` authenticated).",
    "2. Clones all system repos side-by-side into this folder (or fast-forwards",
    "   them if already cloned and clean).",
]
step = 3
if hooks:
    out += [f"{step}. Installs protected-branch git hooks into every repo."]
    step += 1
if semble:
    out += [
        f"{step}. Installs [semble](https://github.com/MinishLab/semble) — semantic code",
        "   search that agents use via MCP instead of grep-and-read.",
    ]
    step += 1
if rtk:
    out += [
        f"{step}. Installs [rtk](https://github.com/rtk-ai/rtk) and registers its Claude Code",
        "   hook — compresses command output to cut token usage.",
    ]
    step += 1
if graphify:
    out += [
        f"{step}. Installs [graphify](https://github.com/Graphify-Labs/graphify) — its skill, the",
        "   PreToolUse guards that point agents at the graph, and the git hooks that",
        "   rebuild each repo's graph after commits, checkouts and merges.",
    ]
    step += 1
out += ["", "Then:", "", "1. Run `claude` from this folder."]
step = 2
if tracker_server:
    out += [f"{step}. Run `/mcp` and authenticate the **{tracker_server}** server (one-time OAuth)."]
    step += 1
if rtk:
    out += [f"{step}. Restart Claude Code once so the rtk hook takes effect."]
    step += 1
if graphify:
    out += [
        f"{step}. Build each repo's knowledge graph once — `graphify update .` from a repo",
        "   root (AST-only, no API key, no LLM cost). After that the git hooks keep it",
        "   current. Or just ask an agent to run `/graphify` in that repo.",
    ]
    step += 1
out += [
    "",
    "## Open in VS Code",
    "",
    "```bash",
    f"code {name}.code-workspace",
    "```",
    "",
    "This multi-root workspace shows every system repo plus the workspace meta",
    "files in one window — the Source Control panel tracks all repos at once.",
    "",
    "## What's inside",
    "",
    "| Repo | System |",
    "|---|---|",
]
for repo in repos:
    out += [f"| `{repo}/` | <!-- TODO: what it is, stack --> |"]
out += [
    "| `knowledge/` | Knowledge base — design docs, ADRs, runbooks |",
    "",
    f"All system repos default to the **`{branch}`** branch. The cloned repos are",
    "gitignored here — this repo only versions the workspace tooling itself",
    "(`setup.sh`, `devrig.toml`, `AGENTS.md`, `CLAUDE.md`, `.agents/skills/`).",
    "",
    "The systems table in [`AGENTS.md`](AGENTS.md) is the source of truth for what",
    "each repo is — keep both in sync when repos change.",
    "",
    "## Knowledge base",
    "",
    "New design docs, architecture notes, and ADRs go in [`knowledge/`](knowledge/)",
]
if semble:
    out += [
        "as markdown via PR — semble indexes it, so agents find design context the",
        "same way they find code.",
    ]
else:
    out += ["as markdown via PR."]
if graphify:
    out += [
        "",
        "## Knowledge graph",
        "",
        "[graphify](https://github.com/Graphify-Labs/graphify) gives every repo its own",
        "`<repo>/graphify-out/` — a queryable graph of the code (hubs, communities,",
        "cross-file relationships) plus `GRAPH_REPORT.md` and an interactive `graph.html`.",
        "",
        "```bash",
        "cd <repo>",
        "graphify query \"how does authentication work\"   # scoped subgraph, not a grep dump",
        "graphify path \"LoginForm\" \"SessionStore\"        # how two things connect",
        "graphify explain \"PaymentService\"               # one node and its neighbours",
        "graphify update .                               # refresh after code changes",
        "```",
        "",
        "The graphs are gitignored (generated locally, per machine). The shared git hooks",
        "rebuild the graph of whichever repo you just committed, checked out, or merged in.",
    ]
out += [
    "",
    "## Customize this workspace",
    "",
    "One-time steps after the first `setup.sh` run:",
    "",
    "- [ ] Fill the **Systems** table above and in `AGENTS.md` (one row per repo:",
    "      what it is, stack), plus `AGENTS.md`'s **Testing** section.",
    "- [ ] Add one reference file per repo in `.agents/skills/code-review/references/`",
    "      and `.agents/skills/write-doc/references/` (copy `_example-repo.md`).",
]
if tracker == "linear":
    out += [
        "- [ ] Verify `.agents/skills/create-ticket/SKILL.md`'s \"Conventions\" table",
        "      against your Linear workspace (teams, projects, labels).",
    ]
else:
    out += [
        "- [ ] Adapt `/start-task`, `/raise-pr`, and `/create-ticket`'s `mcp__linear__*`",
        "      calls to your tracker's MCP tool names (each skill flags this at the top).",
    ]
out += [
    "- [ ] To change any value later (switch tracker, add a repo), edit `devrig.toml`",
    "      and re-run `./setup.sh`.",
    "",
    "## Troubleshooting",
    "",
]
if semble:
    out += [
        "- **`semble` or `uv` not found after setup** — open a new shell (PATH was",
        "  updated) and re-run `./setup.sh`.",
    ]
if tracker_server:
    out += [
        f"- **Tracker tools missing in Claude** — run `/mcp` and complete the OAuth flow",
        f"  for the `{tracker_server}` server.",
    ]
if rtk:
    out += [
        "- **rtk not kicking in** — restart Claude Code; verify with `rtk gain` that",
        "  commands are being proxied.",
    ]
if graphify:
    out += [
        "- **`graphify query` says there's no graph** — build it once with",
        "  `graphify update .` from that repo's root; the hooks only refresh an",
        "  existing graph.",
        "- **Graph rebuilds aren't firing on commit** — check `graphify hook status`",
        "  in the repo, and the rebuild log at `~/.cache/graphify-rebuild.log`. Set",
        "  `GRAPHIFY_SKIP_HOOK=1` to silence them temporarily.",
    ]
out += [
    "- **A repo won't update** — `setup.sh` never touches a repo that has local",
    "  changes or is on a task branch; it only fast-forwards clean default-branch",
    "  checkouts.",
    "",
    "---",
    "",
    "<sub>Scaffolded with [devrig](https://github.com/lakpriya1s/devrig).</sub>",
]

with open(path, "w") as f:
    f.write("\n".join(out) + "\n")
PY
}

check_basic_prereqs() {
  command -v git >/dev/null 2>&1 || fail "git is required. On macOS run: xcode-select --install"
  command -v gh >/dev/null 2>&1 || fail "GitHub CLI (gh) is required. Install: brew install gh"
  gh auth status >/dev/null 2>&1 || fail "gh is not authenticated. Run: gh auth login"
}

# uv is the installer for both semble and graphify — only needed if one of them
# is enabled.
check_uv_prereqs() {
  [ "$ENABLE_SEMBLE" = true ] || [ "$ENABLE_GRAPHIFY" = true ] || return 0
  command -v uv >/dev/null 2>&1 && return 0
  info "Installing uv (needed for semble/graphify)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  command -v uv >/dev/null 2>&1 || fail "uv installed but not on PATH. Open a new shell and re-run ./setup.sh"
}

# --- 2. Clone / update repos --------------------------------------------------

clone_repos() {
  for repo in ${REPOS[@]+"${REPOS[@]}"}; do
    dir="$WORKSPACE_DIR/$repo"
    if [ -d "$dir/.git" ]; then
      info "Updating $repo..."
      git -C "$dir" fetch --prune --quiet
      default_branch="$(git -C "$dir" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's@^origin/@@' || true)"
      [ -n "$default_branch" ] || default_branch="$DEFAULT_BRANCH"
      current_branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
      if [ "$current_branch" = "$default_branch" ] && [ -z "$(git -C "$dir" status --porcelain)" ]; then
        git -C "$dir" pull --ff-only --quiet
      else
        warn "$repo is on '$current_branch' or has local changes — fetched, not pulled."
      fi
    else
      info "Cloning $repo..."
      gh repo clone "$GITHUB_ORG/$repo" "$dir" -- --quiet
    fi
  done
}

# Keep the committed .gitignore free of project-specific repo names: the
# cloned repo directories are excluded locally via .git/info/exclude instead.
exclude_repos() {
  exclude_file="$WORKSPACE_DIR/.git/info/exclude"
  mkdir -p "$(dirname "$exclude_file")"
  touch "$exclude_file"
  for repo in ${REPOS[@]+"${REPOS[@]}"}; do
    grep -qxF "/$repo/" "$exclude_file" || echo "/$repo/" >> "$exclude_file"
  done
}

# --- 3. Protected-branch git hooks --------------------------------------------
# Blocks accidental commits/pushes on the default branch (and main/master) in
# every repo. Hooks live in git-hooks/ at the workspace root; wired via
# core.hooksPath — so this one directory serves the workspace repo and every
# cloned repo, and `graphify hook install` (see install_graphify) drops its
# post-commit/post-checkout rebuild hooks in here too.

install_git_hooks() {
  [ "$ENABLE_GIT_HOOKS" = true ] || { info "Git hooks disabled in devrig.toml — skipping."; return 0; }
  info "Installing protected-branch git hooks..."
  chmod +x "$WORKSPACE_DIR/git-hooks/pre-commit" "$WORKSPACE_DIR/git-hooks/pre-push" \
    "$WORKSPACE_DIR/git-hooks/post-merge"
  git -C "$WORKSPACE_DIR" config core.hooksPath "$WORKSPACE_DIR/git-hooks"
  for repo in ${REPOS[@]+"${REPOS[@]}"}; do
    dir="$WORKSPACE_DIR/$repo"
    [ -d "$dir/.git" ] && git -C "$dir" config core.hooksPath "$WORKSPACE_DIR/git-hooks"
  done
}

# --- 4. MCP configuration ------------------------------------------------------
# Converges .mcp.json and opencode.json to the devrig.toml toggles: the tracker
# (linear/atlassian) and semble entries are added/removed to match, while any
# servers you added by hand are preserved. Also generates
# .claude/settings.local.json (gitignored) if it doesn't exist yet.

sync_mcp_config() {
  info "Syncing MCP config to devrig.toml toggles..."
  python3 - "$WORKSPACE_DIR" "$ISSUE_TRACKER" "$ENABLE_SEMBLE" <<'PY'
import json, os, sys

root, tracker, semble_on = sys.argv[1], sys.argv[2], sys.argv[3] == "true"
linear_on = tracker == "linear"
jira_on = tracker == "jira"

def load(path, default):
    if os.path.exists(path):
        with open(path) as f:
            return json.load(f)
    return default

def save(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")

# .mcp.json (Claude Code)
mcp_path = os.path.join(root, ".mcp.json")
mcp = load(mcp_path, {"mcpServers": {}})
servers = mcp.setdefault("mcpServers", {})
if linear_on:
    servers.setdefault("linear", {"type": "http", "url": "https://mcp.linear.app/mcp"})
else:
    servers.pop("linear", None)
if jira_on:
    # Atlassian's remote MCP server (Jira + Confluence), OAuth-based like linear.
    # Best-effort: double-check the URL against Atlassian's current docs if this
    # doesn't connect — remote MCP endpoints are still evolving.
    servers.setdefault("atlassian", {"type": "sse", "url": "https://mcp.atlassian.com/v1/sse"})
else:
    servers.pop("atlassian", None)
if semble_on:
    servers.setdefault("semble", {"command": "uvx", "args": ["--from", "semble[mcp]", "semble"], "type": "stdio"})
else:
    servers.pop("semble", None)
save(mcp_path, mcp)

# opencode.json
oc_path = os.path.join(root, "opencode.json")
oc = load(oc_path, {"$schema": "https://opencode.ai/config.json", "mcp": {}})
oc_mcp = oc.setdefault("mcp", {})
if linear_on:
    oc_mcp.setdefault("linear", {"type": "remote", "url": "https://mcp.linear.app/mcp", "enabled": True})
else:
    oc_mcp.pop("linear", None)
if jira_on:
    oc_mcp.setdefault("atlassian", {"type": "remote", "url": "https://mcp.atlassian.com/v1/sse", "enabled": True})
else:
    oc_mcp.pop("atlassian", None)
if semble_on:
    oc_mcp.setdefault("semble", {"type": "local", "command": ["uvx", "--from", "semble[mcp]", "semble"], "enabled": True})
else:
    oc_mcp.pop("semble", None)
save(oc_path, oc)

# .claude/settings.local.json — generated once, then left alone
local_path = os.path.join(root, ".claude", "settings.local.json")
if not os.path.exists(local_path):
    enabled = [name for name, on in (("linear", linear_on), ("atlassian", jira_on), ("semble", semble_on)) if on]
    os.makedirs(os.path.dirname(local_path), exist_ok=True)
    save(local_path, {"enableAllProjectMcpServers": True, "enabledMcpjsonServers": enabled})
    print("  generated .claude/settings.local.json")
PY
}

# --- 5. semble (semantic code search, used by agents via MCP) ------------------

install_semble() {
  [ "$ENABLE_SEMBLE" = true ] || { info "semble disabled in devrig.toml — skipping."; return 0; }
  info "Installing semble..."
  # --force so the [mcp] extra is always present even if semble was installed without it.
  uv tool install --force --quiet 'semble[mcp]'
  command -v semble >/dev/null 2>&1 || fail "semble installed but not on PATH. Open a new shell and re-run ./setup.sh"

  # Claude Code for THIS workspace is wired declaratively via files checked into
  # the repo, so it works on clone without any `semble install`:
  #   - MCP server:      .mcp.json                       (semble stdio server)
  #   - enable server:   .claude/settings.local.json     (enabledMcpjsonServers)
  #   - search subagent: .claude/agents/semble-search.md
  #
  # To also let devs use semble in their OTHER editors (Cursor, Codex, Copilot,
  # Gemini, ...), semble ships an installer. Its unattended flags
  # (`--agent ... --type ... --yes`) are best-effort: run the scripted form if
  # this semble supports it, else tell the dev the interactive command. Guarded
  # so it never breaks setup under `set -euo pipefail`.
  if semble install --agent claude --type mcp subagent --yes >/dev/null 2>&1; then
    info "Configuring semble across other editors (Cursor, Codex, Gemini, ...)..."
    semble install --agent claude cursor codex gemini copilot antigravity --type mcp subagent --yes >/dev/null 2>&1 \
      || warn "Some editors were not auto-configured. Run 'semble install' to finish interactively."
  else
    warn "This semble build has no scripted install. To use semble in your other IDEs, run once:  semble install"
  fi

  # Warm the on-disk index for each repo so the first real search is instant,
  # and to verify semble actually runs end-to-end. Non-fatal — best-effort.
  info "Warming semble indexes (first run builds them)..."
  for repo in ${REPOS[@]+"${REPOS[@]}"} knowledge; do
    dir="$WORKSPACE_DIR/$repo"
    [ -d "$dir" ] && semble search "authentication" "$dir" --top-k 1 >/dev/null 2>&1 || true
  done
}

# --- 6. rtk (token-optimizing command proxy for Claude Code) -------------------

install_rtk() {
  [ "$ENABLE_RTK" = true ] || { info "rtk disabled in devrig.toml — skipping."; return 0; }
  if ! command -v rtk >/dev/null 2>&1; then
    info "Installing rtk..."
    if command -v brew >/dev/null 2>&1; then
      brew install rtk
    else
      curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
      export PATH="$HOME/.local/bin:$PATH"
    fi
  fi

  # Verify this is the real rtk (Rust Token Killer), not the unrelated crates.io
  # "Rust Type Kit" of the same name. If it's the wrong one `rtk gain` fails — and
  # the `rtk hook claude` PreToolUse hook registered below would then break EVERY
  # Bash command in Claude Code, so stop here with a clear message instead.
  command -v rtk >/dev/null 2>&1 || fail "rtk installed but not on PATH. Open a new shell and re-run ./setup.sh"
  rtk gain >/dev/null 2>&1 || fail "Installed 'rtk' is not the Rust Token Killer ('rtk gain' failed — likely the crates.io 'Rust Type Kit'). Install the correct one: cargo install --git https://github.com/rtk-ai/rtk"

  info "Registering rtk hook for Claude Code (global)..."
  rtk init -g || true

  # rtk init only patches settings.json when run in an interactive terminal, so
  # add the PreToolUse hook ourselves (no-op if it is already there).
  CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  python3 - "$CLAUDE_DIR/settings.json" <<'PY'
import json, os, sys

path = sys.argv[1]
os.makedirs(os.path.dirname(path), exist_ok=True)
settings = {}
if os.path.exists(path):
    with open(path) as f:
        settings = json.load(f)
hooks = settings.setdefault("hooks", {}).setdefault("PreToolUse", [])
if any("rtk hook claude" in json.dumps(h) for h in hooks):
    print("  rtk hook already present in", path)
else:
    hooks.append({
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "rtk hook claude"}],
    })
    with open(path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    print("  rtk PreToolUse hook added to", path)
PY
}

# --- 7. graphify (knowledge graph agents query instead of grepping) ------------
# https://github.com/Graphify-Labs/graphify — turns a repo into a queryable
# knowledge graph (god nodes, communities, cross-file relationships) that agents
# hit with `graphify query/path/explain` instead of grep-and-read.
#
# One graph per git repo rather than one merged graph: each cloned repo gets its
# own `<repo>/graphify-out/`, and this workspace repo gets one covering
# `knowledge/` and the tooling (the cloned repos are excluded from it via
# .git/info/exclude, which graphify honors). All kept fresh by the git hooks
# below. Wiring installed here:
#   - skill:        .agents/skills/graphify/ (+ .claude/skills/ symlink)
#   - agent nudge:  PreToolUse hook-guards in .claude/settings.json
#   - freshness:    post-commit/post-checkout (graphify) + post-merge (devrig)

install_graphify() {
  if [ "$ENABLE_GRAPHIFY" != true ]; then
    info "graphify disabled in devrig.toml — skipping."
    sync_graphify_claude_hooks false
    return 0
  fi

  info "Installing graphify..."
  # PyPI package is 'graphifyy'; the CLI it ships is 'graphify'.
  uv tool install --force --quiet graphifyy
  command -v graphify >/dev/null 2>&1 || fail "graphify installed but not on PATH. Open a new shell and re-run ./setup.sh"

  # `--platform agents --project` writes the skill to ./.agents/skills/graphify/
  # — exactly where devrig keeps its canonical, agent-agnostic skills. Re-run on
  # every setup so the skill tracks the installed CLI version (graphify warns
  # when the two drift), then symlink it for Claude Code like every other skill.
  info "Installing the graphify skill into .agents/skills/..."
  ( cd "$WORKSPACE_DIR" && graphify install --project --platform agents >/dev/null ) \
    || warn "graphify skill install failed — run 'graphify install --project --platform agents' here by hand."
  mkdir -p "$WORKSPACE_DIR/.claude/skills"
  ln -sfn ../../.agents/skills/graphify "$WORKSPACE_DIR/.claude/skills/graphify"

  sync_graphify_claude_hooks true

  # Rebuild-on-commit hooks. With core.hooksPath pointing every repo at
  # git-hooks/ (install_git_hooks), one install covers the whole workspace —
  # each hook run rebuilds the graph of whichever repo the commit happened in.
  # Without it, every repo has its own .git/hooks and needs its own install.
  info "Installing graphify git hooks (graph rebuild on commit/checkout)..."
  ( cd "$WORKSPACE_DIR" && graphify hook install >/dev/null ) \
    || warn "graphify hook install failed at the workspace root — run it by hand to get commit-triggered rebuilds."
  if [ "$ENABLE_GIT_HOOKS" != true ]; then
    for repo in ${REPOS[@]+"${REPOS[@]}"}; do
      dir="$WORKSPACE_DIR/$repo"
      [ -d "$dir/.git" ] || continue
      ( cd "$dir" && graphify hook install >/dev/null ) \
        || warn "graphify hook install failed in $repo."
    done
  fi
}

# Converges the two graphify PreToolUse hook-guards in .claude/settings.json:
# they fire before the agent greps or reads files and remind it to query the
# graph first. Added when the feature is on, removed when it's off, so the
# committed settings.json always matches devrig.toml.
#
# The command is bare `graphify` (resolved from PATH, not an absolute path) so
# the committed file works for every teammate, and it is wrapped in a
# command-v test so a checkout where graphify isn't installed yet is a silent
# no-op instead of a failing hook on every tool call.
sync_graphify_claude_hooks() {
  local on="$1"
  python3 - "$WORKSPACE_DIR/.claude/settings.json" "$on" <<'PY'
import json, os, sys

path, on = sys.argv[1], sys.argv[2] == "true"

GUARDS = [
    {"matcher": "Bash|Grep", "hooks": [{"type": "command",
     "command": "if command -v graphify >/dev/null 2>&1; then graphify hook-guard search; fi"}]},
    {"matcher": "Read|Glob", "hooks": [{"type": "command",
     "command": "if command -v graphify >/dev/null 2>&1; then graphify hook-guard read; fi"}]},
]

before = ""
settings = {}
if os.path.exists(path):
    before = open(path).read()
    settings = json.loads(before)

# Drop any graphify guard already registered (so an upgrade replaces rather than
# duplicates it), then re-add if the feature is on.
hooks = settings.get("hooks", {})
pre = [h for h in hooks.get("PreToolUse", []) if "graphify" not in json.dumps(h)]
pre += GUARDS if on else []

if pre:
    settings.setdefault("hooks", {})["PreToolUse"] = pre
elif hooks:
    hooks.pop("PreToolUse", None)
    if not hooks:
        settings.pop("hooks", None)

after = json.dumps(settings, indent=2) + "\n"
if after != before:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(after)
    print("  .claude/settings.json  ->  graphify PreToolUse guards " + ("registered" if on else "removed"))
PY
}

# --- 8. VS Code multi-root workspace -------------------------------------------
# Generated from the REPOS list. Skipped if the file already exists so you can
# customize it (and commit it) without setup.sh overwriting your changes.

generate_workspace() {
  ws_file="$WORKSPACE_DIR/$PROJECT_NAME.code-workspace"
  if [ -f "$ws_file" ]; then
    info "$PROJECT_NAME.code-workspace already exists — leaving it alone."
    return 0
  fi
  info "Generating $PROJECT_NAME.code-workspace..."
  python3 - "$ws_file" ${REPOS[@]+"${REPOS[@]}"} <<'PY'
import json, sys

ws_file, repos = sys.argv[1], sys.argv[2:]
folders = [{"name": repo, "path": repo} for repo in repos]
folders.append({"name": "knowledge", "path": "knowledge"})
folders.append({"name": "workspace (meta)", "path": "."})

exclude = {f"{repo}/": True for repo in repos}
exclude["**/.DS_Store"] = True

data = {
    "folders": folders,
    "settings": {
        "files.exclude": exclude,
        "scm.repositories.visible": 10,
    },
    "extensions": {
        "recommendations": [
            "dbaeumer.vscode-eslint",
            "esbenp.prettier-vscode",
        ]
    },
}
with open(ws_file, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
}

# --- 9. Done --------------------------------------------------------------------

final_checks() {
  if grep -q "TODO: fill in" "$WORKSPACE_DIR/AGENTS.md" 2>/dev/null; then
    warn "AGENTS.md still has its 'TODO: fill in' systems table — fill it in so agents know what each repo is."
  fi
  case "$ISSUE_TRACKER" in
    jira)
      warn "Issue tracker set to Jira: the 'atlassian' MCP server was wired up, but /start-task, /raise-pr, and /create-ticket still call Linear's MCP tool names (mcp__linear__*) — adapt those skills to your Jira MCP server's tool names before relying on them."
      ;;
    other)
      warn "Issue tracker set to 'other' — no tracker MCP server was configured. Add your own to .mcp.json/opencode.json, and adapt /start-task, /raise-pr, and /create-ticket to call it."
      ;;
  esac
}

print_next_steps() {
  printf '\n✅ Workspace ready.\n\nNext steps:\n'
  step=1
  printf '  %d. cd into this folder and run `claude`.\n' "$step"; step=$((step+1))
  if [ "$ISSUE_TRACKER" = "linear" ]; then
    printf '  %d. Run /mcp and authenticate the "linear" server (OAuth, one time).\n' "$step"; step=$((step+1))
  elif [ "$ISSUE_TRACKER" = "jira" ]; then
    printf '  %d. Run /mcp and authenticate the "atlassian" server (OAuth, one time).\n' "$step"; step=$((step+1))
  fi
  if [ "$ENABLE_RTK" = true ]; then
    printf '  %d. Restart Claude Code once so the rtk hook takes effect.\n' "$step"; step=$((step+1))
  fi
  if [ "$ENABLE_SEMBLE" = true ]; then
    printf '  %d. Run /agents once to load the `semble-search` subagent.\n' "$step"; step=$((step+1))
  fi

  if [ "$ENABLE_SEMBLE" = true ]; then
    cat <<'EOF'

Code search:
  semble is the default. Agents use it via MCP for "where is X implemented"
  lookups; grep/find stay for exact-string and exhaustive scans.
EOF
  fi

  if [ "$ENABLE_GRAPHIFY" = true ]; then
    cat <<'EOF'

Knowledge graph (graphify):
  Build each repo's graph once — it's AST-only, no API key, no LLM cost:
    cd <repo> && graphify update .
  Then agents query it instead of grepping (graphify query/path/explain), and
  the shared git hooks rebuild it after every commit, checkout and merge.
EOF
  fi

  cat <<EOF

Workflow skills available inside Claude Code:
  /start-task $TICKET_PREFIX-123    fetch ticket, assign it, sync $DEFAULT_BRANCH
  /raise-pr                 branch, commit, push and open PRs for all affected repos
  /code-review              review a PR, branch, or local diff
  /write-doc                write design docs / ADRs / runbooks into knowledge/
  /create-ticket            file well-formed epics, stories, tasks, bugs

VS Code:
  Open $PROJECT_NAME.code-workspace to work across all repos in one window
  (per-repo source control included).
EOF
}

main() {
  check_basic_prereqs
  load_config
  personalize_workspace
  check_uv_prereqs
  clone_repos
  exclude_repos
  install_git_hooks
  sync_mcp_config
  install_semble
  install_rtk
  install_graphify
  generate_workspace
  final_checks
  print_next_steps
}

main "$@"
