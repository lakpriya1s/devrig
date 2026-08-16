# Workspace Policy

Human-readable policy for agents and contributors working in this workspace.
This file states the rules; nothing here is automatically enforced yet
(that's tracked separately — see the note at the bottom).

## Definition of Done

A task is complete only when:

1. Relevant tests pass (see each system's row in `AGENTS.md`'s Commands table).
2. Lint passes.
3. Type checking passes, where the stack has it.
4. Build succeeds, where applicable.
5. Documentation impact has been evaluated — updated in `knowledge/` if the
   change affects architecture, design, product behavior, or operations; or
   explicitly noted as not needed.
6. ADR requirement has been evaluated — see below.
7. Verification evidence has been recorded (see `/verify-change`), not just
   asserted.
8. A PR has been opened for every affected repo (`/raise-pr`).

Agents should never report a task as "done" without this evidence attached —
see [Verification evidence](#verification-evidence).

## Verification evidence

Report verification as evidence, not assertion:

```markdown
## Verification

Unit tests: PASS — `npm test`
Lint: PASS — `npm run lint`
Typecheck: PASS — `npm run typecheck`
Build: PASS — `npm run build`
Documentation: Updated `knowledge/design/<doc>.md`
ADR: Not required — implementation-only change
```

If a check doesn't apply to the repo (no lint config, no build step), say so
explicitly rather than omitting the line silently.

## ADR requirement

An ADR (`knowledge/decisions/`) is required when a change:

- Introduces or changes architecture spanning multiple systems
- Changes a database schema
- Changes authentication or authorization behavior
- Changes a public API contract or inter-service communication
- Touches major infrastructure or a framework choice
- Introduces or replaces a critical external service/dependency

A PR for such a change must say either:

```
ADR: knowledge/decisions/NNNN-<slug>.md
```

or

```
ADR not required: <one-line reason>
```

## Confidence and uncertainty reporting

When handing off work or answering a non-trivial question, state:

```markdown
## Confidence

High | Medium | Low

## Assumptions

- <anything taken as given without direct verification>

## Unverified

- <anything not directly checked, e.g. a production config>

## Human attention required

- <anything that changes user-facing behavior in a risky way>
```

## Sources and citations

Answers to architectural or "where is X" questions should end with:

```
Sources:

knowledge/decisions/000N-<slug>.md
knowledge/design/<slug>.md
<repo>/<path>:<symbol>
```

This gives traceability and lets a human spot-check without re-deriving the answer.

---

*Phase 2 will add machine-enforceable policy: `.ai/policies.yaml` (forbidden
actions, approval-required actions, protected paths), `.ai/risk-levels.yaml`,
and CLI/CI enforcement on top of this document. Until then, this file is the
only enforcement — agents and reviewers are expected to actually follow it.*
