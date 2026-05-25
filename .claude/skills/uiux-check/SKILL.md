---
name: uiux-check
description: UI/UX を Playwright で実画面ベースに検査する。主要画面を Desktop/Mobile で巡回し、Fold 内 CTA・エラー表示・確認ダイアログ a11y・コピーの規約違反を検出する。
when_to_use: UI 変更後の最終確認、PR 作成前の UX 観点レビュー、新画面追加時。
allowed-tools: Bash(npm run dev*) Bash(node scripts/*) Bash(npx playwright*) Bash(curl*) Bash(grep *) Bash(kill *) Read
---

# uiux-check スキル

## ステップ 1 — Dev サーバー起動

```bash
npm run dev > /tmp/dev.log 2>&1 &
echo $! > /tmp/uiux-dev.pid

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/ | grep -q 200; then
    echo "ready"; break
  fi
  sleep 1
done
```

## ステップ 2 — Playwright 巡回スクリプト実行

```bash
npx playwright install chromium 2>&1 | tail -3
node .claude/skills/uiux-check/scripts/tour.mjs
```

スクリーンショットは `/tmp/uiux-screenshots/` に保存される。

## ステップ 3 — Dev サーバー停止

```bash
if [ -f /tmp/uiux-dev.pid ]; then
  kill $(cat /tmp/uiux-dev.pid) 2>/dev/null
  rm /tmp/uiux-dev.pid
fi
```

## 検出ルール（自動 + 人間レビュー）

### 自動検出（tour.mjs）

1. **Fold 内 CTA**: 主要 CTA の bounding box が viewport 内に収まるか
2. **`prompt()` / `alert()` / `confirm()` の grep**: テストファイル以外で残っていないか
3. **`role="tab"` ↔ `role="tabpanel"` リンク**: `aria-controls` が設定されているか
4. **削除ボタン数 vs ConfirmDialog 使用箇所**: 大幅にずれていたら警告
5. **エラーバナーに技術文言**: `responded \d+` `Error:` が含まれないか

### 人間レビュー（スクリーンショット目視）

1. コピー整合性: LP・OG・タイトルがターゲット定義と一致するか
2. モバイル/デスクトップの差: 主要ナビ・ CTA がどちらでも到達可能か
3. ローディング状態: disabled + spinner が出ているか
4. エンプティ状態: 0 件時に次アクションへの導線があるか
5. アイコンのみのボタン: `aria-label` があるか
