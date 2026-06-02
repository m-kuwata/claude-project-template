#!/usr/bin/env bash
# PostToolUse: Write/Edit/MultiEdit 後に ESLint + tsc を実行してエラーを早期検出
set -uo pipefail

input=$(cat)

files=$(echo "$input" | jq -r '
  .tool_input.file_path //
  (.tool_input.edits[]?.file_path) //
  empty
' 2>/dev/null)

ts_file=""
py_file=""
while IFS= read -r file; do
  [ -z "$file" ] && continue
  if [ -z "$ts_file" ] && echo "$file" | grep -qE '\.(tsx?|ts)$' && \
     ! echo "$file" | grep -qE '\.(test|spec|stories)\.(tsx?|ts)$'; then
    ts_file="$file"
  fi
  if [ -z "$py_file" ] && echo "$file" | grep -qE '\.py$'; then
    py_file="$file"
  fi
done <<< "$files"

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$root"

if [ -n "$ts_file" ] && [ -f package.json ]; then
  echo "▶ TS Lint チェック中: $ts_file" >&2
  if ! out=$(npx eslint "$ts_file" 2>&1); then
    echo "⚠ ESLint エラー ($ts_file):" >&2
    echo "$out" | tail -n 20 >&2
  fi
fi

if [ -n "$py_file" ] && [ -d apps/solver-api ]; then
  echo "▶ Python ruff チェック中: $py_file" >&2
  if command -v uv >/dev/null 2>&1; then
    rel="${py_file#apps/solver-api/}"
    if ! out=$(cd apps/solver-api && uv run ruff check "$rel" 2>&1); then
      echo "⚠ ruff エラー ($py_file):" >&2
      echo "$out" | tail -n 20 >&2
    fi
  fi
fi

exit 0
