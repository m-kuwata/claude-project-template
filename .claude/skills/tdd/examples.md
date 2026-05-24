# TDD コード例

## コンポーネントテスト（RTL）

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, vi } from "vitest";
import { ConstraintRow } from "./ConstraintRow";

describe("ConstraintRow", () => {
  const defaultProps = {
    teacher: "A",
    day: "月",
    period: 1,
    priority: "must" as const,
  };

  it("教員名を「A 先生」形式で表示する", () => {
    render(<ConstraintRow {...defaultProps} />);
    expect(screen.getByText("A 先生")).toBeInTheDocument();
  });

  it("優先度「必須」のバッジが赤色で表示される", () => {
    render(<ConstraintRow {...defaultProps} priority="must" />);
    const badge = screen.getByRole("status", { name: /必須/i });
    expect(badge).toHaveClass("badge-must");
  });

  it("削除ボタンを押すと onDelete が呼ばれる", async () => {
    const onDelete = vi.fn();
    const user = userEvent.setup();
    render(<ConstraintRow {...defaultProps} onDelete={onDelete} />);
    await user.click(screen.getByRole("button", { name: /削除/i }));
    expect(onDelete).toHaveBeenCalledOnce();
  });
});
```

## MSW での API モック（Integration）

```ts
import { http, HttpResponse } from "msw";
import { setupServer } from "msw/node";

const server = setupServer(
  http.post("/api/generate", () =>
    HttpResponse.json({ status: "solved", schedule: mockSchedule })
  ),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

it("自動生成 API が solved を返す", async () => {
  const result = await generateSchedule(input);
  expect(result.status).toBe("solved");
});
```
