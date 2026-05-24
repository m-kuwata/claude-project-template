#!/bin/bash
# Stop: 画面ファイルが変更されていたら design-check を強制実行させる
if [ -f /tmp/classly-needs-design-check ]; then
  rm /tmp/classly-needs-design-check
  echo '{"decision":"block","reason":"画面ファイルが変更されました。/design-check スキルを実行してデザインシステム規約チェック（カラートークン・禁止用語・絵文字・gradient・stories）を完了してください。"}'
fi
