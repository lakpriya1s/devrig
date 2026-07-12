#!/usr/bin/env bash
#
# devrig workspace setup.
# Clones your project repos (from .setup) and installs the AI tooling
# (semble, rtk, MCP config, protected-branch git hooks).
# Idempotent — safe to re-run at any time to update everything.
#
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# --- 1. Configuration ---------------------------------------------------------

load_config() {
  [ -f "$WORKSPACE_DIR/.setup" ] || fail ".setup not found. This file defines your project (name, org, repos). It ships with the template — restore it from git."
  # shellcheck source=.setup
  . "$WORKSPACE_DIR/.setup"

  : "${PROJECT_NAME:?PROJECT_NAME missing from .setup}"
  : "${GITHUB_ORG:?GITHUB_ORG missing from .setup}"
  : "${TICKET_PREFIX:?TICKET_PREFIX missing from .setup}"
  : "${DEFAULT_BRANCH:?DEFAULT_BRANCH missing from .setup}"
  : "${ENABLE_SEMBLE:=true}" "${ENABLE_RTK:=true}" "${ENABLE_LINEAR_MCP:=true}" "${ENABLE_GIT_HOOKS:=true}"

  if [ "$PROJECT_NAME" = "acme" ] && [ "$GITHUB_ORG" = "AcmeInc" ]; then
    fail "'.setup' still contains the shipped example values. Edit .setup with your project's values, then re-run ./setup.sh"
  fi
}

check_prereqs() {
  command -v git >/dev/null 2>&1 || fail "git is required. On macOS run: xcode-select --install"
  command -v gh >/dev/null 2>&1 || fail "GitHub CLI (gh) is required. Install: brew install gh"
  gh auth status >/dev/null 2>&1 || fail "gh is not authenticated. Run: gh auth login"

  if [ "$ENABLE_SEMBLE" = true ] && ! command -v uv >/dev/null 2>&1; then
    info "Installing uv (needed for semble)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    command -v uv >/dev/null 2>&1 || fail "uv installed but not on PATH. Open a new shell and re-run ./setup.sh"
  fi
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
# core.hooksPath.

install_git_hooks() {
  [ "$ENABLE_GIT_HOOKS" = true ] || { info "Git hooks disabled in .setup — skipping."; return 0; }
  info "Installing protected-branch git hooks..."
  chmod +x "$WORKSPACE_DIR/git-hooks/pre-commit" "$WORKSPACE_DIR/git-hooks/pre-push"
  git -C "$WORKSPACE_DIR" config core.hooksPath "$WORKSPACE_DIR/git-hooks"
  for repo in ${REPOS[@]+"${REPOS[@]}"}; do
    dir="$WORKSPACE_DIR/$repo"
    [ -d "$dir/.git" ] && git -C "$dir" config core.hooksPath "$WORKSPACE_DIR/git-hooks"
  done
}

# --- 4. MCP configuration ------------------------------------------------------
# Converges .mcp.json and opencode.json to the .setup toggles: the linear and
# semble entries are added/removed to match, while any servers you added by
# hand are preserved. Also generates .claude/settings.local.json (gitignored)
# if it doesn't exist yet.

sync_mcp_config() {
  info "Syncing MCP config to .setup toggles..."
  python3 - "$WORKSPACE_DIR" "$ENABLE_LINEAR_MCP" "$ENABLE_SEMBLE" <<'PY'
import json, os, sys

root, linear_on, semble_on = sys.argv[1], sys.argv[2] == "true", sys.argv[3] == "true"

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
if semble_on:
    oc_mcp.setdefault("semble", {"type": "local", "command": ["uvx", "--from", "semble[mcp]", "semble"], "enabled": True})
else:
    oc_mcp.pop("semble", None)
save(oc_path, oc)

# .claude/settings.local.json — generated once, then left alone
local_path = os.path.join(root, ".claude", "settings.local.json")
if not os.path.exists(local_path):
    enabled = [name for name, on in (("linear", linear_on), ("semble", semble_on)) if on]
    os.makedirs(os.path.dirname(local_path), exist_ok=True)
    save(local_path, {"enableAllProjectMcpServers": True, "enabledMcpjsonServers": enabled})
    print("  generated .claude/settings.local.json")
PY
}

# --- 5. semble (semantic code search, used by agents via MCP) ------------------

install_semble() {
  [ "$ENABLE_SEMBLE" = true ] || { info "semble disabled in .setup — skipping."; return 0; }
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
  [ "$ENABLE_RTK" = true ] || { info "rtk disabled in .setup — skipping."; return 0; }
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

# --- 7. VS Code multi-root workspace -------------------------------------------
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

# --- 8. Done --------------------------------------------------------------------

final_checks() {
  if grep -q "TODO: fill in" "$WORKSPACE_DIR/AGENTS.md" 2>/dev/null; then
    warn "AGENTS.md still has its 'TODO: fill in' systems table — fill it in so agents know what each repo is."
  fi
}

print_next_steps() {
  printf '\n✅ Workspace ready.\n\nNext steps:\n'
  step=1
  printf '  %d. cd into this folder and run `claude`.\n' "$step"; step=$((step+1))
  if [ "$ENABLE_LINEAR_MCP" = true ]; then
    printf '  %d. Run /mcp and authenticate the "linear" server (OAuth, one time).\n' "$step"; step=$((step+1))
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
  load_config
  check_prereqs
  clone_repos
  exclude_repos
  install_git_hooks
  sync_mcp_config
  install_semble
  install_rtk
  generate_workspace
  final_checks
  print_next_steps
}

main "$@"
