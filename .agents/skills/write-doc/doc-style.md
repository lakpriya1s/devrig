# Doc Style — knowledge base

Apply this checklist to every doc drafted for the knowledge base.

## Format

- Every doc opens with **YAML frontmatter** (schema below), then a `#` H1 title, then optionally a short `>` blockquote framing line if the frontmatter alone doesn't convey the doc's provenance (e.g. `> Reverse-engineered from code — verify before treating as spec.`). Don't restate `status`/`created` in the blockquote — that's what the frontmatter is for.
- Markdown tables for any mapping (repo → role, endpoint → consumer, plan → limits).
- **Diagrams are Mermaid fenced blocks** — GitHub renders them natively; never image files:
  - `sequenceDiagram` for cross-repo/message flows (client → service → storage → push)
  - `flowchart TD` for logic/state
  - `erDiagram` for non-trivial data models
- Delete the template's HTML guidance comments after filling; drop optional sections that are genuinely empty rather than writing "N/A".

## Frontmatter schema

Every field is required unless marked optional. See `knowledge/README.md` for the full definitions of status/authority/authorship.

```yaml
---
id: <kebab-slug>                 # decisions/ use adr-NNNN; others use the filename stem
title: <Title>
type: architecture | design | decision | runbook | product | release
status: draft | proposed | accepted | deprecated | superseded | archived
authority: canonical | supporting | generated | historical
systems: [<system-name>, ...]    # from AGENTS.md's Systems table; [] if workspace-wide
owners: [<team-or-handle>, ...]
authorship: human | ai-assisted | generated
human_reviewed: true | false
created: YYYY-MM-DD
last_reviewed: YYYY-MM-DD
tags: [<tag>, ...]                # optional
related: [<doc-id>, ...]           # optional — ids of related docs/ADRs
superseded_by: <doc-id>            # optional — only when status: superseded
---
```

- `authorship: ai-assisted` + `human_reviewed: false` is the default for anything `/write-doc` generates that hasn't been read and confirmed by a person yet. Flip `human_reviewed` to `true` only when a human actually reviewed the content (e.g. approved the PR with a substantive review, not just merged it).
- Never mark a doc `authority: canonical` with `human_reviewed: false` — canonical status is a claim a human is willing to stand behind.
- Keep `last_reviewed` current when you materially edit a doc; leave `created` untouched.

## Citing code

- Cite as repo-relative path + symbol: `acme-api/services/invite.service.ts` `createInvite`. **No line numbers** — they rot.
- Every factual claim must be traceable to a file actually read this session. Anything unverified is written as `TODO(verify: ...)`, never stated as fact.
- Use exact repo names (as listed in `devrig.toml`) and exact endpoint/event casing as coded.

## Voice & audience

- Write for a new engineer who has read `architecture/overview.md` and nothing else.
- As-built docs describe **reality**, present tense — including known gaps, stated honestly with their tracking ids if your team uses them. Design docs describe intent, clearly marked as such in the status line.
- Use your product's terminology consistently — the canonical terms belong in a `product/` doc; keep every other doc consistent with it.
- Don't re-litigate known gaps — state them once with their tracking id and link the relevant doc.

## Linking

- Prefer updating an existing doc over creating a near-duplicate.
- Cross-link related knowledge docs by relative path; link legacy external docs (Google Docs, Notion) rather than re-transcribing them.
- If the doc covers an item on `architecture/overview.md`'s "To document" checklist, check that box in the same change.
