#!/usr/bin/env bash
# SessionStart: 毎セッション共通のプロジェクトセットアップ
# gh/jq のインストールは Web UI の Setup script で行う
set -euo pipefail

# 多数のフック・スキルが jq / gh に依存する。欠如時は黙ってすり抜けるため警告する。
missing=()
command -v jq &>/dev/null || missing+=("jq（pre-commit-check 等のフックが機能しません）")
command -v gh &>/dev/null || missing+=("gh（issue 系スキルは mcp__github__* で代替してください）")
if [ ${#missing[@]} -gt 0 ]; then
  echo "⚠ 必須ツール未検出:" >&2
  for m in "${missing[@]}"; do echo "  - $m" >&2; done
  echo "  Web UI の Setup script で導入してください。" >&2
fi

if [ -f package.json ] && command -v npm &>/dev/null; then
  npm install --prefer-offline --silent 2>/dev/null || true
fi

# git commit-msg フックを .claude/git-hooks/ に向ける（issue #N 強制）
if git rev-parse --git-dir &>/dev/null 2>&1; then
  git config core.hooksPath .claude/git-hooks 2>/dev/null || true
fi

# Playwright ブラウザが未インストールなら取得（ネットワーク許可が必要）
if command -v npx &>/dev/null && [ -f node_modules/.bin/playwright ]; then
  if ! npx playwright install --dry-run chromium &>/dev/null 2>&1; then
    echo "Playwright Chromium をインストール中..." >&2
    npx playwright install chromium --with-deps --quiet 2>/dev/null || \
      echo "⚠ Playwright ブラウザのインストールに失敗しました（ネットワーク設定を確認してください）" >&2
  fi
fi
