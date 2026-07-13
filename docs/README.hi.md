<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**आपके सभी repos के लिए एक rig — AI-तैयार, मल्टी-रेपो डेव वर्कस्पेस टेम्पलेट।**

[![Use this template](https://img.shields.io/badge/Use%20this-template-22D3EE?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · **हिन्दी** · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [한국어](README.ko.md) · [සිංහල](README.si.md)

</div>

---

## devrig क्या है?

devrig एक *meta-repo* है: एक ऐसा फ़ोल्डर जिसमें आपके प्रोजेक्ट के सभी repos
**और साथ में** उन पर काम करने वाली AI टूलिंग रहती है। यह repo केवल टूलिंग को
version करता है — आपके प्रोजेक्ट repos को `setup.sh` अगल-बगल clone करता है और
वे untracked रहते हैं। सब कुछ एक ही **`.setup`** फ़ाइल से कॉन्फ़िगर होता है।

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

1. **[Use this template](https://github.com/lakpriya1s/devrig/generate)** पर क्लिक करके `your-org/your-project-workspace` बनाएं।
2. Clone करें और चलाएं:

   ```bash
   ./setup.sh
   ```

   पहली बार चलाने पर, अगर `.setup` अभी भी example मान रखता है, तो यह आपसे
   इंटरैक्टिव तरीके से पूछेगा: प्रोजेक्ट का नाम, GitHub org, क्लोन करने वाले
   repos (एक साथ कई paste करें, space या comma से अलग करके), issue tracker
   (**Linear**, **Jira**, या **other** — मेनू से चुनें), ticket prefix,
   default branch, और feature toggles — फिर खुद `.setup` में लिख देगा। खुद
   हाथ से एडिट करना पसंद है? स्क्रिप्ट चलाने से पहले `.setup` खुद भर दें, यह
   प्रश्न छोड़ देगा।
3. इसी फ़ोल्डर से `claude` चलाएं और काम शुरू करें।

फिर Claude Code के अंदर: `/mcp` चलाकर जो भी tracker सर्वर कॉन्फ़िगर हुआ है
उसे (**linear** या **atlassian**) authenticate करें (एक बार का OAuth;
**semble** को auth की ज़रूरत नहीं), और rtk hook लागू होने के लिए Claude Code
एक बार restart करें।

## 🤖 अपने AI agent के साथ शुरुआत करें

अभी-अभी इस टेम्पलेट से workspace बनाया है? इसे अपने AI कोडिंग agent
(Claude Code, Cursor, opencode, …) में paste करें और बाकी सेटअप उसके साथ पूरा करें:

```text
मैंने अभी devrig टेम्पलेट (https://github.com/lakpriya1s/devrig) से एक
workspace बनाया है। इसे सेट करने में मेरी मदद करो:

1. README.md, AGENTS.md और .setup पढ़कर workspace को समझो।
2. मेरे साथ ./setup.sh चलाओ — यह मुझसे इंटरैक्टिव तरीके से मेरा प्रोजेक्ट
   नाम, GitHub org, repo सूची (मैं एक साथ कई paste कर सकता हूं), issue
   tracker (Linear, Jira, या other), ticket prefix, default branch, और
   feature toggles पूछेगा, फिर खुद .setup लिखेगा। इसके सवाल मुझे बताओ और
   जवाब भरने में मदद करो।
3. ./setup.sh जो भी समस्या बताए उसे ठीक करने में मदद करो।
4. AGENTS.md की Systems टेबल भरो — हर repo की एक पंक्ति (क्या है, stack)।
5. हर repo के लिए .agents/skills/code-review/references/<repo>.md में review
   reference और .agents/skills/write-doc/references/<repo>.md में doc
   reference लिखो (_example-repo.md scaffold कॉपी करो और हर तथ्य कोड में
   सत्यापित करो)।
6. अगर मैंने Linear चुना है, तो create-ticket की conventions टेबल को मेरे
   Linear workspace से मिलाओ। अगर Jira या कोई और tracker चुना है, तो
   /start-task, /raise-pr, और /create-ticket की MCP calls उसके अनुसार बदलने
   में मदद करो।
7. personalization को एक task branch पर commit करके PR खोलो।
```

## setup.sh क्या करता है

`setup.sh` idempotent है — सभी repos और tools अपडेट करने के लिए कभी भी दोबारा चलाएं। यह:

0. **सिर्फ़ पहली बार**: अगर `.setup` अभी भी example मान रखता है, तो ऊपर की सारी जानकारी इंटरैक्टिव तरीके से पूछता है और `.setup` में लिखता है।
1. Prerequisites जांचता है (`git`, authenticated `gh`; semble चालू हो तो `uv` इंस्टॉल करता है)।
2. `REPOS` का हर repo अगल-बगल clone करता है (या साफ़ default-branch checkouts को fast-forward करता है), और उन्हें `.git/info/exclude` के ज़रिए इस repo की git status से बाहर रखता है।
3. इस repo और हर cloned repo में protected-branch git hooks इंस्टॉल करता है।
4. `.mcp.json` / `opencode.json` को आपके `.setup` toggles पर converge करता है — `ISSUE_TRACKER` के अनुसार `linear` या `atlassian` (Jira) सर्वर जोड़ता है, "other" चुना हो तो कोई नहीं — साथ ही हाथ से जोड़े गए MCP सर्वर सुरक्षित रहते हैं — और `.claude/settings.local.json` जनरेट करता है।
5. semble इंस्टॉल करता है और हर repo के लिए search index warm करता है।
6. rtk इंस्टॉल करके उसका Claude Code hook रजिस्टर करता है।
7. VS Code के लिए `<project>.code-workspace` जनरेट करता है (पहले से मौजूद हो तो छोड़ देता है, इसलिए आप उसे customize करके commit कर सकते हैं)।

## Customization चेकलिस्ट

पहली बार `setup.sh` चलाने के बाद, अपना personalization commit करें:

- [ ] `.setup` — पहली बार चलाने पर `setup.sh` ये मान इंटरैक्टिव तरीके से पूछता है (या चलाने से पहले हाथ से भर दें, यह सवाल छोड़ देगा)। बाद में बदलाव के लिए (tracker बदलना, repo जोड़ना), `.setup` सीधे एडिट करें और `./setup.sh` फिर से चलाएं।
- [ ] `AGENTS.md` — **Systems** टेबल (हर repo की एक पंक्ति: क्या है, stack) और **Testing** सेक्शन भरें। यही वह source of truth है जिसे हर skill पढ़ती है।
- [ ] `.agents/skills/code-review/references/` और `.agents/skills/write-doc/references/` — हर repo के लिए एक reference फ़ाइल (`_example-repo.md` कॉपी करें)। इनके बिना भी skills चलती हैं, पर इनके साथ कहीं तेज़ धार होती हैं।
- [ ] अगर `ISSUE_TRACKER` `linear` है: `.agents/skills/create-ticket/SKILL.md` की "Conventions" टेबल को अपने Linear workspace (teams, projects, labels) से सत्यापित करें। अगर `jira` या `other` है: `/start-task`, `/raise-pr`, और `/create-ticket` की `mcp__linear__*` calls को अपने tracker के MCP tool names में बदलें (हर skill इसे शुरुआत में बताती है)।
- [ ] जो कुछ किसी toggle ने बंद किया है उसे हटाएँ या समायोजित करें (जैसे semble इस्तेमाल न करने पर `CLAUDE.md` से उसके नोट हटाएँ)।

## संरचना

| पथ | विवरण |
|---|---|
| `.setup` | आपका प्रोजेक्ट कॉन्फ़िग — वह एक फ़ाइल जिसे हर टूल पढ़ता है |
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
हो जाए, तो इसे अलग `<project>-knowledge` repo के रूप में push करें, `.setup`
के `REPOS` में जोड़ें, यहाँ का फ़ोल्डर हटाएँ, और `AGENTS.md` का pointer अपडेट करें।

## समस्या-निवारण

- **setup के बाद `semble` या `uv` नहीं मिलता** — नया shell खोलें (PATH अपडेट हुआ है) और `./setup.sh` दोबारा चलाएं।
- **Claude में tracker tools नहीं दिखते** — `/mcp` चलाकर `linear` या `atlassian` सर्वर का OAuth पूरा करें।
- **rtk काम नहीं कर रहा** — Claude Code restart करें; `rtk gain` से जांचें कि commands proxy हो रही हैं।
- **कोई repo अपडेट नहीं होता** — `setup.sh` कभी उस repo को नहीं छूता जिसमें local बदलाव हों या जो task branch पर हो; वह केवल साफ़ default-branch checkouts को fast-forward करता है।
- **setup.sh कुछ पूछता नहीं, सीधे "edit .setup first" कहकर रुक जाता है** — यह सिर्फ़ interactive terminal से जुड़े होने पर पूछता है; script या CI से चलाने पर `.setup` पहले से भरा होना ज़रूरी है।
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
