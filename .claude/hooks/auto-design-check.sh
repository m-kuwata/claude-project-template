#!/bin/bash
# Stop: 画面ファイルが変更されていたら design-check を強制実行させる
# PROJECT_NAME は settings.json の env セクションで設定する。
PROJECT_NAME="${PROJECT_NAME:-myapp}"
if [ -f "/tmp/${PROJECT_NAME}-needs-design-check" ]; then
  rm "/tmp/${PROJECT_NAME}-needs-design-check"
  echo '{"decision":"block","reason":"画面ファイルが変更されました。/design-check スキルを実行してデザインシステム規約チェック（カラートークン・禁止用語・絵文字・gradient・stories）を完了してください。"}'
fi
