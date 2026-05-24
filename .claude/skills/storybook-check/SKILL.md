---
name: storybook-check
description: コンポーネントの Storybook ストーリーカバレッジを確認・補完する。stories.tsx が欠けているコンポーネントを検出し、追加する。
disable-model-invocation: true
allowed-tools: Bash(find src/components *) Bash(npm run build:storybook *) Write Read
---

# storybook-check スキル

## 検出コマンド

```bash
find src/components -name "*.tsx" ! -name "*.stories.tsx" ! -name "*.test.tsx" 2>/dev/null | while read f; do
  dir=$(dirname "$f")
  name=$(basename "$f" .tsx)
  story="$dir/$name.stories.tsx"
  [ ! -f "$story" ] && echo "MISSING story: $story"
done
echo "--- scan complete ---"
```

## ストーリー品質基準

- [ ] `title: "<ComponentName>"` 形式（プロジェクトの命名規則に従う）
- [ ] `tags: ["autodocs"]` で自動ドキュメント有効化
- [ ] `Default` ストーリーが存在
- [ ] 全 variant（primary/secondary/accent/ghost 等）をカバー
- [ ] `disabled` 状態をカバー

## ビルド確認

```bash
npm run build:storybook -- --quiet
```
