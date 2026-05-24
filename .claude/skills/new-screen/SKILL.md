---
name: new-screen
description: 新規画面（App Router ページ）を正しいレイアウト構成でスキャフォールドする。
when_to_use: 新しい画面やページを追加するとき、App Router のルートを新規作成するとき。
argument-hint: "[ScreenName] [/route]"
disable-model-invocation: true
allowed-tools: Write Read Bash(find src/app *)
---

# new-screen スキル

`src/app/<route>/page.tsx` と必要なレイアウトを生成する。

## AppShell レイアウト

```tsx
// src/app/(app)/layout.tsx
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="grid grid-cols-[240px_1fr] grid-rows-[56px_1fr] h-screen">
      <Sidebar />
      <Topbar />
      <main className="col-start-2 row-start-2 overflow-auto bg-gray-50 p-8">
        {children}
      </main>
    </div>
  );
}
```

## コンテンツ幅ルール

- 設定・フォーム系: `max-w-settings` (720px)
- リスト系: `max-w-list` (1080px)
- エディタ: 流体

## 生成ファイル

```
src/app/<route>/
├── page.tsx
├── loading.tsx     Skeleton（必須）
├── error.tsx       エラー境界（必須）
└── page.test.tsx   統合テスト
```

## チェックリスト

- [ ] `max-w-*` を画面種別に合わせて設定
- [ ] 空状態: `EmptyState` コンポーネントで次の一歩を示す
- [ ] `loading.tsx` / Skeleton を用意
- [ ] 個人情報を扱う画面: `PrivacyNotice` を表示
- [ ] テストを先に書いた（TDD）
