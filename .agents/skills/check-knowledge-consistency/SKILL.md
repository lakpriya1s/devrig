---
name: check-knowledge-consistency
description: Compare the knowledge base and .ai/ config against actual repo state — ADRs vs implementation, architecture docs vs repos, runbooks vs scripts, documented API contracts vs actual routes, commands.yaml vs package.json, ownership.yaml vs CODEOWNERS — and report drift. Use when the user asks "are the docs still accurate", "find outdated documentation", "check knowledge consistency", or periodically as a health check.
---

# Check Knowledge Consistency

> Project values (ticket prefix, default branch, repo list) come from
> `devrig.toml` and `AGENTS.md` at the workspace root — read them; never assume.

Combines a mechanical pass (fast, deterministic) with a semantic pass (needs
an agent reading code) to catch documentation that's gone stale — the gap
`scripts/detect-doc-drift.mjs` can't close on its own because it can't read code.

## Usage

`/check-knowledge-consistency` — checks everything.
`/check-knowledge-consistency <system>` — scope to one system/repo.

## Step 1 — Mechanical pass

Run both, capture the output, don't re-derive what they already found:

```bash
node scripts/validate-knowledge.mjs
node scripts/detect-doc-drift.mjs
```

## Step 2 — Semantic checks

Run these per affected system/repo (in parallel where independent). Only
check repos that are actually cloned locally — note as "not checked (repo not
cloned)" for any that aren't, rather than skipping silently.

**Commands ↔ package.json** — for each system in `.ai/commands.yaml`, read
that repo's `package.json` `scripts` and confirm every referenced `npm run
<script>` exists. Flag any command in `.ai/commands.yaml` that would fail.

**Ownership ↔ CODEOWNERS** — if the repo has `.github/CODEOWNERS`, compare
the paths/owners there against `.ai/ownership.yaml`'s `areas`. Flag areas
whose owners disagree, and CODEOWNERS entries with no corresponding area.

**Architecture docs ↔ repos** — for each `architecture/` doc's "Repos
involved"/systems table, confirm every named repo still exists in
`.ai/systems.yaml`/`devrig.toml`, and spot-check a few "Source pointers" —
does the cited path/symbol still exist? Use `mcp__semble__search` or a direct
file check, not a full re-read of the repo.

**Runbooks ↔ scripts** — for each numbered step that runs a command or
script, confirm the script/file it references still exists at that path.

**API docs ↔ API routes** — for each documented endpoint/event in an
as-built doc's "Contracts" section, `mcp__semble__search` the backing repo
for that exact name. Flag anything not found (renamed/removed) and, if you
have time, anything found in code but undocumented (new surface).

**ADRs ↔ implementation** — for `accepted` ADRs touching a system under
review, spot-check whether the "Decision" is still what the code actually
does. Flag contradictions — don't assume an old ADR is still followed just
because no one marked it superseded.

## Step 3 — Report

Group findings by drift type, most actionable first:

```markdown
## Knowledge consistency — <scope>

### Mechanical (validate-knowledge / detect-doc-drift)
<pass-through of Step 1's output, only if non-empty>

### Commands vs package.json
- <repo>: `.ai/commands.yaml` `test` runs `npm run test:unit`, but package.json has no such script — <file:line or "not found">

### Ownership vs CODEOWNERS
- <finding, or "consistent">

### Architecture vs repos
- <finding, or "consistent">

### Runbooks vs scripts
- <finding, or "consistent">

### API docs vs routes
- <finding, or "consistent">

### ADRs vs implementation
- <finding, or "consistent">
```

Omit a subsection only if it was genuinely not applicable (e.g. no CODEOWNERS
file exists at all) — write "consistent" rather than omitting a section that
was actually checked and found nothing wrong, so the reader knows it was
checked.

## Step 4 — Next step

For each finding, suggest either `/write-doc` (doc needs updating) or
`/capture-learning` (if this surfaced during a task's wrap-up) rather than
fixing it inline here — this skill's job is to find drift, not resolve it.
