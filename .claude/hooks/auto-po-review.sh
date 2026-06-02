#!/bin/bash
# Stop: 実装ファイルが変更されていたら po-review を強制実行させる。
# 実装が現場の運用ニーズと合っているかを Product Owner 視点でレビューさせるゲート。
# PROJECT_NAME は settings.json の env セクションで設定する。
PROJECT_NAME="${PROJECT_NAME:-myapp}"
NEED="/tmp/${PROJECT_NAME}-needs-po-review"
DONE="/tmp/${PROJECT_NAME}-po-review-passed"

if [ -f "$NEED" ]; then
  # 直接 touch した場合はファイルが空になり grep が失敗するため、スキップを検知できる。
  if [ -f "$DONE" ] && [ "$DONE" -nt "$NEED" ] && grep -q "^REVIEWED:" "$DONE" 2>/dev/null; then
    rm -f "$NEED" "$DONE"
  else
    echo "{\"decision\":\"block\",\"reason\":\"実装ファイルが変更されました。/po-review スキル（mode: done）で実装が現場の運用ニーズと合っているかをレビューし、最後に \`bash \$CLAUDE_PROJECT_DIR/.claude/hooks/mark-review-passed.sh po-review\` で完了を記録してください。\`touch\` では記録できません。\"}"
  fi
fi
