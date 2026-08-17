<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**一个 rig 管理所有仓库 — 面向 AI 的多仓库开发工作区模板。**

[![npx create-devrig](https://img.shields.io/npm/v/create-devrig?label=npx%20create-devrig&color=22D3EE&style=flat-square)](https://www.npmjs.com/package/create-devrig)
[![Use this template](https://img.shields.io/badge/Use%20this-template-3B82F6?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · **简体中文** · [Español](README.es.md) · [हिन्दी](README.hi.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [한국어](README.ko.md) · [සිංහල](README.si.md)

</div>

---

## devrig 是什么？

devrig 是一个*元仓库（meta-repo）*：一个文件夹容纳项目的所有仓库，**外加**用于跨仓库开发的 AI 工具链。本仓库只对工具本身进行版本管理 — 你的项目仓库由 `setup.sh` 并排克隆，不被跟踪。一切都由一个 **`devrig.toml`** 文件配置。

| | 你将获得 |
|---|---|
| 🧠 | **AI 工作流技能** — `/start-task`、`/plan-task`、`/verify-change`、`/raise-pr`、`/code-review`、`/write-doc`、`/capture-learning`、`/check-knowledge-consistency`、`/create-ticket`（与具体 agent 无关，存放于 `.agents/skills/`，为 Claude Code 建立符号链接，同时配置了 opencode） |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — 语义代码搜索，agent 通过 MCP 使用它替代 grep+逐个读取文件 |
| 🕸️ | **[graphify](https://github.com/Graphify-Labs/graphify)** — 每个仓库一张知识图谱，agent 查询它而不是 grep，由 git 钩子保持最新 |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — 为 Claude Code 优化 token 消耗的命令代理 |
| 🎫 | **工单系统 MCP** — Linear、Jira 或自带其他系统；由 `setup.sh` 交互式询问选择 |
| 🛡️ | **受保护分支的 git 钩子** — 任何仓库都不会意外提交/推送到默认分支 |
| 📚 | **`knowledge/`** — markdown 知识库骨架（架构、ADR、设计文档、运维手册），AI 工具会索引并写入其中 |
| 🖥️ | **自动生成的 VS Code 多根工作区** — 所有仓库在一个窗口中 |

## 快速开始

最快的方式 — 一条命令，无需克隆：

```bash
npx create-devrig my-project
```

[`create-devrig`](https://github.com/lakpriya1s/create-devrig) 会拉取本模板（不含 git 历史）、在 `my-project/` 中初始化全新的 git 仓库，并立即启动交互式安装向导 — 与下面描述的向导相同，只是省去了单独的克隆步骤。

更喜欢 GitHub 的界面，或想从一开始就在你的组织下创建仓库？

1. 点击 **[Use this template](https://github.com/lakpriya1s/devrig/generate)** 创建 `your-org/your-project-workspace`。
2. 克隆后运行：

   ```bash
   ./setup.sh
   ```

   第一次运行时，脚本发现 `devrig.toml` 还是示例值，会以交互方式引导你完成配置：项目名、一句话描述、GitHub 组织、要克隆的仓库（可一次粘贴多个，用空格或逗号分隔）、工单系统（**Linear**、**Jira** 或**其他** — 从菜单中选择）、工单前缀、默认分支、功能开关，然后自动写入 `devrig.toml`、删除 devrig 自身的模板文件，并为*你的*项目生成一份 `README.md` 取而代之。想手动编辑？在运行脚本前自行填好 `devrig.toml`，它就会跳过交互提示。
3. 在此文件夹中运行 `claude`，开始工作。

无论哪种方式，之后在 Claude Code 内：运行 `/mcp` 并为配置好的工单系统服务器（**linear** 或 **atlassian**）完成一次性 OAuth 认证（**semble** 无需认证），并重启一次 Claude Code 使 rtk 钩子生效。 若启用了 graphify，在每个仓库根目录运行一次 `graphify update .` 构建图谱 — 之后 git 钩子会自动保持最新。

## 🤖 用你的 AI agent 启动项目

### 已经有你的仓库了？

刚从模板创建了工作区？把下面的提示词粘贴给你的 AI 编程 agent（Claude Code、Cursor、opencode 等），让它陪你完成剩余设置：

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

### 要开始一个全新的项目？

还没有仓库，只有一个想法？把下面标记处换成你的项目描述，然后粘贴这个 — agent 会带你从想法直接走到一个可运行的工作区，包括新建仓库：

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

## setup.sh 做了什么

`setup.sh` 是幂等的 — 随时重新运行即可更新所有仓库和工具。它会：

0. **仅首次运行**：如果 `devrig.toml` 还是示例值，交互式询问上述所有配置并写入 `devrig.toml`。
1. **个性化工作区**：删除 devrig 自身的模板文件（`docs/`、`assets/`、
   `CITATION.cff`、`CONTRIBUTING.md`、`LICENSE`），并根据 `devrig.toml` 为
   *你的*项目生成一份 `README.md`。在 devrig 模板仓库自身内会跳过此步骤，
   你编辑过的 README 也永远不会被覆盖。
2. 检查前提条件（`git`、已认证的 `gh`；若启用了 semble 或 graphify 则安装 `uv`）。
3. 并排克隆 `repos` 中的每个仓库（或对干净的默认分支检出做 fast-forward），并通过 `.git/info/exclude` 将它们从本仓库的 git 状态中排除。
4. 为本仓库和每个克隆的仓库安装受保护分支的 git 钩子。
5. 使 `.mcp.json` / `opencode.json` 收敛到你的 `devrig.toml` 开关 — 根据 `issue_tracker` 添加 `linear` 或 `atlassian`（Jira）服务器，选择"其他"则两者都不添加 — 同时保留你手动添加的 MCP 服务器，并生成 `.claude/settings.local.json`。
6. 安装 semble，并为每个仓库预热搜索索引。
7. 安装 rtk 并注册其 Claude Code 钩子。
8. 安装 graphify：把它的技能放进 `.agents/skills/`（并为 Claude Code 建立符号链接）、注册在 agent 动手 grep 之前把它指向图谱的 PreToolUse 守卫，以及在提交、检出、合并之后重建该仓库图谱的 git 钩子。
9. 生成 VS Code 的 `<project>.code-workspace`（若已存在则跳过，可放心自定义和提交）。

## 自定义清单

机械式的个性化工作 `setup.sh` 自己就会完成（写入 `devrig.toml`、删除 devrig
模板文件、生成你的项目 README）。剩下的是只有你才知道的信息 — 生成的 README
中 **"Customize this workspace"** 一节把同样的清单带到了你的工作区里：

- [ ] `AGENTS.md` — 填写 **Systems** 表（每个仓库一行：它是什么、技术栈、依赖什么）、**Commands** 表，以及 **Testing** 部分。这是所有技能读取的唯一信息源。同时保持生成的 README 中 "What's inside" 表的同步。
- [ ] `POLICY.md` — 根据你团队的实际标准调整 Definition of Done 和 ADR 触发条件（例如加入安全审查要求）。
- [ ] `.ai/systems.yaml`、`.ai/commands.yaml`、`.ai/ownership.yaml` — 用你真实的系统/命令/负责人替换示例条目（与 `AGENTS.md` 的表格对应；`node scripts/validate-ai-config.mjs` 会校验格式）。
- [ ] `.ai/policies.yaml`、`.ai/risk-levels.yaml` — 为你的项目调整受保护路径、禁止/需审批的操作，以及风险等级示例。
- [ ] `.agents/skills/code-review/references/` 和 `.agents/skills/write-doc/references/` — 每个仓库一个参考文件（复制 `_example-repo.md`）。没有它们技能也能用，但有了会锐利得多。
- [ ] 若 `issue_tracker` 是 `linear`：对照你的 Linear 工作区核实 `.agents/skills/create-ticket/SKILL.md` 的"约定"表（团队、项目、标签）。若是 `jira` 或 `other`：把 `/start-task`、`/raise-pr`、`/create-ticket` 中的 `mcp__linear__*` 调用适配为你的工单系统的 MCP 工具名（每个技能文件顶部都有提示）。
- [ ] 删除或调整被开关禁用的内容（例如不用 semble 就从 `CLAUDE.md` 删除相关说明）。

之后想更改配置值（换工单系统、加仓库），直接编辑 `devrig.toml` 再重新运行
`./setup.sh`。

## 目录结构

| 路径 | 说明 |
|---|---|
| `devrig.toml` | 项目配置 — 所有工具读取的唯一文件 |
| `setup.sh` | 幂等的引导/更新脚本 |
| `AGENTS.md` | 与 agent 无关的唯一信息源（系统、命令、分支规则、检索策略） |
| `POLICY.md` | Definition of Done、ADR 要求、风险/数据/角色策略、验证证据与置信度报告 |
| `.ai/` | 上述内容的机器可读镜像（`systems.yaml`、`commands.yaml`、`ownership.yaml`、`policies.yaml`、`risk-levels.yaml`），及 `.ai/schemas/` 中对应的 JSON Schema，以及 `.ai/context/` 中按任务生成的上下文包（由 `/start-task` 写入） |
| `.github/workflows/` | CI：校验 `.ai/*.yaml` 是否符合其 schema，并校验 `knowledge/`（frontmatter、链接、ADR 编号、索引是否最新、受保护路径的 ADR 要求） |
| `CLAUDE.md` | Claude Code 专属内容；导入 `AGENTS.md` |
| `.agents/skills/` | 规范的工作流技能（与 agent 无关） |
| `.claude/` | Claude Code 设置、agent、技能符号链接 |
| `.opencode/` | opencode 的 agent 和插件配置 |
| `.mcp.json` / `opencode.json` | MCP 服务器（工单系统、semble） |
| `git-hooks/` | 所有仓库共享的钩子（`core.hooksPath`）：受保护分支的 pre-commit / pre-push，以及 graphify 的图谱重建 |
| `knowledge/` | markdown 知识库（架构、决策、设计、运维手册、产品、发布、交接记录、生成内容）— 见 `knowledge/index.md` |
| `evals/` | 带有已知正确答案的问题集，用于长期衡量检索准确率/幻觉率 — 见 `evals/README.md` |
| `scripts/` | 工作区维护脚本 — `build-knowledge-index.mjs`、`validate-knowledge.mjs`、`validate-ai-config.mjs`、`detect-doc-drift.mjs`、`check-adr-requirement.mjs`、`generate-architecture-views.mjs` |
| `<repo>/`（不跟踪） | 你的项目仓库，由 `setup.sh` 克隆 |

## 添加技能

见 [`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md)。
简版：创建 `.agents/skills/<name>/SKILL.md`，符号链接到 `.claude/skills/`，并在 `CLAUDE.md` 中列出。

## 知识图谱

打开 `graphify` 开关后，每个仓库都会有自己的 `<repo>/graphify-out/` — 一张可查询的代码图谱（枢纽节点、社区、跨文件关系），外加一份通俗的 `GRAPH_REPORT.md` 和可交互的 `graph.html`。agent 用它替代 grep+逐个读取文件：

```bash
cd <repo>
graphify update .                                # 构建/刷新（纯 AST，无需 API key）
graphify query "认证是怎么工作的"                  # 有范围的子图，而不是一堆 grep 结果
graphify path "LoginForm" "SessionStore"         # 两者之间如何关联
graphify explain "PaymentService"                # 某个节点及其邻居
```

`setup.sh` 会安装 CLI、把技能放到 `.agents/skills/graphify/`、注册让 agent 先查图谱再搜索的 PreToolUse 守卫，并安装重建钩子 — `graphify hook install` 负责 post-commit 和 post-checkout，devrig 另外提供 `git-hooks/post-merge`，让 `git pull` 也刷新图谱。图谱、安装好的技能和生成的钩子都被 gitignore：每次 `./setup.sh` 都会从 CLI 重新生成，因此不会提交过时内容。

## 知识库

新的设计文档、架构说明、ADR 和运维手册以 markdown 形式通过 PR 进入 [`knowledge/`](../knowledge/) — semble 会索引它，agent 找设计上下文就像找代码一样。当它超出本仓库的规模时，将其推送为独立的 `<project>-knowledge` 仓库，加入 `devrig.toml` 的 `repos`，删除此处的文件夹，并更新 `AGENTS.md` 中的指向。

## 疑难解答

- **setup 后找不到 `semble` 或 `uv`** — 打开新 shell（PATH 已更新）并重新运行 `./setup.sh`。
- **Claude 中缺少工单系统工具** — 运行 `/mcp` 并完成 `linear` 或 `atlassian` 服务器的 OAuth 流程。
- **rtk 没有生效** — 重启 Claude Code；用 `rtk gain` 验证命令是否被代理。
- **`graphify query` 说没有图谱** — 在该仓库根目录运行一次 `graphify update .`；钩子只刷新已存在的图谱。
- **提交后没有触发图谱重建** — 在该仓库运行 `graphify hook status`，并查看 `~/.cache/graphify-rebuild.log`。`GRAPHIFY_SKIP_HOOK=1` 可让单条命令跳过重建。
- **某个仓库不更新** — `setup.sh` 从不触碰有本地改动或在任务分支上的仓库；只对干净的默认分支检出做 fast-forward。
- **setup.sh 没有交互提示，直接报错 "edit devrig.toml first"** — 只有连接到交互式终端时才会提示；在脚本或 CI 中运行则要求 `devrig.toml` 已经填好。
- **选择了 Jira 或"其他"** — `atlassian`（Jira）MCP 服务器会自动配置好，但 `/start-task`、`/raise-pr`、`/create-ticket` 仍调用 Linear 的 MCP 工具名 — 在你适配这些技能之前，`setup.sh` 每次运行结束都会提醒你。

## 参与贡献

每一个用上 devrig 的团队都让它变得更好。欢迎 bug 报告、新的通用技能、更好的文档以及 **README 翻译** — 见 [CONTRIBUTING.md](../CONTRIBUTING.md)。如果 devrig 为你的团队节省了搭建时间，点个 ⭐ 能帮助更多人发现它。

## 许可证与引用

基于 [MIT 许可证](../LICENSE) 发布。

如果你在工作或写作中使用了 devrig，欢迎引用 — GitHub 的 **"Cite this repository"** 按钮（由 [`CITATION.cff`](../CITATION.cff) 驱动）有完整信息，或：

> Senevirathna, L. (2026). *devrig: a multi-repo AI dev workspace template.*
> https://github.com/lakpriya1s/devrig

<div align="center">
<sub>源自生产环境的多仓库工作区 · <img src="../assets/devrig-icon.png" width="14" alt=""> devrig</sub>
</div>
