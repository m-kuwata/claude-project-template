---
name: issue-pm
description: GitHub issue 駆動開発の PM スキル。タスクはすべて issue から始め、ブランチ・PR・進捗記録を issue に紐付けて管理する。
when_to_use: 新しいタスクや機能に着手するとき、issue を作成するとき、ブランチを切るとき、PR を作成するとき。
disable-model-invocation: true
argument-hint: "[capture タイトル | create タイトル | start N | finish N | status]"
allowed-tools: Bash(gh *) Bash(git *) Read
---

# issue-pm スキル

> **原則**: コードより先に issue を作る。ブランチと PR は必ず issue と 1 対 1 で紐付ける。

## gh CLI が使えない実行環境（Claude on web 等）

`gh` CLI が無い環境では、同等の操作を GitHub MCP ツール
（`mcp__github__*`）で代替する。対応表:

| gh コマンド | MCP ツール |
|---|---|
| `gh issue create` | `mcp__github__issue_write`（method: create） |
| `gh issue view` | `mcp__github__issue_read`（method: get） |
| `gh issue comment` | `mcp__github__add_issue_comment` |
| `gh issue list` | `mcp__github__list_issues` |
| `gh pr create` | `mcp__github__create_pull_request` |

## コマンド別ワークフロー

### `capture` — 着手せず要件を issue 化するだけ

```bash
gh issue create \
  --title "タイトル" \
  --body "$(cat .claude/skills/issue-pm/templates.md | sed -n '/^## issue-body/,/^## /p' | tail -n +2 | head -n -1)" \
  --label "feat"
```

### `create` — issue を作ってブランチまで切る

```bash
# 1. issue 作成
gh issue create --title "タイトル" --body "..." --label "feat"
# 作成された issue 番号を記録（例: #42）

# 2. プロジェクトに追加
gh project item-add 2 --owner <owner> --url <issue-url>

# 3. ブランチ作成
gh issue develop 42 --name "feat/42-短い説明" --checkout
```

ブランチ命名規則: `<type>/<issue番号>-<kebab-case-slug>`
- `feat/42-constraint-form`
- `fix/17-solver-timeout`

### `start` — 既存 issue の作業を開始する

```bash
git checkout main && git pull origin main
git checkout -b "feat/42-短い説明"
gh issue comment 42 --body "作業を開始しました。"
```

### `finish` — 実装完了・PR 作成

```bash
git push -u origin $(git branch --show-current)
gh pr create \
  --title "feat: タイトル (#42)" \
  --body "$(cat .claude/skills/issue-pm/templates.md | sed -n '/^## pr-body/,/^## /p' | tail -n +2 | head -n -1 | sed 's/ISSUE_NUMBER/42/g')"
```

## ブランチ・PR ルール

| ルール | 詳細 |
|---|---|
| ブランチ起点 | **必ず `main` から切る** |
| ブランチ命名 | `<type>/<N>-<slug>` 形式必須 |
| PR ベース | **必ず `main`** |
| PR タイトル | `<type>: <概要> (#N)` 形式 |
| PR 本文 | `Closes #N` を含める（自動クローズ） |
