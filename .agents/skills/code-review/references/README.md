# Per-repo review references

Write **one file per repo** in your `.setup` `REPOS` list, named
`<repo>.md` (e.g. `acme-api.md`). The code-review skill loads the file for
the repo under review; if it's missing, the review falls back to generic
checks and notes the gap.

Copy [`_example-repo.md`](_example-repo.md) as a starting point. Keep each
file to facts you have **verified in the code** — stale or guessed facts are
worse than none. Good contents:

- Stack, package manager, deploy pipeline (what CI checks actually exist)
- Whether a test suite exists, and where
- Layout: the directories a reviewer needs to know
- Known pre-existing gaps (so reviews don't re-flag them on unrelated PRs —
  but do flag PRs that touch that exact code)
- Hot spots: the files/patterns where bugs in this repo tend to hide
- Cross-repo impact: what this repo shares with siblings (duplicated models,
  shared secrets, API/event contracts)

Files starting with `_` are documentation/scaffolding, not loaded as repo
references.
