# devrig

A reusable **multi-repo AI dev workspace template**. One folder that contains
every repo of your project plus the AI tooling used to develop across them:

- **Claude Code workflow skills** — `/start-task`, `/raise-pr`, `/code-review`,
  `/write-doc`, `/create-ticket` (agent-agnostic, stored in `.agents/skills/`
  and symlinked for Claude Code; opencode is configured too)
- **[semble](https://github.com/MinishLab/semble)** — semantic code search
  agents use via MCP instead of grep-and-read
- **[rtk](https://github.com/rtk-ai/rtk)** — token-optimizing command proxy
  for Claude Code
- **Linear MCP** — issue tracking wired into the skills
- **Protected-branch git hooks** — no accidental commits/pushes to your
  default branch, in any repo
- **`knowledge/`** — a markdown knowledge base skeleton (architecture docs,
  ADRs, design docs, runbooks) that the AI tooling indexes and writes into
- **Generated VS Code multi-root workspace** — every repo in one window

It's a *meta-repo*: this repo versions only the tooling. Your project repos are
cloned side-by-side by `setup.sh` and stay untracked here.

## Quick start

1. Click **Use this template** on GitHub (or fork/clone) to create
   `your-org/your-project-workspace`.
2. Clone it and edit **`.setup`** — project name, GitHub org, repo list,
   ticket prefix, default branch, feature toggles.
3. Run:

   ```bash
   ./setup.sh
   ```

4. Run `claude` from this folder and start working.

`setup.sh` is idempotent — re-run it anytime to update every repo and tool. It:

1. Checks prerequisites (`git`, `gh` authenticated; installs `uv` if semble is enabled).
2. Clones every repo in `REPOS` side-by-side (or fast-forwards clean
   default-branch checkouts), and excludes them from this repo's git status
   via `.git/info/exclude`.
3. Installs the protected-branch git hooks into this repo and every cloned repo.
4. Converges `.mcp.json` / `opencode.json` to your `.setup` toggles (hand-added
   MCP servers are preserved) and generates `.claude/settings.local.json`.
5. Installs semble and warms a search index per repo.
6. Installs rtk and registers its Claude Code hook.
7. Generates `<project>.code-workspace` for VS Code (skipped if you already
   have one, so it's safe to customize and commit).

Then, inside Claude Code:

1. Run `/mcp` and authenticate the **linear** server (one-time OAuth).
   The **semble** server needs no auth.
2. Restart Claude Code once so the rtk hook takes effect.

## Customization checklist

After the first `setup.sh` run, make your personalization commit:

- [ ] `.setup` — your real values (setup.sh refuses to run with the shipped
      example values).
- [ ] `AGENTS.md` — fill the **Systems** table (one row per repo: what it is,
      stack) and the **Testing** section. This is the source of truth every
      skill reads.
- [ ] `.agents/skills/code-review/references/` and
      `.agents/skills/write-doc/references/` — write one reference file per
      repo (copy `_example-repo.md`). The skills work without them but get
      much sharper with them.
- [ ] `.agents/skills/create-ticket/SKILL.md` — verify the "Conventions"
      table against your Linear workspace (teams, projects, labels).
- [ ] Delete or adjust anything a toggle disabled (e.g. remove the linear
      notes from `CLAUDE.md` if you don't use Linear).

## Open in VS Code

```bash
code <your-project>.code-workspace
```

The generated multi-root workspace shows every repo plus the workspace meta
files in one window — the Source Control panel tracks all repos at once.

## Adding a skill

See [`.agents/skills/_template/README.md`](.agents/skills/_template/README.md).
Short version: create `.agents/skills/<name>/SKILL.md`, symlink it into
`.claude/skills/`, and list it in `CLAUDE.md`.

## Knowledge base

New design docs, architecture notes, ADRs, and runbooks go in
[`knowledge/`](knowledge/) as markdown via PR — semble indexes it, so agents
find design context the same way they find code. When it outgrows this repo,
push it as a separate `<project>-knowledge` repo, add that to `REPOS` in
`.setup`, delete the folder here, and update the pointer in `AGENTS.md`.

## Layout

| Path | What it is |
|---|---|
| `.setup` | Your project config — the one file every tool reads |
| `setup.sh` | Idempotent bootstrap/update script |
| `AGENTS.md` | Agent-agnostic source of truth (systems, branch rules, conventions) |
| `CLAUDE.md` | Claude Code specifics; imports `AGENTS.md` |
| `.agents/skills/` | Canonical workflow skills (agent-agnostic) |
| `.claude/` | Claude Code settings, agents, skill symlinks |
| `.opencode/` | opencode agents and plugin config |
| `.mcp.json` / `opencode.json` | MCP servers (linear, semble) |
| `git-hooks/` | Protected-branch pre-commit / pre-push hooks |
| `knowledge/` | Markdown knowledge base (architecture, decisions, design, runbooks, product, releases) |
| `<repo>/` (untracked) | Your project repos, cloned by `setup.sh` |

## Troubleshooting

- **`semble` or `uv` not found after setup** — open a new shell (PATH was
  updated) and re-run `./setup.sh`.
- **Linear tools missing in Claude** — run `/mcp` and complete the OAuth flow
  for the linear server.
- **rtk not kicking in** — restart Claude Code; verify with `rtk gain` that
  commands are being proxied.
- **A repo won't update** — `setup.sh` never touches a repo that has local
  changes or is on a task branch; it only fast-forwards clean default-branch
  checkouts.
- **setup.sh says "edit .setup first"** — it refuses to run while `.setup`
  still contains the shipped example values (`PROJECT_NAME="acme"`).
