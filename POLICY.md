# Workspace Policy

Human-readable policy for agents and contributors working in this workspace.
The machine-readable mirror lives in `.ai/policies.yaml` and
`.ai/risk-levels.yaml` — keep both in sync when you edit either. CI enforces
what it can (`.github/workflows/validate.yml` validates the yaml against
`.ai/schemas/`; `.github/workflows/knowledge-check.yml` requires an ADR when a
protected path changes) — see [Enforcement status](#enforcement-status) for
what's still human-only.

## Policy areas

| Area | Question it answers | Where |
|---|---|---|
| Access | What may an agent read? | Everything in the workspace is readable by default; `RESTRICTED` data (below) is the one exception. |
| Actions | What can an agent modify, and what needs a human first? | [Forbidden actions](#forbidden-actions), [Approval-required actions](#approval-required-actions), [Agent roles](#agent-roles) |
| Data | What can be sent to external models? | [Data handling](#data-handling) |
| Quality | What must pass before a task is done? | [Definition of Done](#definition-of-done) |
| Knowledge | When must documentation change? | [ADR requirement](#adr-requirement), `knowledge/README.md` |
| Security | What's outright prohibited? | [Forbidden actions](#forbidden-actions), [Protected paths](#protected-paths) |
| Approval | When is a human required before proceeding? | [Approval-required actions](#approval-required-actions), [Risk levels](#risk-levels) |
| Audit | What evidence must be preserved? | [Verification evidence](#verification-evidence), [Sources and citations](#sources-and-citations) |

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

## Forbidden actions

An agent must never do any of the following, in this workspace or any
project repo, regardless of task or user instruction:

- Commit secrets (API keys, tokens, `.env` files, credentials)
- Force-push the default branch
- Disable security checks (skip signature/webhook verification, remove auth checks) to make something pass
- Bypass required tests (`--no-verify`, commenting out a failing test, marking it skip) instead of fixing them
- Delete audit logs or verification evidence
- Modify production data directly (outside a reviewed migration/runbook)

If asked to do one of these, refuse and explain why — see `.ai/policies.yaml`'s `forbidden_actions`.

## Approval-required actions

These require explicit human sign-off before proceeding, even if an agent is
technically capable of doing them:

- Production deployment
- Authentication changes
- Billing changes
- Database migrations
- Secret rotation
- Destructive data changes

See `.ai/policies.yaml`'s `approval_required` for the machine-readable list,
and [Agent roles](#agent-roles) for which roles hit this by default.

## Protected paths

Reading is always permitted. Modifying anything under these paths (see
`.ai/policies.yaml`'s `protected_paths` for the authoritative glob list — this
is the illustrative default) requires human approval:

```text
infrastructure/production/**
migrations/**
auth/**
billing/**
.github/workflows/release.yml
```

`.github/workflows/knowledge-check.yml` enforces the mechanical half of this
for ADRs (protected path touched ⇒ an ADR must be in the same diff); it
can't judge whether human approval was actually obtained, so reviewers still
check that by hand.

## Risk levels

Requirements scale with risk. See `.ai/risk-levels.yaml` for the
machine-readable version.

| Level | Examples | Minimum bar |
|---|---|---|
| Low | Documentation, tests, internal refactor | Definition of Done |
| Medium | Dependency upgrade, API behavior change | Definition of Done + explicit test coverage for the behavior change |
| High | Authentication, database migration, billing, production infrastructure | Definition of Done + ADR + human approval before merge |
| Critical | Secret rotation, destructive data change, production deployment | Definition of Done + ADR + human approval before **and** during execution (no unattended runs) |

When a task's risk level is unclear, treat it as one level higher than your
first guess and say so — this is cheap insurance against under-classifying.

## Data handling

Classify data before sending anything to an external model provider:

| Classification | External AI (hosted API) |
|---|---|
| `PUBLIC` | Allowed |
| `INTERNAL` | Allowed, with secrets/credentials stripped first |
| `CONFIDENTIAL` | Approved providers or local/self-hosted models only |
| `RESTRICTED` | Agent access prohibited outright |

Never expose, to any model or in any doc/log an agent writes: API keys,
passwords, access tokens, private keys, production database exports,
customer secrets, or sensitive PII. See `.ai/policies.yaml`'s
`never_expose` / `data_handling` for the machine-readable version.

## Agent roles

Not every agent invocation needs full read-write access. Where your tooling
supports scoping it (e.g. a dedicated review agent, a read-only planning
pass):

| Role | Scope |
|---|---|
| Planner | Read-only |
| Implementer | Read-write, scoped to the current task's repos/branch |
| Reviewer | Read-only diff analysis — independent from the implementer where possible |
| Documenter | Read-write to `knowledge/` |
| Release agent | Approval-required for every action (see [Approval-required actions](#approval-required-actions)) |

See `.ai/policies.yaml`'s `agent_roles`. This workspace doesn't currently
enforce role separation mechanically (most agent tools run one role at a
time by convention, not by permission system) — treat it as a convention to
follow, not a control to rely on.

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

## Enforcement status

| Rule | Enforced by |
|---|---|
| `.ai/*.yaml` matches its JSON Schema | CI (`.github/workflows/validate.yml`) |
| Knowledge frontmatter valid, links resolve, ADR ids unique, index fresh | CI (`.github/workflows/knowledge-check.yml`) |
| Protected path changed ⇒ ADR present in the same diff | CI (`.github/workflows/knowledge-check.yml`, via `scripts/check-adr-requirement.mjs`) — mechanical presence check only, not a judgment of adequacy |
| Everything else on this page (forbidden actions, approval-required actions, agent roles, data handling, DoD, verification evidence) | **Not mechanically enforced.** Agents and reviewers are expected to actually follow it; nothing in CI or the CLI currently blocks a violation. |

Closing that last row — CLI wrappers or git hooks that check `.ai/policies.yaml`
before allowing an action — is future work, not yet built.
