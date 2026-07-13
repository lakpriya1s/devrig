<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**आपके सभी repos के लिए एक rig — AI-तैयार, मल्टी-रेपो डेव वर्कस्पेस टेम्पलेट।**

[![npx create-devrig](https://img.shields.io/npm/v/create-devrig?label=npx%20create-devrig&color=22D3EE&style=flat-square)](https://www.npmjs.com/package/create-devrig)
[![Use this template](https://img.shields.io/badge/Use%20this-template-3B82F6?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · **हिन्दी** · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [한국어](README.ko.md) · [සිංහල](README.si.md)

</div>

---

## devrig क्या है?

devrig एक *meta-repo* है: एक ऐसा फ़ोल्डर जिसमें आपके प्रोजेक्ट के सभी repos
**और साथ में** उन पर काम करने वाली AI टूलिंग रहती है। यह repo केवल टूलिंग को
version करता है — आपके प्रोजेक्ट repos को `setup.sh` अगल-बगल clone करता है और
वे untracked रहते हैं। सब कुछ एक ही **`devrig.toml`** फ़ाइल से कॉन्फ़िगर होता है।

| | आपको क्या मिलता है |
|---|---|
| 🧠 | **AI वर्कफ़्लो skills** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (agent-agnostic, `.agents/skills/` में, Claude Code के लिए symlink; opencode भी कॉन्फ़िगर है) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — semantic code search, जिसे agents grep-और-पढ़ने की जगह MCP के ज़रिए इस्तेमाल करते हैं |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — Claude Code के लिए token बचाने वाला command proxy |
| 🎫 | **Issue tracker MCP** — Linear, Jira या अपना कोई और; `setup.sh` इंटरैक्टिव तरीके से चुनवाता है |
| 🛡️ | **Protected-branch git hooks** — किसी भी repo में default branch पर गलती से commit/push नहीं |
| 📚 | **`knowledge/`** — markdown नॉलेज बेस का ढांचा (architecture, ADRs, design docs, runbooks) जिसे AI टूलिंग index करती है और उसमें लिखती है |
| 🖥️ | **जनरेटेड VS Code multi-root workspace** — सारे repos एक ही विंडो में |

## जल्दी शुरू करें

सबसे तेज़ तरीका — एक कमांड, clone करने की ज़रूरत नहीं:

```bash
npx create-devrig my-project
```

[`create-devrig`](https://github.com/lakpriya1s/create-devrig) इस टेम्पलेट को fetch करता है (git history के बिना), `my-project/` में एक नया git repo शुरू करता है, और तुरंत इंटरैक्टिव setup wizard चलाता है — बिल्कुल वही wizard जो नीचे बताया गया है, बस अलग से clone करने का चरण नहीं।

GitHub का UI पसंद है, या चाहते हैं कि repo शुरू से आपके org के अंदर बने?

1. **[Use this template](https://github.com/lakpriya1s/devrig/generate)** पर क्लिक करके `your-org/your-project-workspace` बनाएं।
2. Clone करें और चलाएं:

   ```bash
   ./setup.sh
   ```

   पहली बार चलाने पर, अगर `devrig.toml` अभी भी example मान रखता है, तो यह आपसे
   इंटरैक्टिव तरीके से पूछेगा: प्रोजेक्ट का नाम, एक-पंक्ति का विवरण, GitHub org,
   क्लोन करने वाले repos (एक साथ कई paste करें, space या comma से अलग करके),
   issue tracker (**Linear**, **Jira**, या **other** — मेनू से चुनें), ticket
   prefix, default branch, और feature toggles — फिर खुद `devrig.toml` में लिख
   देगा, devrig की अपनी टेम्पलेट फ़ाइलें हटा देगा, और उनकी जगह *आपके* प्रोजेक्ट
   के लिए एक `README.md` जनरेट कर देगा। खुद हाथ से एडिट करना पसंद है? स्क्रिप्ट
   चलाने से पहले `devrig.toml` खुद भर दें, यह प्रश्न छोड़ देगा।
3. इसी फ़ोल्डर से `claude` चलाएं और काम शुरू करें।

किसी भी तरीके से, फिर Claude Code के अंदर: `/mcp` चलाकर जो भी tracker सर्वर कॉन्फ़िगर हुआ है
उसे (**linear** या **atlassian**) authenticate करें (एक बार का OAuth;
**semble** को auth की ज़रूरत नहीं), और rtk hook लागू होने के लिए Claude Code
एक बार restart करें।

## 🤖 अपने AI agent के साथ शुरुआत करें

### पहले से ही आपके repos हैं?

अभी-अभी इस टेम्पलेट से workspace बनाया है? इसे अपने AI कोडिंग agent
(Claude Code, Cursor, opencode, …) में paste करें और बाकी सेटअप उसके साथ पूरा करें:

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

### बिल्कुल नया प्रोजेक्ट शुरू कर रहे हैं?

अभी तक कोई repo नहीं, सिर्फ एक आइडिया है? नीचे चिह्नित जगह पर अपने प्रोजेक्ट का विवरण डालें और इसे paste करें — agent आपको आइडिया से लेकर एक चलता हुआ workspace तक ले जाएगा, नए repos सहित:

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

## setup.sh क्या करता है

`setup.sh` idempotent है — सभी repos और tools अपडेट करने के लिए कभी भी दोबारा चलाएं। यह:

0. **सिर्फ़ पहली बार**: अगर `devrig.toml` अभी भी example मान रखता है, तो ऊपर की सारी जानकारी इंटरैक्टिव तरीके से पूछता है और `devrig.toml` में लिखता है।
1. **Workspace को personalize करता है**: devrig की अपनी टेम्पलेट फ़ाइलें
   (`docs/`, `assets/`, `CITATION.cff`, `CONTRIBUTING.md`, `LICENSE`) हटाता है
   और `devrig.toml` से *आपके* प्रोजेक्ट के लिए एक `README.md` जनरेट करता है।
   devrig repo के अंदर ही यह छोड़ दिया जाता है, और आपने जो README एडिट किया है
   वह कभी overwrite नहीं होता।
2. Prerequisites जांचता है (`git`, authenticated `gh`; semble चालू हो तो `uv` इंस्टॉल करता है)।
3. `repos` का हर repo अगल-बगल clone करता है (या साफ़ default-branch checkouts को fast-forward करता है), और उन्हें `.git/info/exclude` के ज़रिए इस repo की git status से बाहर रखता है।
4. इस repo और हर cloned repo में protected-branch git hooks इंस्टॉल करता है।
5. `.mcp.json` / `opencode.json` को आपके `devrig.toml` toggles पर converge करता है — `issue_tracker` के अनुसार `linear` या `atlassian` (Jira) सर्वर जोड़ता है, "other" चुना हो तो कोई नहीं — साथ ही हाथ से जोड़े गए MCP सर्वर सुरक्षित रहते हैं — और `.claude/settings.local.json` जनरेट करता है।
6. semble इंस्टॉल करता है और हर repo के लिए search index warm करता है।
7. rtk इंस्टॉल करके उसका Claude Code hook रजिस्टर करता है।
8. VS Code के लिए `<project>.code-workspace` जनरेट करता है (पहले से मौजूद हो तो छोड़ देता है, इसलिए आप उसे customize करके commit कर सकते हैं)।

## Customization चेकलिस्ट

`setup.sh` मशीनी personalization खुद कर देता है (`devrig.toml` लिखता है,
devrig की टेम्पलेट फ़ाइलें हटाता है, आपका प्रोजेक्ट README जनरेट करता है)।
जो बचता है वह वह जानकारी है जो सिर्फ़ आप जानते हैं — जनरेट किए गए README का
**"Customize this workspace"** सेक्शन यही चेकलिस्ट आपके workspace में ले
आता है:

- [ ] `AGENTS.md` — **Systems** टेबल (हर repo की एक पंक्ति: क्या है, stack) और **Testing** सेक्शन भरें। यही वह source of truth है जिसे हर skill पढ़ती है। जनरेट किए गए README की "What's inside" टेबल को भी साथ में अपडेट रखें।
- [ ] `.agents/skills/code-review/references/` और `.agents/skills/write-doc/references/` — हर repo के लिए एक reference फ़ाइल (`_example-repo.md` कॉपी करें)। इनके बिना भी skills चलती हैं, पर इनके साथ कहीं तेज़ धार होती हैं।
- [ ] अगर `issue_tracker` `linear` है: `.agents/skills/create-ticket/SKILL.md` की "Conventions" टेबल को अपने Linear workspace (teams, projects, labels) से सत्यापित करें। अगर `jira` या `other` है: `/start-task`, `/raise-pr`, और `/create-ticket` की `mcp__linear__*` calls को अपने tracker के MCP tool names में बदलें (हर skill इसे शुरुआत में बताती है)।
- [ ] जो कुछ किसी toggle ने बंद किया है उसे हटाएँ या समायोजित करें (जैसे semble इस्तेमाल न करने पर `CLAUDE.md` से उसके नोट हटाएँ)।

बाद में config मान बदलने के लिए (tracker बदलना, repo जोड़ना), `devrig.toml`
सीधे एडिट करें और `./setup.sh` फिर से चलाएं।

## संरचना

| पथ | विवरण |
|---|---|
| `devrig.toml` | आपका प्रोजेक्ट कॉन्फ़िग — वह एक फ़ाइल जिसे हर टूल पढ़ता है |
| `setup.sh` | Idempotent bootstrap/update स्क्रिप्ट |
| `AGENTS.md` | Agent-agnostic source of truth (systems, branch नियम, conventions) |
| `CLAUDE.md` | Claude Code विशेष; `AGENTS.md` import करता है |
| `.agents/skills/` | Canonical workflow skills (agent-agnostic) |
| `.claude/` | Claude Code settings, agents, skill symlinks |
| `.opencode/` | opencode agents और plugin config |
| `.mcp.json` / `opencode.json` | MCP सर्वर (issue tracker, semble) |
| `git-hooks/` | Protected-branch pre-commit / pre-push hooks |
| `knowledge/` | Markdown नॉलेज बेस (architecture, decisions, design, runbooks, product, releases) |
| `<repo>/` (untracked) | आपके प्रोजेक्ट repos, `setup.sh` द्वारा cloned |

## नई skill जोड़ना

देखें [`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md)।
संक्षेप में: `.agents/skills/<name>/SKILL.md` बनाएं, `.claude/skills/` में
symlink करें, और `CLAUDE.md` में सूचीबद्ध करें।

## नॉलेज बेस

नए design docs, architecture notes, ADRs और runbooks markdown के रूप में PR के
ज़रिए [`knowledge/`](../knowledge/) में जाते हैं — semble इसे index करता है,
इसलिए agents design context उसी तरह खोजते हैं जैसे code। जब यह इस repo से बड़ा
हो जाए, तो इसे अलग `<project>-knowledge` repo के रूप में push करें, `devrig.toml`
के `repos` में जोड़ें, यहाँ का फ़ोल्डर हटाएँ, और `AGENTS.md` का pointer अपडेट करें।

## समस्या-निवारण

- **setup के बाद `semble` या `uv` नहीं मिलता** — नया shell खोलें (PATH अपडेट हुआ है) और `./setup.sh` दोबारा चलाएं।
- **Claude में tracker tools नहीं दिखते** — `/mcp` चलाकर `linear` या `atlassian` सर्वर का OAuth पूरा करें।
- **rtk काम नहीं कर रहा** — Claude Code restart करें; `rtk gain` से जांचें कि commands proxy हो रही हैं।
- **कोई repo अपडेट नहीं होता** — `setup.sh` कभी उस repo को नहीं छूता जिसमें local बदलाव हों या जो task branch पर हो; वह केवल साफ़ default-branch checkouts को fast-forward करता है।
- **setup.sh कुछ पूछता नहीं, सीधे "edit devrig.toml first" कहकर रुक जाता है** — यह सिर्फ़ interactive terminal से जुड़े होने पर पूछता है; script या CI से चलाने पर `devrig.toml` पहले से भरा होना ज़रूरी है।
- **Jira या "other" चुना** — `atlassian` (Jira) MCP सर्वर अपने आप कॉन्फ़िगर हो जाता है, पर `/start-task`, `/raise-pr`, और `/create-ticket` अभी भी Linear के MCP tool names कॉल करते हैं — जब तक आप इन skills को adapt नहीं करते, `setup.sh` हर बार चलने पर अंत में यह चेतावनी देगा।

## योगदान दें

हर टीम जो devrig अपनाती है, उसे बेहतर बनाती है। Bug रिपोर्ट, नई generic
skills, बेहतर docs और **README अनुवाद** — सबका स्वागत है, देखें
[CONTRIBUTING.md](../CONTRIBUTING.md)। अगर devrig ने आपकी टीम का सेटअप समय
बचाया, तो एक ⭐ दूसरों को इसे खोजने में मदद करता है।

## लाइसेंस और उद्धरण

[MIT License](../LICENSE) के अंतर्गत जारी।

अगर आप अपने काम या लेखन में devrig का उपयोग करते हैं, तो उद्धरण की सराहना
होगी — GitHub का **"Cite this repository"** बटन ([`CITATION.cff`](../CITATION.cff)
द्वारा संचालित) में विवरण है, या:

> Senevirathna, L. (2026). *devrig: a multi-repo AI dev workspace template.*
> https://github.com/lakpriya1s/devrig

<div align="center">
<sub>एक production multi-repo workspace से निर्मित · <img src="../assets/devrig-icon.png" width="14" alt=""> devrig</sub>
</div>
