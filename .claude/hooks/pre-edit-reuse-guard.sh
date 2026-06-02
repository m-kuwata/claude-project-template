#!/usr/bin/env bash
# PreToolUse(Edit|Write): 再利用ガード（非ブロック・警告のみ）
#
# 新規ファイル作成時に既存資産を提示し、再発明していないか確認を促す。
#   - UI:        src/components/<Name>.tsx → 既存コンポーネント一覧
#   - ロジック:  src/lib/<name>.ts          → 既存ユーティリティ・公開関数一覧
# ブロックはせず additionalContext で警告するだけ。
#
# プロジェクトのディレクトリ構成に合わせて UI_DIR / LIB_DIR を調整すること。
set -uo pipefail

# プロジェクト構成に合わせて調整する
UI_DIR="src/components"
LIB_DIR="src/lib"

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")

[[ -z "$file_path" ]] && exit 0

# 相対パスを絶対パスに変換
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
if [[ ! "$file_path" = /* ]]; then
  file_path="${root}/${file_path}"
fi

# テスト・ストーリーは対象外
if echo "$file_path" | grep -qE '\.(test|spec|stories)\.(tsx?|ts)$'; then exit 0; fi
if echo "$file_path" | grep -qE '(/__tests__/|/tests/|/test_|_test\.py$|conftest\.py$|__init__\.py$)'; then exit 0; fi

# 既存ファイルの編集（=新規作成でない）はスキップ。再発明は新規時のみ問題。
[[ -f "$file_path" ]] && exit 0

emit() {
  jq -n --arg c "$1" \
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":$c}}'
  exit 0
}

# 類似名の簡易検出（新規名の語が既存名に含まれる / 既存名が新規名に含まれる）
detect_similar() {
  local new_lc="$1"; shift
  local existing="$1"
  local similar=""
  while IFS= read -r e; do
    [[ -z "$e" ]] && continue
    local e_lc
    e_lc=$(echo "$e" | tr '[:upper:]' '[:lower:]')
    if [[ "$new_lc" == *"$e_lc"* || "$e_lc" == *"$new_lc"* ]]; then
      similar="${similar}  - ${e}\n"
    fi
  done <<< "$existing"
  printf "%s" "$similar"
}

# --- UI コンポーネント: src/components/**/<Name>.tsx ---
if echo "$file_path" | grep -qE "/${UI_DIR}/.*\.tsx$"; then
  comp_dir="${root}/${UI_DIR}"
  [[ -d "$comp_dir" ]] || exit 0

  new_name=$(basename "$file_path" .tsx)
  existing=$(find "$comp_dir" -name '*.tsx' ! -name '*.test.tsx' ! -name '*.stories.tsx' \
             -exec basename {} .tsx \; 2>/dev/null | sort -u)
  [[ -z "$existing" ]] && exit 0

  similar=$(detect_similar "$(echo "$new_name" | tr '[:upper:]' '[:lower:]')" "$existing")
  existing_list=$(echo "$existing" | sed 's/^/  - /')

  context="🔁 再利用ガード: 新規コンポーネント「${new_name}」を作成しようとしています。

再発明していないか確認してください:
  1. 既存のコンポーネントで代替・拡張できないか
  2. UI ライブラリのプリミティブ（shadcn/ui 等）で足りないか
  3. Storybook で既存の見た目・variant を確認したか"

  if [[ -n "$similar" ]]; then
    context="${context}

⚠️ 名前が似た既存コンポーネントがあります（重複の可能性）:
$(printf "%b" "$similar")"
  fi

  context="${context}

既存コンポーネント一覧:
${existing_list}

代替できないことを確認した上で新規作成してください。詳細は /refactor・/new-component スキル参照。"

  emit "$context"
fi

# --- ユーティリティ・ロジック: src/lib/**/<name>.ts ---
if echo "$file_path" | grep -qE "/${LIB_DIR}/.*\.ts$"; then
  lib_dir="${root}/${LIB_DIR}"
  [[ -d "$lib_dir" ]] || exit 0

  new_name=$(basename "$file_path" .ts)
  modules=$(find "$lib_dir" -name '*.ts' ! -name '*.test.ts' ! -name '*.d.ts' \
            -exec basename {} .ts \; 2>/dev/null | sort -u)
  [[ -z "$modules" ]] && exit 0

  similar=$(detect_similar "$(echo "$new_name" | tr '[:upper:]' '[:lower:]')" "$modules")
  module_list=$(echo "$modules" | sed 's/^/  - /')
  # 既存の公開関数・定数（export されているもの）
  symbols=$(grep -rhnE '^export (async )?(function|const|class) [A-Za-z]' "$lib_dir" 2>/dev/null \
            | sed -E 's/^.*export (async )?(function|const|class) /  - /; s/[ (=<:].*//' | sort -u)

  context="🔁 再利用ガード: 新規モジュール「${LIB_DIR}/${new_name}.ts」を作成しようとしています。

再発明していないか確認してください:
  1. 既存のユーティリティ・hook で賄える処理を再実装していないか
  2. 共通ヘルパー（cn() 等）を再定義していないか
  3. 新規モジュールを作らず既存モジュールへの追加で済まないか"

  if [[ -n "$similar" ]]; then
    context="${context}

⚠️ 名前が似た既存モジュールがあります（重複の可能性）:
$(printf "%b" "$similar")"
  fi

  context="${context}

既存モジュール:
${module_list}

既存の公開関数・定数:
${symbols}

代替できないことを確認した上で新規作成してください。詳細は /refactor スキル参照。"

  emit "$context"
fi

exit 0
