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
| 🧠 | **AI ワークフロースキル** — `/start-task`、`/raise-pr`、`/code-review`、`/write-doc`、`/create-ticket`（エージェント非依存で `.agents/skills/` に配置、Claude Code 用に symlink、opencode も設定済み） |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — grep とファイル読みの代わりにエージェントが MCP 経由で使うセマンティックコード検索 |
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
   プロジェクト名、GitHub org、クローンするリポジトリ（スペースまたはカンマ
   区切りで複数まとめて貼り付け可）、課題管理ツール（**Linear**、**Jira**、
   **その他** からメニューで選択）、チケットプレフィックス、デフォルト
   ブランチ、機能トグル。回答は自動的に `devrig.toml` に書き込まれます。手動編集
   したい場合は、スクリプト実行前に `devrig.toml` を自分で埋めておけばプロンプトは
   スキップされます。
3. このフォルダから `claude` を起動して作業開始。

いずれの方法でも、その後 Claude Code 内で `/mcp` を実行して設定された課題管理サーバー
（**linear** または **atlassian**）を認証し（初回のみの OAuth。**semble** は
認証不要）、rtk フックを有効にするため Claude Code を一度再起動してください。

## 🤖 AI エージェントでキックスタート

このテンプレートからワークスペースを作ったばかりですか？以下を AI コーディング
エージェント（Claude Code、Cursor、opencode など）に貼り付けて、残りの
セットアップを一緒に仕上げましょう：

```text
devrig テンプレート（https://github.com/lakpriya1s/devrig）からワークスペースを
作成しました。セットアップを手伝ってください：

1. README.md、AGENTS.md、devrig.toml を読んでワークスペースを理解する。
2. 一緒に ./setup.sh を実行する — プロジェクト名、GitHub org、リポジトリ
   一覧（複数まとめて貼り付け可）、課題管理ツール（Linear、Jira、その他）、
   チケットプレフィックス、デフォルトブランチ、機能トグルを対話式に質問
   してくるので、その内容を私に伝えて回答を埋めるのを手伝ってください。
   最後に devrig.toml が自動生成されます。
3. ./setup.sh が指摘した問題の修正を手伝う。
4. AGENTS.md の Systems テーブルを埋める — リポジトリごとに1行（役割、スタック）。
5. 各リポジトリについて .agents/skills/code-review/references/<repo>.md に
   レビューリファレンスを、.agents/skills/write-doc/references/<repo>.md に
   ドキュメントリファレンスを書く（_example-repo.md の雛形をコピーし、
   すべての事実をコードで検証する）。
6. Linear を選んだ場合は create-ticket の規約テーブルを私の Linear
   ワークスペースと照合する。Jira やその他を選んだ場合は /start-task、
   /raise-pr、/create-ticket の MCP 呼び出しをそちらに合わせて調整する。
7. パーソナライズをタスクブランチにコミットして PR を開く。
```

## setup.sh がやること

`setup.sh` は冪等です — いつでも再実行してすべてのリポジトリとツールを更新できます。内容：

0. **初回のみ**：`devrig.toml` がまだサンプル値のままなら、上記すべてを対話式に質問し `devrig.toml` に書き込む。
1. 前提条件を確認（`git`、認証済み `gh`。semble 有効時は `uv` をインストール）。
2. `repos` の各リポジトリを横並びにクローン（クリーンなデフォルトブランチのチェックアウトは fast-forward）し、`.git/info/exclude` 経由でこのリポジトリの git status から除外。
3. このリポジトリとクローンした各リポジトリに保護ブランチ用 git フックをインストール。
4. `.mcp.json` / `opencode.json` を `devrig.toml` のトグルに収束させる — `issue_tracker` に応じて `linear` または `atlassian`（Jira）サーバーを追加し、「その他」なら追加しない。手動追加した MCP サーバーは保持し、`.claude/settings.local.json` を生成。
5. semble をインストールし、リポジトリごとに検索インデックスをウォームアップ。
6. rtk をインストールし、Claude Code フックを登録。
7. VS Code 用の `<project>.code-workspace` を生成（既存の場合はスキップされるため、カスタマイズしてコミットしても安全）。

## カスタマイズチェックリスト

初回の `setup.sh` 実行後、パーソナライズをコミットしましょう：

- [ ] `devrig.toml` — 初回実行時に `setup.sh` が対話式に質問します（または実行前に手動で埋めておけばプロンプトはスキップされます）。後で値を変える場合（トラッカーの変更、リポジトリの追加など）は `devrig.toml` を直接編集して `./setup.sh` を再実行してください。
- [ ] `AGENTS.md` — **Systems** テーブル（リポジトリごとに1行：役割、スタック）と **Testing** セクションを記入。すべてのスキルが読む唯一の情報源です。
- [ ] `.agents/skills/code-review/references/` と `.agents/skills/write-doc/references/` — リポジトリごとにリファレンスファイルを1つ（`_example-repo.md` をコピー）。なくても動きますが、あると格段に鋭くなります。
- [ ] `issue_tracker` が `linear` の場合：`.agents/skills/create-ticket/SKILL.md` の「規約」テーブルを自分の Linear ワークスペース（チーム、プロジェクト、ラベル）と照合。`jira` や `other` の場合：`/start-task`、`/raise-pr`、`/create-ticket` の `mcp__linear__*` 呼び出しを自分のトラッカーの MCP ツール名に合わせて調整（各スキルの冒頭にその旨の記載あり）。
- [ ] トグルで無効化したものを削除・調整（例：semble を使わないなら `CLAUDE.md` から関連記述を削除）。

## 構成

| パス | 説明 |
|---|---|
| `devrig.toml` | プロジェクト設定 — すべてのツールが読む唯一のファイル |
| `setup.sh` | 冪等なブートストラップ/更新スクリプト |
| `AGENTS.md` | エージェント非依存の唯一の情報源（システム、ブランチルール、規約） |
| `CLAUDE.md` | Claude Code 固有の内容。`AGENTS.md` をインポート |
| `.agents/skills/` | 正規のワークフロースキル（エージェント非依存） |
| `.claude/` | Claude Code の設定、エージェント、スキルの symlink |
| `.opencode/` | opencode のエージェントとプラグイン設定 |
| `.mcp.json` / `opencode.json` | MCP サーバー（課題管理ツール、semble） |
| `git-hooks/` | 保護ブランチ用 pre-commit / pre-push フック |
| `knowledge/` | markdown ナレッジベース（アーキテクチャ、決定、設計、runbook、プロダクト、リリース） |
| `<repo>/`（未追跡） | `setup.sh` がクローンするプロジェクトリポジトリ |

## スキルの追加

[`.agents/skills/_template/README.md`](../.agents/skills/_template/README.md) を参照。
要約：`.agents/skills/<name>/SKILL.md` を作成し、`.claude/skills/` に symlink し、
`CLAUDE.md` に記載します。

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
