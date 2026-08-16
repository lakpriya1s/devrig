---
name: start-task
description: Start work on a Linear issue — verifies the issue exists, assigns it to you, moves it to In Progress, determines the task type, syncs the default branch, and gathers context (affected systems, related ADRs/designs, likely files, risks, test plan) before any code changes.
---

# Start a Linear Issue

> Project values (ticket prefix, default branch, repo list) come from
> `devrig.toml` and `AGENTS.md` at the workspace root — read them; never assume.
> This skill's MCP calls (`mcp__linear__*`) assume `issue_tracker = "linear"`
> in `devrig.toml`. If your workspace uses Jira or another tracker instead,
> adapt these calls to your tracker's MCP tool names before relying on this
> skill.

## Usage

`/start-task <linear-issue-id>`

Example: `/start-task <TICKET_PREFIX>-123` (the prefix is `ticket_prefix` in `devrig.toml`)

## Instructions

### 1. Fetch and verify the issue

Use the Linear MCP to retrieve the issue:

```
mcp__linear__get_issue  { "id": "<ISSUE_ID>" }
```

If the issue is not found, stop and tell the user.

### 1a. Assign the issue to yourself and move it to In Progress

Fetch the currently authenticated Linear user:

```
mcp__linear__list_users  { "query": "me" }
```

**Assignee:** If the issue's `assignee.id` is missing or does not match the viewer's `id`, assign the issue to yourself:

```
mcp__linear__save_issue  { "id": "<ISSUE_ID>", "assignee": "<VIEWER_ID>" }
```

Tell the user if you assigned it (e.g. "Assigned to you."). If already assigned to you, say nothing.

**Status:** If the issue's `state.name` is not already `"In Progress"`, fetch the team's workflow states to get the correct state ID:

```
mcp__linear__list_issue_statuses  { "team": "<TEAM_ID>" }
```

Find the state whose `name` is `"In Progress"` and update the issue:

```
mcp__linear__save_issue  { "id": "<ISSUE_ID>", "state": "<IN_PROGRESS_STATE_ID>" }
```

Tell the user if you moved it (e.g. "Status set to In Progress."). If it was already In Progress, say nothing.

### 2. Determine the branch type

Check the labels on the issue and map to a type:

| Label | Type |
|---|---|
| `Bug` | `bug` |
| `Feature` | `feature` |
| `Hotfix` | `hotfix` |
| `Chore` | `chore` |

- **Exactly one match** → use it, no need to ask
- **Multiple matches or no match** → ask the user to choose one of: `feature`, `bug`, `hotfix`, `chore`

Do not accept any other answer.

**Missing label:** If no matching label was found on the issue (i.e. you had to ask the user), apply the corresponding label after the user answers. Map the chosen type back to its label name (`feature` → `Feature`, `bug` → `Bug`, `hotfix` → `Hotfix`, `chore` → `Chore`), fetch the team's labels to get the label ID, then add it:

```
mcp__linear__list_issue_labels  { "team": "<TEAM_ID>" }
```

```
mcp__linear__save_issue  { "id": "<ISSUE_ID>", "labels": [<EXISTING_LABELS..., "<NEW_LABEL>"] }
```

Preserve any labels already on the issue. Tell the user (e.g. "Added label Feature.").

### 3. Sync the default branch

Read `default_branch` from `devrig.toml` at the workspace root — call it `<BASE>` below.

**Always work from `<BASE>`. Never use any other branch as the base — even if `<BASE>` is missing or the pull fails.**

Switch to `<BASE>` and pull the latest changes:

```bash
git checkout <BASE> && git pull origin <BASE>
```

If this fails (e.g. `<BASE>` doesn't exist locally), try fetching and checking out from remote:

```bash
git fetch origin <BASE> && git checkout -b <BASE> origin/<BASE>
```

If that also fails, report the error and stop — do NOT fall back to `main` or any other branch.

Confirm `<BASE>` is up to date.

### 4. Gather context

Before any code changes, collect enough context that `/plan-task` (or direct
implementation, for small tasks) doesn't start from zero. Run these in
parallel where possible — this follows the retrieval policy in `AGENTS.md`:

1. **Systems** — from the issue title/description and labels, identify which
   rows of `AGENTS.md`'s Systems table are affected, plus anything those
   systems depend on.
2. **Repositories** — the repos backing the affected systems.
3. **Related ADRs** — search `knowledge/decisions/` (or check
   `knowledge/index.md`'s Accepted Decisions section) for anything touching
   the affected systems.
4. **Relevant designs** — search `knowledge/design/` and `mcp__semble__search
   --content docs` for the issue's terminology.
5. **Related code** — `mcp__semble__search` in each affected repo for the
   issue's terminology; note likely files, don't open every hit.
6. **Dependencies** — anything outside this task's control the work relies on
   (a third-party API, another team's in-flight change, a migration).
7. **Risks** — flag if the issue touches auth, billing, schemas, or
   production infra (see `POLICY.md`'s ADR requirement — these usually need one).
8. **Tests** — which test suite(s) (per `AGENTS.md`'s Commands table) cover
   the affected systems.

Do not recursively read whole repos — if search surfaces nothing, say so
rather than falling back to browsing everything.

Report:

```markdown
## Context gathered

Ticket: <ID> — <title>
Systems: <affected systems>
Repositories: <repos>
Related ADRs: <paths, or "none found">
Relevant designs: <paths, or "none found">
Likely files: <repo/path, ...>
Dependencies: <external factors, or "none identified">
Risks: <flags, or "none identified">
Test plan: <suite(s) to run>
```

Suggest `/plan-task` next for anything non-trivial (multi-repo, schema/auth
changes, or unclear scope); small, well-scoped tasks can go straight to
implementation.

### 5. Persist the context bundle

Write the same information as JSON to `.ai/context/<ISSUE-ID>.json` (uppercase
ticket id, e.g. `.ai/context/AC-143.json`), so `/plan-task` and any other
agent picking up this ticket later in the same session or a fresh one can
reuse it instead of re-running retrieval:

```json
{
  "ticket": "<ISSUE-ID>",
  "title": "<title>",
  "systems": ["<system>", ...],
  "documents": ["<relevant design doc paths>"],
  "decisions": ["<related ADR paths>"],
  "likely_files": ["<repo/path>", ...],
  "dependencies": ["<external factors>"],
  "risk": "low | medium | high | critical",
  "test_plan": ["<suite(s)>"]
}
```

This is working state for the task's branch, not permanent knowledge — it's
fine to commit alongside the task's other changes, and there's no need to
clean it up specially (it becomes stale/irrelevant once the branch merges,
same as the branch itself).
