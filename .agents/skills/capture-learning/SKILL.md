---
name: capture-learning
description: After a PR merges, examine the completed change and decide whether permanent project knowledge should be preserved — a new ADR, an updated runbook, a changed command/dependency in .ai/, or an architecture doc that's now stale — then write it and clean up the task's handoff/context files. Use when the user says "capture learnings from this", "what should we document from this merge", after merging a PR, or when closing out a ticket.
---

# Capture Learning

> Project values (ticket prefix, default branch, repo list) come from
> `devrig.toml` and `AGENTS.md` at the workspace root — read them; never assume.

Closes the loop in `AGENTS.md`'s lifecycle: implement → verify → review → PR →
merge → **capture learning** → better context for the next task. This is the
one point where the workspace's own knowledge improves from doing the work,
instead of staying static until someone remembers to update a doc.

## Usage

`/capture-learning` — the merged PR/ticket is inferred from the current session or branch.
`/capture-learning <PR-URL or TICKET-ID>` — explicit target.

## Step 1 — Resolve what happened

Gather, in parallel:

1. The merged PR's diff and description: `gh pr view <num> --json title,body,files,commits` and `gh pr diff <num>` (same resolution as `/code-review`'s Step 1 if only a branch/ticket is given).
2. The task's persisted context, if it exists: `.ai/context/<TICKET-ID>.json`.
3. The task's handoff doc, if it exists: `knowledge/handoffs/<TICKET-ID>.md`.
4. Any `/verify-change` evidence from this session.

## Step 2 — Ask the reflective questions

Go through each; answer from the actual diff/PR body, not speculation:

| Question | If yes |
|---|---|
| Did we make an architectural decision (a real fork in the road, not just "how we implemented it")? | Draft an ADR — `/write-doc adr <decision>` |
| Did we discover an operational lesson (something that would help whoever's on call next)? | Add/update a runbook — `/write-doc runbook for <task>` |
| Did a command change (new script, changed test/build/lint invocation)? | Update `.ai/commands.yaml` and `AGENTS.md`'s Commands table |
| Did a system or dependency relationship change? | Update `.ai/systems.yaml` and `AGENTS.md`'s Systems table |
| Did we solve a recurring bug worth remembering? | Note it in the relevant architecture/runbook doc's known-gaps section (and remove the gap if it's now fixed) |
| Did this make existing architecture/design documentation inaccurate? | Update that doc directly; bump its `last_reviewed` |

If every answer is genuinely no, say so and stop — don't manufacture a doc
for a purely mechanical change. Manufactured documentation is worse than none
(it erodes trust in `authority: canonical`).

## Step 3 — Confirm scope

If more than one item came back "yes", list them and let the user pick via
`AskUserQuestion` (multi-select) which to write now vs. skip — don't silently
write everything without a chance to review the list first.

## Step 4 — Write it

For each confirmed item, follow `/write-doc`'s normal flow (template, frontmatter, style) — don't duplicate its logic here, just feed it the right doc type and content. Set `authorship: ai-assisted`, `human_reviewed: false` unless a human is actively co-authoring.

## Step 5 — Close out the task's working state

- If `knowledge/handoffs/<TICKET-ID>.md` exists, delete it (the task is done, not interrupted) or set `status: archived` if the team prefers keeping history.
- If `.ai/context/<TICKET-ID>.json` exists, delete it — it's no longer useful once the task is merged.

## Step 6 — Regenerate and land

1. `node scripts/build-knowledge-index.mjs`.
2. Land all changes from this run on **one** branch (`<ticket-id>-docs-capture-learning`) and suggest `/raise-pr` — do not commit to the default branch.

## Output

Report what was captured (or "nothing worth capturing, here's why") and what was cleaned up (handoff/context files removed).
