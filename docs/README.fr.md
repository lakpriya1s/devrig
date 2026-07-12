<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**Un seul rig pour tous vos dépôts — un template de workspace multi-dépôts prêt pour l'IA.**

[![Use this template](https://img.shields.io/badge/Use%20this-template-22D3EE?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [हिन्दी](README.hi.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · **Français** · [한국어](README.ko.md) · [සිංහල](README.si.md)

</div>

---

## Qu'est-ce que devrig ?

devrig est un *méta-dépôt* : un dossier qui contient tous les dépôts de votre
projet **plus** l'outillage IA utilisé pour développer à travers eux. Ce dépôt
ne versionne que l'outillage — vos dépôts de projet sont clonés côte à côte
par `setup.sh` et restent non suivis. Tout se configure depuis un unique
fichier **`.setup`**.

| | Ce que vous obtenez |
|---|---|
| 🧠 | **Skills de workflow IA** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (indépendantes de l'agent, dans `.agents/skills/`, avec des liens symboliques pour Claude Code ; opencode est aussi configuré) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — recherche sémantique de code que les agents utilisent via MCP au lieu de grep et lecture de fichiers |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — proxy de commandes optimisant les tokens pour Claude Code |
| 🎫 | **Linear MCP** — gestion de tickets intégrée aux skills |
| 🛡️ | **Hooks git de branches protégées** — aucun commit/push accidentel vers votre branche par défaut, dans aucun dépôt |
| 📚 | **`knowledge/`** — squelette de base de connaissances en markdown (architecture, ADR, documents de conception, runbooks) que l'outillage IA indexe et alimente |
| 🖥️ | **Workspace multi-racines VS Code généré** — tous les dépôts dans une seule fenêtre |

## Démarrage rapide

1. Cliquez sur **[Use this template](https://github.com/lakpriya1s/devrig/generate)** pour créer `votre-org/votre-projet-workspace`.
2. Clonez-le et éditez **`.setup`** — nom du projet, organisation GitHub, liste des dépôts, préfixe de tickets, branche par défaut, options.
3. Exécutez :

   ```bash
   ./setup.sh
   ```

4. Lancez `claude` depuis ce dossier et commencez à travailler.

Ensuite, dans Claude Code : lancez `/mcp` et authentifiez le serveur
**linear** (OAuth unique ; **semble** ne nécessite aucune authentification),
puis redémarrez Claude Code une fois pour que le hook rtk prenne effet.

## 🤖 Démarrez avec votre agent IA

Vous venez de créer un workspace depuis ce template ? Collez ceci dans votre
agent de programmation (Claude Code, Cursor, opencode, …) et laissez-le
terminer la configuration avec vous :

```text
Je viens de créer un workspace depuis le template devrig
(https://github.com/lakpriya1s/devrig). Aide-moi à le configurer :

1. Lis README.md, AGENTS.md et .setup pour comprendre le workspace.
2. Demande-moi le nom du projet, l'organisation GitHub, la liste des dépôts,
   le préfixe de tickets et la branche par défaut, puis remplis .setup.
3. Exécute ./setup.sh et aide-moi à corriger ce qu'il signale.
4. Remplis le tableau Systems d'AGENTS.md — une ligne par dépôt (rôle, stack).
5. Pour chaque dépôt, écris une référence de revue dans
   .agents/skills/code-review/references/<repo>.md et une référence de doc
   dans .agents/skills/write-doc/references/<repo>.md (copie les squelettes
   _example-repo.md et vérifie chaque fait dans le code).
6. Vérifie le tableau des conventions de create-ticket avec mon workspace Linear.
7. Committe la personnalisation sur une branche de tâche et ouvre une PR.
```

## Ce que fait setup.sh

`setup.sh` est idempotent — relancez-le à tout moment pour mettre à jour tous
les dépôts et outils. Il :

1. Vérifie les prérequis (`git`, `gh` authentifié ; installe `uv` si semble est activé).
2. Clone chaque dépôt de `REPOS` côte à côte (ou fait un fast-forward des checkouts propres de la branche par défaut), et les exclut du statut git de ce dépôt via `.git/info/exclude`.
3. Installe les hooks git de branches protégées dans ce dépôt et chaque dépôt cloné.
4. Fait converger `.mcp.json` / `opencode.json` vers vos options `.setup` (les serveurs MCP ajoutés à la main sont préservés) et génère `.claude/settings.local.json`.
5. Installe semble et préchauffe un index de recherche par dépôt.
6. Installe rtk et enregistre son hook Claude Code.
7. Génère `<project>.code-workspace` pour VS Code (ignoré si vous en avez déjà un, vous pouvez donc le personnaliser et le committer).

## Checklist de personnalisation

Après la première exécution de `setup.sh`, faites votre commit de personnalisation :

- [ ] `.setup` — vos vraies valeurs (setup.sh refuse de s'exécuter avec les valeurs d'exemple).
- [ ] `AGENTS.md` — remplissez le tableau **Systems** (une ligne par dépôt : rôle, stack) et la section **Testing**. C'est la source de vérité que lit chaque skill.
- [ ] `.agents/skills/code-review/references/` et `.agents/skills/write-doc/references/` — un fichier de référence par dépôt (copiez `_example-repo.md`). Les skills fonctionnent sans, mais elles sont bien plus affûtées avec.
- [ ] `.agents/skills/create-ticket/SKILL.md` — vérifiez le tableau des « Conventions » avec votre workspace Linear (équipes, projets, labels).
- [ ] Supprimez ou ajustez ce qu'une option a désactivé (par ex. retirez les notes linear de `CLAUDE.md` si vous n'utilisez pas Linear).

## Arborescence

| Chemin | Description |
|---|---|
| `.setup` | Votre configuration projet — le seul fichier que lit chaque outil |
| `setup.sh` | Script de bootstrap/mise à jour idempotent |
| `AGENTS.md` | Source de vérité indépendante de l'agent (systèmes, règles de branches, conventions) |
| `CLAUDE.md` | Spécificités Claude Code ; importe `AGENTS.md` |
| `.agents/skills/` | Skills de workflow canoniques (indépendantes de l'agent) |
| `.claude/` | Réglages Claude Code, agents, liens symboliques de skills |
| `.opencode/` | Agents et configuration de plugin opencode |
| `.mcp.json` / `opencode.json` | Serveurs MCP (linear, semble) |
| `git-hooks/` | Hooks pre-commit / pre-push de branches protégées |
| `knowledge/` | Base de connaissances markdown (architecture, décisions, conception, runbooks, produit, releases) |
| `<repo>/` (non suivi) | Vos dépôts de projet, clonés par `setup.sh` |

## Ajouter une skill

Voir [`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md).
En bref : créez `.agents/skills/<name>/SKILL.md`, liez-la dans
`.claude/skills/` et listez-la dans `CLAUDE.md`.

## Base de connaissances

Les nouveaux documents de conception, notes d'architecture, ADR et runbooks
vont dans [`knowledge/`](../knowledge/) en markdown via PR — semble l'indexe,
donc les agents trouvent le contexte de conception comme ils trouvent le code.
Quand elle dépasse ce dépôt, publiez-la comme dépôt `<project>-knowledge`
séparé, ajoutez-le à `REPOS` dans `.setup`, supprimez le dossier ici et
mettez à jour le pointeur dans `AGENTS.md`.

## Dépannage

- **`semble` ou `uv` introuvables après le setup** — ouvrez un nouveau shell (le PATH a été mis à jour) et relancez `./setup.sh`.
- **Outils Linear absents dans Claude** — lancez `/mcp` et terminez le flux OAuth du serveur linear.
- **rtk ne s'active pas** — redémarrez Claude Code ; vérifiez avec `rtk gain` que les commandes sont bien proxifiées.
- **Un dépôt ne se met pas à jour** — `setup.sh` ne touche jamais un dépôt avec des changements locaux ou sur une branche de tâche ; il ne fait que du fast-forward sur des checkouts propres de la branche par défaut.
- **setup.sh dit « edit .setup first »** — il refuse de s'exécuter tant que `.setup` contient les valeurs d'exemple (`PROJECT_NAME="acme"`).

## Contribuer

devrig s'améliore avec chaque équipe qui le monte. Rapports de bugs, nouvelles
skills génériques, meilleure documentation et **traductions du README** sont
les bienvenus — voir [CONTRIBUTING.md](../CONTRIBUTING.md). Si devrig a fait
gagner du temps à votre équipe, une ⭐ aide les autres à le trouver.

## Licence et citation

Publié sous [licence MIT](../LICENSE).

Si vous utilisez devrig dans vos travaux ou publications, une citation est
appréciée — le bouton **« Cite this repository »** de GitHub (alimenté par
[`CITATION.cff`](../CITATION.cff)) contient les détails, ou :

> Senevirathna, L. (2026). *devrig: a multi-repo AI dev workspace template.*
> https://github.com/lakpriya1s/devrig

<div align="center">
<sub>Issu d'un workspace multi-dépôts en production · <img src="../assets/devrig-icon.png" width="14" alt=""> devrig</sub>
</div>
