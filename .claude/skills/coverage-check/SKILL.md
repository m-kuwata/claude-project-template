---
name: coverage-check
description: テストカバレッジが 80% 以上を維持しているか確認・修復する。カバレッジレポートを読み、未カバーの重要パスにテストを追加する。
disable-model-invocation: true
allowed-tools: Bash(npm run test:coverage*) Bash(npx vitest run --coverage*) Read Write
---

# coverage-check スキル

## カバレッジ閾値

| 対象 | Statements | Branches | Functions | Lines |
|---|---|---|---|---|
| 全体 | **80%** | **80%** | **80%** | **80%** |

## 確認手順

```bash
npm run test:coverage
```

## 完了条件

- [ ] `npm run test:coverage` が全指標 80% 以上で通過
- [ ] 追加したテストが RED→GREEN を経由している
