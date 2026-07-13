---
name: write-doc
description: Write documentation for the workspace into the knowledge base, in four modes. Existing-feature mode — reverse-engineers a shipped feature from the code across repos into an as-built doc. New-feature mode — turns a Linear ticket or a described idea into a design doc with cross-repo impact. Decision/ops mode — ADRs, runbooks, product docs. Gap-fill mode — inventories what's missing (architecture/overview.md's "To document" list, empty folders) and proposes what to write next. Use whenever the user says "write a doc", "document how X works", "design doc for <ticket>", "write an ADR/runbook", "what docs are missing", or "fill the knowledge base" — even if they just paste a ticket key with "doc" in the request.
---

# Write Doc — Knowledge Base

> Project values (ticket prefix, default branch, repo list) come from `.setup`
> and `AGENTS.md` at the workspace root — read them; never assume.
> The ticket-lookup step (`mcp__linear__get_issue`) assumes `ISSUE_TRACKER="linear"`
> in `.setup`. If your workspace uses Jira or another tracker instead, adapt
> that call to your tracker's MCP tool names.

Generate documentation into **the knowledge base named in `AGENTS.md`**
(default: `knowledge/` in the workspace root), following its conventions (see
its `README.md`). Output always lands on a task branch and is handed to
`/raise-pr` — **never commit to the default branch**.

## Usage

- `/write-doc <what>` — e.g. `/write-doc how invite links work`, `/write-doc runbook for deploying the api`
- `/write-doc <TICKET-ID>` — design doc from a Linear ticket
- `/write-doc adr <decision>` — record an architecture decision
- `/write-doc fill` — gap-fill mode: inventory missing docs and propose what to write next

## Doc-type decision table

| User intent | Folder | Template | Filename |
|---|---|---|---|
| Design a new feature (ticket or description) | `design/` | [templates/design-doc.md](templates/design-doc.md) | `YYYY-MM-<short-title>.md` (current month) |
| Document how an existing feature works | `architecture/` | [templates/as-built.md](templates/as-built.md) | `<feature-slug>.md` |
| Architecture topic (auth model, data flow, environments) | `architecture/` | [templates/as-built.md](templates/as-built.md) | `<topic-slug>.md` |
| Record/justify a decision ("we chose X over Y") | `decisions/` | copy `decisions/0000-template.md` | `NNNN-<short-title>.md` (next number) |
| Operational procedure (deploy, restore, incident) | `runbooks/` | [templates/runbook.md](templates/runbook.md) | `<verb-slug>.md` (e.g. `deploy-api.md`) |
| Product behavior, personas, terminology, plan rules | `product/` | [templates/product-doc.md](templates/product-doc.md) | `<topic-slug>.md` |
| "Fill missing docs" / "what's undocumented" | (varies) | [Gap-fill mode](#gap-fill-mode) | (per pick) |

Tie-breakers: not-yet-built → design doc; already shipped → as-built; "why did/should we" → ADR; "how do I operate/recover" → runbook. **If the intent is ambiguous between design (future) and as-built (present), ask the user one question before writing — the two land in different folders and must not be mixed.**

---

## Step 1 — Resolve doc type, target file, and repos involved

1. Match the request against the decision table above.
2. If a `<TICKET_PREFIX>-XXXX` key is present: `mcp__linear__get_issue {"id": "<TICKET-ID>"}` — capture title, description, labels, and any linked docs. A ticket for unbuilt work defaults to a design doc.
3. Determine which system repos the topic touches (from the ticket, the request, or a quick `mcp__semble__search` per candidate repo). **Load only the [reference files](#per-repo-reference-files) for repos actually involved.**
4. Compute the filename:
   - Design docs use the current month: `date +%Y-%m`
   - ADRs use the next number: `ls <knowledge>/decisions/` → highest `NNNN` + 1 (the `0000` template doesn't count)

---

## Step 2 — Check for existing docs (avoid duplicates)

```bash
grep -ril "<feature terms>" <knowledge>/
ls <knowledge>/{architecture,design,decisions,runbooks,product}
```

- **Prefer updating an existing doc over creating a near-duplicate.** If a closely related doc exists, propose extending it and confirm with the user before writing a new file.
- Check whether the topic matches an unchecked item on `<knowledge>/architecture/overview.md`'s "To document" checklist — if so, the new doc must check that box (Step 5).
- If the ticket or an existing doc links an external doc (Google Docs, Notion, ...), link it from the new doc rather than re-transcribing.

---

## Step 3 — Gather context

Run independent lookups in parallel.

1. Read each involved repo's [reference file](#per-repo-reference-files) (if it exists), then that repo's `AGENTS.md`/`CLAUDE.md`.
2. `mcp__semble__search` each involved repo with 2-3 focused queries (feature name, event names, model names); Read the hits; `mcp__semble__find_related` for sibling implementations.
3. **For as-built docs**: trace the actual flow end-to-end (trigger → transport → backend → storage → notification) and record repo-relative file paths + symbol names as source pointers. **Every factual claim must be traceable to a file you read; anything unverified is written as `TODO(verify: ...)`, never stated as fact.**
4. **For design docs**: read the current state of each affected repo well enough to fill the per-repo rows of the cross-repo impact table.
5. Read any related knowledge-base docs found in Step 2 so terminology stays consistent.

---

## Step 4 — Draft

1. Copy the matching template and fill every section; delete the HTML guidance comments; drop genuinely empty optional sections rather than writing "N/A".
2. Apply [doc-style.md](doc-style.md) — no frontmatter, blockquote status line, Mermaid for diagrams, path+symbol citations, honest treatment of known gaps.
3. For design docs, the **Cross-repo impact**, **Privacy & security**, and **Rollout & sequencing** sections are required for anything touching sensitive data, notifications, or billing/plans.

---

## Step 5 — Land in the knowledge base

**Never commit to the default branch.**

If the knowledge base is a folder in this workspace repo (the default), work on
a task branch of the workspace repo. If it has been split into its own repo
(check `AGENTS.md`), branch there instead:

```bash
git checkout <BASE> && git pull
git checkout -b <branch>
```

Branch name: `<ticket-id>-docs-<slug>` when a ticket exists (e.g. `ac-301-docs-invite-links`), otherwise `docs-<slug>`.

1. Write the doc file(s) to the target folder from the decision table.
2. Make the index edits in the same change: check off the matching `architecture/overview.md` "To document" item, and add a cross-link from the most closely related existing doc if one exists.
3. Show the user the doc (or a summary + path) for review.
4. Finish by suggesting `/raise-pr` — it detects the changes, commits, pushes, and opens the PR. Do not duplicate its logic here.

---

## Gap-fill mode

For `/write-doc fill` or "what docs are missing":

1. **Inventory** (parallel):
   - Unchecked items: `grep -n "\- \[ \]" <knowledge>/architecture/overview.md`
   - Empty categories: `ls <knowledge>/{design,runbooks,product,decisions}` — a folder with only `.gitkeep` (or `decisions/` with only the template) means the whole category is missing
   - Each relevant reference file's "Flows worth documenting" and "Gotchas to surface" bullets with no corresponding knowledge doc
2. **Rank** by this priority order:
   1. `overview.md` checklist items (data flow, environments/deploys, auth model, third-party inventory)
   2. One runbook per deploy target
   3. As-built docs for core features
   4. Product docs
3. **Propose** a table — proposed doc | folder/filename | doc type | main sources (repos/files) | rough effort — and let the user pick via `AskUserQuestion` (multi-select, **cap at ~3 per run** so one PR stays reviewable).
4. **Execute** each pick through Steps 1-4, landing all picks on **one** task branch (Step 5) → one `/raise-pr`.

---

## Per-repo reference files

Write one per repo (see [references/README.md](references/README.md) and
[references/_example-repo.md](references/_example-repo.md)). Load only the
ones for repos the doc actually touches; if a repo has no reference file yet,
work from its `AGENTS.md` and note the gap.
