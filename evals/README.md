# Evals

Questions with known-good answers, used to measure whether this workspace is
actually getting easier for agents to work in over time — not just whether it
*feels* more organized.

## Files

| File | Category |
|---|---|
| `retrieval.yaml` | Direct retrieval, dependency questions — "where is X", "what depends on Y" |
| `architecture.yaml` | Architecture understanding, historical decisions, impact analysis — "why was X chosen", "what breaks if I change Y" |
| `workflows.yaml` | Operational questions — "how do I run tests", "what must I do before Z" |
| `semble-vs-graphify.md` | Methodology for comparing retrieval tools on the same question set |

Each entry needs `expected_sources` filled in with real paths once your
`knowledge/`, `AGENTS.md`, and repos have real content — the versions
committed here are templates with the illustrative example questions from
the workspace roadmap, not yet wired to a specific project.

## Running an eval by hand

There's no automated eval harness wired up yet (that's real future work — see
[Automating this](#automating-this)). Until then:

1. Start a fresh agent session (no prior context from working on the answer).
2. Ask it the `question` verbatim.
3. Score the answer against these dimensions:

| Dimension | What it measures | How to score |
|---|---|---|
| Retrieval accuracy | Did it find the right source(s) at all? | Compare cited sources to `expected_sources` |
| Source correctness | Are the cited sources actually authoritative (not a stale/superseded doc)? | Check `authority`/`status` of each cited doc |
| Token consumption | How much context did it burn getting there? | Rough count from the session, or `rtk gain` if using rtk |
| Answer completeness | Did it answer the whole question, or just part? | Judgment call against the question's intent |
| Hallucination rate | Did it state anything as fact that isn't traceable to a source it read? | Check every factual claim against `expected_sources` or the actual repo |

4. Record the result (pass/partial/fail per dimension) somewhere you can
   compare over time — a spreadsheet is fine to start.

## Automating this

Once this matters enough to run regularly: script the "ask fresh agent, grade
against `expected_sources`" loop (the `Workflow` tool's `agent()` +
`schema` option is a natural fit — one eval item per agent call, graded by a
judge agent comparing its cited sources against `expected_sources`). Not
built yet; this file's job for now is to make sure the *questions* exist so
scripting the runner later is straightforward.
