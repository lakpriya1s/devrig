---
name: plan-task
description: Turn gathered task context into a written plan before touching code — goal, affected systems, relevant knowledge/ADRs, files likely to change, proposed changes, risks, test strategy, and documentation impact. Use for anything non-trivial (multi-repo, schema/auth/billing changes, unclear scope) after /start-task, or whenever the user asks to "plan this task" / "write a plan before implementing". Skip for small, well-scoped changes.
---

# Plan a Task

> Project values (ticket prefix, default branch, repo list) come from
> `devrig.toml` and `AGENTS.md` at the workspace root — read them; never assume.

Produces a written plan an agent (or a human) implements against, instead of
rediscovering context mid-implementation. Complements Claude Code's native
plan mode — where available, presenting this plan through that flow (so the
user gets the same approve/edit gate) is preferred over dumping it as chat
text; on agent tools without a native plan mode, print it directly.

## Usage

`/plan-task` — uses context already gathered by `/start-task` in this session.
`/plan-task <TICKET-ID or description>` — gathers context first if `/start-task` wasn't run.

## Step 1 — Ensure context exists

If `/start-task`'s "Context gathered" block is already in this session, use it.
Otherwise check for a persisted bundle at `.ai/context/<ISSUE-ID>.json` (from
a prior `/start-task` run, possibly in an earlier session) and use that. If
neither exists, run `/start-task`'s Step 4 (Gather context) now — don't plan
on a guess.

## Step 2 — Read what retrieval found

Per the retrieval policy in `AGENTS.md`: read the related ADRs and design
docs found, not just their titles. Read enough of each likely-affected file
to know its current shape — don't propose changes to code you haven't looked at.

If retrieval found nothing relevant for a non-trivial task, say so explicitly
in the plan rather than proceeding on assumptions.

## Step 3 — Draft the plan

```markdown
## Goal

<1-2 sentences: what this task achieves and why, from the ticket/request.>

## Systems affected

<rows from AGENTS.md's Systems table, plus anything depending on them.>

## Relevant knowledge

<knowledge/ docs read, with a one-line takeaway each — "none found" if genuinely none.>

## Relevant ADRs

<knowledge/decisions/ docs that constrain this work — "none found" if genuinely none.>

## Files likely affected

<repo/path — what changes there, one line each. Group by repo.>

## Proposed changes

<the approach, as concrete steps. Call out any alternative considered and why
it lost, if there was a real fork in the road.>

## Risks

<what could go wrong — breaking changes, cross-repo coordination, migration
order, rollback difficulty. "None identified" only if you actually checked
POLICY.md's risk triggers and none apply.>

## Test strategy

<which suites run (per AGENTS.md's Commands table), and any new test coverage
this task should add.>

## Documentation impact

<which knowledge/ docs need creating/updating, and whether this crosses
POLICY.md's ADR-required list. "None" only if genuinely nothing changes.>

## Confidence

<High | Medium | Low — per POLICY.md's confidence/uncertainty reporting.>

## Assumptions

<anything taken as given without direct verification.>

## Unverified

<anything not directly checked — e.g. a config only readable in production.>

## Human attention required

<anything risky enough (per POLICY.md's risk levels) that a human should
look closely before/while it's implemented — "none" only if the risk level
is genuinely Low.>
```

Every claim in the plan should trace back to something actually read this
session — retrieval hits, `AGENTS.md`, or the ticket. Mark anything unverified
as `TODO(verify: ...)` rather than asserting it.

## Step 4 — Get the plan approved

Present the plan and wait for the user to approve, edit, or redirect before
implementing. Treat this as a real gate, not a formality — a plan the user
hasn't seen is not an approved plan.

Once approved, write the final plan (as approved, including any edits the
user made) to `.ai/runs/<ISSUE-ID>/plan.md` — the next entry in that ticket's
observability trail (see `.ai/README.md`).

## Step 5 — Hand off

Once approved, implement against the plan directly, or note that
`/verify-change` should run once implementation is done. Don't re-run context
gathering mid-implementation unless the plan turns out to be wrong.
