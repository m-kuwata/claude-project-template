---
name: classly-design
description: classly のデザインシステムに準拠した UI を生成・実装するスキル。コンポーネント実装、画面スケルトン、デザイントークンの参照などすべての UI 作業でこのスキルを参照すること。
when_to_use: UI コンポーネントを実装するとき、React コンポーネントを新規作成するとき、画面レイアウトを組むとき、色・タイポ・スペーシングを決めるとき、デザイントークンを確認するとき。
---

# classly デザインスキル

classly のすべての UI 実装は **`src/design-system/README.md` のルールに従う**こと。

## 必ず確認すること

1. `src/design-system/README.md` — 実装規約（必読）
2. `src/design-system/tokens.css` — CSS 変数一覧
3. `src/design-system/tokens.ts` — TypeScript トークン

## クイックリファレンス

### カラー
- プライマリ: `teal-500 (#1f857d)` / ホバー: `teal-600`
- アクセント（CTA のみ）: `orange-400 (#f07f1d)` — 1 画面 2 箇所まで
- ページ背景: `bg-2 (#f7f8f9)` / カード: `bg-1 (#ffffff)`
- グラデーション禁止。ダークモード未対応。

### タイポグラフィ
- `font-sans` = Inter + BIZ UDPGothic
- 基準 16px。最小 12px。日本語 line-height 1.6 以上

### 角丸・影
- 標準 `rounded-md` (8px)。モーダルは `rounded-lg` (12px)
- 影は `shadow-1` (カード) 〜 `shadow-3` (モーダル)

### コンポーネント配置ルール
- shadcn `ui/` は直接編集しない
- classly 固有は `src/components/classly/<Name>/<Name>.tsx` に作成
- 必ず `.stories.tsx` と `.test.tsx` を同時作成（TDD + Storybook）

### コピー絶対ルール
- 日本語・です・ます調 / 絵文字ゼロ
- 「A 先生」「B 先生」（「教員 A」禁止）

### アイコン
`lucide-react` のみ。サイズ 20px / ストローク 1.5px
