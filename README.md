<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/devrig-logo-dark.png">
  <img src="assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**One rig for all your repos — an AI-ready, multi-repo dev workspace template.**

[![Use this template](https://img.shields.io/badge/Use%20this-template-22D3EE?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](CONTRIBUTING.md)

**English** · [简体中文](docs/README.zh-CN.md) · [Español](docs/README.es.md) · [हिन्दी](docs/README.hi.md) · [Português](docs/README.pt-BR.md) · [日本語](docs/README.ja.md) · [Français](docs/README.fr.md) · [한국어](docs/README.ko.md) · [සිංහල](docs/README.si.md)

</div>

---

## What is devrig?

devrig is a *meta-repo*: one folder that contains every repo of your project
**plus** the AI tooling used to develop across them. This repo versions only
the tooling — your project repos are cloned side-by-side by `setup.sh` and
stay untracked. Everything is configured from a single **`.setup`** file.

| | What you get |
|---|---|
| 🧠 | **AI workflow skills** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (agent-agnostic in `.agents/skills/`, symlinked for Claude Code, opencode configured too) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — semantic code search agents use via MCP instead of grep-and-read |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — token-optimizing command proxy for Claude Code |
| 🎫 | **Linear MCP** — issue tracking wired into the skills |
| 🛡️ | **Protected-branch git hooks** — no accidental commits/pushes to your default branch, in any repo |
| 📚 | **`knowledge/`** — a markdown knowledge base skeleton (architecture, ADRs, design docs, runbooks) the AI tooling indexes and writes into |
| 🖥️ | **Generated VS Code multi-root workspace** — every repo in one window |

## Quick start

1. Click **[Use this template](https://github.com/lakpriya1s/devrig/generate)** to create `your-org/your-project-workspace`.
2. Clone it and edit **`.setup`** — project name, GitHub org, repo list, ticket prefix, default branch, feature toggles.
3. Run:

   ```bash
   ./setup.sh
   ```

4. Run `claude` from this folder and start working.

Then, inside Claude Code: run `/mcp` and authenticate the **linear** server
(one-time OAuth; **semble** needs no auth), and restart Claude Code once so
the rtk hook takes effect.

## 🤖 Kickstart with your AI agent

Just created a workspace from this template? Paste this into your AI coding
agent (Claude Code, Cursor, opencode, …) and let it finish the setup with you:

```text
I just created a workspace from the devrig template
(https://github.com/lakpriya1s/devrig). Help me set it up:

1. Read README.md, AGENTS.md, and .setup to understand the workspace.
2. Ask me for my project name, GitHub org, repo list, ticket prefix, and
   default branch, then fill .setup with them.
3. Run ./setup.sh and help me fix anything it flags.
4. Fill the Systems table in AGENTS.md — one row per repo (what it is, stack).
5. For each repo, write a review reference in
   .agents/skills/code-review/references/<repo>.md and a doc reference in
   .agents/skills/write-doc/references/<repo>.md (copy the _example-repo.md
   scaffolds and verify every fact in the code).
6. Verify the create-ticket conventions table against my Linear workspace.
7. Commit the personalization on a task branch and open a PR.
```

## What setup.sh does

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

## Customization checklist

After the first `setup.sh` run, make your personalization commit:

- [ ] `.setup` — your real values (setup.sh refuses to run with the shipped
      example values).
- [ ] `AGENTS.md` — fill the **Systems** table (one row per repo: what it is,
      stack) and the **Testing** section. This is the source of truth every
      skill reads.
- [ ] `.agents/skills/code-review/references/` and
      `.agents/skills/write-doc/references/` — one reference file per repo
      (copy `_example-repo.md`). The skills work without them but get much
      sharper with them.
- [ ] `.agents/skills/create-ticket/SKILL.md` — verify the "Conventions"
      table against your Linear workspace (teams, projects, labels).
- [ ] Delete or adjust anything a toggle disabled (e.g. remove the linear
      notes from `CLAUDE.md` if you don't use Linear).

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

## Contributing

devrig gets better with every team that rigs it up. Bug reports, new generic
skills, better docs, and **README translations** are all very welcome — see
[CONTRIBUTING.md](CONTRIBUTING.md). If devrig saved your team setup time,
a ⭐ helps others find it.

## License & citation

Released under the [MIT License](LICENSE).

If you use devrig in your work or writing, a citation is appreciated — GitHub's
**"Cite this repository"** button (powered by [`CITATION.cff`](CITATION.cff))
has the details, or:

> Senevirathna, L. (2026). *devrig: a multi-repo AI dev workspace template.*
> https://github.com/lakpriya1s/devrig

<div align="center">
<sub>Built from a production multi-repo workspace · <img src="assets/devrig-icon.png" width="14" alt=""> devrig</sub>
</div>
