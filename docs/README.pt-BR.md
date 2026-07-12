<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**Um rig para todos os seus repos — template de workspace multi-repo pronto para IA.**

[![Use this template](https://img.shields.io/badge/Use%20this-template-22D3EE?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
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
de um único arquivo **`.setup`**.

| | O que você ganha |
|---|---|
| 🧠 | **Skills de fluxo de trabalho com IA** — `/start-task`, `/raise-pr`, `/code-review`, `/write-doc`, `/create-ticket` (independentes de agente, em `.agents/skills/`, com symlinks para o Claude Code; opencode também configurado) |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — busca semântica de código que os agentes usam via MCP em vez de grep e leitura de arquivos |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — proxy de comandos que otimiza tokens para o Claude Code |
| 🎫 | **Linear MCP** — gestão de tickets integrada às skills |
| 🛡️ | **Hooks de git para branches protegidas** — sem commits/pushes acidentais na sua branch padrão, em nenhum repo |
| 📚 | **`knowledge/`** — esqueleto de base de conhecimento em markdown (arquitetura, ADRs, documentos de design, runbooks) que as ferramentas de IA indexam e onde escrevem |
| 🖥️ | **Workspace multi-root do VS Code gerado** — todos os repos em uma janela |

## Início rápido

1. Clique em **[Use this template](https://github.com/lakpriya1s/devrig/generate)** para criar `sua-org/seu-projeto-workspace`.
2. Clone e edite o **`.setup`** — nome do projeto, organização do GitHub, lista de repos, prefixo de tickets, branch padrão, toggles.
3. Execute:

   ```bash
   ./setup.sh
   ```

4. Execute `claude` a partir desta pasta e comece a trabalhar.

Depois, dentro do Claude Code: execute `/mcp` e autentique o servidor
**linear** (OAuth único; **semble** não precisa de autenticação), e reinicie o
Claude Code uma vez para o hook do rtk entrar em vigor.

## 🤖 Comece com seu agente de IA

Acabou de criar um workspace a partir deste template? Cole isto no seu agente
de programação (Claude Code, Cursor, opencode, …) e deixe-o terminar a
configuração com você:

```text
Acabei de criar um workspace a partir do template devrig
(https://github.com/lakpriya1s/devrig). Me ajude a configurá-lo:

1. Leia README.md, AGENTS.md e .setup para entender o workspace.
2. Pergunte meu nome de projeto, organização do GitHub, lista de repos,
   prefixo de tickets e branch padrão, e preencha o .setup.
3. Execute ./setup.sh e me ajude a corrigir o que ele apontar.
4. Preencha a tabela Systems do AGENTS.md — uma linha por repo (o que é, stack).
5. Para cada repo, escreva uma referência de revisão em
   .agents/skills/code-review/references/<repo>.md e uma de documentação em
   .agents/skills/write-doc/references/<repo>.md (copie os scaffolds
   _example-repo.md e verifique cada fato no código).
6. Verifique a tabela de convenções do create-ticket contra meu workspace do Linear.
7. Faça commit da personalização em uma branch de tarefa e abra um PR.
```

## O que o setup.sh faz

O `setup.sh` é idempotente — execute-o novamente a qualquer momento para
atualizar todos os repos e ferramentas. Ele:

1. Verifica os pré-requisitos (`git`, `gh` autenticado; instala `uv` se o semble estiver habilitado).
2. Clona cada repo de `REPOS` lado a lado (ou faz fast-forward de checkouts limpos da branch padrão), e os exclui do status git deste repo via `.git/info/exclude`.
3. Instala os hooks de git de branches protegidas neste repo e em cada repo clonado.
4. Converge `.mcp.json` / `opencode.json` para os toggles do seu `.setup` (servidores MCP adicionados manualmente são preservados) e gera `.claude/settings.local.json`.
5. Instala o semble e aquece um índice de busca por repo.
6. Instala o rtk e registra seu hook do Claude Code.
7. Gera o `<project>.code-workspace` para o VS Code (pulado se você já tiver um, então é seguro personalizar e commitar).

## Checklist de personalização

Após a primeira execução do `setup.sh`, faça seu commit de personalização:

- [ ] `.setup` — seus valores reais (o setup.sh se recusa a rodar com os valores de exemplo).
- [ ] `AGENTS.md` — preencha a tabela **Systems** (uma linha por repo: o que é, stack) e a seção **Testing**. É a fonte de verdade que toda skill lê.
- [ ] `.agents/skills/code-review/references/` e `.agents/skills/write-doc/references/` — um arquivo de referência por repo (copie `_example-repo.md`). As skills funcionam sem eles, mas ficam muito mais afiadas com eles.
- [ ] `.agents/skills/create-ticket/SKILL.md` — verifique a tabela de "Convenções" contra seu workspace do Linear (times, projetos, labels).
- [ ] Remova ou ajuste o que um toggle desabilitou (ex.: remova as notas do linear do `CLAUDE.md` se você não usa Linear).

## Estrutura

| Caminho | O que é |
|---|---|
| `.setup` | Sua configuração de projeto — o único arquivo que toda ferramenta lê |
| `setup.sh` | Script de bootstrap/atualização idempotente |
| `AGENTS.md` | Fonte de verdade independente de agente (sistemas, regras de branch, convenções) |
| `CLAUDE.md` | Específicos do Claude Code; importa `AGENTS.md` |
| `.agents/skills/` | Skills de fluxo de trabalho canônicas (independentes de agente) |
| `.claude/` | Configurações do Claude Code, agentes, symlinks de skills |
| `.opencode/` | Agentes e configuração de plugin do opencode |
| `.mcp.json` / `opencode.json` | Servidores MCP (linear, semble) |
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
`<project>-knowledge` separado, adicione-o a `REPOS` no `.setup`, apague a
pasta aqui e atualize o ponteiro no `AGENTS.md`.

## Solução de problemas

- **`semble` ou `uv` não encontrados após o setup** — abra um novo shell (o PATH foi atualizado) e execute `./setup.sh` novamente.
- **Ferramentas do Linear ausentes no Claude** — execute `/mcp` e complete o fluxo OAuth do servidor linear.
- **rtk não está funcionando** — reinicie o Claude Code; verifique com `rtk gain` que os comandos estão sendo proxificados.
- **Um repo não atualiza** — o `setup.sh` nunca toca um repo com mudanças locais ou em uma branch de tarefa; ele só faz fast-forward de checkouts limpos da branch padrão.
- **setup.sh diz "edit .setup first"** — ele se recusa a rodar enquanto o `.setup` contiver os valores de exemplo (`PROJECT_NAME="acme"`).

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
