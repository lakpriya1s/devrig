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
