# Adding a skill

Skills are agent-agnostic and live here in `.agents/skills/`; Claude Code
finds them through symlinks in `.claude/skills/`.

## Three steps

1. **Create the skill** — copy this template:

   ```bash
   cp -r .agents/skills/_template .agents/skills/<name>
   ```

   Edit `.agents/skills/<name>/SKILL.md`: set `name:` to `<name>`, write the
   `description:` for the agent that decides whether to invoke it, and fill in
   the steps. Delete this README from the copy. Add supporting files
   (checklists, templates, references) next to `SKILL.md` and link them
   relatively.

2. **Symlink it for Claude Code** (relative link, from the repo root):

   ```bash
   ln -s ../../.agents/skills/<name> .claude/skills/<name>
   ```

3. **List it** in `CLAUDE.md`'s skill list so agents know it exists.

## Conventions

- One skill = one workflow. If a skill needs a mode flag for two unrelated
  jobs, it's two skills.
- Keep the "project values come from `.setup`/`AGENTS.md`" line — it keeps
  skills portable when this template is reused.
- Supporting files pattern: `references/` for per-repo facts (one file per
  repo, `_example-repo.md` shows the shape), `templates/` for output the
  skill fills in.
- `_template/` itself is deliberately **not** symlinked into `.claude/skills/`
  — it's a scaffold, not a live skill.
