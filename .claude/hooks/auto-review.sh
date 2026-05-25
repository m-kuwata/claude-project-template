#!/bin/bash
# Stop: 実装ファイルが変更されていたら project-review を強制実行させる。
# needs-review フラグはレビュー完了マーカーがフラグより新しいときのみクリアする。
# PROJECT_NAME は settings.json の env セクションで設定する。
PROJECT_NAME="${PROJECT_NAME:-myapp}"
NEED="/tmp/${PROJECT_NAME}-needs-review"
DONE="/tmp/${PROJECT_NAME}-review-passed"

if [ -f "$NEED" ]; then
  if [ -f "$DONE" ] && [ "$DONE" -nt "$NEED" ]; then
    rm -f "$NEED" "$DONE"
  else
    echo "{\"decision\":\"block\",\"reason\":\"実装ファイルが変更されました。/project-review スキルでコミット前チェック（テスト・型・Lint・デザイン規約・コピー・セキュリティ）を完了し、最後に \`touch /tmp/${PROJECT_NAME}-review-passed\` でレビュー完了を記録してください。記録がない限り再度ブロックします。\"}"
  fi
fi
