# Knowledge Base

Design documents, architecture notes, decisions, and runbooks for this
project. Everything here is markdown so it is versioned, reviewable via PRs,
and semantically searchable by AI tooling (semble indexes this folder as part
of the workspace).

## Structure

| Folder | Contents |
|---|---|
| `architecture/` | System-level architecture: how the repos fit together, data flow, infra |
| `design/` | Feature design documents (one file per feature/epic) |
| `decisions/` | Architecture Decision Records (ADRs) — see the template |
| `runbooks/` | Operational guides: deploys, incident response, environment setup |
| `product/` | Product context: personas, feature specs, terminology, UX audits |
| `releases/` | Release notes and store submission notes |

## Conventions

- New design docs and ADRs land **here**, as markdown, via PR on a task
  branch — never directly on the default branch.
- Name design docs `YYYY-MM-<short-title>.md`; ADRs are numbered
  (`0001-<short-title>.md`) — copy `decisions/0000-template.md`.
- The `/write-doc` skill knows these conventions and the templates — prefer
  it over writing docs by hand.
- Legacy documents in external systems (Google Docs, Notion, ...): link them
  from the relevant markdown file rather than re-transcribing.

## When this outgrows the meta repo

For small teams, keeping the knowledge base inside the workspace repo is
simplest. When you want independent review flow or reuse across workspaces,
promote it:

1. Push this folder as its own repo: `<project>-knowledge`.
2. Add `<project>-knowledge` to `REPOS` in `.setup` and re-run `./setup.sh`.
3. Delete this folder from the workspace repo.
4. Update the "Knowledge base" section in `AGENTS.md` — the skills target
   whatever is named there, so nothing else changes.
