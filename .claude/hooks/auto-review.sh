#!/bin/bash
# Stop: 実装ファイルが変更されていたら project-review を強制実行させる。
# needs-review フラグは mark-review-passed.sh で書かれた完了マーカーが
# フラグより新しく、かつ "REVIEWED:" 行を持つときのみクリアする。
# 直接 touch した場合はファイルが空になり grep が失敗するため、スキップを検知できる。
# PROJECT_NAME は settings.json の env セクションで設定する。
PROJECT_NAME="${PROJECT_NAME:-myapp}"
NEED="/tmp/${PROJECT_NAME}-needs-review"
DONE="/tmp/${PROJECT_NAME}-project-review-passed"

if [ -f "$NEED" ]; then
  if [ -f "$DONE" ] && [ "$DONE" -nt "$NEED" ] && grep -q "^REVIEWED:" "$DONE" 2>/dev/null; then
    rm -f "$NEED" "$DONE"
  else
    echo "{\"decision\":\"block\",\"reason\":\"実装ファイルが変更されました。/project-review スキルでコミット前チェック（テスト・型・Lint・デザイン規約・コピー・セキュリティ）を完了し、最後に \`bash \$CLAUDE_PROJECT_DIR/.claude/hooks/mark-review-passed.sh project-review\` で完了を記録してください。\`touch\` では記録できません。記録がない限り再度ブロックします。\"}"
  fi
fi
