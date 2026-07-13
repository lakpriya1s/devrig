# <repo-name> — Review Reference

<!-- Copy this file to <repo-name>.md and replace every section with verified
facts about that repo. Delete these comments. -->

## Repo facts

- **Default branch:** <BASE from devrig.toml>. <Note any release/deploy branches
  that must not be used as review bases.>
- **Stack:** <framework, database, key services>
- **Package manager:** <npm/yarn/pnpm/uv/...> <Note missing version pins if any.>
- **Tests:** <"Jest suite in __tests__/" or "No test suite in this repo — don't
  treat 'no tests' as a new finding unless the PR is the natural place to
  start one.">

## Layout

- `<dir>/` — <what lives here, and anything a reviewer must know about it>

## Deep checks

<!-- The repo-specific things a generic review would miss. For each known
pre-existing gap: describe it, mark it "pre-existing — don't re-flag on
unrelated PRs", and state what a PR touching that code must do. Example: -->

- **<Known gap> (severity, pre-existing).** <What it is, why it matters.
  (a) if a PR touches this file, treat fixing it as in-scope and call it out;
  (b) never approve new code that copies the pattern.>

## CI checks

- <Which workflows exist, what they actually verify, and which branches
  trigger them. Say explicitly if there is no PR-gating check.>

## Cross-repo impact

- **<sibling-repo>** — <what is shared: duplicated models, secrets, API/event
  contracts — and what must change together>

## Common pitfalls

- <The mistakes PRs in this repo actually make, one line each.>
