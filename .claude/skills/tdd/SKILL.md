---
name: tdd
description: classly の TDD ワークフロースキル。新機能・バグ修正・リファクタ時に Red→Green→Refactor サイクルを守る。Vitest + RTL + Playwright + MSW を使う。Python ソルバー（apps/solver-api/）は pytest + ruff を使う。
when_to_use: 新機能を実装するとき、バグを修正するとき、コンポーネントを新規作成するとき、テストを書くとき、リファクタリングするとき。
allowed-tools: Write Read Bash(npm run test*) Bash(npx vitest*) Bash(uv run *)
---

# TDD スキル

## テストスタック

| 層 | ツール | 対象 |
|---|---|---|
| Unit | Vitest | 純粋関数・ソルバ（TS）・ユーティリティ |
| Component | Vitest + RTL | React コンポーネント |
| Integration | Vitest + MSW | API / Supabase クライアント |
| E2E | Playwright | ユーザーフロー全体 |
| Python Unit | pytest + pytest-cov | `apps/solver-api/solver/`（カバレッジ **90% 以上**） |
| Python Lint | ruff | `apps/solver-api/` 全体 |

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
├── components/classly/<Name>/
│   ├── <Name>.tsx
│   ├── <Name>.test.tsx      ← RTL テスト
│   └── <Name>.stories.tsx
├── lib/solver/
│   ├── backtrack.ts
│   └── backtrack.test.ts    ← ソルバは 90% 以上必須
└── lib/utils/
    └── schedule.test.ts
```

## テスト記述のルール

- `describe` / `it` は **日本語・ユーザー視点**
  - ✅ `it("A 先生の制約が削除される")`
  - ❌ `it("should call onDelete handler")`
- Arrange / Act / Assert パターンで書く

コード例は [examples.md](examples.md) を参照。

## テスト実行

### TypeScript

```bash
npm run test            # watch
npm run test:run        # CI（1回）
npm run test:coverage   # カバレッジ（80% 以上必須）
npm run test:e2e        # Playwright
```

### Python（apps/solver-api/ を変更した場合）

```bash
cd apps/solver-api
uv run ruff check .                            # Lint
uv run pytest --cov --cov-report=term-missing  # テスト + カバレッジ（90% 以上必須）
```

## チェックリスト

着手前:
- [ ] テストファイルを先に作る（`.test.ts` or `tests/test_*.py`）
- [ ] `it()` / `def test_*` の説明を日本語で書く
- [ ] RED を確認してからコードを書く

完了（TypeScript）:
- [ ] `npm run test:coverage` が 80% 以上（TS ソルバは 90%）
- [ ] E2E が関連フローをカバー
- [ ] Storybook ストーリーも更新済み

完了（Python solver-api）:
- [ ] `uv run ruff check .` がクリーン
- [ ] `uv run pytest --cov` が 90% 以上
