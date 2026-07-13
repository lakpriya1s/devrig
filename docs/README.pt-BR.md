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
| 🧠 | **Skills de fluxo de trabalho com IA** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (independentes de agente, em `.agents/skills/`, com symlinks para o Claude Code; opencode também configurado) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — busca semântica de código que os agentes usam via MCP em vez de grep e leitura de arquivos |
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
   vai te guiar interativamente: nome do projeto, organização do GitHub, os
   repos a clonar (cole vários de uma vez, separados por espaço ou vírgula),
   seu gestor de tickets (**Linear**, **Jira** ou **outro** — escolha em um
   menu), prefixo de tickets, branch padrão e toggles de funcionalidades — e
   então grava o `devrig.toml` para você. Prefere editar à mão? Preencha o
   `devrig.toml` antes de rodar o script e ele pula as perguntas.
3. Execute `claude` a partir desta pasta e comece a trabalhar.

De qualquer forma, dentro do Claude Code: execute `/mcp` e autentique o servidor do
gestor de tickets configurado (**linear** ou **atlassian**; OAuth único —
**semble** não precisa de autenticação), e reinicie o Claude Code uma vez
para o hook do rtk entrar em vigor.

## 🤖 Comece com seu agente de IA

Acabou de criar um workspace a partir deste template? Cole isto no seu agente
de programação (Claude Code, Cursor, opencode, …) e deixe-o terminar a
configuração com você:

```text
I just created a workspace from the devrig template
(https://github.com/lakpriya1s/devrig). Help me set it up:

1. Read README.md and AGENTS.md to understand the workspace.
2. Run ./setup.sh with me, relaying its interactive prompts (project name,
   GitHub org, repos, issue tracker, ticket prefix, default branch, feature
   toggles) so I can answer them — then help me fix anything it flags.
3. Work through the README's "Customization checklist" section with me.
4. Commit the personalization on a task branch and open a PR.
```

## O que o setup.sh faz

O `setup.sh` é idempotente — execute-o novamente a qualquer momento para
atualizar todos os repos e ferramentas. Ele:

0. **Só na primeira vez**: se o `devrig.toml` ainda tiver os valores de exemplo, pergunta tudo acima interativamente e grava o `devrig.toml`.
1. Verifica os pré-requisitos (`git`, `gh` autenticado; instala `uv` se o semble estiver habilitado).
2. Clona cada repo de `repos` lado a lado (ou faz fast-forward de checkouts limpos da branch padrão), e os exclui do status git deste repo via `.git/info/exclude`.
3. Instala os hooks de git de branches protegidas neste repo e em cada repo clonado.
4. Converge `.mcp.json` / `opencode.json` para os toggles do seu `devrig.toml` — adicionando o servidor `linear` ou `atlassian` (Jira) conforme `issue_tracker`, ou nenhum se você escolheu "outro" — preservando servidores MCP adicionados manualmente — e gera `.claude/settings.local.json`.
5. Instala o semble e aquece um índice de busca por repo.
6. Instala o rtk e registra seu hook do Claude Code.
7. Gera o `<project>.code-workspace` para o VS Code (pulado se você já tiver um, então é seguro personalizar e commitar).

## Checklist de personalização

Após a primeira execução do `setup.sh`, faça seu commit de personalização:

- [ ] `devrig.toml` — o `setup.sh` pergunta esses valores interativamente na primeira execução (ou preencha o arquivo à mão antes de rodá-lo e ele pula as perguntas). Para mudar valores depois (trocar de gestor, adicionar um repo), edite `devrig.toml` diretamente e rode `./setup.sh` de novo.
- [ ] `AGENTS.md` — preencha a tabela **Systems** (uma linha por repo: o que é, stack) e a seção **Testing**. É a fonte de verdade que toda skill lê.
- [ ] `.agents/skills/code-review/references/` e `.agents/skills/write-doc/references/` — um arquivo de referência por repo (copie `_example-repo.md`). As skills funcionam sem eles, mas ficam muito mais afiadas com eles.
- [ ] Se `issue_tracker` for `linear`: verifique a tabela de "Convenções" de `.agents/skills/create-ticket/SKILL.md` contra seu workspace do Linear (times, projetos, labels). Se for `jira` ou `other`: adapte as chamadas `mcp__linear__*` de `/start-task`, `/raise-pr` e `/create-ticket` para as ferramentas MCP do seu gestor (cada skill sinaliza isso no topo).
- [ ] Remova ou ajuste o que um toggle desabilitou (ex.: remova as notas do semble do `CLAUDE.md` se você não usa).

## Estrutura

| Caminho | O que é |
|---|---|
| `devrig.toml` | Sua configuração de projeto — o único arquivo que toda ferramenta lê |
| `setup.sh` | Script de bootstrap/atualização idempotente |
| `AGENTS.md` | Fonte de verdade independente de agente (sistemas, regras de branch, convenções) |
| `CLAUDE.md` | Específicos do Claude Code; importa `AGENTS.md` |
| `.agents/skills/` | Skills de fluxo de trabalho canônicas (independentes de agente) |
| `.claude/` | Configurações do Claude Code, agentes, symlinks de skills |
| `.opencode/` | Agentes e configuração de plugin do opencode |
| `.mcp.json` / `opencode.json` | Servidores MCP (gestor de tickets, semble) |
| `git-hooks/` | Hooks pre-commit / pre-push de branches protegidas |
| `knowledge/` | Base de conhecimento em markdown (arquitetura, decisões, design, runbooks, produto, releases) |
| `<repo>/` (não rastreado) | Seus repos de projeto, clonados pelo `setup.sh` |

## Adicionando uma skill

Veja [`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md).
Versão curta: crie `.agents/skills/<name>/SKILL.md`, faça symlink em
`.claude/skills/` e liste-a no `CLAUDE.md`.

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
