#!/usr/bin/env bash
# Claude Code 設定（CLAUDE.md / skills / hooks / settings.json）の健全性チェック。
# `/config-audit` スキルと CI（config-audit.yml）の双方から呼ぶ共通実装。
#
# 終了コード: 致命（FATAL）が 1 件以上で 1、それ以外は 0。
# FATAL = フック実行不可/シバンなし、settings.json 不正、jq 未導入、
#         スキルに name/description なし。
# WARN/INFO は表示のみ（CI を落とさない）。
set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

fatal=0
warn=0

err()  { echo "FATAL: $*"; fatal=$((fatal + 1)); }
wrn()  { echo "WARN:  $*"; warn=$((warn + 1)); }
inf()  { echo "INFO:  $*"; }

echo "=== チェック 0 — 前提ツール ==="
if ! command -v jq &>/dev/null; then
  err "jq 未インストール（フックが機能しません）"
fi

echo "=== チェック 1 — スキル frontmatter ==="
for f in .claude/skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  for field in name description; do
    grep -q "^${field}:" "$f" || err "'${field}' 未設定 → $f"
  done
  if ! grep -q "^when_to_use:" "$f" && ! grep -q "^disable-model-invocation: true" "$f"; then
    wrn "自動呼び出し設定なし (when_to_use か disable-model-invocation) → $f"
  fi
done

echo "=== チェック 2 — フック実行可能性 ==="
for hook in .claude/hooks/*.sh; do
  [ -f "$hook" ] || continue
  [ -x "$hook" ] || err "実行権限なし → $hook"
  head -1 "$hook" | grep -q "^#!" || err "シバン行なし → $hook"
  if grep -q "jq" "$hook" && ! command -v jq &>/dev/null; then
    err "jq 未インストールだが $hook が jq を使用"
  fi
done

echo "=== チェック 3 — settings.json 構造 ==="
if jq empty .claude/settings.json 2>/dev/null; then
  echo "OK: settings.json は valid JSON"
else
  err "settings.json が不正な JSON"
fi
jq -e '.permissions.deny | length > 0' .claude/settings.json &>/dev/null \
  && echo "OK: deny ルールあり" \
  || wrn "deny ルールなし（破壊的操作が無制限）"
for event in PreToolUse PostToolUse Stop UserPromptSubmit PreCompact SessionStart; do
  jq -e ".hooks.${event}" .claude/settings.json &>/dev/null \
    && echo "OK: ${event} フック登録済み" \
    || inf "${event} フック未登録"
done

echo "=== チェック 4 — settings.local.json 残髨 ==="
if [ -f .claude/settings.local.json ]; then
  if jq -r '.permissions.allow[]?' .claude/settings.local.json 2>/dev/null \
       | grep -Eq "(/tmp/|gunzip|webfetch)"; then
    wrn "settings.local.json に一時ファイル操作が残存"
  else
    echo "OK: settings.local.json クリーン"
  fi
fi

echo "=== チェック 5 — CLAUDE.md サイズと参照整合 ==="
lines=$(wc -l < CLAUDE.md)
if [ "$lines" -le 200 ]; then
  echo "OK: CLAUDE.md ${lines}行（200行以内）"
else
  wrn "CLAUDE.md ${lines}行（200行超。.claude/rules/ への分割を検討）"
fi
for dir in .claude/skills/*/; do
  skill=$(basename "$dir")
  grep -q "\`${skill}\`" CLAUDE.md || inf "スキル '${skill}' が CLAUDE.md スキルテーブルに未記載"
done

echo ""
echo "=== 結果: FATAL=${fatal} WARN=${warn} ==="
[ "$fatal" -eq 0 ] || exit 1
exit 0
