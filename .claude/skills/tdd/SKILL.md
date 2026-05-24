---
name: tdd
description: TDD ワークフロースキル。新機能・バグ修正・リファクタ時に Red→Green→Refactor サイクルを守る。Vitest + RTL + Playwright + MSW を使う。
when_to_use: 新機能を実装するとき、バグを修正するとき、コンポーネントを新規作成するとき、テストを書くとき、リファクタリングするとき。
allowed-tools: Write Read Bash(npm run test*) Bash(npx vitest*)
---

# TDD スキル

## テストスタック

| 層 | ツール | 対象 |
|---|---|---|
| Unit | Vitest | 純粋関数・ユーティリティ |
| Component | Vitest + RTL | React コンポーネント |
| Integration | Vitest + MSW | API クライアント |
| E2E | Playwright | ユーザーフロー全体 |

## Red → Green → Refactor

```
1. RED    テストを先に書く（実装なしで失敗させる）
2. GREEN  最小限のコードでテストを通す
3. REFACTOR テストを保ちながら整理する
```

**必ず RED から始める。後付けテスト禁止。**

## テストファイルの配置

```
src/
├── components/<Name>/
│   ├── <Name>.tsx
│   ├── <Name>.test.tsx      ← RTL テスト
│   └── <Name>.stories.tsx
└── lib/
    └── utils.test.ts
```

## テスト記述のルール

- `describe` / `it` は **日本語・ユーザー視点**
  - ✅ `it("削除ボタンを押すと確認ダイアログが表示される")`
  - ❌ `it("should call onDelete handler")`
- Arrange / Act / Assert パターンで書く

コード例は [examples.md](examples.md) を参照。

## テスト実行

```bash
npm run test            # watch
npm run test:run        # CI（1回）
npm run test:coverage   # カバレッジ（80% 以上必須）
npm run test:e2e        # Playwright
```

## チェックリスト

着手前:
- [ ] テストファイルを先に作る（`.test.ts`）
- [ ] `it()` の説明を日本語・ユーザー視点で書く
- [ ] RED を確認してからコードを書く

完了:
- [ ] `npm run test:coverage` が 80% 以上
- [ ] E2E が関連フローをカバー
- [ ] Storybook ストーリーも更新済み
