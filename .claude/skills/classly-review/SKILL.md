---
name: classly-review
description: classly プロジェクト固有のコードレビュー。TDD 準拠・デザインシステム・コピー・セキュリティ・Cloudflare 互換をコミット前にチェックする。
when_to_use: コミット前・PR 作成前に規約違反（TDD・デザイン・コピー・セキュリティ・Cloudflare 互換）をチェックするとき。
allowed-tools: Bash(npm run test*) Bash(npx tsc*) Bash(npm run lint*) Bash(git diff*) Bash(uv run *) Read
---

# classly-review スキル

> **使うタイミング**: コミット前・PR 作成前。
> 公式 `/review`（PR 全体のアーキテクチャレビュー）とは役割が異なる。

## ステップ 1 — 自動チェック（TypeScript）

```bash
npm run test:run       # テスト全通過
npm run test:coverage  # カバレッジ 80% 以上
npx tsc --noEmit      # 型エラーなし
npm run lint          # Lint クリーン
```

## ステップ 1b — 自動チェック（Python solver-api）

`apps/solver-api/` 配下のファイルを変更した場合のみ実行:

```bash
cd apps/solver-api
uv run ruff check .                              # Lint クリーン
uv run pytest --cov --cov-report=term-missing   # テスト全通過・カバレッジ 90% 以上
```

## ステップ 2 — TDD 準拠

- [ ] 変更した `.tsx`/`.ts` に `.test.tsx`/`.test.ts` が存在する
- [ ] `src/lib/solver/` の変更はカバレッジ **90%** 以上を維持
- [ ] `it()` の説明が **日本語・ユーザー視点**

## ステップ 3 — デザインシステム

- [ ] 新規 `classly/` コンポーネントに `.stories.tsx` が存在する
- [ ] `shadcn/ui/` を直接編集していない
- [ ] 色はトークン指定（生の `#1f857d` をハードコードしていない）
- [ ] グラデーションなし / 角丸 `rounded-md` 基本
- [ ] アイコンは `lucide-react` のみ（絵文字禁止）

## ステップ 4 — コピー

- [ ] 絵文字ゼロ（コード・UI・コメント全体）
- [ ] 教員表記が「A 先生」形式（「教員 A」禁止）
- [ ] 禁止用語なし: スケジュール / ソルバ / 最適化 / アンケート / サインアップ

## ステップ 5 — セキュリティ・PII

- [ ] 個人情報（氏名・児童情報）を扱う実装なし
- [ ] `process.env.*` がクライアント側で露出していない
- [ ] Supabase クエリは RLS 前提
- [ ] API ルートに認証チェックあり

## ステップ 6 — Cloudflare 互換

- [ ] `fs` / `path` / `child_process` など Node.js 専用 API を使っていない
- [ ] ソルバが Edge Function 30s タイムアウト内に収まる見込み

## ステップ 7 — レビュー完了を記録（必須）

全ステップ通過後、Stop フックのブロックを解除するためにマーカーを置く。

```bash
touch /tmp/classly-review-passed
```
