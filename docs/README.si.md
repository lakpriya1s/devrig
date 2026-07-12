<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**ඔබගේ සියලුම repos සඳහා එක rig එකක් — AI සූදානම්, multi-repo dev workspace template එකක්.**

[![Use this template](https://img.shields.io/badge/Use%20this-template-22D3EE?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [हिन्दी](README.hi.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [한국어](README.ko.md) · **සිංහල**

</div>

---

## devrig යනු කුමක්ද?

devrig යනු *meta-repo* එකකි: ඔබේ ව්‍යාපෘතියේ සියලුම repos **සහ** ඒවා හරහා
සංවර්ධනය කිරීමට භාවිත වන AI මෙවලම් එකම folder එකක තබා ගන්නා අතර, මෙම repo
එක version කරන්නේ මෙවලම් පමණි — ඔබේ ව්‍යාපෘති repos `setup.sh` මගින් එකිනෙක
අසල clone වන අතර untracked ලෙස පවතී. සියල්ල වින්‍යාස වන්නේ එක **`.setup`**
ගොනුවකින්.

| | ඔබට ලැබෙන දේ |
|---|---|
| 🧠 | **AI workflow skills** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (agent-agnostic ලෙස `.agents/skills/` තුළ, Claude Code සඳහා symlink කර ඇත; opencode ද වින්‍යාස කර ඇත) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — grep කර ගොනු කියවීම වෙනුවට agents MCP හරහා භාවිත කරන semantic code search |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — Claude Code සඳහා token ඉතිරි කරන command proxy |
| 🎫 | **Linear MCP** — skills සමඟ සම්බන්ධ issue tracking |
| 🛡️ | **Protected-branch git hooks** — කිසිදු repo එකක default branch එකට වැරදීමකින් commit/push වීම වළක්වයි |
| 📚 | **`knowledge/`** — AI මෙවලම් index කර ලියන markdown දැනුම් පදනමක සැකිල්ල (architecture, ADRs, design docs, runbooks) |
| 🖥️ | **ස්වයංක්‍රීයව සෑදෙන VS Code multi-root workspace** — සියලුම repos එක window එකක |

## ඉක්මන් ආරම්භය

1. **[Use this template](https://github.com/lakpriya1s/devrig/generate)** ක්ලික් කර `your-org/your-project-workspace` සාදන්න.
2. Clone කර **`.setup`** සංස්කරණය කරන්න — ව්‍යාපෘති නම, GitHub org, repo ලැයිස්තුව, ticket prefix, default branch, feature toggles.
3. ධාවනය කරන්න:

   ```bash
   ./setup.sh
   ```

4. මෙම folder එකෙන් `claude` ධාවනය කර වැඩ අරඹන්න.

ඉන්පසු Claude Code තුළ: `/mcp` ධාවනය කර **linear** server එක authenticate
කරන්න (එක් වරක් OAuth; **semble** ට auth අවශ්‍ය නැත), rtk hook ක්‍රියාත්මක
වීමට Claude Code එක වරක් restart කරන්න.

## 🤖 ඔබේ AI agent සමඟ ආරම්භ කරන්න

මේ template එකෙන් workspace එකක් දැන් සෑදුවාද? මෙය ඔබේ AI coding agent
(Claude Code, Cursor, opencode, …) වෙත paste කර ඉතිරි සැකසුම ඔහු සමඟ
අවසන් කරන්න:

```text
මම devrig template එකෙන් (https://github.com/lakpriya1s/devrig) workspace
එකක් සෑදුවා. එය සකසන්න මට උදව් කරන්න:

1. README.md, AGENTS.md සහ .setup කියවා workspace එක තේරුම් ගන්න.
2. මගේ ව්‍යාපෘති නම, GitHub org, repo ලැයිස්තුව, ticket prefix සහ
   default branch මගෙන් අසා .setup පුරවන්න.
3. ./setup.sh ධාවනය කර එය පෙන්වන ගැටලු විසඳන්න උදව් කරන්න.
4. AGENTS.md හි Systems වගුව පුරවන්න — repo එකකට එක පේළියක් (එය කුමක්ද, stack).
5. සෑම repo එකකටම .agents/skills/code-review/references/<repo>.md හි review
   reference එකක් සහ .agents/skills/write-doc/references/<repo>.md හි doc
   reference එකක් ලියන්න (_example-repo.md scaffold copy කර සෑම කරුණක්ම
   code එකෙන් තහවුරු කරන්න).
6. create-ticket හි conventions වගුව මගේ Linear workspace එක සමඟ සසඳන්න.
7. personalization එක task branch එකක commit කර PR එකක් විවෘත කරන්න.
```

## setup.sh කරන දේ

`setup.sh` idempotent ය — සියලුම repos සහ මෙවලම් යාවත්කාලීන කිරීමට ඕනෑම
වේලාවක නැවත ධාවනය කළ හැක. එය:

1. පූර්ව අවශ්‍යතා පරීක්ෂා කරයි (`git`, authenticate වූ `gh`; semble සක්‍රීය නම් `uv` install කරයි).
2. `REPOS` හි සෑම repo එකක්ම එකිනෙක අසල clone කරයි (හෝ පිරිසිදු default-branch checkouts fast-forward කරයි), සහ `.git/info/exclude` හරහා ඒවා මෙම repo එකේ git status වෙතින් බැහැර කරයි.
3. මෙම repo එකට සහ clone වූ සෑම repo එකකටම protected-branch git hooks install කරයි.
4. `.mcp.json` / `opencode.json` ඔබේ `.setup` toggles වෙත converge කරයි (අතින් එකතු කළ MCP servers ආරක්ෂා වේ) සහ `.claude/settings.local.json` සාදයි.
5. semble install කර repo එකකට search index එකක් warm කරයි.
6. rtk install කර එහි Claude Code hook එක register කරයි.
7. VS Code සඳහා `<project>.code-workspace` සාදයි (දැනටමත් තිබේ නම් මඟ හරින බැවින් customize කර commit කිරීම ආරක්ෂිතයි).

## Customization පිරික්සුම් ලැයිස්තුව

පළමු `setup.sh` ධාවනයෙන් පසු, ඔබේ personalization commit එක කරන්න:

- [ ] `.setup` — ඔබේ සැබෑ අගයන් (example අගයන් සමඟ setup.sh ධාවනය ප්‍රතික්ෂේප කරයි).
- [ ] `AGENTS.md` — **Systems** වගුව (repo එකකට එක පේළියක්: එය කුමක්ද, stack) සහ **Testing** කොටස පුරවන්න. සෑම skill එකක්ම කියවන source of truth මෙයයි.
- [ ] `.agents/skills/code-review/references/` සහ `.agents/skills/write-doc/references/` — repo එකකට එක reference ගොනුවක් (`_example-repo.md` copy කරන්න). ඒවා නැතිවත් skills ක්‍රියා කරයි, නමුත් ඒවා සමඟ බෙහෙවින් තියුණුයි.
- [ ] `.agents/skills/create-ticket/SKILL.md` — "Conventions" වගුව ඔබේ Linear workspace එක (teams, projects, labels) සමඟ තහවුරු කරන්න.
- [ ] Toggle එකකින් අක්‍රීය කළ දේ ඉවත් කරන්න හෝ සකසන්න (උදා: Linear භාවිත නොකරන්නේ නම් `CLAUDE.md` වෙතින් linear සටහන් ඉවත් කරන්න).

## ව්‍යුහය

| මාර්ගය | විස්තරය |
|---|---|
| `.setup` | ඔබේ ව්‍යාපෘති වින්‍යාසය — සෑම මෙවලමක්ම කියවන එකම ගොනුව |
| `setup.sh` | Idempotent bootstrap/update script |
| `AGENTS.md` | Agent-agnostic source of truth (systems, branch නීති, conventions) |
| `CLAUDE.md` | Claude Code විශේෂිත; `AGENTS.md` import කරයි |
| `.agents/skills/` | සම්මත workflow skills (agent-agnostic) |
| `.claude/` | Claude Code settings, agents, skill symlinks |
| `.opencode/` | opencode agents සහ plugin config |
| `.mcp.json` / `opencode.json` | MCP servers (linear, semble) |
| `git-hooks/` | Protected-branch pre-commit / pre-push hooks |
| `knowledge/` | Markdown දැනුම් පදනම (architecture, decisions, design, runbooks, product, releases) |
| `<repo>/` (untracked) | `setup.sh` මගින් clone වන ඔබේ ව්‍යාපෘති repos |

## Skill එකක් එකතු කිරීම

[`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md) බලන්න.
කෙටියෙන්: `.agents/skills/<name>/SKILL.md` සාදා, `.claude/skills/` වෙත
symlink කර, `CLAUDE.md` හි ලැයිස්තුගත කරන්න.

## දැනුම් පදනම

නව design docs, architecture සටහන්, ADRs සහ runbooks markdown ලෙස PR හරහා
[`knowledge/`](../knowledge/) වෙත යයි — semble එය index කරන බැවින් agents
code සොයන ආකාරයටම design context සොයා ගනී. එය මෙම repo එකට වඩා විශාල වූ විට,
වෙනම `<project>-knowledge` repo එකක් ලෙස push කර, `.setup` හි `REPOS` වෙත
එකතු කර, මෙහි folder එක මකා, `AGENTS.md` හි pointer එක යාවත්කාලීන කරන්න.

## ගැටලු නිරාකරණය

- **setup ට පසු `semble` හෝ `uv` හමු නොවේ** — නව shell එකක් විවෘත කර (PATH යාවත්කාලීන විය) `./setup.sh` නැවත ධාවනය කරන්න.
- **Claude හි Linear මෙවලම් නැත** — `/mcp` ධාවනය කර linear server එකේ OAuth ක්‍රියාවලිය සම්පූර්ණ කරන්න.
- **rtk ක්‍රියා නොකරයි** — Claude Code restart කරන්න; `rtk gain` මගින් commands proxy වන බව තහවුරු කරන්න.
- **Repo එකක් යාවත්කාලීන නොවේ** — `setup.sh` local වෙනස්කම් ඇති හෝ task branch එකක ඇති repo එකක් කිසිවිටෙක ස්පර්ශ නොකරයි; පිරිසිදු default-branch checkouts පමණක් fast-forward කරයි.
- **setup.sh "edit .setup first" කියයි** — `.setup` හි example අගයන් (`PROJECT_NAME="acme"`) ඇති තාක් එය ධාවනය ප්‍රතික්ෂේප කරයි.

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
