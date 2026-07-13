# Review Checklist

Use this checklist after you identify the correct repo and base branch.
`<BASE>` means the `DEFAULT_BRANCH` from the workspace `devrig.toml`.

## 1. Establish Review Scope

- Confirm the repository root (one of the repos in `devrig.toml`'s `repos` list).
- All repos base off `<BASE>`. Confirm the branch actually being diffed matches
  `<BASE>` (release branches like `staging`/`production`/`prod` are deploy
  targets, not review bases — do not diff against them by mistake).
- Review the full diff from the merge base, not just the latest commit.
- Check whether local staged or unstaged changes affect the review context.
- Note whether the change set spans client, backend, infra/CI, or a shared
  data model that multiple repos read (see the systems table in `AGENTS.md`
  and the per-repo reference files for which repos share what).

## 2. Full-Picture Review

- Read beyond the changed hunk when behavior depends on another repo or
  service reacting to the same data.
- Check for partial refactors, dead paths, TODO-like loose ends, and missing
  follow-through changes.
- Verify tests were updated where business rules changed. Check the repo's
  reference file for whether a test suite exists — do not accept "tests pass"
  as evidence in a repo that has none, and don't penalize an absent test in a
  repo that has never had one, but do flag if this PR was the natural place to
  start one (e.g. new auth logic, new webhook handler).
- Flag risky areas even if they are not obvious bugs yet.

## 3. Breaking-Change Review

Treat these as breaking until shown otherwise:

- Removed or renamed fields on data models that more than one repo reads —
  especially models **duplicated** across repos rather than shared via a
  package, where a rename in one is invisible to the other until someone
  manually mirrors it.
- Narrowed validation or stricter parsing on any endpoint a client consumes.
- Response shape changes on endpoints consumed by another repo or shipped client.
- Event name or payload changes on any realtime/message contract (websockets,
  queues, push) — producer and consumer must change together.
- Enum value changes on fields other repos switch on.
- Push/notification payload shape changes — clients often parse these by key.
- Webhook payload or signature changes.
- Permission or auth-scope changes (token claims, role middleware).
- Infra or CI/CD changes that alter deploy behavior.

Check for:

- Backward compatibility for any client that cannot be force-upgraded
  (e.g. a mobile app: store review lag can strand users on an old client
  for days).
- Safe rollout sequencing between backend and client repos — backends must
  tolerate the currently-shipped client.
- Deprecation handling where needed.
- Clear coordination notes when a change spans repos.

## 4. Sensitive-Data Review

<!-- CUSTOMIZE: replace this section's opening line with your product's
highest-sensitivity data path (payments, health data, location, minors' data,
PII exports...) and add product-specific checks. The generic checks below
apply everywhere. -->

- Any change to who can read another user's data: verify an
  ownership/membership check exists — do not accept a bare "look up by id"
  with no relationship check to the requesting user.
- Any change to retention, precision, or access scope of personal data:
  verify the new behavior is intentional and documented.
- Safety- or money-critical code paths (emergency alerts, payment capture,
  irreversible deletes): treat as critical — verify failures are not silently
  swallowed (missing token, network failure) without fallback or logging.
- Verify sensitive values are not logged in plaintext to general application
  logs or crash reporting.

## 5. Auth & Token Review

- Verify token handling calls a signature-verifying function (e.g. `jwt.verify`
  with the shared secret/key), not decode-only (`jwt.decode`). Never approve
  new code that copies a decode-only pattern, even if one already exists in
  the repo — and if a change touches such a file, note that fixing it is
  in scope.
- Any new endpoint or realtime handler: confirm it runs behind the auth
  middleware (or explicitly document why it's public, e.g. a signed
  third-party webhook).
- Confirm shared secrets (e.g. a JWT secret used by more than one service)
  are read from environment/secret storage, never hardcoded, and that all
  consumers would still agree on token validity if one side changes its
  verification logic.
- Admin surfaces: any PR that wires an admin UI to real backend endpoints
  deserves extra scrutiny — that is the point where a weak admin-auth check
  starts exposing every user's data.

## 6. Secrets & CI Review

- Scan the diff for any new committed key/credential/`.env` file,
  service-account JSON, or hardcoded password/token in application code or CI
  config (`.github/workflows/*.yml` and equivalents).
- If CI config changed, confirm secrets are referenced via the CI system's
  secret store (`${{ secrets.* }}` on GitHub Actions), not inlined.
- If a new workflow was added, confirm it doesn't widen the trigger surface
  unexpectedly (e.g. running deploy steps on arbitrary branches).

## 7. Cross-Repo Impact Review

Inspect adjacent repositories when the change affects shared contracts or
shared data. The per-repo reference files (`references/<repo>.md`) document
what each repo shares with its siblings — build that table as part of
customizing this skill.

If a sibling repo is likely impacted, say whether:

- Matching code changes are required
- Coordinated rollout is required (which repo needs to ship first/last)
- A note in the knowledge base (design docs/ADRs) is warranted

## 8. Perspective Sweep

Before finishing, review the change through these lenses:

- Senior engineer: correctness, edge cases, maintainability, tests
- Sensitive data: who can see whose data, retention, safety-critical flows
- DevOps: deployability, observability, rollback
- SecOps: auth verification correctness, secret handling, webhook signature checks
- Lean tech lead: complexity, ownership, hidden cross-repo dependencies,
  coordination cost

## 9. Review Output Checklist

- Findings are listed first and ordered by severity.
- Breaking changes are called out explicitly.
- Cross-repo coordination is called out explicitly.
- Sensitive-data, auth, and webhook-signature checks are mentioned when
  relevant, even briefly.
- Residual risks or testing gaps are mentioned even when no concrete bug is
  found.
