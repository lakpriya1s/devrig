<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**Un seul rig pour tous vos dépôts — un template de workspace multi-dépôts prêt pour l'IA.**

[![npx create-devrig](https://img.shields.io/npm/v/create-devrig?label=npx%20create-devrig&color=22D3EE&style=flat-square)](https://www.npmjs.com/package/create-devrig)
[![Use this template](https://img.shields.io/badge/Use%20this-template-3B82F6?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
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
fichier **`devrig.toml`**.

| | Ce que vous obtenez |
|---|---|
| 🧠 | **Skills de workflow IA** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (indépendantes de l'agent, dans `.agents/skills/`, avec des liens symboliques pour Claude Code ; opencode est aussi configuré) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — recherche sémantique de code que les agents utilisent via MCP au lieu de grep et lecture de fichiers |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — proxy de commandes optimisant les tokens pour Claude Code |
| 🎫 | **MCP de gestion de tickets** — Linear, Jira, ou le vôtre ; choisi de façon interactive par `setup.sh` |
| 🛡️ | **Hooks git de branches protégées** — aucun commit/push accidentel vers votre branche par défaut, dans aucun dépôt |
| 📚 | **`knowledge/`** — squelette de base de connaissances en markdown (architecture, ADR, documents de conception, runbooks) que l'outillage IA indexe et alimente |
| 🖥️ | **Workspace multi-racines VS Code généré** — tous les dépôts dans une seule fenêtre |

## Démarrage rapide

Le plus rapide — une seule commande, sans cloner :

```bash
npx create-devrig my-project
```

[`create-devrig`](https://github.com/lakpriya1s/create-devrig) récupère ce template (sans historique git), initialise un nouveau dépôt git dans `my-project/`, et lance immédiatement l'assistant de configuration interactif — le même assistant que ci-dessous, sans l'étape de clonage séparée.

Vous préférez l'interface de GitHub, ou voulez que le dépôt soit créé directement sous votre organisation ?

1. Cliquez sur **[Use this template](https://github.com/lakpriya1s/devrig/generate)** pour créer `votre-org/votre-projet-workspace`.
2. Clonez-le et exécutez :

   ```bash
   ./setup.sh
   ```

   Au premier lancement, si `devrig.toml` contient encore les valeurs d'exemple,
   le script vous guide de façon interactive : nom du projet, une description
   d'une ligne, organisation GitHub, les dépôts à cloner (collez-en plusieurs
   d'un coup, séparés par des espaces ou des virgules), votre gestionnaire de
   tickets (**Linear**, **Jira**, ou **autre** — au choix dans un menu), préfixe
   de tickets, branche par défaut, et options — puis il écrit `devrig.toml` pour
   vous, supprime les fichiers propres à devrig, et génère un `README.md` pour
   votre projet à leur place. Vous préférez éditer à la main ? Remplissez
   `devrig.toml` vous-même avant de lancer le script et les questions seront
   sautées.
3. Lancez `claude` depuis ce dossier et commencez à travailler.

Dans les deux cas, dans Claude Code : lancez `/mcp` et authentifiez le serveur du
gestionnaire de tickets configuré (**linear** ou **atlassian** ; OAuth
unique — **semble** ne nécessite aucune authentification), puis redémarrez
Claude Code une fois pour que le hook rtk prenne effet.

## 🤖 Démarrez avec votre agent IA

### Vous avez déjà vos dépôts ?

Vous venez de créer un workspace depuis ce template ? Collez ceci dans votre
agent de programmation (Claude Code, Cursor, opencode, …) et laissez-le
terminer la configuration avec vous :

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

### Vous démarrez un tout nouveau projet ?

Pas encore de dépôts, juste une idée ? Remplacez la partie indiquée par la description de votre projet et collez ceci à la place — l'agent vous emmène de l'idée à un workspace fonctionnel, nouveaux dépôts inclus :

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

## Ce que fait setup.sh

`setup.sh` est idempotent — relancez-le à tout moment pour mettre à jour tous
les dépôts et outils. Il :

0. **Au premier lancement seulement** : si `devrig.toml` contient encore les valeurs d'exemple, demande tout ce qui précède de façon interactive et écrit `devrig.toml`.
1. **Personnalise le workspace** : supprime les fichiers propres à devrig
   (`docs/`, `assets/`, `CITATION.cff`, `CONTRIBUTING.md`, `LICENSE`) et génère
   un `README.md` pour votre projet à partir de `devrig.toml`. Ignoré à
   l'intérieur du dépôt devrig lui-même, et un README que vous avez modifié
   n'est jamais écrasé.
2. Vérifie les prérequis (`git`, `gh` authentifié ; installe `uv` si semble est activé).
3. Clone chaque dépôt de `repos` côte à côte (ou fait un fast-forward des checkouts propres de la branche par défaut), et les exclut du statut git de ce dépôt via `.git/info/exclude`.
4. Installe les hooks git de branches protégées dans ce dépôt et chaque dépôt cloné.
5. Fait converger `.mcp.json` / `opencode.json` vers vos options `devrig.toml` — en ajoutant le serveur `linear` ou `atlassian` (Jira) selon `issue_tracker`, ou aucun si vous avez choisi « autre » — tout en préservant les serveurs MCP ajoutés à la main, et génère `.claude/settings.local.json`.
6. Installe semble et préchauffe un index de recherche par dépôt.
7. Installe rtk et enregistre son hook Claude Code.
8. Génère `<project>.code-workspace` pour VS Code (ignoré si vous en avez déjà un, vous pouvez donc le personnaliser et le committer).

## Checklist de personnalisation

`setup.sh` s'occupe lui-même de la personnalisation mécanique (écrit
`devrig.toml`, supprime les fichiers du template devrig, génère le README de
votre projet). Ce qui reste, c'est la connaissance que vous seul possédez —
la section **« Customize this workspace »** du README généré reprend cette
même checklist dans votre workspace :

- [ ] `AGENTS.md` — remplissez le tableau **Systems** (une ligne par dépôt : rôle, stack) et la section **Testing**. C'est la source de vérité que lit chaque skill. Gardez le tableau « What's inside » du README généré synchronisé.
- [ ] `.agents/skills/code-review/references/` et `.agents/skills/write-doc/references/` — un fichier de référence par dépôt (copiez `_example-repo.md`). Les skills fonctionnent sans, mais elles sont bien plus affûtées avec.
- [ ] Si `issue_tracker` vaut `linear` : vérifiez le tableau des « Conventions » de `.agents/skills/create-ticket/SKILL.md` avec votre workspace Linear (équipes, projets, labels). S'il vaut `jira` ou `other` : adaptez les appels `mcp__linear__*` de `/start-task`, `/raise-pr` et `/create-ticket` aux outils MCP de votre gestionnaire (chaque skill le signale en haut de fichier).
- [ ] Supprimez ou ajustez ce qu'une option a désactivé (par ex. retirez les notes semble de `CLAUDE.md` si vous ne l'utilisez pas).

Pour changer des valeurs de configuration plus tard (changer de gestionnaire,
ajouter un dépôt), éditez `devrig.toml` directement et relancez `./setup.sh`.

## Arborescence

| Chemin | Description |
|---|---|
| `devrig.toml` | Votre configuration projet — le seul fichier que lit chaque outil |
| `setup.sh` | Script de bootstrap/mise à jour idempotent |
| `AGENTS.md` | Source de vérité indépendante de l'agent (systèmes, règles de branches, conventions) |
| `CLAUDE.md` | Spécificités Claude Code ; importe `AGENTS.md` |
| `.agents/skills/` | Skills de workflow canoniques (indépendantes de l'agent) |
| `.claude/` | Réglages Claude Code, agents, liens symboliques de skills |
| `.opencode/` | Agents et configuration de plugin opencode |
| `.mcp.json` / `opencode.json` | Serveurs MCP (gestionnaire de tickets, semble) |
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
séparé, ajoutez-le à `repos` dans `devrig.toml`, supprimez le dossier ici et
mettez à jour le pointeur dans `AGENTS.md`.

## Dépannage

- **`semble` ou `uv` introuvables après le setup** — ouvrez un nouveau shell (le PATH a été mis à jour) et relancez `./setup.sh`.
- **Outils du gestionnaire de tickets absents dans Claude** — lancez `/mcp` et terminez le flux OAuth du serveur `linear` ou `atlassian`.
- **rtk ne s'active pas** — redémarrez Claude Code ; vérifiez avec `rtk gain` que les commandes sont bien proxifiées.
- **Un dépôt ne se met pas à jour** — `setup.sh` ne touche jamais un dépôt avec des changements locaux ou sur une branche de tâche ; il ne fait que du fast-forward sur des checkouts propres de la branche par défaut.
- **setup.sh ne me demande rien, il échoue directement avec « edit devrig.toml first »** — il n'interroge que s'il est attaché à un terminal interactif ; le lancer depuis un script ou une CI exige que `devrig.toml` soit déjà rempli.
- **Vous avez choisi Jira ou « autre »** — le serveur MCP `atlassian` (Jira) est configuré automatiquement, mais `/start-task`, `/raise-pr` et `/create-ticket` appellent toujours les outils MCP de Linear — `setup.sh` vous le rappellera à la fin de chaque exécution tant que vous n'aurez pas adapté ces skills.

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
