#!/usr/bin/env bash
# PreToolUse(Edit|Write): Issue 駆動開発ガード（ハードブロック）
#
# /tmp/${PROJECT_NAME}-issue-acked が存在しない場合、ファイル編集を deny する。
# マーカー設置: echo "#N" > /tmp/${PROJECT_NAME}-issue-acked
# PROJECT_NAME は settings.json の env セクションで設定する。
#
# 除外対象:
#   - .claude/ 配下（フック・スキル自体の編集）
#   - docs/ 配下（ドキュメント更新）
#   - /tmp/ 配下
#   - CLAUDE.md / README.md / AGENTS.md（ルートドキュメント）
#   - テスト・ストーリーファイル（RED フェーズの先行追加は issue なしでも可）
set -uo pipefail

PROJECT_NAME="${PROJECT_NAME:-myapp}"
MARKER="/tmp/${PROJECT_NAME}-issue-acked"

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")

[[ -z "$file_path" ]] && exit 0

# .claude/ 配下（hooks, skills 等の設定ファイル）は除外
if echo "$file_path" | grep -qE '(^|/)\.claude/'; then exit 0; fi

# docs/ 配下は除外
if echo "$file_path" | grep -qE '(^|/)docs/'; then exit 0; fi

# /tmp/ 配下は除外
if echo "$file_path" | grep -qE '^/tmp/'; then exit 0; fi

# CLAUDE.md, README.md 等のルートドキュメントは除外
if echo "$file_path" | grep -qE '^[^/]*(CLAUDE|README|AGENTS)\.md$'; then exit 0; fi

# テスト・スペック・ストーリーファイルは除外（RED フェーズ先行追加のため）
if echo "$file_path" | grep -qE '\.(test|spec|stories)\.(ts|tsx|js|jsx|py)$'; then exit 0; fi

# マーカーが存在する場合は許可
[[ -f "$MARKER" ]] && exit 0

# ブロック
reason="🚫 Issue 駆動開発ガード: 編集をブロックしました

ファイル: ${file_path}

コードより issue が先です。以下の手順で進めてください:

  1. GitHub issue を確認・作成する
     （新規の場合は /issue-pm create \"タイトル\" または mcp__github__issue_write）
  2. issue 番号を記録する:
       echo \"#N\" > ${MARKER}
  3. 再度編集を試みる

Issue 番号が分かっている場合:
  echo \"#N\" > ${MARKER}  # N は issue 番号

詳細: CLAUDE.md「Issue 駆動開発」を参照"

jq -n --arg r "$reason" \
  '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":$r}}'
exit 0
