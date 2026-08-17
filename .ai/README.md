# .ai/ — machine-readable workspace metadata

Structured mirror of `AGENTS.md`/`POLICY.md`, for scripts/CI to parse
reliably (Markdown tables aren't machine-parseable). The Markdown files stay
the human-readable source of truth — keep both in sync when you edit either.

| File / folder | Mirrors | Validated by |
|---|---|---|
| `systems.yaml` | `AGENTS.md`'s Systems table | `scripts/validate-ai-config.mjs` |
| `commands.yaml` | `AGENTS.md`'s Commands table | `scripts/validate-ai-config.mjs` |
| `ownership.yaml` | (no Markdown equivalent yet) | parsed, not schema-checked |
| `policies.yaml` | `POLICY.md`'s forbidden/approval-required/protected-path/data-handling/role sections | `scripts/validate-ai-config.mjs` |
| `risk-levels.yaml` | `POLICY.md`'s Risk levels table | `scripts/validate-ai-config.mjs` |
| `schemas/` | JSON Schemas for the four files above | used by `validate-ai-config.mjs` |
| `context/<TICKET-ID>.json` | Compact, reusable task context — written by `/start-task`, read by `/plan-task` | not validated (ephemeral working state) |
| `runs/<TICKET-ID>/` | Observability trail for one task's full lifecycle — see below | not validated (audit trail, not config) |

## `runs/<TICKET-ID>/`

Written incrementally across a task's lifecycle so you can see what an agent
actually did without digging through chat history:

| File | Written by | Contents |
|---|---|---|
| `context.json` | `/start-task` | Same shape as `.ai/context/<TICKET-ID>.json` |
| `plan.md` | `/plan-task` | The plan as approved (Step 4 of that skill) |
| `verification.md` | `/verify-change` | The verification evidence block(s) |
| `changed-files.txt` | `/raise-pr` | `git diff --stat` per affected repo |
| `summary.md` | `/capture-learning` | What was captured as permanent knowledge, and what was cleaned up |

None of this is sensitive-prompt or secret data — just which steps ran, what
was decided, and what changed. Don't put secrets, tokens, or raw user data in
any of these files (see `POLICY.md`'s data-handling rules).

This is a record, not a gate — nothing currently reads it back automatically
to enforce sequencing. Its value is *"which searches were useful, how often
did tests fail, where did agents get stuck"* — the kind of question you can
only answer if the trail exists. Directories accumulate one per ticket; clean
up old ones periodically the same way you'd prune old branches.
