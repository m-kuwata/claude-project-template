#!/bin/bash
# PostToolUse: 画面に影響するファイルが変更されたらスクリーンショットチェックフラグを立てる
input=$(cat)

files=$(echo "$input" | jq -r '
  .tool_input.file_path //
  (.tool_input.edits[]?.file_path) //
  empty
' 2>/dev/null)

while IFS= read -r file; do
  [ -z "$file" ] && continue
  # テスト・ストーリーは除外
  echo "$file" | grep -qE '\.(test|spec|stories)\.(tsx?|jsx?)$' && continue
  # 対象: AppShell / src/app/ ページ・レイアウト / src/components/classly/ の全コンポーネント
  if echo "$file" | grep -qE '(AppShell/AppShell\.tsx|src/app/(.*/)?(page|layout)\.tsx|src/components/classly/[^/]+/[^/]+\.tsx)$'; then
    touch /tmp/classly-needs-screenshot-check
    break
  fi
done <<< "$files"
