#!/bin/bash
# Stop hook: レイアウトファイルが変更されたらスクリーンショット確認を要求する
# set-screenshot-flag.sh がフラグを立て、このフックが検出して Claude に指示を注入する
# PROJECT_NAME は settings.json の env セクションで設定する。
PROJECT_NAME="${PROJECT_NAME:-myapp}"

if [ ! -f "/tmp/${PROJECT_NAME}-needs-screenshot-check" ]; then
  exit 0
fi

rm "/tmp/${PROJECT_NAME}-needs-screenshot-check"

cat <<'JSON'
{
  "decision": "block",
  "reason": "レイアウトファイルが変更されました。Playwright でスクリーンショットを撮影して目視確認してください。\n\n手順:\n1. dev サーバーを起動（例: npm run dev）\n2. Playwright で主要画面を Mobile / Tablet / Desktop の各ビューポートで撮影し /tmp/screenshots/ に保存\n3. Read ツールで各画像を読み込み、レイアウト崩れ・表示ズレがないか確認\n4. 問題があれば修正して再チェック\n5. 問題なければ SendUserFile でスクリーンショットをユーザーに送信して確認を求める\n\n※ 確認対象の画面ルートはプロジェクトに合わせて調整すること"
}
JSON
