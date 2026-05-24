# Claude Code プロジェクト設定テンプレート

[classly](https://github.com/m-kuwata/classly) プロジェクトで実際に運用している Claude Code 設定ファイル一式を、新規プロジェクトへ持ち込むためのテンプレートリポジトリ。

## このテンプレートで実現できること

| 自動化 | 仕組み | タイミング |
|---|---|---|
| TDD 強制 | テストなしで実装ファイルを編集しようとするとブロック | 編集前 |
| コミット品質ゲート | テスト・型チェック・カバレッジを自動実行 | `git commit` 前 |
| Issue 番号強制 | ブランチ名・コミットメッセージに issue 番号がなければブロック | コミット時 |
| ESLint 早期チェック | ファイル保存後に Lint を即時実行 | 編集後 |
| コードレビュー強制 | 実装変更後にレビュースキルの実行を強制 | Claude 応答終了時 |
| デザインチェック強制 | 画面変更後にデザイン規約チェックを強制 | Claude 応答終了時 |
| セッションノートバックアップ | git log・差分をファイルに自動保存 | コンテキスト圧縮前 |

## リポジトリ構成

```
.
├── README.md
├── CLAUDE.md                              Claude が最初に読むプロジェクトコンテキスト
└── .claude/
    ├── settings.json                      Claude Code 設定（権限・フック定義）
    ├── git-hooks/
    │   └── commit-msg                     コミットメッセージ検証（issue 番号必須化）
    ├── hooks/                             Claude Code フック群
    │   ├── session-start.sh               SessionStart: 共通セットアップ
    │   ├── pre-commit-check.sh            PreToolUse(Bash): コミット前品質ゲート
    │   ├── pre-edit-tdd-guard.sh          PreToolUse(Edit|Write): TDD RED フェーズ強制
    │   ├── post-edit-lint.sh              PostToolUse: ESLint + ruff 早期実行
    │   ├── set-impl-flag.sh               PostToolUse: 実装ファイル変更フラグ
    │   ├── set-screen-flag.sh             PostToolUse: 画面ファイル変更フラグ
    │   ├── set-screenshot-flag.sh         PostToolUse: レイアウト変更フラグ
    │   ├── auto-classly-review.sh         Stop: コードレビュースキル実行強制
    │   ├── auto-design-check.sh           Stop: デザインチェックスキル実行強制
    │   ├── auto-screenshot-check.sh       Stop: スクリーンショット確認強制
    │   ├── pre-compact-backup.sh          PreCompact: コンテキスト圧縮前バックアップ
    │   └── tdd-reminder.sh                UserPromptSubmit: TDD リマインダー注入
    └── skills/                            Claude Code スキル（/コマンド）
        ├── tdd/                           TDD ワークフロー
        │   ├── SKILL.md
        │   └── examples.md
        ├── classly-review/SKILL.md        コミット前チェックリスト
        ├── classly-design/SKILL.md        デザインシステム準拠
        ├── issue-pm/                      Issue 駆動開発 PM
        │   ├── SKILL.md
        │   └── templates.md
        ├── issue-progress/                GitHub Projects 進捗管理
        │   ├── SKILL.md
        │   └── project-cache.json
        ├── design-check/SKILL.md          デザイン規約自動スキャン
        ├── config-audit/SKILL.md          Claude 設定健全性チェック
        ├── coverage-check/SKILL.md        カバレッジ確認
        ├── new-component/SKILL.md         コンポーネントスキャフォールド
        ├── new-screen/SKILL.md            画面スキャフォールド
        ├── storybook-check/SKILL.md       Storybook カバレッジ確認
        └── uiux-check/                    Playwright UI/UX 検査
            ├── SKILL.md
            └── scripts/tour.mjs
```

## 各ファイルの役割

### CLAUDE.md

Claude がセッション開始時に最初に読むファイル。プロジェクトの概要・確定方針・開発ルール・スキル一覧を記述する。**このファイルはプロジェクト固有のため、テンプレートを参考に全面書き換えが必要。**

### .claude/settings.json

Claude Code の設定ファイル。以下を定義する。

- `permissions.allow` — 確認なしで実行できるコマンド（git, npm, gh など）
- `permissions.deny` — 常にブロックするコマンド（force push, rm -rf など）
- `hooks` — Claude のライフサイクルイベントに紐付くフックスクリプトの登録

フックのパスはすべて `$CLAUDE_PROJECT_DIR` で解決するため、プロジェクトのルートパスに依存しない。

### .claude/git-hooks/commit-msg

Issue ブランチ（`feat/N-*`, `fix/N-*` 等）でのコミット時に、メッセージに `#N` が含まれているかを検証する git フック。`session-start.sh` が `git config core.hooksPath .claude/git-hooks` を自動設定するため、手動での git フック設定は不要。

### .claude/hooks/ — フック群

| フック | イベント | 役割 |
|---|---|---|
| `session-start.sh` | SessionStart | npm install・git hook 設定・Playwright ブラウザセットアップ |
| `pre-commit-check.sh` | PreToolUse(Bash) | git commit 前にテスト・型チェック・カバレッジを実行してブロック |
| `pre-edit-tdd-guard.sh` | PreToolUse(Edit\|Write) | `src/lib/` / `src/features/` 編集前に対応テストの存在を確認 |
| `post-edit-lint.sh` | PostToolUse | ファイル保存後に ESLint / ruff を実行して早期エラー検出 |
| `set-impl-flag.sh` | PostToolUse | 実装ファイル変更時に `/tmp/classly-needs-review` フラグを立てる |
| `set-screen-flag.sh` | PostToolUse | 画面ファイル変更時に `/tmp/classly-needs-design-check` フラグを立てる |
| `set-screenshot-flag.sh` | PostToolUse | レイアウトファイル変更時に `/tmp/classly-needs-screenshot-check` フラグを立てる |
| `auto-classly-review.sh` | Stop | フラグを検知してコードレビュースキルの実行を強制 |
| `auto-design-check.sh` | Stop | フラグを検知してデザインチェックスキルの実行を強制 |
| `auto-screenshot-check.sh` | Stop | フラグを検知してスクリーンショット確認を強制 |
| `pre-compact-backup.sh` | PreCompact | コンテキスト圧縮前に git log と差分を `.claude/session-notes/` へ保存 |
| `tdd-reminder.sh` | UserPromptSubmit | 実装キーワードを含むプロンプト提出時に TDD リマインダーをコンテキストへ注入 |

**フラグベースの遅延チェックの仕組み**:

```
[Edit/Write] → set-impl-flag.sh ─────────→ /tmp/classly-needs-review
                                                        ↓
[Stop] ←────────────── auto-classly-review.sh がフラグを検知してブロック
         ↑ /classly-review スキル実行 + touch /tmp/classly-review-passed でブロック解除
```

### .claude/skills/ — スキル群

`/スキル名` で呼び出せるプロジェクト固有のスラッシュコマンド。各スキルは `SKILL.md` に手順・チェックリストを記述する。

| スキル | 用途 |
|---|---|
| `tdd` | TDD ワークフロー（Red→Green→Refactor） |
| `classly-review` | コミット前チェックリスト（テスト・型・デザイン・セキュリティ） |
| `classly-design` | デザインシステム規約クイックリファレンス |
| `issue-pm` | Issue 駆動開発 PM（issue 作成・ブランチ・PR 管理） |
| `issue-progress` | GitHub Projects 進捗管理（ステータス更新・ボード表示） |
| `design-check` | 画面変更後のデザインシステム規約スキャン |
| `config-audit` | .claude/ 設定ファイルの健全性チェック |
| `coverage-check` | テストカバレッジ確認・未テストパスへのテスト追加 |
| `new-component` | コンポーネント + ストーリー + テストのスキャフォールド |
| `new-screen` | App Router ページのスキャフォールド |
| `storybook-check` | Storybook ストーリーカバレッジ確認・補完 |
| `uiux-check` | Playwright による実画面 UI/UX 検査 |

> **注**: スキルの内容はすべて classly プロジェクト固有。新しいプロジェクトでは内容を書き換えるか、不要なスキルは削除すること。

## 新規プロジェクトへのセットアップ手順

### Step 1: ファイルをコピーする

このリポジトリを「Use this template」でフォークするか、手動でコピーする。

```bash
# 手動コピーの場合
git clone https://github.com/m-kuwata/claude-project-template tmp-template
cp -r tmp-template/CLAUDE.md ./CLAUDE.md
cp -r tmp-template/.claude ./.claude
rm -rf tmp-template
```

### Step 2: フックに実行権限を付与する

```bash
chmod +x .claude/hooks/*.sh
chmod +x .claude/git-hooks/commit-msg
```

### Step 3: CLAUDE.md を書く

`CLAUDE.md` をプロジェクト固有の内容に書き換える。最低限以下を記載すること。

- プロジェクトの概要・目的
- 確定方針（変更に合意が必要なもの）
- 技術スタック
- 開発ルール（TDD・Issue 駆動開発など）
- 使用するスキルの一覧

### Step 4: settings.json をカスタマイズする

`$CLAUDE_PROJECT_DIR` はそのまま使える。必要に応じて以下を調整する。

- `permissions.allow` にプロジェクト固有のコマンドを追加（例: `Bash(python *)`, `Bash(docker *)`）
- 使わないフックのエントリを削除

### Step 5: フックをカスタマイズする

**変更が必要なフック**:

| フック | 変更点 |
|---|---|
| `pre-commit-check.sh` | テストコマンド・カバレッジ閾値。Python の `apps/solver-api/` 部分は不要なら削除 |
| `pre-edit-tdd-guard.sh` | TDD 対象ディレクトリ（`src/lib/` / `src/features/` 以外を使う場合） |
| `post-edit-lint.sh` | Lint コマンド（eslint / ruff 以外を使う場合） |
| `set-screen-flag.sh` | 画面ファイルのパスパターン（classly 固有のパスを変更） |
| `set-screenshot-flag.sh` | スクリーンショットチェック対象のファイルパターン |
| `auto-screenshot-check.sh` | スクリーンショット手順（使用する画面ルートを修正） |
| `tdd-reminder.sh` | 実装キーワード・Python ソルバーの有無 |

**汎用的でそのまま使えるフック**:
- `session-start.sh`
- `pre-compact-backup.sh`
- `auto-classly-review.sh`（フラグのパスだけ確認）
- `auto-design-check.sh`

### Step 6: スキルをカスタマイズする

**必ず書き換えるもの**:
- `classly-review/SKILL.md` → プロジェクト固有のチェックリストに変更
- `classly-design/SKILL.md` → プロジェクトのデザイントークン・規約に変更
- `issue-progress/project-cache.json` → `/issue-progress setup` で再生成

**内容を確認・調整すれば使えるもの**:
- `tdd/SKILL.md` → テストコマンドと閾値を調整
- `issue-pm/SKILL.md` → ブランチ命名規則・PR フォーマットを確認
- `coverage-check/SKILL.md` → カバレッジ閾値を調整
- `new-component/SKILL.md` → コンポーネント配置先パスを調整
- `new-screen/SKILL.md` → 画面ルートとレイアウト構成を調整

### Step 7: GitHub Projects のセットアップ（issue-progress スキルを使う場合）

1. GitHub Projects v2 でプロジェクトを作成
2. Status フィールドに `未着手` / `作業中` / `レビュー中` / `完了` のオプションを追加
3. リポジトリ Settings > Secrets に `PROJECT_TOKEN` を設定（スコープ: `repo` + `project`）
4. `/issue-progress setup` を実行して `project-cache.json` を再生成

### Step 8: 動作確認

```bash
# フックが実行できるか確認
bash .claude/hooks/session-start.sh

# 設定ファイルの健全性チェック（Claude Code セッション内で）
/config-audit
```

## カスタマイズ早見表

| 状況 | 変更するファイル |
|---|---|
| テストコマンドが違う | `pre-commit-check.sh`, `tdd/SKILL.md`, `coverage-check/SKILL.md` |
| カバレッジ閾値を変える | `pre-commit-check.sh`, `coverage-check/SKILL.md` |
| Python バックエンドが不要 | `pre-commit-check.sh`, `post-edit-lint.sh`, `tdd-reminder.sh` から solver-api 記述を削除 |
| TDD 対象ディレクトリが違う | `pre-edit-tdd-guard.sh` |
| デザインシステムが違う | `set-screen-flag.sh`, `auto-design-check.sh`, `design-check/SKILL.md`, `classly-design/SKILL.md` |
| Storybook を使わない | `storybook-check/` スキルと関連フラグを削除 |
| GitHub Projects を使わない | `issue-progress/` スキルを削除 |
| スキル名を変える | `SKILL.md` の `name:` フィールドと `auto-*.sh` のメッセージを変更 |

## 参考リンク

- [classly — 実運用プロジェクト](https://github.com/m-kuwata/classly)（このテンプレートの出所）
- [Claude Code ドキュメント](https://docs.anthropic.com/ja/docs/claude-code)
- [Claude Code Hooks リファレンス](https://docs.anthropic.com/ja/docs/claude-code/hooks)
