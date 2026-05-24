---
name: new-component
description: classly の新規コンポーネントをスキャフォールドする。コンポーネント本体・テスト・Storybook ストーリーを同時生成する。
when_to_use: 新しい UI コンポーネントを作成するとき、classly/ 配下に新しいコンポーネントを追加するとき。
argument-hint: "[ComponentName]"
disable-model-invocation: true
allowed-tools: Write Read Bash(find src/components/classly *)
---

# new-component スキル

`src/components/classly/$ARGUMENTS/` に以下を生成する。

## 生成するファイル

```
src/components/classly/$ARGUMENTS/
├── $ARGUMENTS.tsx
├── $ARGUMENTS.test.tsx     Vitest + RTL（TDD: テストを先に書く）
└── $ARGUMENTS.stories.tsx  Storybook ストーリー
```

## 手順（TDD 順守）

1. **テストファイルを先に作る**（RED）
2. コンポーネントを実装して通す（GREEN）
3. リファクタする

## $ARGUMENTS.test.tsx テンプレート

```tsx
import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import { $ARGUMENTS } from "./$ARGUMENTS";

describe("$ARGUMENTS", () => {
  it("デフォルト状態で正しくレンダリングされる", () => {
    render(<$ARGUMENTS />);
    // TODO: expect(screen.getBy...).toBeInTheDocument();
  });
});
```

## $ARGUMENTS.tsx テンプレート

```tsx
import { cn } from "@/lib/utils";

interface ${ARGUMENTS}Props {
  className?: string;
}

export function $ARGUMENTS({ className }: ${ARGUMENTS}Props) {
  return (
    <div className={cn("", className)}>
      {/* implementation */}
    </div>
  );
}
```

## $ARGUMENTS.stories.tsx テンプレート

```tsx
import type { Meta, StoryObj } from "@storybook/react";
import { $ARGUMENTS } from "./$ARGUMENTS";

const meta: Meta<typeof $ARGUMENTS> = {
  title: "classly/$ARGUMENTS",
  component: $ARGUMENTS,
  tags: ["autodocs"],
  parameters: { backgrounds: { default: "page" } },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};
```

## チェックリスト

- [ ] テストを先に書いた（RED → GREEN の順）
- [ ] デザイン規約準拠（`/classly-design` スキル参照）
- [ ] `cn()` で className マージ
- [ ] Lucide アイコン使用（絵文字禁止）
- [ ] `npm run test:coverage` でカバレッジ 80% 以上
