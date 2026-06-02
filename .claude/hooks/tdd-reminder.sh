#!/usr/bin/env bash
# Claude Code UserPromptSubmit hook
# 実装タスクのプロンプトを検知したとき、TDD リマインダーをコンテキストに注入する。
input=$(cat)
prompt=$(echo "$input" | jq -r '.prompt // ""' 2>/dev/null || echo "")

# 実装キーワードを検出（日本語・英語）
impl_pattern="実装|新規作成|コンポーネント.*作|スクリーン.*作|機能.*追加|テスト.*書|ソルバ|solver|implement|create.*component|add.*feature|write.*test|build.*screen|fix.*bug"

if echo "$prompt" | grep -qiE "$impl_pattern"; then
  cat <<'REMINDER'

---
[Issue 駆動開発ルール（絶対）]
実装を開始する前に必ず GitHub issue を確認・作成してください:
1. 会話の中で発生した要件・設計変更も issue 化が必要（コードより issue が先）
2. 既存 issue がなければ先に作成する（/issue-pm create "タイトル"）
3. ブランチ名に issue 番号を含める（例: feat/42-constraint-form）
4. コミットメッセージに #N を含める（例: Closes #42）

[TDD 強制ルール]
このタスクは TDD（テスト駆動開発）で進めてください:
1. RED   — テストを先に書く（実装なしで失敗することを確認）
2. GREEN — 最小限のコードでテストを通す
3. REFACTOR — テストを保ちながらコードを整理する

コードを書く前にテストファイルを作成すること。
完了後は `npm run test:coverage` でカバレッジが 80% 以上であることを確認すること。
---
REMINDER
fi

exit 0
