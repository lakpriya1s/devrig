<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**ඔබගේ සියලුම repos සඳහා එක rig එකක් — AI සූදානම්, multi-repo dev workspace template එකක්.**

[![npx create-devrig](https://img.shields.io/npm/v/create-devrig?label=npx%20create-devrig&color=22D3EE&style=flat-square)](https://www.npmjs.com/package/create-devrig)
[![Use this template](https://img.shields.io/badge/Use%20this-template-3B82F6?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [हिन्दी](README.hi.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [한국어](README.ko.md) · **සිංහල**

</div>

---

## devrig යනු කුමක්ද?

devrig යනු *meta-repo* එකකි: ඔබේ ව්‍යාපෘතියේ සියලුම repos **සහ** ඒවා හරහා
සංවර්ධනය කිරීමට භාවිත වන AI මෙවලම් එකම folder එකක තබා ගන්නා අතර, මෙම repo
එක version කරන්නේ මෙවලම් පමණි — ඔබේ ව්‍යාපෘති repos `setup.sh` මගින් එකිනෙක
අසල clone වන අතර untracked ලෙස පවතී. සියල්ල වින්‍යාස වන්නේ එක **`devrig.toml`**
ගොනුවකින්.

| | ඔබට ලැබෙන දේ |
|---|---|
| 🧠 | **AI workflow skills** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (agent-agnostic ලෙස `.agents/skills/` තුළ, Claude Code සඳහා symlink කර ඇත; opencode ද වින්‍යාස කර ඇත) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — grep කර ගොනු කියවීම වෙනුවට agents MCP හරහා භාවිත කරන semantic code search |
| 🕸️ | **[graphify](https://github.com/Graphify-Labs/graphify)** — repo එකකට එකක් වන knowledge graph; agents grep කිරීම වෙනුවට එය query කරයි, git hooks එය නැවුම්ව තබා ගනී |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — Claude Code සඳහා token ඉතිරි කරන command proxy |
| 🎫 | **Issue tracker MCP** — Linear, Jira, හෝ ඔබේම එකක්; `setup.sh` විසින් interactive ලෙස තෝරවයි |
| 🛡️ | **Protected-branch git hooks** — කිසිදු repo එකක default branch එකට වැරදීමකින් commit/push වීම වළක්වයි |
| 📚 | **`knowledge/`** — AI මෙවලම් index කර ලියන markdown දැනුම් පදනමක සැකිල්ල (architecture, ADRs, design docs, runbooks) |
| 🖥️ | **ස්වයංක්‍රීයව සෑදෙන VS Code multi-root workspace** — සියලුම repos එක window එකක |

## ඉක්මන් ආරම්භය

වේගවත්ම ක්‍රමය — clone කිරීමකින් තොරව, එක command එකක්:

```bash
npx create-devrig my-project
```

[`create-devrig`](https://github.com/lakpriya1s/create-devrig) මෙම template එක fetch කර (git history නොමැතිව), `my-project/` හි නව git repo එකක් initialize කර, වහාම interactive setup wizard එක ධාවනය කරයි — පහත විස්තර කර ඇති wizard එකමයි, වෙනම clone පියවරක් නැත.

GitHub UI එක කැමතිද, නැතහොත් ආරම්භයේ සිටම repo එක ඔබේ org යටතේ සාදන්න කැමතිද?

1. **[Use this template](https://github.com/lakpriya1s/devrig/generate)** ක්ලික් කර `your-org/your-project-workspace` සාදන්න.
2. Clone කර ධාවනය කරන්න:

   ```bash
   ./setup.sh
   ```

   පළමු වතාවේ ධාවනයේදී, `devrig.toml` තවමත් example අගයන් නම්, එය ඔබෙන් interactive
   ලෙස අසයි: ව්‍යාපෘති නම, පේළියක විස්තරයක්, GitHub org, clone කළ යුතු repos
   (space හෝ comma වලින් වෙන් කර කිහිපයක් එකවර paste කරන්න), issue tracker
   (**Linear**, **Jira**, හෝ **other** — මෙනුවකින් තෝරන්න), ticket prefix,
   default branch, සහ feature toggles — පසුව එය ඔබ වෙනුවෙන් `devrig.toml`
   ලියා, devrig හි own template files ඉවත් කර, ඒවා වෙනුවට *ඔබේ* ව්‍යාපෘතිය
   සඳහා `README.md` එකක් සාදයි. අතින් සංස්කරණය කිරීමට කැමතිද? script ධාවනය
   කිරීමට පෙර ඔබම `devrig.toml` පුරවන්න, එවිට එය ප්‍රශ්න මඟ හරියි.
3. මෙම folder එකෙන් `claude` ධාවනය කර වැඩ අරඹන්න.

කුමන ක්‍රමය භාවිත කළත්, ඉන්පසු Claude Code තුළ: `/mcp` ධාවනය කර වින්‍යාස කළ tracker server එක
(**linear** හෝ **atlassian**) authenticate කරන්න (එක් වරක් OAuth; **semble**
ට auth අවශ්‍ය නැත), rtk hook ක්‍රියාත්මක වීමට Claude Code එක වරක් restart
කරන්න. graphify සක්‍රීය නම්, එක් එක් repo එකේ root එකෙන් වරක් `graphify update .` ධාවනය කර graph එක සාදන්න — ඉන් පසු git hooks එය නැවුම්ව තබා ගනී.

## 🤖 ඔබේ AI agent සමඟ ආරම්භ කරන්න

### දැනටමත් ඔබේ repos තිබේද?

මේ template එකෙන් workspace එකක් දැන් සෑදුවාද? මෙය ඔබේ AI coding agent
(Claude Code, Cursor, opencode, …) වෙත paste කර ඉතිරි සැකසුම ඔහු සමඟ
අවසන් කරන්න:

```text
I just created a workspace from the devrig template
(https://github.com/lakpriya1s/devrig). Help me set it up:

1. Read README.md and AGENTS.md to understand the workspace.
2. Run ./setup.sh with me, relaying its interactive prompts (project name,
   description, GitHub org, repos, issue tracker, ticket prefix, default
   branch, feature toggles) so I can answer them — then help me fix anything
   it flags. It personalizes the workspace: devrig's own template files are
   removed and a README for my project is generated.
3. Work through the generated README's "Customize this workspace" checklist
   with me — fill AGENTS.md's Systems table and the per-repo skill references.
4. Commit the personalization on a task branch and open a PR.
```

### සම්පූර්ණයෙන්ම නව ව්‍යාපෘතියක් ආරම්භ කරනවාද?

තවම repos නැත, idea එකක් පමණද? සලකුණු කර ඇති කොටස ඔබේ ව්‍යාපෘති විස්තරයෙන් වෙනස් කර මෙය ඒ වෙනුවට paste කරන්න — agent ඔබව idea එකේ සිට ක්‍රියාත්මක workspace එකකට (නව repos ඇතුළුව) ගෙන යයි:

```text
I want to start a brand-new project using the devrig template
(https://github.com/lakpriya1s/devrig). Here's what I'm building:

[describe your project — what it does, who it's for, and any stack or
platform preferences you already have]

Help me go from this description to a working workspace:

1. Run `npx create-devrig <name>` to scaffold the workspace (pick a short
   project name from my description if I haven't given one).
2. Propose a repo breakdown and stack for each piece based on what I'm
   building — confirm with me before creating anything.
3. Create each repo on GitHub under my org (ask which) and scaffold it
   with its framework's starter command, committing the initial code.
4. Fill in devrig.toml (project name, description, org, the repos we just
   created, issue tracker, ticket prefix, default branch — make sure it
   matches what the new repos actually use) and run ./setup.sh.
5. Fill in AGENTS.md's Systems table and the generated README's "What's
   inside" table since you already know each stack.
```

## setup.sh කරන දේ

`setup.sh` idempotent ය — සියලුම repos සහ මෙවලම් යාවත්කාලීන කිරීමට ඕනෑම
වේලාවක නැවත ධාවනය කළ හැක. එය:

0. **පළමු වතාවේ පමණක්**: `devrig.toml` තවමත් example අගයන් නම්, ඉහත සියල්ල interactive ලෙස අසා `devrig.toml` ලියයි.
1. **Workspace එක personalize කරයි**: devrig හි own template files
   (`docs/`, `assets/`, `CITATION.cff`, `CONTRIBUTING.md`, `LICENSE`) ඉවත් කර
   `devrig.toml` වෙතින් *ඔබේ* ව්‍යාපෘතිය සඳහා `README.md` එකක් සාදයි. devrig
   repo එක ඇතුළතම මෙය මඟ හරින අතර, ඔබ සංස්කරණය කළ README එකක් කිසිවිටෙක
   overwrite නොවේ.
2. පූර්ව අවශ්‍යතා පරීක්ෂා කරයි (`git`, authenticate වූ `gh`; semble හෝ graphify සක්‍රීය නම් `uv` install කරයි).
3. `repos` හි සෑම repo එකක්ම එකිනෙක අසල clone කරයි (හෝ පිරිසිදු default-branch checkouts fast-forward කරයි), සහ `.git/info/exclude` හරහා ඒවා මෙම repo එකේ git status වෙතින් බැහැර කරයි.
4. මෙම repo එකට සහ clone වූ සෑම repo එකකටම protected-branch git hooks install කරයි.
5. `.mcp.json` / `opencode.json` ඔබේ `devrig.toml` toggles වෙත converge කරයි — `issue_tracker` අනුව `linear` හෝ `atlassian` (Jira) server එක එකතු කර, "other" තෝරා ඇත්නම් කිසිවක් එකතු නොකරයි — අතින් එකතු කළ MCP servers ආරක්ෂා වන අතර `.claude/settings.local.json` සාදයි.
6. semble install කර repo එකකට search index එකක් warm කරයි.
7. rtk install කර එහි Claude Code hook එක register කරයි.
8. graphify install කරයි: එහි skill එක `.agents/skills/` වෙත (Claude Code සඳහා symlink සමඟ), agents grep කිරීමට පෙර ඔවුන් graph එක වෙත යොමු කරන PreToolUse guards, සහ commit, checkout සහ merge වලින් පසු එම repo එකේ graph නැවත ගොඩනඟන git hooks.
9. VS Code සඳහා `<project>.code-workspace` සාදයි (දැනටමත් තිබේ නම් මඟ හරින බැවින් customize කර commit කිරීම ආරක්ෂිතයි).

## Customization පිරික්සුම් ලැයිස්තුව

යාන්ත්‍රික personalization එක `setup.sh` විසින්ම කරනු ලැබේ (`devrig.toml`
ලියයි, devrig ගේ template files ඉවත් කරයි, ඔබේ ව්‍යාපෘති README එක සාදයි).
ඉතිරි වන්නේ ඔබට පමණක් දන්නා දැනුමයි — generate වූ README හි
**"Customize this workspace"** කොටස මෙම පිරික්සුම් ලැයිස්තුවම ඔබේ workspace
එකට ගෙන එයි:

- [ ] `AGENTS.md` — **Systems** වගුව (repo එකකට එක පේළියක්: එය කුමක්ද, stack) සහ **Testing** කොටස පුරවන්න. සෑම skill එකක්ම කියවන source of truth මෙයයි. generate වූ README හි "What's inside" වගුවද යාවත්කාලීනව තබා ගන්න.
- [ ] `.agents/skills/code-review/references/` සහ `.agents/skills/write-doc/references/` — repo එකකට එක reference ගොනුවක් (`_example-repo.md` copy කරන්න). ඒවා නැතිවත් skills ක්‍රියා කරයි, නමුත් ඒවා සමඟ බෙහෙවින් තියුණුයි.
- [ ] `issue_tracker` `linear` නම්: `.agents/skills/create-ticket/SKILL.md` හි "Conventions" වගුව ඔබේ Linear workspace එක (teams, projects, labels) සමඟ තහවුරු කරන්න. `jira` හෝ `other` නම්: `/start-task`, `/raise-pr`, සහ `/create-ticket` හි `mcp__linear__*` calls ඔබේ tracker එකේ MCP tool නම් වලට ගැලපෙන ලෙස සකසන්න (එය සෑම skill එකකම මුලින්ම සඳහන් වේ).
- [ ] Toggle එකකින් අක්‍රීය කළ දේ ඉවත් කරන්න හෝ සකසන්න (උදා: semble භාවිත නොකරන්නේ නම් `CLAUDE.md` වෙතින් ඒ පිළිබඳ සටහන් ඉවත් කරන්න).

පසුව config අගයන් වෙනස් කිරීමට (tracker මාරු කිරීම, repo එකතු කිරීම),
`devrig.toml` කෙලින්ම සංස්කරණය කර `./setup.sh` නැවත ධාවනය කරන්න.

## ව්‍යුහය

| මාර්ගය | විස්තරය |
|---|---|
| `devrig.toml` | ඔබේ ව්‍යාපෘති වින්‍යාසය — සෑම මෙවලමක්ම කියවන එකම ගොනුව |
| `setup.sh` | Idempotent bootstrap/update script |
| `AGENTS.md` | Agent-agnostic source of truth (systems, branch නීති, conventions) |
| `CLAUDE.md` | Claude Code විශේෂිත; `AGENTS.md` import කරයි |
| `.agents/skills/` | සම්මත workflow skills (agent-agnostic) |
| `.claude/` | Claude Code settings, agents, skill symlinks |
| `.opencode/` | opencode agents සහ plugin config |
| `.mcp.json` / `opencode.json` | MCP servers (issue tracker, semble) |
| `git-hooks/` | සියලු repos බෙදාගන්නා hooks (`core.hooksPath`): protected-branch pre-commit / pre-push, සහ graphify graph නැවත ගොඩනැඟීම් |
| `knowledge/` | Markdown දැනුම් පදනම (architecture, decisions, design, runbooks, product, releases) |
| `<repo>/` (untracked) | `setup.sh` මගින් clone වන ඔබේ ව්‍යාපෘති repos |

## Skill එකක් එකතු කිරීම

[`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md) බලන්න.
කෙටියෙන්: `.agents/skills/<name>/SKILL.md` සාදා, `.claude/skills/` වෙත
symlink කර, `CLAUDE.md` හි ලැයිස්තුගත කරන්න.

## දැනුම් ග්‍රාෆය

`graphify` toggle සක්‍රීය විට එක් එක් repo එකට තමන්ගේම `<repo>/graphify-out/` එකක් ලැබේ — query කළ හැකි code graph එකක් (hubs, communities, ගොනු අතර සම්බන්ධතා), සමඟම සරල භාෂාවෙන් `GRAPH_REPORT.md` සහ interactive `graph.html`. Agents grep කර ගොනු කියවීම වෙනුවට මෙය භාවිත කරයි:

```bash
cd <repo>
graphify update .                                # සාදන්න/නැවුම් කරන්න (AST පමණි, API key අවශ්‍ය නැත)
graphify query "authentication ක්‍රියා කරන ආකාරය"  # සීමිත subgraph එකක්, grep ගොඩක් නොවේ
graphify path "LoginForm" "SessionStore"         # දෙකක් සම්බන්ධ වන ආකාරය
graphify explain "PaymentService"                # node එකක් සහ එහි අසල්වාසීන්
```

`setup.sh` CLI එක install කරයි, skill එක `.agents/skills/graphify/` හි තබයි, සොයන්නට පෙර agents graph එක වෙත යොමු කරන PreToolUse guards register කරයි, සහ නැවත ගොඩනැඟීමේ hooks install කරයි — post-commit සහ post-checkout `graphify hook install` මගින් ලැබෙන අතර, `git pull` එකකින් ද graph නැවුම් වන පිණිස devrig `git-hooks/post-merge` එකතු කරයි. Graphs, install කළ skill සහ generate කළ hooks සියල්ල gitignore කර ඇත: සෑම `./setup.sh` එකකදීම CLI එකෙන් නැවත සාදන බැවින් පැරණි කිසිවක් commit නොවේ.

## දැනුම් පදනම

නව design docs, architecture සටහන්, ADRs සහ runbooks markdown ලෙස PR හරහා
[`knowledge/`](../knowledge/) වෙත යයි — semble එය index කරන බැවින් agents
code සොයන ආකාරයටම design context සොයා ගනී. එය මෙම repo එකට වඩා විශාල වූ විට,
වෙනම `<project>-knowledge` repo එකක් ලෙස push කර, `devrig.toml` හි `repos` වෙත
එකතු කර, මෙහි folder එක මකා, `AGENTS.md` හි pointer එක යාවත්කාලීන කරන්න.

## ගැටලු නිරාකරණය

- **setup ට පසු `semble` හෝ `uv` හමු නොවේ** — නව shell එකක් විවෘත කර (PATH යාවත්කාලීන විය) `./setup.sh` නැවත ධාවනය කරන්න.
- **Claude හි tracker මෙවලම් නැත** — `/mcp` ධාවනය කර `linear` හෝ `atlassian` server එකේ OAuth ක්‍රියාවලිය සම්පූර්ණ කරන්න.
- **rtk ක්‍රියා නොකරයි** — Claude Code restart කරන්න; `rtk gain` මගින් commands proxy වන බව තහවුරු කරන්න.
- **`graphify query` කියන්නේ graph එකක් නැති බව** — එම repo එකේ root එකෙන් වරක් `graphify update .` ධාවනය කරන්න; hooks දැනටමත් ඇති graph එකක් පමණක් නැවුම් කරයි.
- **Commit කිරීමේදී graph නැවත ගොඩනැඟීම සිදු නොවේ** — එම repo එකේ `graphify hook status` ධාවනය කර `~/.cache/graphify-rebuild.log` බලන්න. `GRAPHIFY_SKIP_HOOK=1` එක් command එකකට එය නවත්වයි.
- **Repo එකක් යාවත්කාලීන නොවේ** — `setup.sh` local වෙනස්කම් ඇති හෝ task branch එකක ඇති repo එකක් කිසිවිටෙක ස්පර්ශ නොකරයි; පිරිසිදු default-branch checkouts පමණක් fast-forward කරයි.
- **setup.sh කිසිවක් නොඅසා කෙලින්ම "edit devrig.toml first" කියා අසාර්ථක වේ** — interactive terminal එකකට සම්බන්ධ විටදී පමණක් එය අසයි; script එකකින් හෝ CI එකකින් ධාවනය කරන්නේ නම් `devrig.toml` කලින්ම පුරවා තිබිය යුතුය.
- **Jira හෝ "other" තෝරා ඇත** — `atlassian` (Jira) MCP server එක ස්වයංක්‍රීයව සකසනු ලැබේ, නමුත් `/start-task`, `/raise-pr`, සහ `/create-ticket` තවමත් Linear හි MCP tool නම් call කරයි — ඔබ එම skills සකසන තෙක් `setup.sh` සෑම ධාවනයක අවසානයේම මේ ගැන අනතුරු අඟවනු ඇත.

## දායක වන්න

devrig භාවිත කරන සෑම කණ්ඩායමක් සමඟම එය වඩා හොඳ වේ. Bug වාර්තා, නව generic
skills, වඩා හොඳ docs සහ **README පරිවර්තන** — සියල්ල සාදරයෙන් පිළිගනිමු —
[CONTRIBUTING.md](../CONTRIBUTING.md) බලන්න. devrig ඔබේ කණ්ඩායමේ setup
කාලය ඉතිරි කළේ නම්, ⭐ එකක් අන් අයට එය සොයා ගැනීමට උදව් වේ.

## බලපත්‍රය සහ උපුටා දැක්වීම

[MIT බලපත්‍රය](../LICENSE) යටතේ නිකුත් කර ඇත.

ඔබේ වැඩ හෝ ලේඛනවල devrig භාවිත කරන්නේ නම් උපුටා දැක්වීමක් අගය කරමු —
GitHub හි **"Cite this repository"** බොත්තමේ ([`CITATION.cff`](../CITATION.cff)
මගින්) විස්තර ඇත, නැතහොත්:

> Senevirathna, L. (2026). *devrig: a multi-repo AI dev workspace template.*
> https://github.com/lakpriya1s/devrig

<div align="center">
<sub>නිෂ්පාදන multi-repo workspace එකකින් උපත · <img src="../assets/devrig-icon.png" width="14" alt=""> devrig</sub>
</div>
