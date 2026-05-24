#!/bin/bash
# Stop hook: AppShell / layout ファイルが変更されたらスクリーンショット確認を要求する
# set-screenshot-flag.sh がフラグを立て、このフックが検出して Claude に指示を注入する

if [ ! -f /tmp/classly-needs-screenshot-check ]; then
  exit 0
fi

rm /tmp/classly-needs-screenshot-check

cat <<'JSON'
{
  "decision": "block",
  "reason": "AppShell またはレイアウトファイルが変更されました。Playwright でスクリーンショットを撑影して目視確認してください。\n\n手順:\n1. dev サーバーを起動（例: npx next dev --port 3001）\n2. Playwright で以下の4パターンを撑影して /tmp/screenshots/ に保存:\n   - mobile (375×812): /templates\n   - mobile-drawer (375×812): ハンバーガーボタンをクリックしてからドロワーを撑影\n   - tablet (768×1024): /templates\n   - desktop (1280×800): /templates\n3. Read ツールで各画像を読み込み、以下を確認:\n   - モバイル・タブレット: サイドバー非表示、ハンバーガー（≡）表示、コンテンツ全幅\n   - デスクトップ: 240px サイドバー表示\n4. レイアウト崩れや意図しない変化があれば修正してから再チェック\n5. 問題なければ SendUserFile で4枚をユーザーに送信して確認を求める"
}
JSON
