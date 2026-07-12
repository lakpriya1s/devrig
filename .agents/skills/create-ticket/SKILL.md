---
name: create-ticket
description: Create well-formed Linear tickets — epics, stories, tasks, and bug reports — from a short description or pasted findings, using the team's templates, label/project conventions, and a duplicate check. Use when the user says "create a ticket/epic/story/task", "file a bug", "add this to Linear", or pastes an error/finding to be filed.
---

# Create a Linear Ticket

> Project values (ticket prefix, repo list) come from `.setup` and `AGENTS.md`
> at the workspace root — read them; never assume.

## Usage

```
/create-ticket <type> <short description>
/create-ticket bug Save button unresponsive on the settings screen
/create-ticket epic Team usage dashboard
/create-ticket            (type + details gathered interactively)
```

Types: `epic` | `story` | `task` | `bug`

---

## Conventions — verify for your team

<!-- CUSTOMIZE: fill this table once for your Linear workspace, then treat it
as verified. Until then, discover the values with the MCP calls noted. -->

| Fact | Value |
|---|---|
| Team | <!-- TODO: your Linear team name + key (matches TICKET_PREFIX in .setup) — discover via `mcp__linear__list_teams` --> |
| Projects (map to repos) | <!-- TODO: one Linear project per repo, e.g. `Acme API` → `acme-api` — discover via `mcp__linear__list_projects` --> |
| Type labels | `Feature`, `Improvement`, `Bug` <!-- verify via `mcp__linear__list_issue_labels` --> |
| Surface labels | e.g. `BE`, `FE`, `Android`, `iOS` <!-- verify / adapt to your surfaces --> |
| Statuses | `Backlog`, `Todo`, `In Progress`, `In Review`, `Done` <!-- verify via `mcp__linear__list_issue_statuses` --> |
| Priorities | 1=Urgent (crash, data loss, security), 2=High, 3=Medium, 4=Low, 0=None |
| Estimates | Points (1–5) on stories/tasks; omit for epics and bugs unless the user gives one |
| Epics | Linear has no native epic — an epic is a **parent issue**; stories/tasks attach via `parentId`. Label it `Epic` (create the label with `mcp__linear__create_issue_label` if it doesn't exist yet) |

Bug title convention: `[<Project> <Surface>] <symptom, specific and observable>` — e.g. `[Acme Web] Save button unresponsive after tab switch`.

---

## Step 1 — Determine the type and gather the facts

Infer the type from the request (`bug` if an error/defect is described, `epic` for a multi-story outcome, `story` for a user-facing capability, `task` for engineering work). If genuinely ambiguous, ask.

Then collect what the template needs (see `templates/<type>.md`). Pull as much as possible from the conversation, code, and logs already in context — **do not interrogate the user field by field**. Ask (one `AskUserQuestion` round max) only for what you cannot infer, typically:

- **Project** — infer from which repo the work touches (table above). Cross-repo work: pick the primary repo's project and name the rest in the description.
- **Priority** — default `bug` to 3/Medium unless it's a crash/data-loss/security issue (then 1–2); default others to 3/Medium.
- **Assignee** — only set if the user names someone (accepts name, email, or "me"); otherwise leave unassigned.

Labels: always apply one type label (`Bug` for bugs, `Feature` for stories/epics, `Improvement` for refactor/cleanup tasks) plus the surface labels that apply.

## Step 2 — Check for duplicates

Before creating, search for existing tickets covering the same thing:

```
mcp__linear__list_issues  { "team": "<TEAM>", "query": "<2–4 keywords from the title>" }
```

If a likely duplicate exists, show it to the user and ask whether to update/comment on the existing ticket instead. Never file a duplicate silently.

## Step 3 — Compose from the template

Read `templates/<type>.md` (relative to this skill's directory) and fill every section from the gathered facts. Rules:

- Omit a section entirely rather than writing filler or "N/A".
- Bugs: include exact error text, file/line for the root cause when identified, and repro steps someone else can follow. Attach evidence paths (screenshots, log excerpts) if they exist.
- Stories: acceptance criteria are checkboxes, each independently verifiable.
- Epics: the description lists the child issues as a checklist; scope explicitly states what is *out*.
- Never include secrets, tokens, or real user data in ticket bodies.

## Step 4 — Create the issue(s)

```
mcp__linear__save_issue  {
  "team": "<TEAM>",
  "title": "<title>",
  "description": "<filled template markdown>",
  "labels": ["<type label>", "<surface labels...>"],
  "project": "<project name>",
  "priority": <0-4>,
  "state": "Backlog"          // "Todo" if the user says it's planned/next-up
}
```

- Do **not** pass `id` when creating.
- **Epic**: create the parent issue first, then create each child story/task with `"parentId": "<epic identifier, e.g. <TICKET_PREFIX>-400>"`. If the user described children only loosely, propose the breakdown (titles + one-liners) for confirmation before creating them.
- **Story/task under an existing epic**: set `parentId` to that epic's identifier.
- Relations: use `blockedBy`/`blocks`/`relatedTo` when the user states them.

## Step 5 — Report

Print each created ticket as `<TICKET_PREFIX>-xxx — <title> — <url>`, and for an epic, the children indented beneath it. Mention any duplicate you found and skipped.
