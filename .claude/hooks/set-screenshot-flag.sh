#!/bin/bash
# PostToolUse: 画面に影響するファイルが変更されたらスクリーンショットチェックフラグを立てる
# PROJECT_NAME は settings.json の env セクションで設定する。
PROJECT_NAME="${PROJECT_NAME:-myapp}"
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
  # 対象: src/app/ ページ・レイアウト / src/components/ 配下のコンポーネント
  # ※ パスパターンはプロジェクトに合わせて調整すること
  if echo "$file" | grep -qE '(src/app/(.*/)?(page|layout)\.tsx|src/components/[^/]+/[^/]+\.tsx)$'; then
    touch "/tmp/${PROJECT_NAME}-needs-screenshot-check"
    break
  fi
done <<< "$files"
