# Workspace — Claude guidance

@AGENTS.md

## Claude Code specifics

This workspace also configures Claude-Code-only tooling not covered by `AGENTS.md`:

- **Skills** (`.claude/skills/`, symlinked from `.agents/skills/` — see
  `AGENTS.md`): use these for the corresponding workflows instead of
  reinventing them ad hoc.
  - `/start-task <TICKET-ID>` — fetch the ticket, assign it, move it to
    In Progress, sync the default branch
  - `/raise-pr` — branch, commit, push, and open PRs for every affected repo
  - `/code-review` — review a PR, branch, or local diff (full or light mode)
  - `/write-doc` — write design docs, as-builts, ADRs, and runbooks into the
    knowledge base
  - `/create-ticket` — file well-formed epics, stories, tasks, and bugs
- **semble MCP server**: semantic code search across repos — prefer it over
  grep-and-read for "where is X implemented" questions.
- **Issue tracker MCP** (`linear` or `atlassian`, wired up by `setup.sh`
  according to `ISSUE_TRACKER` in `devrig.toml`): issue tracking. `/start-task`,
  `/raise-pr`, and `/create-ticket` currently call **Linear's** MCP tool
  names (`mcp__linear__*`) — if `ISSUE_TRACKER` is `jira` or `other`, adapt
  those skills' tool calls to your tracker's MCP server before relying on
  them. Ticket ids use the `TICKET_PREFIX` defined in `devrig.toml`.
