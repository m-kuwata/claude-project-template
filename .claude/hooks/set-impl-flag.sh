#!/bin/bash
# PostToolUse: Write/Edit/MultiEdit で実装ファイルが変更されたらフラグを立てる
# PROJECT_NAME は settings.json の env セクションで設定する。
PROJECT_NAME="${PROJECT_NAME:-myapp}"
input=$(cat)

# Write/Edit は file_path、MultiEdit は edits[].file_path を持つ
files=$(echo "$input" | jq -r '
  .tool_input.file_path //
  (.tool_input.edits[]?.file_path) //
  empty
' 2>/dev/null)

while IFS= read -r file; do
  [ -z "$file" ] && continue
  # .ts/.tsx 実装ファイル（テスト・ストーリー・設定を除く）
  if echo "$file" | grep -qE '\.(tsx?|ts)$' && \
     ! echo "$file" | grep -qE '\.(test|spec|stories)\.(tsx?|ts)$' && \
     ! echo "$file" | grep -qE '(vitest|playwright|tailwind|next|postcss)\.config'; then
    touch "/tmp/${PROJECT_NAME}-needs-review"
    break
  fi
  # .py 実装ファイル（テスト・conftest を除く）
  if echo "$file" | grep -qE '\.py$' && \
     ! echo "$file" | grep -qE '(test_.*|.*_test|conftest)\.py$'; then
    touch "/tmp/${PROJECT_NAME}-needs-review"
    break
  fi
done <<< "$files"
