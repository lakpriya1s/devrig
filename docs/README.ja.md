<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**すべてのリポジトリをひとつの rig で — AI 対応のマルチリポジトリ開発ワークスペーステンプレート。**

[![npx create-devrig](https://img.shields.io/npm/v/create-devrig?label=npx%20create-devrig&color=22D3EE&style=flat-square)](https://www.npmjs.com/package/create-devrig)
[![Use this template](https://img.shields.io/badge/Use%20this-template-3B82F6?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [हिन्दी](README.hi.md) · [Português](README.pt-BR.md) · **日本語** · [Français](README.fr.md) · [한국어](README.ko.md) · [සිංහල](README.si.md)

</div>

---

## devrig とは？

devrig は*メタリポジトリ*です。プロジェクトのすべてのリポジトリと、それらを
横断して開発するための AI ツール群をひとつのフォルダに収めます。このリポジトリが
バージョン管理するのはツールのみ — プロジェクトのリポジトリは `setup.sh` が
横並びにクローンし、追跡されません。すべては単一の **`devrig.toml`** ファイルで
設定されます。

| | 含まれるもの |
|---|---|
| 🧠 | **AI ワークフロースキル** — `/start-task`、`/plan-task`、`/verify-change`、`/raise-pr`、`/code-review`、`/write-doc`、`/capture-learning`、`/check-knowledge-consistency`、`/create-ticket`（エージェント非依存で `.agents/skills/` に配置、Claude Code 用に symlink、opencode も設定済み） |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — grep とファイル読みの代わりにエージェントが MCP 経由で使うセマンティックコード検索 |
| 🕸️ | **[graphify](https://github.com/Graphify-Labs/graphify)** — リポジトリごとのナレッジグラフ。エージェントは grep の代わりにこれを問い合わせ、git フックが常に最新に保つ |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — Claude Code のトークンを節約するコマンドプロキシ |
| 🎫 | **課題管理 MCP** — Linear、Jira、または自前のもの。`setup.sh` が対話式に選ばせる |
| 🛡️ | **保護ブランチ用 git フック** — どのリポジトリでもデフォルトブランチへの誤コミット/プッシュを防止 |
| 📚 | **`knowledge/`** — AI ツールがインデックスし書き込む markdown ナレッジベースの骨組み（アーキテクチャ、ADR、設計ドキュメント、runbook） |
| 🖥️ | **自動生成される VS Code マルチルートワークスペース** — すべてのリポジトリをひとつのウィンドウで |

## クイックスタート

最速の方法 — クローン不要、コマンド一つだけ：

```bash
npx create-devrig my-project
```

[`create-devrig`](https://github.com/lakpriya1s/create-devrig) がこのテンプレートを取得し（git履歴なし）、`my-project/` に新しい git リポジトリを初期化して、すぐに対話式セットアップウィザードを起動します — 下記と同じウィザードですが、別途クローンする手順が不要です。

GitHub の UI を使いたい、または最初から自分の org 配下にリポジトリを作りたい場合は：

1. **[Use this template](https://github.com/lakpriya1s/devrig/generate)** をクリックして `your-org/your-project-workspace` を作成。
2. クローンして実行：

   ```bash
   ./setup.sh
   ```

   初回実行時、`devrig.toml` がまだサンプル値のままなら、対話式に設定を案内します:
   プロジェクト名、一行の説明、GitHub org、クローンするリポジトリ（スペースまたは
   カンマ区切りで複数まとめて貼り付け可）、課題管理ツール（**Linear**、**Jira**、
   **その他** からメニューで選択）、チケットプレフィックス、デフォルト
   ブランチ、機能トグル。回答は自動的に `devrig.toml` に書き込まれ、devrig 自身の
   テンプレートファイルが削除され、代わりに*あなたの*プロジェクト用の
   `README.md` が生成されます。手動編集したい場合は、スクリプト実行前に
   `devrig.toml` を自分で埋めておけばプロンプトはスキップされます。
3. このフォルダから `claude` を起動して作業開始。

いずれの方法でも、その後 Claude Code 内で `/mcp` を実行して設定された課題管理サーバー
（**linear** または **atlassian**）を認証し（初回のみの OAuth。**semble** は
認証不要）、rtk フックを有効にするため Claude Code を一度再起動してください。 graphify を有効にした場合は、各リポジトリのルートで一度 `graphify update .` を実行してグラフを構築してください。以降は git フックが最新に保ちます。

## 🤖 AI エージェントでキックスタート

### すでにリポジトリをお持ちですか？

このテンプレートからワークスペースを作ったばかりですか？以下を AI コーディング
エージェント（Claude Code、Cursor、opencode など）に貼り付けて、残りの
セットアップを一緒に仕上げましょう：

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

### まったく新しいプロジェクトを始めますか？

まだリポジトリがなく、アイデアだけの段階ですか？マークされた部分をプロジェクトの説明に置き換えてこちらを貼り付けてください — エージェントがアイデアから実際に動くワークスペースまで（新しいリポジトリも含めて）連れて行ってくれます：

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

## setup.sh がやること

`setup.sh` は冪等です — いつでも再実行してすべてのリポジトリとツールを更新できます。内容：

0. **初回のみ**：`devrig.toml` がまだサンプル値のままなら、上記すべてを対話式に質問し `devrig.toml` に書き込む。
1. **ワークスペースをパーソナライズ**：devrig 自身のテンプレートファイル
   （`docs/`、`assets/`、`CITATION.cff`、`CONTRIBUTING.md`、`LICENSE`）を削除し、
   `devrig.toml` から*あなたの*プロジェクト用の `README.md` を生成。devrig
   リポジトリ自体の中では実行されず、編集済みの README が上書きされることも
   ありません。
2. 前提条件を確認（`git`、認証済み `gh`。semble または graphify 有効時は `uv` をインストール）。
3. `repos` の各リポジトリを横並びにクローン（クリーンなデフォルトブランチのチェックアウトは fast-forward）し、`.git/info/exclude` 経由でこのリポジトリの git status から除外。
4. このリポジトリとクローンした各リポジトリに保護ブランチ用 git フックをインストール。
5. `.mcp.json` / `opencode.json` を `devrig.toml` のトグルに収束させる — `issue_tracker` に応じて `linear` または `atlassian`（Jira）サーバーを追加し、「その他」なら追加しない。手動追加した MCP サーバーは保持し、`.claude/settings.local.json` を生成。
6. semble をインストールし、リポジトリごとに検索インデックスをウォームアップ。
7. rtk をインストールし、Claude Code フックを登録。
8. graphify をインストール：スキルを `.agents/skills/` へ（Claude Code 用のシンボリックリンクも作成）、エージェントが grep する前にグラフへ誘導する PreToolUse ガード、そしてコミット・チェックアウト・マージ後にそのリポジトリのグラフを再構築する git フックを登録。
9. VS Code 用の `<project>.code-workspace` を生成（既存の場合はスキップされるため、カスタマイズしてコミットしても安全）。

## カスタマイズチェックリスト

`setup.sh` は機械的なパーソナライズ自体を行います（`devrig.toml` の書き込み、
devrig のテンプレートファイルの削除、プロジェクト README の生成）。残るのは
あなただけが知っている情報です — 生成された README の
**「Customize this workspace」** セクションが、このチェックリストをそのまま
あなたのワークスペースに引き継ぎます：

- [ ] `AGENTS.md` — **Systems** テーブル（リポジトリごとに1行：役割、スタック、依存関係）、**Commands** テーブル、**Testing** セクションを記入。すべてのスキルが読む唯一の情報源です。生成された README の「What's inside」テーブルも合わせて更新してください。
- [ ] `POLICY.md` — Definition of Done と ADR のトリガー条件を、あなたのチームの実際の基準に合わせて調整（例：セキュリティレビューの要件を追加）。
- [ ] `.ai/systems.yaml`、`.ai/commands.yaml`、`.ai/ownership.yaml` — サンプルの内容を実際のシステム/コマンド/オーナーに置き換える（`AGENTS.md` のテーブルと対応します。形式は `node scripts/validate-ai-config.mjs` で検証できます）。
- [ ] `.ai/policies.yaml`、`.ai/risk-levels.yaml` — protected paths、forbidden/approval-required actions、リスクの例を自分のプロジェクトに合わせて調整。
- [ ] `.agents/skills/code-review/references/` と `.agents/skills/write-doc/references/` — リポジトリごとにリファレンスファイルを1つ（`_example-repo.md` をコピー）。なくても動きますが、あると格段に鋭くなります。
- [ ] `issue_tracker` が `linear` の場合：`.agents/skills/create-ticket/SKILL.md` の「規約」テーブルを自分の Linear ワークスペース（チーム、プロジェクト、ラベル）と照合。`jira` や `other` の場合：`/start-task`、`/raise-pr`、`/create-ticket` の `mcp__linear__*` 呼び出しを自分のトラッカーの MCP ツール名に合わせて調整（各スキルの冒頭にその旨の記載あり）。
- [ ] トグルで無効化したものを削除・調整（例：semble を使わないなら `CLAUDE.md` から関連記述を削除）。

後で設定値を変える場合（トラッカーの変更、リポジトリの追加など）は
`devrig.toml` を直接編集して `./setup.sh` を再実行してください。

## 構成

| パス | 説明 |
|---|---|
| `devrig.toml` | プロジェクト設定 — すべてのツールが読む唯一のファイル |
| `setup.sh` | 冪等なブートストラップ/更新スクリプト |
| `AGENTS.md` | エージェント非依存の唯一の情報源（システム、コマンド、ブランチルール、リトリーバルポリシー） |
| `POLICY.md` | Definition of Done、ADR の要件、リスク/データ/ロールに関するポリシー、検証/確信度レポートの形式 |
| `.ai/` | 上記の機械可読なミラー（`systems.yaml`、`commands.yaml`、`ownership.yaml`、`policies.yaml`、`risk-levels.yaml`）と、`.ai/schemas/` の JSON Schema、`.ai/context/` のタスクごとのコンテキストバンドル（`/start-task` が書き込む） |
| `.github/workflows/` | CI：`.ai/*.yaml` をスキーマと照合して検証し、`knowledge/`（フロントマター、リンク、ADR の ID、インデックスの鮮度、protected path での ADR 要件）を検証 |
| `CLAUDE.md` | Claude Code 固有の内容。`AGENTS.md` をインポート |
| `.agents/skills/` | 正規のワークフロースキル（エージェント非依存） |
| `.claude/` | Claude Code の設定、エージェント、スキルの symlink |
| `.opencode/` | opencode のエージェントとプラグイン設定 |
| `.mcp.json` / `opencode.json` | MCP サーバー（課題管理ツール、semble） |
| `git-hooks/` | 全リポジトリ共有のフック（`core.hooksPath`）：保護ブランチ用 pre-commit / pre-push と、graphify のグラフ再構築 |
| `knowledge/` | markdown ナレッジベース（アーキテクチャ、決定、設計、runbook、プロダクト、リリース、handoff、generated）— `knowledge/index.md` を参照 |
| `evals/` | 検索精度/ハルシネーション率を継続的に測定するための、模範解答つきの質問集 — `evals/README.md` を参照 |
| `scripts/` | ワークスペース保守用スクリプト — `build-knowledge-index.mjs`、`validate-knowledge.mjs`、`validate-ai-config.mjs`、`detect-doc-drift.mjs`、`check-adr-requirement.mjs`、`generate-architecture-views.mjs` |
| `<repo>/`（未追跡） | `setup.sh` がクローンするプロジェクトリポジトリ |

## スキルの追加

[`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md) を参照。
要約：`.agents/skills/<name>/SKILL.md` を作成し、`.claude/skills/` に symlink し、
`CLAUDE.md` に記載します。

## ナレッジグラフ

`graphify` トグルを有効にすると、各リポジトリが自分の `<repo>/graphify-out/` を持ちます — 問い合わせ可能なコードのグラフ（ハブ、コミュニティ、ファイル間の関係）に加え、平易な `GRAPH_REPORT.md` とインタラクティブな `graph.html`。エージェントは grep してファイルを読む代わりにこれを使います：

```bash
cd <repo>
graphify update .                                # 構築/更新（AST のみ、API キー不要）
graphify query "認証はどう動くのか"                # 範囲を絞ったサブグラフ。grep の羅列ではない
graphify path "LoginForm" "SessionStore"         # 2 つがどう繋がっているか
graphify explain "PaymentService"                # あるノードとその隣接ノード
```

`setup.sh` は CLI をインストールし、スキルを `.agents/skills/graphify/` に配置し、検索前にエージェントをグラフへ向ける PreToolUse ガードを登録し、再構築フックを入れます — post-commit と post-checkout は `graphify hook install` が担当し、devrig は `git-hooks/post-merge` を追加して `git pull` でもグラフを更新します。グラフ・インストール済みスキル・生成されたフックはすべて gitignore 対象です：`./setup.sh` ごとに CLI から再生成されるため、古いものがコミットされることはありません。

## ナレッジベース

新しい設計ドキュメント、アーキテクチャノート、ADR、runbook は markdown として
PR 経由で [`knowledge/`](../knowledge/) に入ります — semble がインデックスする
ため、エージェントはコードと同じ方法で設計コンテキストを見つけます。この
リポジトリに収まらなくなったら、独立した `<project>-knowledge` リポジトリとして
push し、`devrig.toml` の `repos` に追加、ここのフォルダを削除して `AGENTS.md` の
ポインタを更新してください。

## トラブルシューティング

- **setup 後に `semble` や `uv` が見つからない** — 新しいシェルを開き（PATH が更新されています）、`./setup.sh` を再実行。
- **Claude に課題管理ツールが表示されない** — `/mcp` を実行して `linear` または `atlassian` サーバーの OAuth フローを完了。
- **rtk が効かない** — Claude Code を再起動し、`rtk gain` でコマンドがプロキシされているか確認。
- **`graphify query` がグラフがないと言う** — そのリポジトリのルートで一度 `graphify update .` を実行。フックは既存のグラフを更新するだけです。
- **コミットでグラフ再構築が走らない** — そのリポジトリで `graphify hook status` を実行し、`~/.cache/graphify-rebuild.log` を確認。`GRAPHIFY_SKIP_HOOK=1` で 1 コマンドだけ抑止できます。
- **リポジトリが更新されない** — `setup.sh` はローカル変更があるリポジトリやタスクブランチ上のリポジトリには触れません。クリーンなデフォルトブランチのチェックアウトだけを fast-forward します。
- **setup.sh が何も聞いてこず "edit devrig.toml first" と言う** — 対話式端末に接続している場合のみプロンプトが出ます。スクリプトや CI から実行する場合は `devrig.toml` を事前に埋めておく必要があります。
- **Jira や「その他」を選んだ** — `atlassian`（Jira）MCP サーバーは自動で設定されますが、`/start-task`、`/raise-pr`、`/create-ticket` は依然として Linear の MCP ツール名を呼び出します — これらのスキルを調整するまで、`setup.sh` は実行のたびに末尾でこの点を警告します。

## コントリビュート

devrig は使うチームが増えるほど良くなります。バグ報告、新しい汎用スキル、
ドキュメント改善、そして **README の翻訳** を歓迎します —
[CONTRIBUTING.md](../CONTRIBUTING.md) をご覧ください。devrig がチームの
セットアップ時間を節約できたなら、⭐ が他の人の発見を助けます。

## ライセンスと引用

[MIT ライセンス](../LICENSE)で公開されています。

お仕事や執筆で devrig を使う場合、引用していただけると嬉しいです — GitHub の
**"Cite this repository"** ボタン（[`CITATION.cff`](../CITATION.cff) による）に
詳細があります。または：

> Senevirathna, L. (2026). *devrig: a multi-repo AI dev workspace template.*
> https://github.com/lakpriya1s/devrig

<div align="center">
<sub>本番運用中のマルチリポジトリワークスペースから生まれました · <img src="../assets/devrig-icon.png" width="14" alt=""> devrig</sub>
</div>
