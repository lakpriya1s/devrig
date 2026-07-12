# Per-repo doc references

Write **one file per repo** in your `.setup` `REPOS` list, named `<repo>.md`.
The write-doc skill loads the files for repos a doc actually touches; if one
is missing, it works from that repo's `AGENTS.md` and notes the gap.

Copy [`_example-repo.md`](_example-repo.md) as a starting point. These
references serve documentation (not review), so focus on:

- Where the truth lives: entry points, key directories, config
- Flows worth documenting (the feature paths a new engineer asks about)
- Gotchas to surface (things the code does that nobody expects)
- Terminology the repo uses that docs must match

Files starting with `_` are documentation/scaffolding, not loaded as repo
references.
