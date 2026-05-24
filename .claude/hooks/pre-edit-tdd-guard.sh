#!/usr/bin/env bash
# PreToolUse(Edit|Write): src/lib/ と src/features/ の実装ファイルを編集する前に
# 対応するテストファイルが存在するか検証する（TDD RED フェーズ強制）
set -uo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")

[[ -z "$file_path" ]] && exit 0

# 相対パスを絶対パスに変換
if [[ ! "$file_path" = /* ]]; then
  root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  file_path="${root}/${file_path}"
fi

# src/lib/ または src/features/ 配下のファイルのみ対象
if ! echo "$file_path" | grep -qE '/src/(lib|features)/'; then exit 0; fi

# .ts / .tsx ファイルのみ
if ! echo "$file_path" | grep -qE '\.(ts|tsx)$'; then exit 0; fi

# テスト・スペック・ストーリー・型定義ファイルは除外
if echo "$file_path" | grep -qE '\.(test|spec|stories)\.(ts|tsx)$'; then exit 0; fi
if echo "$file_path" | grep -qE '\.d\.ts$'; then exit 0; fi

# __tests__/ や test-utils/ ディレクトリ内は除外
if echo "$file_path" | grep -qE '/(__tests__|test-utils)/'; then exit 0; fi

# 対応するテストファイルの候補を探す
dir=$(dirname "$file_path")
base=$(basename "$file_path")
ext="${base##*.}"
base_noext="${base%.*}"

# 複合拡張子（.test.ts 等）を除去
if [[ "$base_noext" == *.test || "$base_noext" == *.spec ]]; then exit 0; fi

candidates=(
  "${dir}/__tests__/${base_noext}.test.${ext}"
  "${dir}/__tests__/${base_noext}.test.ts"
  "${dir}/__tests__/${base_noext}.spec.${ext}"
  "${dir}/__tests__/${base_noext}.spec.ts"
  "${dir}/${base_noext}.test.${ext}"
  "${dir}/${base_noext}.test.ts"
)

for candidate in "${candidates[@]}"; do
  [[ -f "$candidate" ]] && exit 0
done

# ファイルが存在しない場合（新規作成）→ まずテストを書くよう要求
if [[ ! -f "$file_path" ]]; then
  expected="${dir}/__tests__/${base_noext}.test.${ext}"
  reason="🔴 TDD 違反（RED フェーズ未完了）

実装ファイル: ${file_path}
対応テストが見つかりません。

テストファーストで進めてください:
  1. まず ${expected} を作成（RED）
  2. テストが失敗することを確認
  3. その後で実装ファイルを作成・編集（GREEN）

緊急の場合は SKIP_TDD_CHECK=1 を設定してください。"

  jq -n --arg r "$reason" \
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":$r}}'
  exit 0
fi

# 既存ファイルの編集でテストがない場合はブロックせず警告のみ
context="⚠️ TDD 警告: ${file_path} の対応テストファイルが見つかりません。
テストを追加してから実装を変更することを推奨します（TDD GREEN/REFACTOR フェーズ）。
対応テストの期待パス: ${dir}/__tests__/${base_noext}.test.${ext}"

jq -n --arg c "$context" \
  '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":$c}}'
exit 0
