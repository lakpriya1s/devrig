# Knowledge Base

Design documents, architecture notes, decisions, and runbooks for this
project. Everything here is markdown so it is versioned, reviewable via PRs,
and semantically searchable by AI tooling (semble indexes this folder as part
of the workspace).

## Structure

| Folder / file | Contents |
|---|---|
| `index.md` | Generated entry point — start here instead of searching blindly. See [Index](#index). |
| `architecture/` | System-level architecture: how the repos fit together, data flow, infra |
| `design/` | Feature design documents (one file per feature/epic) |
| `decisions/` | Architecture Decision Records (ADRs) — see the template |
| `runbooks/` | Operational guides: deploys, incident response, environment setup |
| `product/` | Product context: personas, feature specs, terminology, UX audits |
| `releases/` | Release notes and store submission notes |
| `handoffs/` | Working state for an interrupted task — see [Handoffs](#handoffs) |
| `generated/` | Views generated from `.ai/*.yaml` (system map, ownership map) — `authority: generated`, never hand-edited |

## Index

`index.md` groups every doc by type and status (Architecture, Active Designs,
Accepted Decisions, Operational Runbooks, Product Knowledge, Recently
Reviewed, Deprecated/Superseded/Archived), generated from frontmatter. It's
**generated, not hand-edited** — run this after adding, removing, or changing
the status of any doc:

```bash
node scripts/build-knowledge-index.mjs
```

`/write-doc` and `/capture-learning` run this automatically as their last
step. Agents doing broad "what do we know about X" retrieval should check
`index.md` before searching, per the retrieval policy in `AGENTS.md`.

Similarly, `generated/`'s contents come from `scripts/generate-architecture-views.mjs`
— run it after editing `.ai/systems.yaml` or `.ai/ownership.yaml`, then
regenerate `index.md` since the generated docs are new inputs to it.

## Handoffs

`handoffs/` holds working state for a task interrupted mid-flight — enough
that a different agent (or the same one, in a fresh session) can pick it up
without rediscovering everything. It is **not permanent knowledge**: once the
task finishes, delete the handoff or set its `status: archived`. A handoff
that's still `status: accepted` signals unfinished work — `knowledge/index.md`
surfaces these so they don't get silently forgotten.

## Conventions

- New design docs and ADRs land **here**, as markdown, via PR on a task
  branch — never directly on the default branch.
- Name design docs `YYYY-MM-<short-title>.md`; ADRs are numbered
  (`0001-<short-title>.md`) — copy `decisions/0000-template.md`.
- The `/write-doc` skill knows these conventions and the templates — prefer
  it over writing docs by hand.
- Legacy documents in external systems (Google Docs, Notion, ...): link them
  from the relevant markdown file rather than re-transcribing.
- Every doc carries YAML frontmatter — see [Frontmatter](#frontmatter) below.
  `/write-doc`'s templates already include it; fill in every field.

## Frontmatter

Every file in `knowledge/` (except this README, `index.md`, and the ADR
template itself) opens with frontmatter agents can parse without reading the
whole doc:

```yaml
---
id: <kebab-slug>                 # decisions/ use adr-NNNN; others use the filename stem
title: <Title>
type: architecture | design | decision | runbook | product | release | handoff
status: draft | proposed | accepted | deprecated | superseded | archived
authority: canonical | supporting | generated | historical
systems: [<system-name>, ...]    # names from AGENTS.md's Systems table; [] if workspace-wide
owners: [<team-or-handle>, ...]
authorship: human | ai-assisted | generated
human_reviewed: true | false
created: YYYY-MM-DD
last_reviewed: YYYY-MM-DD
tags: [<tag>, ...]                # optional
related: [<doc-id>, ...]           # optional
superseded_by: <doc-id>            # optional — only when status: superseded
review_interval: 180d              # optional — how often this doc should be re-checked
---
```

`review_interval` (optional, e.g. `90d`, `180d`, `365d`) drives the freshness
warning in `scripts/detect-doc-drift.mjs`: if `last_reviewed` plus the
interval is in the past, the doc surfaces as stale. Add it to anything whose
accuracy decays — architecture, runbooks, product behavior — skip it on docs
that don't go stale the same way (most ADRs, once accepted, don't need one).

### Status — is it current?

| Status | Meaning |
|---|---|
| `draft` | Being written; not yet ready for review |
| `proposed` | Ready for review; not yet decided/adopted |
| `accepted` | Current and in effect |
| `deprecated` | Still true today, but on its way out — don't build on it |
| `superseded` | Replaced by another doc — see `superseded_by` |
| `archived` | Kept for history only; not applicable to current work |

Agents: prefer `accepted` docs over anything else. Never treat `deprecated`,
`superseded`, or `archived` docs as current guidance — read them for
historical context only, and say so if you cite one.

### Authority — how much to trust it

| Authority | Meaning |
|---|---|
| `canonical` | The source of truth for its topic. Requires `human_reviewed: true`. |
| `supporting` | Useful and believed accurate, but not the final word. |
| `generated` | Machine-derived (e.g. an as-built doc from code reading); treat as a lead to verify, not a citation. |
| `historical` | Was true once; kept for context, not for current decisions. |

Preference order when sources conflict: `canonical` > `supporting` >
`generated` > `historical`. An agent that finds a `generated` doc contradicting
a `canonical` one should trust the `canonical` one and flag the discrepancy
rather than silently picking either.

### Authorship

`authorship: ai-assisted` + `human_reviewed: false` is the default for
anything an agent writes. Flip `human_reviewed: true` only when a person
actually read and confirmed the content — approving a PR without comment
doesn't count. A doc can never be `authority: canonical` while
`human_reviewed: false`.

## When this outgrows the meta repo

For small teams, keeping the knowledge base inside the workspace repo is
simplest. When you want independent review flow or reuse across workspaces,
promote it:

1. Push this folder as its own repo: `<project>-knowledge`.
2. Add `<project>-knowledge` to `repos` in `devrig.toml` and re-run `./setup.sh`.
3. Delete this folder from the workspace repo.
4. Update the "Knowledge base" section in `AGENTS.md` — the skills target
   whatever is named there, so nothing else changes.
