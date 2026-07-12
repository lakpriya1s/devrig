---
name: code-review
description: Code review for any workspace repository, in two modes. Full mode — given a PR URL, branch name, or repo path, detects the repo, pulls the PR + linked Linear ticket + any related knowledge-base design doc, checks the implementation against the ticket, verifies test coverage where a suite exists, and confirms CI status. Light mode — diff-only review of a branch against the default branch with breaking-change, sensitive-data, auth, webhook, and cross-repo checks. Use whenever the user asks for a code review, PR review, or "review this branch"/"review this PR" — even if they paste just a GitHub URL, branch name, or ticket key with "review" in the request.
---

# Code Review

> Project values (ticket prefix, default branch, repo list, org) come from
> `.setup` and `AGENTS.md` at the workspace root — read them; never assume.
> Below, `<BASE>` means the `DEFAULT_BRANCH` from `.setup`.

Comprehensive review for any repo in the workspace, in two modes:

- **Full mode (default for PRs)**: closes the loop on **whether the change is fit to ship** — does it match the linked Linear ticket, is it tested where this repo has a test suite, has CI passed? Use when the user supplies a PR URL/number or asks for a full review.
- **Light mode**: findings-first review of the **diff itself** against `<BASE>` — no Linear/CI verification. Use when the user asks for a quick diff review, points at uncommitted/local changes, or explicitly wants code-only feedback.

Both modes apply the [Review Lenses](#review-lenses-both-modes) below. If unsure which mode the user wants, default to full mode for anything with an open PR, light mode otherwise.

## Inputs accepted

- Full GitHub PR URL: `https://github.com/<GITHUB_ORG>/<repo>/pull/<number>`
- Repo + PR number: `my-api#42`, `api PR 42`
- Branch name only, including this workspace's convention `<ticket-id>-<type>-<short-title>` (e.g. `ac-295-chore-remove-legacy-api` → `AC-295`)
- Repo path: a directory name from the `REPOS` list (use current branch in that path)
- No input at all: check every repo under the workspace root for uncommitted changes or a branch ahead of `<BASE>` (same detection logic as the `raise-pr` skill) and ask which one(s) to review if more than one qualifies.

If the input is ambiguous (no repo named), look at the current working directory and ask the user only if it's still unclear.

## Review Lenses (both modes)

Review each change from all of these perspectives:

- **Senior engineer**: correctness, edge cases, test coverage, maintainability, loose ends
- **Sensitive data** <!-- CUSTOMIZE: name your product's highest-sensitivity data path here (e.g. payment data, health records, location, PII) and treat this lens as seriously as security. Until customized: any data about one user that another user can request. -->
- **DevOps**: deployment risk, observability, rollback safety — check each repo's deploy pipeline in its reference file / `AGENTS.md`
- **SecOps**: auth verification correctness, secret handling, webhook signature checks
- **Lean tech lead**: unnecessary complexity, coordination needs across repos, missing ownership

### Mandatory checks

**Base branch and diff scope**
- All repos base off `<BASE>` — confirm the diff is actually against `<BASE>`, not a release/deploy branch.
- Review changes from the merge base against `<BASE>` — the full branch delta, not just the latest commit.
- If local unstaged/staged changes materially affect the review, include them and say so.

**Breaking changes**
- Call out breaking changes explicitly and early.
- Treat database schema, API contract, event/message payload, webhook, config, infra, permission, and cross-repo data-model changes as potentially breaking until proven otherwise — see [review-checklist.md §3](review-checklist.md#3-breaking-change-review).
- If any client of the API cannot be force-upgraded (e.g. a mobile app with store-review lag), a backend-breaking change strands shipped clients — verify safe rollout sequencing.

**Auth**
- Verify token handling actually verifies signatures (e.g. `jwt.verify`), not just decodes (`jwt.decode`).
- Check ownership/membership checks (not just "is logged in") on anything returning another user's data.

**Webhooks and third-party callbacks**
- Any new webhook endpoint must verify a signature or shared secret server-side — decoding a payload is not verifying it.

**Secrets and CI**
- Scan diffs for newly committed keys/`.env` files/hardcoded passwords, especially in CI config (`.github/workflows/*.yml` etc.) — see [review-checklist.md §6](review-checklist.md#6-secrets--ci-review).

**Cross-repo impact**
- If the change touches a shared data model, API contract, or event payload, check the sibling repo that duplicates or consumes it. The systems table in `AGENTS.md` and the per-repo reference files say which repos share what.

See [review-checklist.md](review-checklist.md) for the full detailed checklist.

## Light Mode Workflow

1. Identify the repo root and confirm the diff is against `<BASE>` (or the correct merge base).
2. Review the full branch delta, including local changes if relevant.
3. Load the repo's reference file (`references/<repo>.md`, if it exists) for repo-specific deep checks. If it doesn't exist, note the gap and continue with the generic checks.
4. Read enough surrounding code to understand downstream effects — sibling flows in this repo, and contracts with other repos if touched.
5. Apply the Review Lenses and mandatory checks above.
6. Report **findings first**, ordered by severity, with concise `file:line` references; then open questions, then a brief change summary; close with residual risks or testing gaps if no concrete defect is found.

For each finding, include: severity and why it matters, the affected file/area, the concrete risk or loose end, and what coupling or downstream impact was checked.

## Per-repo reference files

Load only the one you need: `references/<repo>.md` (one per repo in your `REPOS`
list — see [references/README.md](references/README.md) for how to write them,
and [references/_example-repo.md](references/_example-repo.md) for the shape).
If the file for the repo under review doesn't exist, say so — it's a
customization gap worth fixing.

## Full Mode Workflow

Run these steps in order. Use parallel tool calls within a step where independent.

### 1. Resolve target

Determine repo + PR number + branch + base branch (`<BASE>`):

- If the user gave a GitHub URL, parse it. Otherwise use `gh` and `git` from the relevant repo directory.
- From within the repo: `gh pr view --json number,title,body,headRefName,baseRefName,state,author,url,labels,reviews,comments,commits,statusCheckRollup,files`

### 2. Pull PR context

Capture from the same `gh pr view` call: title, body, author, state, head/base branches and merge base, all commits (not just latest), PR/review comments, CI status rollup, changed files with additions/deletions.

For the full diff and commit messages:
- `gh pr diff <num>`
- `git log --format="%s%n%b" $(git merge-base HEAD origin/<BASE>)..HEAD`

### 3. Find the linked Linear ticket

Extract a `<TICKET_PREFIX>-XXXX`-style key from, in order of authority:

1. Branch name (this workspace's convention: `ac-295-chore-...` → `AC-295`)
2. PR title
3. PR body
4. Commit messages on the branch

Fetch it via `mcp__linear__get_issue`. Capture title, description, acceptance criteria (if present in the description), status, labels, and any linked design doc references.

If no ticket key is found anywhere, flag it — this workspace's convention (see the `raise-pr`/`start-task` skills) expects one.

### 4. Check for a related design doc

This workspace keeps design docs/ADRs in the knowledge base named in `AGENTS.md` (default: `knowledge/`). Look in this order:

1. A relative or repo-name reference inside the Linear ticket description.
2. The knowledge base, for a filename matching the ticket key or feature name (grep/ls).
3. If nothing is found and the change is non-trivial (>~300 LOC, touches a cross-repo contract, alters a shared schema, adds a new service/webhook), flag the absence rather than assuming it doesn't matter.

If a design doc is found, treat it as the source of truth for scope — flag drift between the doc and the implementation.

### 5. Per-repo deep checks

Load the relevant [reference file](#per-repo-reference-files) for the target repo and apply its checks.

### 6. CI verification

Pull CI status from `gh pr view --json statusCheckRollup` or `gh pr checks <num>`. CI shape can differ sharply by repo — the reference file documents what checks exist (some repos build in external CI, some have deploy-only workflows, some have none).

Required signal before declaring the PR "ready": all required checks that *do exist* are green, not pending or failed. Don't invent an expectation for a check the repo doesn't have.

### 7. Acceptance criteria coverage

Cross-reference the PR's actual changes against the Linear ticket's description/acceptance criteria and the design doc's scope (if found). For each criterion, mark:

- **Met** — concrete code evidence (`file:line`)
- **Partial** — addressed but incomplete
- **Missing** — no evidence in the diff
- **N/A** — out of scope per the ticket/doc

### 8. Test coverage

Check the repo's reference file / `AGENTS.md` for whether a test suite exists:

- Repo **has** a suite → expect specs for new/changed logic; "no test added" is a real finding.
- Repo **has no** suite → don't flag "no tests" as a new problem — but if the PR is the natural place to start one (new auth logic, new webhook/payment handler), say so as a suggestion, not a blocker.

### 9. Cross-repo impact

Apply [review-checklist.md §7](review-checklist.md#7-cross-repo-impact-review). Briefly list adjacent open PRs on the same ticket if relevant: `gh search prs --owner <GITHUB_ORG> "<TICKET-KEY>"`.

## Full Mode Output

Produce **one inline review** in the chat. Use this structure exactly — tuned for skimming:

```
# Review — <repo>#<PR-number>: <title>

**Linear**: <TICKET-KEY> (<status>) — <one-line summary>
**Design doc**: <knowledge-base doc> — or "none found"
**CI**: <green / red / pending / not applicable> — <one-line detail>

## Verdict

<one of: ship-it | ship-with-followups | needs-changes | needs-discussion>

<2-3 sentence rationale>

## Spec coverage

For each acceptance criterion: ✅ Met / ⚠️ Partial / ❌ Missing / — N/A
Point to file:line evidence for Met / Partial.

## Findings — by severity

### Blockers
- <file:line> — <issue> — <why it matters>

### Important
- <file:line> — <issue> — <why it matters>

### Nits / suggestions
- <file:line> — <issue>

## Tests
- <pass/fail/gap/none-expected for this repo> — <detail>

## Cross-repo
- <repo>: <matching change found / needed / not applicable> — <detail>

## Open questions
- <only if applicable>
```

If a section is genuinely empty, omit it rather than writing "N/A" — keeps the output tight.

## Style notes

- Lead with the **verdict** (full mode) or top-severity findings (light mode) so the user can skim and decide whether to drill in.
- Distinguish **blockers** (won't ship) from **important** (should fix before merge) from **nits** (suggestions).
- Cite `file:line` for every concrete finding.
- Treat a found design doc or Linear ticket as the spec, not the PR description. If they disagree, flag it.
- Don't re-flag known pre-existing gaps (document them per-repo in the reference files) as new bugs on unrelated PRs — but do flag them if the PR touches that exact code, and never let new code copy the same pattern.
- Don't repeat what the diff already shows. Give the **synthesis** — what's missing, what's risky, what's unverified.
