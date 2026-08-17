# Workspace guide for agents

This folder is a multi-repo AI dev workspace. The project repos are cloned
side-by-side here by `setup.sh`; this repo versions only the workspace tooling.
Project values (name, org, repo list, ticket prefix, default branch) live in
[`devrig.toml`](devrig.toml) — read them from there, never assume.

## Systems

<!-- TODO: fill in — one row per repo in your devrig.toml repos list.
     Delete the example rows below once you've added your own. "Depends on"
     lists other systems this one calls or shares data with — an agent
     changing a system should check what depends on it before assuming a
     change is isolated. -->

| System | Repo | Purpose | Stack | Depends on |
|---|---|---|---|---|
| _api_ | _`example-api/`_ | _Backend API_ | _e.g. NestJS, PostgreSQL_ | — |
| _web_ | _`example-web/`_ | _Web frontend_ | _e.g. Next.js, Tailwind_ | _api_ |

An agent should never have to guess which repo owns something, what stack it
uses, what it depends on, how to test it, or what "done" means for it — that's
what this file, the per-repo `AGENTS.md`, and [`POLICY.md`](POLICY.md) are for.

Each system repo should carry its own `AGENTS.md` with stack/structure/gotcha
details — read the relevant one(s) before working in that repo. A repo's
`CLAUDE.md` should be a thin stub that imports its `AGENTS.md`.

## Branch rules

All repos use the default branch named in `devrig.toml` (`DEFAULT_BRANCH`).
**Never commit directly to it** — the hooks in `git-hooks/` enforce this
(along with `main`/`master`) in every repo once `setup.sh` has run.
Task branches follow `<ticket-id>-<type>-<short-title>`, all lowercase
kebab-case (e.g. `ac-123-feature-user-invites`).

## Commands

<!-- TODO: fill in per system — install, dev, test, lint, typecheck, build.
     Agents should never have to guess these. Keep in sync with each repo's
     own AGENTS.md, which is the source of truth for repo-specific detail. -->

| System | Install | Test | Lint | Typecheck | Build |
|---|---|---|---|---|---|
| _api_ | | | | | |
| _web_ | | | | | |

## Testing

<!-- TODO: document how changes are validated per repo — test suites,
     commands, what runs in CI vs. locally. -->

## Definition of Done

See [`POLICY.md`](POLICY.md#definition-of-done) — every task follows it, and
`/verify-change` checks it before a PR is raised.

## Retrieval policy

Before changing code or answering an architectural question:

1. Read this file (workspace `AGENTS.md`).
2. Read the target repo's own `AGENTS.md`.
3. Identify which systems are affected (the table above).
4. Check [`knowledge/index.md`](knowledge/index.md) for relevant docs by type/status.
5. Search Semble (`mcp__semble__search`) for the task's terminology, in the
   affected repos and with `--content docs` against `knowledge/`.
6. Search `knowledge/decisions/` for accepted ADRs touching the affected systems.
7. Search `knowledge/design/` for active (`draft`/`proposed`) design docs on the same topic.
8. Inspect only the source files retrieval actually surfaced as relevant —
   don't recursively read a whole repo unless retrieval failed to find
   anything and you have to fall back to browsing.
9. When answering or handing off a plan, cite the sources used (doc paths,
   `repo/path:symbol`) — see `POLICY.md`'s audit section.

Prefer `authority: canonical` docs over `supporting`, `generated`, or
`historical` ones when they conflict (see `knowledge/README.md`). Never treat
a `deprecated`, `superseded`, or `archived` doc as current guidance.

## Context efficiency

- Search before recursively reading — grep-and-read a whole repo is a last
  resort, not a first move.
- Read only the files retrieval actually surfaced as relevant.
- Prefer narrow ranges on very large files instead of reading the whole thing.
- Don't reread a file you haven't changed since you last read it this session.
- Summarize large logs/command output rather than pasting it verbatim into
  later reasoning.
- Reuse previously gathered task context — check `.ai/context/<TICKET-ID>.json`
  (written by `/start-task`) before re-running retrieval from scratch.
- Avoid loading generated/vendor files (`graphify-out/`, build output,
  `node_modules/`, lockfiles) unless specifically debugging them.

If the `rtk` toggle in `devrig.toml` is on, `rtk gain` shows measured token
savings from this discipline — see the root `README.md`'s rtk section for setup/usage.

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

## Risk & agent permissions

<!-- TODO (Phase 2): backfill with .ai/policies.yaml and .ai/risk-levels.yaml
     once those exist. Until then, treat anything touching auth, billing,
     schemas, or production infra as high-risk by default and confirm with
     the user before proceeding, per POLICY.md. -->

See [`POLICY.md`](POLICY.md) for what requires human approval and what's
forbidden outright. When in doubt about risk, ask rather than assume.

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
