# Doc Style — knowledge base

Apply this checklist to every doc drafted for the knowledge base.

## Format

- Plain markdown, **no YAML frontmatter** — a single `#` H1 title, then a `>` blockquote status/provenance line right under it (e.g. `> As-built, derived from code — 2026-07-05.`).
- Markdown tables for any mapping (repo → role, endpoint → consumer, plan → limits).
- **Diagrams are Mermaid fenced blocks** — GitHub renders them natively; never image files:
  - `sequenceDiagram` for cross-repo/message flows (client → service → storage → push)
  - `flowchart TD` for logic/state
  - `erDiagram` for non-trivial data models
- Delete the template's HTML guidance comments after filling; drop optional sections that are genuinely empty rather than writing "N/A".

## Citing code

- Cite as repo-relative path + symbol: `acme-api/services/invite.service.ts` `createInvite`. **No line numbers** — they rot.
- Every factual claim must be traceable to a file actually read this session. Anything unverified is written as `TODO(verify: ...)`, never stated as fact.
- Use exact repo names (as listed in `.setup`) and exact endpoint/event casing as coded.

## Voice & audience

- Write for a new engineer who has read `architecture/overview.md` and nothing else.
- As-built docs describe **reality**, present tense — including known gaps, stated honestly with their tracking ids if your team uses them. Design docs describe intent, clearly marked as such in the status line.
- Use your product's terminology consistently — the canonical terms belong in a `product/` doc; keep every other doc consistent with it.
- Don't re-litigate known gaps — state them once with their tracking id and link the relevant doc.

## Linking

- Prefer updating an existing doc over creating a near-duplicate.
- Cross-link related knowledge docs by relative path; link legacy external docs (Google Docs, Notion) rather than re-transcribing them.
- If the doc covers an item on `architecture/overview.md`'s "To document" checklist, check that box in the same change.
