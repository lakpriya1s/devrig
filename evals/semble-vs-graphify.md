# Semble vs. Graphify: evaluation methodology

> This lives in `evals/`, not `knowledge/` — it's a methodology doc for
> running the comparison, not part of the frontmatter-tracked knowledge base.
> If you run this and reach a verdict, that verdict belongs in
> `knowledge/decisions/` as an ADR (see the bottom of this file), with real
> frontmatter.

> This is a methodology, not a verdict — run it against your own repos before
> deciding whether to run Semble alone, Graphify alone, or both. Don't decide
> based on marketing; decide based on your own eval results.

## Why compare at all

`AGENTS.md` currently tells agents to reach for both: Semble for "where is
the information" and Graphify for relationship/impact questions. That's a
reasonable default, but it's untested against real usage. This eval exists to
find out whether that default holds, or whether one tool covers most of what
you need and the other is dead weight (extra retrieval policy an agent has to
hold in its head, for marginal benefit).

## Method

1. Assemble **~30 real questions** — pull from `evals/retrieval.yaml`,
   `architecture.yaml`, `workflows.yaml`, plus real questions you or your team
   have actually asked while working in this codebase. Cover all six
   categories:

   | Category | Example |
   |---|---|
   | Direct retrieval | "Where is X implemented?" |
   | Architecture understanding | "Why was X chosen?" |
   | Dependency questions | "What depends on X?" |
   | Historical decision questions | "Which ADR controls X?" |
   | Impact analysis | "What breaks if I change X?" |
   | Operational questions | "How do I run X?" |

2. For each question, run it three ways, each in a **fresh session** (no
   context carried over between runs, and no run sees another run's answer):
   - Semble only (disable/ignore Graphify for this run)
   - Graphify only (disable/ignore Semble for this run)
   - Both available (today's default)

3. Score each run against `evals/README.md`'s five dimensions: retrieval
   accuracy, source correctness, token consumption, answer completeness,
   hallucination rate.

4. Tabulate per category, not just overall — a tool can win on "dependency
   questions" and lose on "direct retrieval". The aggregate number hides that.

## Recording results

```markdown
## Results — <date>

| Category | Semble only | Graphify only | Both |
|---|---|---|---|
| Direct retrieval | | | |
| Architecture understanding | | | |
| Dependency questions | | | |
| Historical decisions | | | |
| Impact analysis | | | |
| Operational | | | |

## Verdict

<Keep both / Semble only / Graphify only / Needs another round>, and why.
```

Once you have real results, promote the verdict to an ADR
(`knowledge/decisions/`) — this is exactly the kind of architectural choice
`POLICY.md`'s ADR requirement is for, and it should be revisited if the
codebase or the tools change enough to invalidate the original numbers.
