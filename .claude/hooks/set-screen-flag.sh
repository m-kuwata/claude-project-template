#!/bin/bash
# PostToolUse: 画面ファイルが変更されたら design-check フラグを立てる
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
  # src/app/ または src/components/ 配下の .tsx（テスト・ストーリー除く）
  # ※ パスパターンはプロジェクトに合わせて調整すること
  if echo "$file" | grep -qE '(src/app/|src/components/).*\.tsx$' && \
     ! echo "$file" | grep -qE '\.(test|spec|stories)\.tsx$'; then
    touch "/tmp/${PROJECT_NAME}-needs-design-check"
    break
  fi
done <<< "$files"
