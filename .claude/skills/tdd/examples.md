# TDD コード例

## コンポーネントテスト（RTL）

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, it, expect, vi } from "vitest";
import { DeleteButton } from "./DeleteButton";

describe("DeleteButton", () => {
  it("削除ボタンが表示される", () => {
    render(<DeleteButton onDelete={vi.fn()} />);
    expect(screen.getByRole("button", { name: /削除/i })).toBeInTheDocument();
  });

  it("削除ボタンを押すと onDelete が呼ばれる", async () => {
    const onDelete = vi.fn();
    const user = userEvent.setup();
    render(<DeleteButton onDelete={onDelete} />);
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
  http.post("/api/submit", () =>
    HttpResponse.json({ status: "ok" })
  ),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

it("API が正常レスポンスを返す", async () => {
  const result = await submitData(input);
  expect(result.status).toBe("ok");
});
```
