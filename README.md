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
| 🎫 | **Issue tracker MCP** — Linear, Jira, or bring your own; picked interactively by `setup.sh` |
| 🛡️ | **Protected-branch git hooks** — no accidental commits/pushes to your default branch, in any repo |
| 📚 | **`knowledge/`** — a markdown knowledge base skeleton (architecture, ADRs, design docs, runbooks) the AI tooling indexes and writes into |
| 🖥️ | **Generated VS Code multi-root workspace** — every repo in one window |

## Quick start

1. Click **[Use this template](https://github.com/lakpriya1s/devrig/generate)** to create `your-org/your-project-workspace`.
2. Clone it and run:

   ```bash
   ./setup.sh
   ```

   The first run notices `.setup` still has the shipped example values and
   walks you through configuring it interactively: project name, GitHub org,
   the repos to clone (paste several at once, space- or comma-separated),
   your issue tracker (**Linear**, **Jira**, or **other** — pick one from a
   menu), ticket prefix, default branch, and feature toggles. It then writes
   `.setup` for you. Prefer to hand-edit instead? Fill in `.setup` yourself
   before running the script and it'll skip the prompts.
3. Run `claude` from this folder and start working.

Then, inside Claude Code: run `/mcp` and authenticate the tracker server that
was configured (**linear** or **atlassian**; one-time OAuth — **semble**
needs no auth), and restart Claude Code once so the rtk hook takes effect.

## 🤖 Kickstart with your AI agent

Just created a workspace from this template? Paste this into your AI coding
agent (Claude Code, Cursor, opencode, …) and let it finish the setup with you:

```text
I just created a workspace from the devrig template
(https://github.com/lakpriya1s/devrig). Help me set it up:

1. Read README.md, AGENTS.md, and .setup to understand the workspace.
2. Run ./setup.sh with me — it will interactively ask for my project name,
   GitHub org, repo list (I may paste several at once), issue tracker
   (Linear, Jira, or other), ticket prefix, default branch, and feature
   toggles, then write .setup itself. Relay its prompts to me and fill in
   my answers.
3. Help me fix anything ./setup.sh flags.
4. Fill the Systems table in AGENTS.md — one row per repo (what it is, stack).
5. For each repo, write a review reference in
   .agents/skills/code-review/references/<repo>.md and a doc reference in
   .agents/skills/write-doc/references/<repo>.md (copy the _example-repo.md
   scaffolds and verify every fact in the code).
6. If I picked Linear, verify the create-ticket conventions table against my
   Linear workspace. If I picked Jira or another tracker, help me adapt
   /start-task, /raise-pr, and /create-ticket's MCP calls to it instead.
7. Commit the personalization on a task branch and open a PR.
```

## What setup.sh does

`setup.sh` is idempotent — re-run it anytime to update every repo and tool. It:

0. **First run only**: if `.setup` still has the shipped example values,
   prompts for all of the values below interactively and writes `.setup`.
1. Checks prerequisites (`git`, `gh` authenticated; installs `uv` if semble is enabled).
2. Clones every repo in `REPOS` side-by-side (or fast-forwards clean
   default-branch checkouts), and excludes them from this repo's git status
   via `.git/info/exclude`.
3. Installs the protected-branch git hooks into this repo and every cloned repo.
4. Converges `.mcp.json` / `opencode.json` to your `.setup` toggles — adding
   the `linear` or `atlassian` (Jira) server per `ISSUE_TRACKER`, or neither
   if you picked "other" — while preserving any MCP servers you added by
   hand, and generates `.claude/settings.local.json`.
5. Installs semble and warms a search index per repo.
6. Installs rtk and registers its Claude Code hook.
7. Generates `<project>.code-workspace` for VS Code (skipped if you already
   have one, so it's safe to customize and commit).

## Customization checklist

After the first `setup.sh` run, make your personalization commit:

- [ ] `.setup` — `setup.sh` prompts for these interactively on first run (or
      hand-edit the file before running it, and it'll skip the prompts). To
      change values later — switch tracker, add a repo — edit `.setup`
      directly and re-run `./setup.sh`.
- [ ] `AGENTS.md` — fill the **Systems** table (one row per repo: what it is,
      stack) and the **Testing** section. This is the source of truth every
      skill reads.
- [ ] `.agents/skills/code-review/references/` and
      `.agents/skills/write-doc/references/` — one reference file per repo
      (copy `_example-repo.md`). The skills work without them but get much
      sharper with them.
- [ ] If `ISSUE_TRACKER` is `linear`: verify `.agents/skills/create-ticket/SKILL.md`'s
      "Conventions" table against your Linear workspace (teams, projects, labels).
      If it's `jira` or `other`: adapt `/start-task`, `/raise-pr`, and
      `/create-ticket`'s `mcp__linear__*` calls to your tracker's MCP tool names
      (each skill flags this at the top).
- [ ] Delete or adjust anything a toggle disabled (e.g. remove the semble
      notes from `CLAUDE.md` if you don't use it).

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
| `.mcp.json` / `opencode.json` | MCP servers (issue tracker, semble) |
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
- **Tracker tools missing in Claude** — run `/mcp` and complete the OAuth flow
  for the `linear` or `atlassian` server.
- **rtk not kicking in** — restart Claude Code; verify with `rtk gain` that
  commands are being proxied.
- **A repo won't update** — `setup.sh` never touches a repo that has local
  changes or is on a task branch; it only fast-forwards clean default-branch
  checkouts.
- **setup.sh isn't prompting me, it just fails with "edit .setup first"** —
  it only prompts when attached to an interactive terminal; running it from
  a script or CI falls back to requiring `.setup` to already be filled in.
- **Picked Jira or "other"** — the `atlassian` MCP server (Jira) is wired up
  automatically, but `/start-task`, `/raise-pr`, and `/create-ticket` still
  call Linear's MCP tool names — `setup.sh` will warn you about this at the
  end of every run until you adapt those skills.

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
