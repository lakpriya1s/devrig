<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**Um rig para todos os seus repos — template de workspace multi-repo pronto para IA.**

[![npx create-devrig](https://img.shields.io/npm/v/create-devrig?label=npx%20create-devrig&color=22D3EE&style=flat-square)](https://www.npmjs.com/package/create-devrig)
[![Use this template](https://img.shields.io/badge/Use%20this-template-3B82F6?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [हिन्दी](README.hi.md) · **Português** · [日本語](README.ja.md) · [Français](README.fr.md) · [한국어](README.ko.md) · [සිංහල](README.si.md)

</div>

---

## O que é o devrig?

O devrig é um *meta-repo*: uma pasta que contém todos os repos do seu projeto
**mais** as ferramentas de IA usadas para desenvolver entre eles. Este repo
versiona apenas as ferramentas — seus repos de projeto são clonados lado a
lado pelo `setup.sh` e permanecem não rastreados. Tudo é configurado a partir
de um único arquivo **`devrig.toml`**.

| | O que você ganha |
|---|---|
| 🧠 | **Skills de fluxo de trabalho com IA** — `/start-task`, `/plan-task`, `/verify-change`, `/raise-pr`, `/code-review`, `/write-doc`, `/capture-learning`, `/check-knowledge-consistency`, `/create-ticket` (independentes de agente, em `.agents/skills/`, com symlinks para o Claude Code; opencode também configurado) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — busca semântica de código que os agentes usam via MCP em vez de grep e leitura de arquivos |
| 🕸️ | **[graphify](https://github.com/Graphify-Labs/graphify)** — um grafo de conhecimento por repo que os agentes consultam em vez de fazer grep, mantido atualizado por hooks do git |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — proxy de comandos que otimiza tokens para o Claude Code |
| 🎫 | **MCP de gestor de tickets** — Linear, Jira ou o seu; escolhido interativamente pelo `setup.sh` |
| 🛡️ | **Hooks de git para branches protegidas** — sem commits/pushes acidentais na sua branch padrão, em nenhum repo |
| 📚 | **`knowledge/`** — esqueleto de base de conhecimento em markdown (arquitetura, ADRs, documentos de design, runbooks) que as ferramentas de IA indexam e onde escrevem |
| 🖥️ | **Workspace multi-root do VS Code gerado** — todos os repos em uma janela |

## Início rápido

O jeito mais rápido — um único comando, sem clonar:

```bash
npx create-devrig my-project
```

O [`create-devrig`](https://github.com/lakpriya1s/create-devrig) busca este template (sem histórico de git), inicializa um repositório git novo em `my-project/`, e já lança o assistente de configuração interativo — o mesmo assistente descrito abaixo, só que sem o passo separado de clonar.

Prefere a interface do GitHub, ou quer que o repo já seja criado dentro da sua organização?

1. Clique em **[Use this template](https://github.com/lakpriya1s/devrig/generate)** para criar `sua-org/seu-projeto-workspace`.
2. Clone e execute:

   ```bash
   ./setup.sh
   ```

   Na primeira execução, se o `devrig.toml` ainda tiver os valores de exemplo, ele
   vai te guiar interativamente: nome do projeto, uma descrição de uma linha,
   organização do GitHub, os repos a clonar (cole vários de uma vez, separados
   por espaço ou vírgula), seu gestor de tickets (**Linear**, **Jira** ou
   **outro** — escolha em um menu), prefixo de tickets, branch padrão e
   toggles de funcionalidades — e então grava o `devrig.toml` para você,
   remove os arquivos próprios do devrig, e gera um `README.md` para o seu
   projeto no lugar deles. Prefere editar à mão? Preencha o `devrig.toml`
   antes de rodar o script e ele pula as perguntas.
3. Execute `claude` a partir desta pasta e comece a trabalhar.

De qualquer forma, dentro do Claude Code: execute `/mcp` e autentique o servidor do
gestor de tickets configurado (**linear** ou **atlassian**; OAuth único —
**semble** não precisa de autenticação), e reinicie o Claude Code uma vez
para o hook do rtk entrar em vigor. Se o graphify estiver habilitado, construa o grafo de cada repo uma vez com `graphify update .` na raiz do repo — a partir daí os hooks do git o mantêm atualizado.

## 🤖 Comece com seu agente de IA

### Já tem seus repos?

Acabou de criar um workspace a partir deste template? Cole isto no seu agente
de programação (Claude Code, Cursor, opencode, …) e deixe-o terminar a
configuração com você:

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

### Começando um projeto totalmente novo?

Ainda sem repos, só uma ideia? Troque a parte marcada pela descrição do seu projeto e cole isto — o agente te leva da ideia a um workspace funcionando, repos novos incluídos:

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

## O que o setup.sh faz

O `setup.sh` é idempotente — execute-o novamente a qualquer momento para
atualizar todos os repos e ferramentas. Ele:

0. **Só na primeira vez**: se o `devrig.toml` ainda tiver os valores de exemplo, pergunta tudo acima interativamente e grava o `devrig.toml`.
1. **Personaliza o workspace**: remove os arquivos próprios do devrig
   (`docs/`, `assets/`, `CITATION.cff`, `CONTRIBUTING.md`, `LICENSE`) e gera
   um `README.md` para o seu projeto a partir do `devrig.toml`. Pulado dentro
   do próprio repo do devrig, e um README que você editou nunca é sobrescrito.
2. Verifica os pré-requisitos (`git`, `gh` autenticado; instala `uv` se o semble ou o graphify estiver habilitado).
3. Clona cada repo de `repos` lado a lado (ou faz fast-forward de checkouts limpos da branch padrão), e os exclui do status git deste repo via `.git/info/exclude`.
4. Instala os hooks de git de branches protegidas neste repo e em cada repo clonado.
5. Converge `.mcp.json` / `opencode.json` para os toggles do seu `devrig.toml` — adicionando o servidor `linear` ou `atlassian` (Jira) conforme `issue_tracker`, ou nenhum se você escolheu "outro" — preservando servidores MCP adicionados manualmente — e gera `.claude/settings.local.json`.
6. Instala o semble e aquece um índice de busca por repo.
7. Instala o rtk e registra seu hook do Claude Code.
8. Instala o graphify: sua skill em `.agents/skills/` (com symlink para o Claude Code), os guards PreToolUse que apontam os agentes para o grafo antes de eles fazerem grep, e os hooks do git que reconstroem o grafo de um repo após commits, checkouts e merges.
9. Gera o `<project>.code-workspace` para o VS Code (pulado se você já tiver um, então é seguro personalizar e commitar).

## Checklist de personalização

O `setup.sh` cuida sozinho da personalização mecânica (grava `devrig.toml`,
remove os arquivos do template do devrig, gera o README do seu projeto). O
que resta é o conhecimento que só você tem — a seção **"Customize this
workspace"** do README gerado leva essa mesma checklist para o seu workspace:

- [ ] `AGENTS.md` — preencha a tabela **Systems** (uma linha por repo: o que é, stack, do que depende), a tabela **Commands** e a seção **Testing**. É a fonte de verdade que toda skill lê. Mantenha a tabela "What's inside" do README gerado sincronizada.
- [ ] `POLICY.md` — ajuste a Definition of Done e os gatilhos de ADR para o padrão real do seu time (ex.: adicione uma exigência de revisão de segurança).
- [ ] `.ai/systems.yaml`, `.ai/commands.yaml`, `.ai/ownership.yaml` — substitua os exemplos pelos seus sistemas/comandos/donos reais (espelham as tabelas do `AGENTS.md`; `node scripts/validate-ai-config.mjs` verifica o formato).
- [ ] `.ai/policies.yaml`, `.ai/risk-levels.yaml` — ajuste os caminhos protegidos, as ações proibidas/que exigem aprovação e os exemplos de risco para o seu projeto.
- [ ] `.agents/skills/code-review/references/` e `.agents/skills/write-doc/references/` — um arquivo de referência por repo (copie `_example-repo.md`). As skills funcionam sem eles, mas ficam muito mais afiadas com eles.
- [ ] Se `issue_tracker` for `linear`: verifique a tabela de "Convenções" de `.agents/skills/create-ticket/SKILL.md` contra seu workspace do Linear (times, projetos, labels). Se for `jira` ou `other`: adapte as chamadas `mcp__linear__*` de `/start-task`, `/raise-pr` e `/create-ticket` para as ferramentas MCP do seu gestor (cada skill sinaliza isso no topo).
- [ ] Remova ou ajuste o que um toggle desabilitou (ex.: remova as notas do semble do `CLAUDE.md` se você não usa).

Para mudar valores de configuração depois (trocar de gestor, adicionar um
repo), edite `devrig.toml` diretamente e rode `./setup.sh` de novo.

## Estrutura

| Caminho | O que é |
|---|---|
| `devrig.toml` | Sua configuração de projeto — o único arquivo que toda ferramenta lê |
| `setup.sh` | Script de bootstrap/atualização idempotente |
| `AGENTS.md` | Fonte de verdade independente de agente (sistemas, comandos, regras de branch, política de retrieval) |
| `POLICY.md` | Definition of Done, exigência de ADR, política de risco/dados/papéis, relatórios de verificação/confiança |
| `.ai/` | Espelho legível por máquina do acima (`systems.yaml`, `commands.yaml`, `ownership.yaml`, `policies.yaml`, `risk-levels.yaml`), seus JSON Schemas em `.ai/schemas/`, e pacotes de contexto por tarefa em `.ai/context/` (gravados pelo `/start-task`) |
| `.github/workflows/` | CI: valida os `.ai/*.yaml` contra seus schemas, e valida o `knowledge/` (frontmatter, links, ids de ADR, atualização do índice, exigência de ADR em caminhos protegidos) |
| `CLAUDE.md` | Específicos do Claude Code; importa `AGENTS.md` |
| `.agents/skills/` | Skills de fluxo de trabalho canônicas (independentes de agente) |
| `.claude/` | Configurações do Claude Code, agentes, symlinks de skills |
| `.opencode/` | Agentes e configuração de plugin do opencode |
| `.mcp.json` / `opencode.json` | Servidores MCP (gestor de tickets, semble) |
| `git-hooks/` | Hooks compartilhados por todos os repos (`core.hooksPath`): pre-commit / pre-push de branches protegidas, mais as reconstruções do grafo do graphify |
| `knowledge/` | Base de conhecimento em markdown (arquitetura, decisões, design, runbooks, produto, releases, handoffs, generated) — veja `knowledge/index.md` |
| `evals/` | Perguntas com respostas conhecidas, para medir a precisão de retrieval/taxa de alucinação ao longo do tempo — veja `evals/README.md` |
| `scripts/` | Scripts de manutenção do workspace — `build-knowledge-index.mjs`, `validate-knowledge.mjs`, `validate-ai-config.mjs`, `detect-doc-drift.mjs`, `check-adr-requirement.mjs`, `generate-architecture-views.mjs` |
| `<repo>/` (não rastreado) | Seus repos de projeto, clonados pelo `setup.sh` |

## Adicionando uma skill

Veja [`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md).
Versão curta: crie `.agents/skills/<name>/SKILL.md`, faça symlink em
`.claude/skills/` e liste-a no `CLAUDE.md`.

## Grafo de conhecimento

Com o toggle `graphify` ligado, cada repo ganha seu próprio `<repo>/graphify-out/` — um grafo consultável do código (hubs, comunidades, relações entre arquivos) mais um `GRAPH_REPORT.md` em linguagem simples e um `graph.html` interativo. Os agentes usam isso em vez de grep + leitura de arquivos:

```bash
cd <repo>
graphify update .                                # construir/atualizar (só AST, sem API key)
graphify query "como funciona a autenticação"    # subgrafo delimitado, não um despejo de grep
graphify path "LoginForm" "SessionStore"         # como duas coisas se conectam
graphify explain "PaymentService"                # um nó e seus vizinhos
```

O `setup.sh` instala a CLI, coloca a skill em `.agents/skills/graphify/`, registra os guards PreToolUse que levam os agentes ao grafo antes de buscarem, e instala os hooks de reconstrução — o `graphify hook install` cobre post-commit e post-checkout, e o devrig acrescenta `git-hooks/post-merge` para que um `git pull` também atualize o grafo. Os grafos, a skill instalada e os hooks gerados estão todos no gitignore: são regerados a partir da CLI em cada `./setup.sh`, então nada desatualizado é commitado.

## Base de conhecimento

Novos documentos de design, notas de arquitetura, ADRs e runbooks vão para
[`knowledge/`](../knowledge/) como markdown via PR — o semble a indexa, então
os agentes encontram contexto de design da mesma forma que encontram código.
Quando ela crescer além deste repo, publique-a como um repo
`<project>-knowledge` separado, adicione-o a `repos` no `devrig.toml`, apague a
pasta aqui e atualize o ponteiro no `AGENTS.md`.

## Solução de problemas

- **`semble` ou `uv` não encontrados após o setup** — abra um novo shell (o PATH foi atualizado) e execute `./setup.sh` novamente.
- **Ferramentas do gestor de tickets ausentes no Claude** — execute `/mcp` e complete o fluxo OAuth do servidor `linear` ou `atlassian`.
- **rtk não está funcionando** — reinicie o Claude Code; verifique com `rtk gain` que os comandos estão sendo proxificados.
- **`graphify query` diz que não há grafo** — construa-o uma vez por repo com `graphify update .` na raiz do repo; os hooks só atualizam um grafo que já existe.
- **As reconstruções não disparam no commit** — rode `graphify hook status` no repo e confira `~/.cache/graphify-rebuild.log`. `GRAPHIFY_SKIP_HOOK=1` silencia por um comando.
- **Um repo não atualiza** — o `setup.sh` nunca toca um repo com mudanças locais ou em uma branch de tarefa; ele só faz fast-forward de checkouts limpos da branch padrão.
- **setup.sh não pergunta nada, só falha com "edit devrig.toml first"** — ele só pergunta interativamente quando conectado a um terminal; rodá-lo a partir de um script ou CI exige que o `devrig.toml` já esteja preenchido.
- **Escolheu Jira ou "outro"** — o servidor MCP `atlassian` (Jira) é configurado automaticamente, mas `/start-task`, `/raise-pr` e `/create-ticket` ainda chamam as ferramentas MCP do Linear — o `setup.sh` vai te avisar disso no final de cada execução até você adaptar essas skills.

## Contribuindo

O devrig melhora com cada time que o monta. Relatos de bugs, novas skills
genéricas, documentação melhor e **traduções do README** são muito
bem-vindos — veja [CONTRIBUTING.md](../CONTRIBUTING.md). Se o devrig
economizou tempo de setup do seu time, uma ⭐ ajuda outros a encontrá-lo.

## Licença e citação

Publicado sob a [Licença MIT](../LICENSE).

Se você usa o devrig no seu trabalho ou em publicações, uma citação é
apreciada — o botão **"Cite this repository"** do GitHub (alimentado pelo
[`CITATION.cff`](../CITATION.cff)) tem os detalhes, ou:

> Senevirathna, L. (2026). *devrig: a multi-repo AI dev workspace template.*
> https://github.com/lakpriya1s/devrig

<div align="center">
<sub>Construído a partir de um workspace multi-repo em produção · <img src="../assets/devrig-icon.png" width="14" alt=""> devrig</sub>
</div>
