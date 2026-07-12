<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**一个 rig 管理所有仓库 — 面向 AI 的多仓库开发工作区模板。**

[![Use this template](https://img.shields.io/badge/Use%20this-template-22D3EE?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · **简体中文** · [Español](README.es.md) · [हिन्दी](README.hi.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [한국어](README.ko.md) · [සිංහල](README.si.md)

</div>

---

## devrig 是什么？

devrig 是一个*元仓库（meta-repo）*：一个文件夹容纳项目的所有仓库，**外加**用于跨仓库开发的 AI 工具链。本仓库只对工具本身进行版本管理 — 你的项目仓库由 `setup.sh` 并排克隆，不被跟踪。一切都由一个 **`.setup`** 文件配置。

| | 你将获得 |
|---|---|
| 🧠 | **AI 工作流技能** — `/start-task`、`/raise-pr`、`/code-review`、`/write-doc`、`/create-ticket`（与具体 agent 无关，存放于 `.agents/skills/`，为 Claude Code 建立符号链接，同时配置了 opencode） |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — 语义代码搜索，agent 通过 MCP 使用它替代 grep+逐个读取文件 |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — 为 Claude Code 优化 token 消耗的命令代理 |
| 🎫 | **Linear MCP** — 与技能打通的工单系统 |
| 🛡️ | **受保护分支的 git 钩子** — 任何仓库都不会意外提交/推送到默认分支 |
| 📚 | **`knowledge/`** — markdown 知识库骨架（架构、ADR、设计文档、运维手册），AI 工具会索引并写入其中 |
| 🖥️ | **自动生成的 VS Code 多根工作区** — 所有仓库在一个窗口中 |

## 快速开始

1. 点击 **[Use this template](https://github.com/lakpriya1s/devrig/generate)** 创建 `your-org/your-project-workspace`。
2. 克隆后编辑 **`.setup`** — 项目名、GitHub 组织、仓库列表、工单前缀、默认分支、功能开关。
3. 运行：

   ```bash
   ./setup.sh
   ```

4. 在此文件夹中运行 `claude`，开始工作。

然后在 Claude Code 内：运行 `/mcp` 并为 **linear** 服务器完成一次性 OAuth 认证（**semble** 无需认证），并重启一次 Claude Code 使 rtk 钩子生效。

## 🤖 用你的 AI agent 启动项目

刚从模板创建了工作区？把下面的提示词粘贴给你的 AI 编程 agent（Claude Code、Cursor、opencode 等），让它陪你完成剩余设置：

```text
我刚从 devrig 模板（https://github.com/lakpriya1s/devrig）创建了一个工作区。
请帮我完成设置：

1. 阅读 README.md、AGENTS.md 和 .setup，理解这个工作区。
2. 询问我的项目名、GitHub 组织、仓库列表、工单前缀和默认分支，
   然后填入 .setup。
3. 运行 ./setup.sh，并帮我解决它报告的问题。
4. 填写 AGENTS.md 中的 Systems 表 — 每个仓库一行（它是什么、技术栈）。
5. 为每个仓库编写评审参考 .agents/skills/code-review/references/<repo>.md
   和文档参考 .agents/skills/write-doc/references/<repo>.md
   （复制 _example-repo.md 脚手架，所有事实都要在代码中核实）。
6. 对照我的 Linear 工作区核实 create-ticket 的约定表。
7. 在任务分支上提交这些个性化改动并开一个 PR。
```

## setup.sh 做了什么

`setup.sh` 是幂等的 — 随时重新运行即可更新所有仓库和工具。它会：

1. 检查前置条件（`git`、已认证的 `gh`；若启用 semble 则安装 `uv`）。
2. 并排克隆 `REPOS` 中的每个仓库（或对干净的默认分支检出做 fast-forward），并通过 `.git/info/exclude` 将它们从本仓库的 git 状态中排除。
3. 为本仓库和每个克隆的仓库安装受保护分支的 git 钩子。
4. 使 `.mcp.json` / `opencode.json` 收敛到你的 `.setup` 开关（手动添加的 MCP 服务器会被保留），并生成 `.claude/settings.local.json`。
5. 安装 semble，并为每个仓库预热搜索索引。
6. 安装 rtk 并注册其 Claude Code 钩子。
7. 生成 VS Code 的 `<project>.code-workspace`（若已存在则跳过，可放心自定义和提交）。

## 自定义清单

首次运行 `setup.sh` 后，完成你的个性化提交：

- [ ] `.setup` — 填入真实值（保留示例值时 setup.sh 会拒绝运行）。
- [ ] `AGENTS.md` — 填写 **Systems** 表（每个仓库一行：它是什么、技术栈）和 **Testing** 部分。这是所有技能读取的唯一信息源。
- [ ] `.agents/skills/code-review/references/` 和 `.agents/skills/write-doc/references/` — 每个仓库一个参考文件（复制 `_example-repo.md`）。没有它们技能也能用，但有了会锐利得多。
- [ ] `.agents/skills/create-ticket/SKILL.md` — 对照你的 Linear 工作区核实"约定"表（团队、项目、标签）。
- [ ] 删除或调整被开关禁用的内容（例如不用 Linear 就从 `CLAUDE.md` 删除 linear 相关说明）。

## 目录结构

| 路径 | 说明 |
|---|---|
| `.setup` | 项目配置 — 所有工具读取的唯一文件 |
| `setup.sh` | 幂等的引导/更新脚本 |
| `AGENTS.md` | 与 agent 无关的唯一信息源（系统、分支规则、约定） |
| `CLAUDE.md` | Claude Code 专属内容；导入 `AGENTS.md` |
| `.agents/skills/` | 规范的工作流技能（与 agent 无关） |
| `.claude/` | Claude Code 设置、agent、技能符号链接 |
| `.opencode/` | opencode 的 agent 和插件配置 |
| `.mcp.json` / `opencode.json` | MCP 服务器（linear、semble） |
| `git-hooks/` | 受保护分支的 pre-commit / pre-push 钩子 |
| `knowledge/` | markdown 知识库（架构、决策、设计、运维手册、产品、发布） |
| `<repo>/`（不跟踪） | 你的项目仓库，由 `setup.sh` 克隆 |

## 添加技能

见 [`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md)。
简版：创建 `.agents/skills/<name>/SKILL.md`，符号链接到 `.claude/skills/`，并在 `CLAUDE.md` 中列出。

## 知识库

新的设计文档、架构说明、ADR 和运维手册以 markdown 形式通过 PR 进入 [`knowledge/`](../knowledge/) — semble 会索引它，agent 找设计上下文就像找代码一样。当它超出本仓库的规模时，将其推送为独立的 `<project>-knowledge` 仓库，加入 `.setup` 的 `REPOS`，删除此处的文件夹，并更新 `AGENTS.md` 中的指向。

## 疑难解答

- **setup 后找不到 `semble` 或 `uv`** — 打开新 shell（PATH 已更新）并重新运行 `./setup.sh`。
- **Claude 中缺少 Linear 工具** — 运行 `/mcp` 并完成 linear 服务器的 OAuth 流程。
- **rtk 没有生效** — 重启 Claude Code；用 `rtk gain` 验证命令是否被代理。
- **某个仓库不更新** — `setup.sh` 从不触碰有本地改动或在任务分支上的仓库；只对干净的默认分支检出做 fast-forward。
- **setup.sh 提示 "edit .setup first"** — `.setup` 仍是示例值（`PROJECT_NAME="acme"`）时它会拒绝运行。

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
