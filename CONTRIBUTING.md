# Contributing to devrig

Thanks for helping make devrig better! All kinds of contributions are welcome.

## What we're looking for

- **Bug fixes** — anything in `setup.sh`, the git hooks, or the MCP config
  that breaks on your platform or shell.
- **New generic skills** — workflows that are useful to *any* team, written
  the devrig way (see `.agents/skills/_template/`). Project-specific skills
  belong in your own workspace, not the template.
- **Better docs** — clearer README sections, better examples, fixes to the
  customization checklist.
- **README translations** — add `docs/README.<lang>.md` mirroring the English
  README, and add the language to the switcher bar at the top of **every**
  README (English one included).
- **Tooling integrations** — support for more agents/editors, as long as the
  agent-agnostic `.agents/` + symlink pattern is preserved.

## Ground rules

1. **Keep it generic.** Nothing project-specific: no hardcoded repo names,
   ticket prefixes, org names, or stacks. Values come from `devrig.toml`;
   conventions come from `AGENTS.md`. If a skill needs a project fact, it
   reads it — never assumes it.
2. **Keep `setup.sh` idempotent.** Every function must converge: re-running
   setup must always be safe and produce the same state. Guard appends with
   `grep -q`, skip generation when the file exists, prefer "ensure present"
   over "add".
3. **Mind the shells.** `setup.sh` is bash (and must work on macOS's bash
   3.2 — guard empty arrays with `${ARR[@]+"${ARR[@]}"}`). `devrig.toml` is
   real TOML, not shell — both `setup.sh` and the POSIX-sh git hooks read it
   by shelling out to `python3`'s `tomllib` (falling back to the `tomli`
   package on pre-3.11 Python), never by sourcing or regexing it.
4. **Skills are agent-agnostic.** Canonical copies live in
   `.agents/skills/<name>/`; `.claude/skills/<name>` is a relative symlink.
   Never put content directly in `.claude/skills/`.

## Workflow

1. Fork, then branch from `main`: `<short-description>` or
   `fix/<short-description>`.
2. Make your change. For `setup.sh` changes, smoke-test both paths:
   the fail-fast guard (example `devrig.toml`) and a real run with an empty
   `repos` list.
3. Check nothing project-specific leaked in: `grep -ri <your-project> .`
4. Open a PR describing what changed and why — screenshots welcome for
   README changes.

## Reporting issues

Open a [GitHub issue](https://github.com/lakpriya1s/devrig/issues) with your
OS, shell, and the full output of the failing command. For `setup.sh` issues,
include your `devrig.toml` (redact anything private).
