#!/usr/bin/env bash
# PreToolUse: git commit 前の品質ゲート
# A: テスト + カバレッジ（死守）+ 型チェックをブロッキング実行
# B: ブランチ名が issue 番号付き形式か検証
set -uo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

if ! echo "$command" | grep -qE "git commit"; then
  exit 0
fi

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$root"

errors=()
warnings=()

# ---- B: ブランチ名検証 ----------------------------------------
branch=$(git branch --show-current 2>/dev/null || echo "")
issue_branch_pattern="^(feat|fix|refactor|chore|docs)/[0-9]+-"

if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  errors+=("main/master への直接コミットは禁止です。/issue-pm create で issue とブランチを作成してください。")
elif [[ -n "$branch" ]] && ! echo "$branch" | grep -qE "^claude/" && ! echo "$branch" | grep -qE "$issue_branch_pattern"; then
  if [[ "${SKIP_ISSUE_CHECK:-}" != "1" ]]; then
    errors+=("ブランチ名 '${branch}' に issue 番号がありません（例: feat/42-constraint-form）。先に issue を作成してください（/issue-pm create）。緊急修正の場合は SKIP_ISSUE_CHECK=1 を設定してください。")
  fi
fi


# ---- C: solver-api Python テスト（変更ファイルに apps/solver-api が含まれる場合）----
staged_solver=$(git diff --cached --name-only 2>/dev/null | grep -c "^apps/solver-api/" || true)
if [ "${staged_solver:-0}" -gt 0 ]; then
  solver_dir="$root/apps/solver-api"
  if command -v uv >/dev/null 2>&1; then
    echo "▶ Python ruff チェック中（solver-api）..." >&2
    if ! (cd "$solver_dir" && uv run ruff check . 2>&1); then
      errors+=("solver-api: ruff lint エラーがあります。cd apps/solver-api && uv run ruff check . を確認してください。")
    fi
    echo "▶ Python テスト + カバレッジ実行中（solver-api, 90% 必須）..." >&2
    if ! (cd "$solver_dir" && uv run pytest --cov --cov-report=term-missing -q 2>&1); then
      errors+=("solver-api: Python テストまたはカバレッジ（90% 以上必須）が失敗しました。cd apps/solver-api && uv run pytest --cov --cov-report=term-missing を確認してください。")
    fi
  else
    echo "▶ uv が見つかりません。Python テストをスキップします。" >&2
  fi
fi

# package.json がなければテスト系はスキップ（初期セットアップ前）
if [ ! -f package.json ]; then
  if [ ${#errors[@]} -gt 0 ]; then
    msg="コミットをブロックしました:\n"
    for e in "${errors[@]}"; do msg+="• ${e}\n"; done
    jq -n --arg r "$msg" '{"decision":"block","reason":$r}'
    exit 0
  fi
  exit 0
fi

# ---- A: テスト実行 -------------------------------------------
echo "▶ テスト実行中..." >&2
if ! npm run test:run --silent 2>&1; then
  errors+=("テストが失敗しました。npm run test:run を確認してください。")
fi

# ---- A: 型チェック -------------------------------------------
if [ -f tsconfig.json ]; then
  echo "▶ 型チェック中..." >&2
  if ! npx tsc --noEmit 2>&1; then
    errors+=("TypeScript 型エラーがあります。npx tsc --noEmit を確認してください。")
  fi
fi

# ---- A: カバレッジ死守（テスト通過時のみ実行） ---------------
if [ ${#errors[@]} -eq 0 ]; then
  echo "▶ カバレッジ確認中（全体 80% / solver 90% 必須）..." >&2
  if ! npm run test:coverage --silent 2>&1; then
    errors+=("カバレッジが閾値を下回っています（全体 80% / solver 90%）。/coverage-check で修正してください。")
  fi
fi

# ---- 結果出力 -------------------------------------------------
if [ ${#errors[@]} -gt 0 ]; then
  msg="コミットをブロックしました:\n"
  for e in "${errors[@]}"; do msg+="• ${e}\n"; done
  jq -n --arg r "$msg" '{"decision":"block","reason":$r}'
  exit 0
fi

if [ ${#warnings[@]} -gt 0 ]; then
  msg="警告（コミットは続行します）:\n"
  for w in "${warnings[@]}"; do msg+="• ${w}\n"; done
  jq -n --arg r "$msg" '{"decision":"allow","reason":$r}'
  exit 0
fi

exit 0
