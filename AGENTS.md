# Workspace guide for agents

This folder is a multi-repo AI dev workspace. The project repos are cloned
side-by-side here by `setup.sh`; this repo versions only the workspace tooling.
Project values (name, org, repo list, ticket prefix, default branch) live in
[`devrig.toml`](devrig.toml) — read them from there, never assume.

## Systems

<!-- TODO: fill in — one row per repo in your devrig.toml repos list.
     Delete the example rows below once you've added your own. -->

| Repo | What it is | Stack |
|---|---|---|
| _`example-api/`_ | _Backend API_ | _e.g. NestJS, PostgreSQL_ |
| _`example-web/`_ | _Web frontend_ | _e.g. Next.js, Tailwind_ |

Each system repo should carry its own `AGENTS.md` with stack/structure/gotcha
details — read the relevant one(s) before working in that repo. A repo's
`CLAUDE.md` should be a thin stub that imports its `AGENTS.md`.

## Branch rules

All repos use the default branch named in `devrig.toml` (`DEFAULT_BRANCH`).
**Never commit directly to it** — the hooks in `git-hooks/` enforce this
(along with `main`/`master`) in every repo once `setup.sh` has run.
Task branches follow `<ticket-id>-<type>-<short-title>`, all lowercase
kebab-case (e.g. `ac-123-feature-user-invites`).

## Testing

<!-- TODO: document how changes are validated per repo — test suites,
     commands, what runs in CI vs. locally. -->

## Knowledge graph (graphify)

Enabled by the `graphify` toggle in `devrig.toml`. There is no single
merged graph — one graph per git repo, each in its own `graphify-out/`
(hubs, community structure, cross-file relationships): one per cloned project
repo, plus one for this workspace repo covering `knowledge/` and the tooling.
The cloned repos are excluded from the workspace graph, so the scopes never
overlap.

Rules:

- For a codebase question about a specific repo, `cd` into that repo first, then
  use `graphify query "<question>"` when `<repo>/graphify-out/graph.json` exists.
  Use `graphify path "<A>" "<B>"` for how two things connect and
  `graphify explain "<concept>"` for one node and its neighbours. These return a
  scoped subgraph — usually far smaller than `GRAPH_REPORT.md` or a grep dump.
- If `<repo>/graphify-out/wiki/index.md` exists, use it for broad navigation
  instead of browsing raw source.
- Read `<repo>/graphify-out/GRAPH_REPORT.md` only for a broad architecture review,
  or when query/path/explain don't surface enough context.
- No graph yet in a repo? Build it with `graphify update .` from that repo root
  (AST-only, no API key). The git hooks in `git-hooks/` keep it fresh after
  commits, checkouts and merges — you don't need to rebuild by hand after
  committing.
- The full skill lives in `.agents/skills/graphify/SKILL.md` (installed by
  `setup.sh` from the graphify CLI, so it's gitignored, not committed).

## Knowledge base

Design docs, architecture notes, ADRs, and runbooks live in [`knowledge/`](knowledge/)
as markdown (see its README for structure and naming). Skills like `/write-doc`
target whatever knowledge base is named here — if you later split it into a
separate `<project>-knowledge` repo, update this section.

## Agent Skills

Workspace skills live in `.agents/skills/<name>/SKILL.md` so any agent tool can
use them, not just Claude Code. The `.claude/skills/<name>` entries are symlinks
for Claude Code compatibility. When adding or updating a skill, edit
`.agents/skills` and keep the matching Claude symlink in place
(`ln -s ../../.agents/skills/<name> .claude/skills/<name>`).
See `.agents/skills/_template/` for a scaffold and instructions.
