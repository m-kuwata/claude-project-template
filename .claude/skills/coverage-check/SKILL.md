---
name: coverage-check
description: テストカバレッジが 80% 以上を維持しているか確認・修復する。カバレッジレポートを読み、未カバーの重要パスにテストを追加する。Python solver-api は pytest --cov で 90% 以上。
disable-model-invocation: true
allowed-tools: Bash(npm run test:coverage*) Bash(npx vitest run --coverage*) Bash(uv run *) Read Write
---

# coverage-check スキル

## カバレッジ閾値

| 対象 | Statements | Branches | Functions | Lines |
|---|---|---|---|---|
| 全体 | **80%** | **80%** | **80%** | **80%** |
| `src/lib/solver/` | **90%** | **90%** | **90%** | **90%** |
| `apps/solver-api/solver/` | — | — | — | **90%** |

## 確認手順

```bash
# TypeScript
npm run test:coverage

# Python
cd apps/solver-api
uv run pytest --cov --cov-report=term-missing
```

## 完了条件

- [ ] `npm run test:coverage` が全指標 80% 以上で通過
- [ ] `src/lib/solver/` が 90% 以上
- [ ] `apps/solver-api/` で `uv run pytest --cov` が 90% 以上
- [ ] 追加したテストが RED→GREEN を経由している
