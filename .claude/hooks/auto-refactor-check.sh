#!/bin/bash
# Stop: 実装ファイルが変更されていたら refactor ゲートを強制実行させる。
# 差分の重複・dead code・既存資産の再発明・複雑度を確認させる TDD REFACTOR フェーズのゲート。
# PROJECT_NAME は settings.json の env セクションで設定する。
PROJECT_NAME="${PROJECT_NAME:-myapp}"
NEED="/tmp/${PROJECT_NAME}-needs-refactor"
DONE="/tmp/${PROJECT_NAME}-refactor-passed"

if [ -f "$NEED" ]; then
  # 直接 touch した場合はファイルが空になり grep が失敗するため、スキップを検知できる。
  if [ -f "$DONE" ] && [ "$DONE" -nt "$NEED" ] && grep -q "^REVIEWED:" "$DONE" 2>/dev/null; then
    rm -f "$NEED" "$DONE"
  else
    echo "{\"decision\":\"block\",\"reason\":\"実装ファイルが変更されました。/refactor スキルで差分の重複・dead code・既存資産の再発明・複雑度を確認し、テストを緑に保ったまま整理してから、最後に \`bash \$CLAUDE_PROJECT_DIR/.claude/hooks/mark-review-passed.sh refactor\` で完了を記録してください。\`touch\` では記録できません。\"}"
  fi
fi
