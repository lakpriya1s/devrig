---
name: verify-change
description: Run the applicable tests, lint, typecheck, build, and security checks for the current change and report evidence in POLICY.md's format, instead of asserting a task is done. Use before /raise-pr, whenever the user asks to "verify this" / "run the checks" / "is this done", or as the last step of implementing a task.
---

# Verify a Change

> Project values (ticket prefix, default branch, repo list) come from
> `devrig.toml` and `AGENTS.md` at the workspace root — read them; never assume.

Closes the loop between "I made the change" and "it's actually done" per
`POLICY.md`'s Definition of Done. Never report a task complete without
running this.

## Usage

`/verify-change` — verifies every affected repo (same detection as `/raise-pr`).
`/verify-change <repo>` — verifies just one repo.

## Step 1 — Detect affected repos

Same detection as `/raise-pr`'s Step 2: a repo is affected if it has
uncommitted changes, is on a task branch, or has local commits ahead of
`origin/<BASE>`. Run the rest of this skill per affected repo.

## Step 2 — Run the applicable checks

For each affected repo, look up its commands in `AGENTS.md`'s Commands table
(or its own `AGENTS.md` if more specific). Run whichever of these the repo
actually has — do not invent a command it doesn't define, and do not skip one
it does define:

```bash
<install>      # only if dependencies changed
<test>
<lint>
<typecheck>
<build>
```

Run them in the order that fails fastest and cheapest first (typically lint →
typecheck → test → build), and stop reporting further steps as PASS once one
fails — a failed lint doesn't mean tests were also checked.

If a repo has no test suite / no lint config / no typecheck / no build step,
say so explicitly — it's not a failure, but it must be stated, not omitted.

## Step 3 — Security and sensitive-change checks

Applicable when the diff touches auth, secrets/config, webhooks, or a new
external-facing endpoint (see `POLICY.md`'s ADR triggers and the code-review
skill's mandatory checks):

- Scan the diff for hardcoded secrets/keys/tokens: `git diff --stat` +
  targeted `grep` for common patterns, or defer to the repo's existing
  secret-scanning if configured.
- Confirm any new webhook/callback endpoint verifies a signature server-side.
- Confirm any new/changed auth check verifies (not just decodes) tokens and
  checks ownership/membership, not just "is logged in".

If none of these apply to the diff, state "Security checks: not applicable to
this diff" rather than omitting the section.

## Step 4 — Documentation and ADR evaluation

Cross-check against `POLICY.md`:

- Does this change match any of the ADR-required triggers? If yes, confirm an
  ADR exists (`knowledge/decisions/`) or flag that one is missing — don't let
  verification pass silently on a missing required ADR.
- Does `knowledge/` need updating for this change (design doc, runbook,
  architecture doc)? If a doc was updated, confirm
  `node scripts/build-knowledge-index.mjs` was run afterward.

## Step 5 — Report evidence

Use `POLICY.md`'s exact format, one block per affected repo:

```markdown
## Verification — <repo>

Unit tests: PASS — `<command>`
Lint: PASS — `<command>`
Typecheck: PASS — `<command>`
Build: PASS — `<command>`
Security checks: <PASS / not applicable> — <detail>
Documentation: <Updated <path> / Not required — reason>
ADR: <knowledge/decisions/NNNN-<slug>.md / Not required — reason>
```

Any line that isn't PASS must show the actual failure output (or a short
excerpt of it), not just "FAIL" — the next step is fixing it, not re-asserting
success.

## Step 6 — Stop on failure

If anything fails, fix it and re-run this skill from Step 2 for that repo —
do not proceed to `/raise-pr` with a failing check. If a failure is
pre-existing and unrelated to this change, say so explicitly and confirm with
the user before proceeding past it.
