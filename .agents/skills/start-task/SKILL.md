---
name: start-task
description: Start work on a Linear issue — verifies the issue exists, assigns it to you, moves it to In Progress, determines the task type, and syncs the default branch.
---

# Start a Linear Issue

> Project values (ticket prefix, default branch, repo list) come from `.setup`
> and `AGENTS.md` at the workspace root — read them; never assume.
> This skill's MCP calls (`mcp__linear__*`) assume `ISSUE_TRACKER="linear"` in
> `.setup`. If your workspace uses Jira or another tracker instead, adapt these
> calls to your tracker's MCP tool names before relying on this skill.

## Usage

`/start-task <linear-issue-id>`

Example: `/start-task <TICKET_PREFIX>-123` (the prefix is `TICKET_PREFIX` in `.setup`)

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

Read `DEFAULT_BRANCH` from `.setup` at the workspace root — call it `<BASE>` below.

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
