#!/bin/bash
# PostToolUse: 画面ファイルが変更されたら design-check フラグを立てる
input=$(cat)

files=$(echo "$input" | jq -r '
  .tool_input.file_path //
  (.tool_input.edits[]?.file_path) //
  empty
' 2>/dev/null)

while IFS= read -r file; do
  [ -z "$file" ] && continue
  # src/app/ または src/components/classly/ の .tsx（テスト・ストーリー除く）
  if echo "$file" | grep -qE '(src/app/|src/components/classly/).*\.tsx$' && \
     ! echo "$file" | grep -qE '\.(test|spec|stories)\.tsx$'; then
    touch /tmp/classly-needs-design-check
    break
  fi
done <<< "$files"
