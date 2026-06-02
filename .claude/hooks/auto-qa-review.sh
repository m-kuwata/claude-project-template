#!/bin/bash
# Stop: 実装ファイルが変更されていたら qa-review を強制実行させる。
# テストシナリオが実運用に沿っているかを QA 視点でレビューさせるゲート。
# PROJECT_NAME は settings.json の env セクションで設定する。
PROJECT_NAME="${PROJECT_NAME:-myapp}"
NEED="/tmp/${PROJECT_NAME}-needs-qa-review"
DONE="/tmp/${PROJECT_NAME}-qa-review-passed"

if [ -f "$NEED" ]; then
  # 直接 touch した場合はファイルが空になり grep が失敗するため、スキップを検知できる。
  if [ -f "$DONE" ] && [ "$DONE" -nt "$NEED" ] && grep -q "^REVIEWED:" "$DONE" 2>/dev/null; then
    rm -f "$NEED" "$DONE"
  else
    echo "{\"decision\":\"block\",\"reason\":\"実装ファイルが変更されました。/qa-review スキルでテストシナリオが実運用に沿っているかをレビューし、最後に \`bash \$CLAUDE_PROJECT_DIR/.claude/hooks/mark-review-passed.sh qa-review\` で完了を記録してください。\`touch\` では記録できません。\"}"
  fi
fi
