<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="../assets/devrig-logo-dark.png">
  <img src="../assets/devrig-logo-light.png" alt="devrig" width="420">
</picture>

**すべてのリポジトリをひとつの rig で — AI 対応のマルチリポジトリ開発ワークスペーステンプレート。**

[![Use this template](https://img.shields.io/badge/Use%20this-template-22D3EE?style=flat-square&logo=github&logoColor=white)](https://github.com/lakpriya1s/devrig/generate)
[![License: MIT](https://img.shields.io/badge/License-MIT-3B82F6?style=flat-square)](../LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-8B5CF6?style=flat-square)](../CONTRIBUTING.md)

[English](../README.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [हिन्दी](README.hi.md) · [Português](README.pt-BR.md) · **日本語** · [Français](README.fr.md) · [한국어](README.ko.md) · [සිංහල](README.si.md)

</div>

---

## devrig とは？

devrig は*メタリポジトリ*です。プロジェクトのすべてのリポジトリと、それらを
横断して開発するための AI ツール群をひとつのフォルダに収めます。このリポジトリが
バージョン管理するのはツールのみ — プロジェクトのリポジトリは `setup.sh` が
横並びにクローンし、追跡されません。すべては単一の **`.setup`** ファイルで
設定されます。

| | 含まれるもの |
|---|---|
| 🧠 | **AI ワークフロースキル** — `/start-task`、`/raise-pr`、`/code-review`、`/write-doc`、`/create-ticket`（エージェント非依存で `.agents/skills/` に配置、Claude Code 用に symlink、opencode も設定済み） |
| 🔍 | **[semble](https://github.com/MinishLab/semble)** — grep とファイル読みの代わりにエージェントが MCP 経由で使うセマンティックコード検索 |
| ⚡ | **[rtk](https://github.com/rtk-ai/rtk)** — Claude Code のトークンを節約するコマンドプロキシ |
| 🎫 | **Linear MCP** — スキルと連携した課題管理 |
| 🛡️ | **保護ブランチ用 git フック** — どのリポジトリでもデフォルトブランチへの誤コミット/プッシュを防止 |
| 📚 | **`knowledge/`** — AI ツールがインデックスし書き込む markdown ナレッジベースの骨組み（アーキテクチャ、ADR、設計ドキュメント、runbook） |
| 🖥️ | **自動生成される VS Code マルチルートワークスペース** — すべてのリポジトリをひとつのウィンドウで |

## クイックスタート

1. **[Use this template](https://github.com/lakpriya1s/devrig/generate)** をクリックして `your-org/your-project-workspace` を作成。
2. クローンして **`.setup`** を編集 — プロジェクト名、GitHub org、リポジトリ一覧、チケットプレフィックス、デフォルトブランチ、機能トグル。
3. 実行：

   ```bash
   ./setup.sh
   ```

4. このフォルダから `claude` を起動して作業開始。

その後、Claude Code 内で `/mcp` を実行して **linear** サーバーを認証し
（初回のみの OAuth。**semble** は認証不要）、rtk フックを有効にするため
Claude Code を一度再起動してください。

## 🤖 AI エージェントでキックスタート

このテンプレートからワークスペースを作ったばかりですか？以下を AI コーディング
エージェント（Claude Code、Cursor、opencode など）に貼り付けて、残りの
セットアップを一緒に仕上げましょう：

```text
devrig テンプレート（https://github.com/lakpriya1s/devrig）からワークスペースを
作成しました。セットアップを手伝ってください：

1. README.md、AGENTS.md、.setup を読んでワークスペースを理解する。
2. プロジェクト名、GitHub org、リポジトリ一覧、チケットプレフィックス、
   デフォルトブランチを私に質問し、.setup に記入する。
3. ./setup.sh を実行し、指摘された問題の修正を手伝う。
4. AGENTS.md の Systems テーブルを埋める — リポジトリごとに1行（役割、スタック）。
5. 各リポジトリについて .agents/skills/code-review/references/<repo>.md に
   レビューリファレンスを、.agents/skills/write-doc/references/<repo>.md に
   ドキュメントリファレンスを書く（_example-repo.md の雛形をコピーし、
   すべての事実をコードで検証する）。
6. create-ticket の規約テーブルを私の Linear ワークスペースと照合する。
7. パーソナライズをタスクブランチにコミットして PR を開く。
```

## setup.sh がやること

`setup.sh` は冪等です — いつでも再実行してすべてのリポジトリとツールを更新できます。内容：

1. 前提条件を確認（`git`、認証済み `gh`。semble 有効時は `uv` をインストール）。
2. `REPOS` の各リポジトリを横並びにクローン（クリーンなデフォルトブランチのチェックアウトは fast-forward）し、`.git/info/exclude` 経由でこのリポジトリの git status から除外。
3. このリポジトリとクローンした各リポジトリに保護ブランチ用 git フックをインストール。
4. `.mcp.json` / `opencode.json` を `.setup` のトグルに収束させ（手動追加した MCP サーバーは保持）、`.claude/settings.local.json` を生成。
5. semble をインストールし、リポジトリごとに検索インデックスをウォームアップ。
6. rtk をインストールし、Claude Code フックを登録。
7. VS Code 用の `<project>.code-workspace` を生成（既存の場合はスキップされるため、カスタマイズしてコミットしても安全）。

## カスタマイズチェックリスト

初回の `setup.sh` 実行後、パーソナライズをコミットしましょう：

- [ ] `.setup` — 実際の値を設定（サンプル値のままでは setup.sh は実行を拒否します）。
- [ ] `AGENTS.md` — **Systems** テーブル（リポジトリごとに1行：役割、スタック）と **Testing** セクションを記入。すべてのスキルが読む唯一の情報源です。
- [ ] `.agents/skills/code-review/references/` と `.agents/skills/write-doc/references/` — リポジトリごとにリファレンスファイルを1つ（`_example-repo.md` をコピー）。なくても動きますが、あると格段に鋭くなります。
- [ ] `.agents/skills/create-ticket/SKILL.md` — 「規約」テーブルを自分の Linear ワークスペース（チーム、プロジェクト、ラベル）と照合。
- [ ] トグルで無効化したものを削除・調整（例：Linear を使わないなら `CLAUDE.md` から linear の記述を削除）。

## 構成

| パス | 説明 |
|---|---|
| `.setup` | プロジェクト設定 — すべてのツールが読む唯一のファイル |
| `setup.sh` | 冪等なブートストラップ/更新スクリプト |
| `AGENTS.md` | エージェント非依存の唯一の情報源（システム、ブランチルール、規約） |
| `CLAUDE.md` | Claude Code 固有の内容。`AGENTS.md` をインポート |
| `.agents/skills/` | 正規のワークフロースキル（エージェント非依存） |
| `.claude/` | Claude Code の設定、エージェント、スキルの symlink |
| `.opencode/` | opencode のエージェントとプラグイン設定 |
| `.mcp.json` / `opencode.json` | MCP サーバー（linear、semble） |
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
push し、`.setup` の `REPOS` に追加、ここのフォルダを削除して `AGENTS.md` の
ポインタを更新してください。

## トラブルシューティング

- **setup 後に `semble` や `uv` が見つからない** — 新しいシェルを開き（PATH が更新されています）、`./setup.sh` を再実行。
- **Claude に Linear ツールが表示されない** — `/mcp` を実行して linear サーバーの OAuth フローを完了。
- **rtk が効かない** — Claude Code を再起動し、`rtk gain` でコマンドがプロキシされているか確認。
- **リポジトリが更新されない** — `setup.sh` はローカル変更があるリポジトリやタスクブランチ上のリポジトリには触れません。クリーンなデフォルトブランチのチェックアウトだけを fast-forward します。
- **setup.sh が "edit .setup first" と言う** — `.setup` がサンプル値（`PROJECT_NAME="acme"`）のままだと実行を拒否します。

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
