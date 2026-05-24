---
name: design-check
description: 画面（src/app/** / src/components/classly/**）変更後にデザインシステム規約（カラートークン・禁止用語・絵文字・gradient・stories）を自動スキャンでチェックする。
when_to_use: 画面ファイル（src/app/**/*.tsx / src/components/classly/**/*.tsx）を追加・変更したとき。Stop フックが自動発火する。
allowed-tools: Bash(grep *) Bash(git diff*) Read
---

# design-check スキル

## ステップ 1 — 自動スキャン

```bash
# 1-1. ハードコード色が TSX に残っていないか
grep -rn '#[0-9a-fA-F]\{3,6\}' src/app src/components/classly \
  --include='*.tsx' --include='*.ts' \
  | grep -v '\.stories\.' | grep -v '\.test\.' \
  || echo "OK: ハードコード色なし"

# 1-2. 禁止用語スキャン
grep -rn 'スケジュール\|ソルバ\|最適化\|アンケート\|サインアップ' \
  src/app src/components/classly --include='*.tsx' --include='*.ts' \
  || echo "OK: 禁止用語なし"

# 1-3. 絵文字スキャン
grep -Prn '[\x{1F000}-\x{1FFFF}\x{2600}-\x{27BF}]' \
  src/app src/components/classly --include='*.tsx' --include='*.ts' \
  || echo "OK: 絵文字なし"

# 1-4. gradient が使われていないか
grep -rn 'gradient\|bg-gradient' \
  src/app src/components/classly --include='*.tsx' --include='*.ts' \
  || echo "OK: gradient なし"

# 1-5. 新規コンポーネントに .stories.tsx が存在するか確認
for f in $(git diff --name-only HEAD | grep 'src/components/classly/.*\.tsx$' \
           | grep -v '\.stories\.\|\.test\.'); do
  dir=$(dirname "$f")
  base=$(basename "$f" .tsx)
  if [ ! -f "$dir/$base.stories.tsx" ]; then
    echo "MISSING stories: $dir/$base.stories.tsx"
  fi
done
echo "stories チェック完了"
```

## ステップ 2 — 目視チェックリスト

- [ ] 色はすべて `var(--token-name)` 形式
- [ ] グラデーション無し
- [ ] classly 固有コンポーネントに `.stories.tsx` がある
- [ ] 絵文字ゼロ
- [ ] 禁止用語なし

## 問題があった場合

| 問題 | 対処 |
|------|------|
| `#hex` が検出された | `var(--token-name)` に置換 |
| 禁止用語が検出された | 代替表記に置き換え |
| stories が存在しない | `/new-component` スキルでスキャフォールド |
