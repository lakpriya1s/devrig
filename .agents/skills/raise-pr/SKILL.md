---
name: raise-pr
description: Raise pull requests for the current task — detects which workspace repos have changes, creates the task branch where needed, commits, pushes, then opens a PR for every affected repo with a contextual title and engineer-focused description.
---

# Raise Pull Requests

> Project values (ticket prefix, default branch, repo list) come from `.setup`
> and `AGENTS.md` at the workspace root — read them; never assume.
> Below, `<BASE>` means the `DEFAULT_BRANCH` from `.setup`.

## Usage

`/raise-pr`

Detects which workspace repos have changes for the current task, creates the task branch where needed, commits and pushes, then creates a PR on GitHub for every affected repo.

---

## Step 1 — Recall the ticket context

The ticket context is normally already in the session from `/start-task`: the Linear issue ID, title, and task type (`feature`, `bug`, `hotfix`, `chore`). Use it.

If it is not in the session (e.g. a fresh conversation), determine the issue ID from the branch name of a repo already on a task branch (e.g. `ac-123-chore-remove-legacy-api` → `AC-123`), or ask the user, then fetch it:

```
mcp__linear__get_issue  { "id": "<ISSUE-ID>" }
```

and derive the type from the labels (`Feature` → `feature`, `Bug` → `bug`, `Hotfix` → `hotfix`, `Chore` → `chore`); if ambiguous, ask the user.

---

## Step 2 — Detect the affected repos

Check every system repo in the workspace root (the list comes from `.setup`):

```bash
source .setup
for r in "${REPOS[@]}" knowledge; do
  [ -d "$r" ] || continue
  echo "== $r ($(git -C $r rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'workspace repo'))"
  git -C $r status --short 2>/dev/null
  git -C $r log --oneline origin/$DEFAULT_BRANCH..HEAD 2>/dev/null
done
```

(`knowledge/` is part of the workspace meta repo unless it has been split into
its own repo — check `AGENTS.md`. Workspace-meta changes, including
`knowledge/`, are committed to this repo's own branch the same way.)

A repo is **affected** if any of the following is true:

- It has uncommitted changes (staged or unstaged)
- It is already on a task branch (current branch is not `<BASE>`)
- It has local commits not yet on `origin/<BASE>`

List the affected repos and what kind of changes each has, and confirm the list with the user before proceeding. If no repo has any changes, tell the user and stop.

All the following steps apply to **each affected repo**.

---

## Step 3 — Create the branch in each affected repo

Compose the branch name — `<ticket-id>-<type>-<short-title>`, all lowercase kebab-case, short title derived from the ticket title:

```
ac-295-chore-remove-legacy-api
ac-123-feature-user-invites
```

The **same branch name** is used in every affected repo. If an affected repo is already on a task branch for this ticket, use that existing branch name everywhere instead.

Then, for each affected repo:

- **Already on the task branch** → nothing to do.
- **On `<BASE>` with only uncommitted changes** → create the branch; the uncommitted changes carry over:
  ```bash
  git checkout -b <branch-name>
  ```
- **On `<BASE>` with local commits ahead of `origin/<BASE>`** → move those commits onto the task branch and reset local `<BASE>` back to the remote (never leave commits on `<BASE>`):
  ```bash
  git checkout -b <branch-name>
  git branch -f <BASE> origin/<BASE>
  ```
- **On some other unrelated branch** → stop and ask the user how to proceed for that repo.

---

## Step 4 — Commit in each affected repo

If a repo has uncommitted changes, show the user a short summary (`git status --short`), then stage and commit everything:

```bash
git add -A
git commit -m "<type>(<scope>): <summary> [<ISSUE-ID>]"
```

- `type` is the conventional-commit type matching the task type (`feat` for feature, `fix` for bug, `chore`, `hotfix`)
- `scope` is the area touched in that repo (e.g. `api`, `auth`, `ui`)
- The Linear ID in the message links the commit to the ticket automatically

Example: `chore(api): remove legacy v1 endpoints [AC-295]`

If a repo's changes are already committed, skip it.

---

## Step 5 — Push each affected repo

```bash
git push -u origin HEAD
```

If a push fails, report the error for that repo and stop — do not force-push.

---

## Step 6 — Gather context for each PR

Do this per affected repo.

### Commit log

Fetch the commits on this branch that are not on the base branch:
```bash
git log --oneline $(git merge-base HEAD origin/<BASE>)..HEAD
```

Use the full commit messages (not just `--oneline`) to understand the work done:
```bash
git log --format="%s%n%b" $(git merge-base HEAD origin/<BASE>)..HEAD
```

### Diff summary

Get a high-level sense of the files changed:
```bash
git diff --stat $(git merge-base HEAD origin/<BASE>)..HEAD
```

---

## Step 7 — Determine the target repo

For each affected repo, detect the GitHub remote automatically:
```bash
git remote get-url origin
```

Parse the owner and repo from the URL (handles both `https://github.com/owner/repo.git` and `git@github.com:owner/repo.git`).

If parsing fails, ask the user: **"Which repo? (e.g. <GITHUB_ORG>/<repo-name>)"**

---

## Step 8 — Compose the PR title and description

Compose one per affected repo, based on that repo's commits and diff.

### Title

Format: `[ISSUE-ID] Contextual title derived from the work`

- If a Linear issue ID was found, prefix the title with it in brackets: `[AC-295]`
- Derive the title from the commit messages and diff — make it specific and human-readable, not just the branch name slug
- Keep it under 72 characters
- Use sentence case

Examples:
- `[AC-123] Add invite links for team workspaces`
- `[AC-89] Fix token expiry not refreshing on silent auth`

### Description

Write a description aimed at an engineer reviewer. Structure it as follows:

```
## What

[1–3 sentence summary of what this PR does and why. Include the motivation or ticket context if inferable from commits.]

## How

[Bullet list of the key implementation decisions — what was changed, added, or removed and the reasoning. Be specific: name files, functions, or APIs touched where helpful.]

## How to test

[Step-by-step instructions a reviewer can follow to verify the changes work. Include:
- Setup steps if any (migrations, env vars, seed data)
- The specific flows to exercise (happy path and at least one edge case)
- What the expected outcome looks like]

## Concerns / notes

[Any risks, trade-offs, known limitations, or things the reviewer should pay special attention to. If there are none, omit this section entirely.]
```

Populate each section from the commit messages, diff, and any context available. Do not leave placeholder text — if a section has nothing meaningful to say, omit it rather than filling it with filler.

---

## Step 8b — Determine the base branch

Resolve the base branch in this order:

1. **`DEFAULT_BRANCH` from `.setup`** — the workspace-wide base for every repo.
   Exception: hotfixes may target a production branch — ask the user first.

2. **Remote detection** — if `<BASE>` doesn't exist on the remote, check which branches do:
   ```bash
   git branch -r | grep -E 'origin/(dev|develop)$'
   ```
   Prefer `dev` if both exist. Use whichever is found.

3. **Fallback** — if none of the above exists on the remote, check for `main` or `master`. If found, warn the user that you're falling back to a default branch, and ask them to confirm before continuing.

4. If nothing can be determined, ask the user: **"What should the base branch be?"**

---

## Step 8c — Select reviewers

Ask once — the selected reviewers are applied to every PR. Fetch the list of collaborators (from the first affected repo):
```bash
gh api repos/<owner>/<repo>/collaborators --jq '.[].login'
```

Determine the current user's GitHub login to exclude them from the list:
```bash
gh api user --jq '.login'
```

Remove the current user from the collaborator list. Then use the `AskUserQuestion` tool to present the remaining collaborators as a **multi-select** question:

```
AskUserQuestion({
  questions: [{
    question: "Who should review this PR?",
    header: "Reviewers",
    multiSelect: true,
    options: [
      { label: "<username1>", description: "Add as reviewer" },
      { label: "<username2>", description: "Add as reviewer" },
      ...
    ]
  }]
})
```

If the user selects one or more reviewers, store the selected usernames for Step 9.
If the user selects none or dismisses, proceed without reviewers.

---

## Step 9 — Create the PRs

In each affected repo, use the `gh` CLI:

```bash
gh pr create \
  --title "<composed title>" \
  --body "<composed description>" \
  --base <resolved-base-branch> \
  --head <branch-name> \
  --reviewer <reviewer1,reviewer2>   # omit this flag if no reviewers were selected
```

---

## Step 10 — Report success

Print the full PR URL for every affected repo:

> "Pull requests created:
> - repo-a: https://github.com/<owner>/repo-a/pull/<number>
> - repo-b: https://github.com/<owner>/repo-b/pull/<number>"

If the CLI returned a URL, use that directly. If only a PR number was returned, construct the URL from the known owner/repo/number.
