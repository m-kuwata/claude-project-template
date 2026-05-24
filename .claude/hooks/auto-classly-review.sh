#!/bin/bash
# Stop: 実装ファイルが変更されていたら classly-review を強制実行させる。
# needs-review フラグはレビュー完了マーカー (classly-review-passed) が
# フラグより新しいときのみクリアする。
NEED=/tmp/classly-needs-review
DONE=/tmp/classly-review-passed

if [ -f "$NEED" ]; then
  if [ -f "$DONE" ] && [ "$DONE" -nt "$NEED" ]; then
    rm -f "$NEED" "$DONE"
  else
    echo '{"decision":"block","reason":"実装ファイルが変更されました。/classly-review スキルでコミット前チェック（テスト・型・Lint・デザイン規約・コピー・セキュリティ）を完了し、最後に `touch /tmp/classly-review-passed` でレビュー完了を記録してください。記録がない限り再度ブロックします。"}'
  fi
fi
