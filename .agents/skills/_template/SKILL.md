---
name: my-skill
description: >
  Write this for the AGENT deciding whether to invoke the skill, not for
  humans browsing. Include: what it does, the triggers (the exact phrases a
  user might say — "deploy the api", "check the logs"), and what inputs it
  accepts. A skill with a vague description never gets invoked.
---

# My Skill

> Project values (ticket prefix, default branch, repo list) come from `.setup`
> and `AGENTS.md` at the workspace root — read them; never assume.
> Keep this line in every skill so it stays portable across projects.

## Usage

<!-- The slash-command forms, with an example per form:
`/my-skill <arg>` — e.g. `/my-skill deploy staging`
-->

## Steps

<!-- Numbered, imperative instructions to the agent. Good skills:
- Say which tools to use (exact MCP tool names, exact shell commands)
- Say what to do on failure ("if X fails, report and stop — do NOT do Y")
- Say when to ask the user (one AskUserQuestion round max) vs. infer
- Reference supporting files relative to this directory:
  [checklist.md](checklist.md), [templates/foo.md](templates/foo.md)
-->

1.

## Output

<!-- What the agent should show the user at the end — exact format if it
matters. Skills that end with "suggest /other-skill" chain well. -->
