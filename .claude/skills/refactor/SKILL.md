---
name: refactor
description: リファクタゲート。変更差分の重複・dead code・肥大化・既存資産の再発明をスキャンし、テストを保ったまま整理する。実装ファイル変更後に Stop フックで通過必須。
when_to_use: 実装ファイル（.ts/.tsx/.py）を変更した後、コミット前。重複コード・未使用コード・肥大化した関数・既存コンポーネント/ユーティリティの再発明が紛れていないかを確認するとき。
allowed-tools: Bash(git diff*) Bash(npm run lint*) Bash(npx tsc*) Bash(grep *) Bash(rg *) Bash(find *) Bash(npm run test*) Bash(npx vitest*) Read Edit
---

# refactor スキル

> **使うタイミング**: 実装ファイル変更後・コミット前。
> Stop フック（`auto-refactor-check.sh`）が `/tmp/${PROJECT_NAME}-needs-refactor` フラグで自動要求する。
> 「動くが後で直したい」コードが debt として溜まるのを **その場で** 食い止めるためのゲート。

TDD の **REFACTOR フェーズ** を強制する位置づけ。RED→GREEN で動かしたコードを、
テストを緑に保ったまま整理してからコミットする。

> **このファイルの調整方法**: ディレクトリ構成（`src/lib` / `src/features` /
> `src/components`）やテスト・Lint コマンドはプロジェクトに合わせて差し替えること。
> Python など別言語を扱う場合は専用ステップを追記する。

## ステップ 1 — 変更差分を把握する

```bash
git diff --stat
git diff            # 追加・変更行を確認
```

レビュー対象は **今回の差分で追加・変更した行** に絞る。既存コードの全面リファクタは
別 issue（`refactor/N-slug`）に切り出すこと。差分外の整理に着手しない。

## ステップ 2 — 重複コードの検出

同じロジック・JSX・条件分岐が差分内 or 既存コードと重複していないか確認する。

```bash
# 差分で追加した特徴的な式・文字列が既存にも無いか探す
grep -rn "<特徴的な式やリテラル>" src/

# 似た関数名・コンポーネント名が既にないか
grep -rn "function <名前>\|const <名前>\|export" src/lib src/features src/components
```

- [ ] 3 回以上繰り返すロジックは関数 / hook / 定数に抽出した
- [ ] コピペした条件分岐・バリデーションを共通化した
- [ ] マジックナンバー・繰り返すリテラルを定数化した

## ステップ 3 — 既存資産の再発明チェック（再利用）

新規に書いたコンポーネント・ユーティリティが、既存の資産で代替できないか確認する。

```bash
# 既存コンポーネント一覧
find src/components -name '*.tsx' | sort

# 既存ユーティリティ・hook
find src/lib src/features -name '*.ts' | sort
```

- [ ] 新規コンポーネントは既存と機能重複していない（重複なら既存を拡張）
- [ ] `cn()` などの共通ユーティリティを再実装していない
- [ ] UI ライブラリのプリミティブで足りるものを自作していない
- [ ] 既存 hook で賄える状態管理を新規に書いていない

## ステップ 4 — dead code の除去

```bash
npm run lint        # 未使用 import / 変数を検出
npx tsc --noEmit    # 到達不能・未使用エクスポートの手掛かり
```

- [ ] 未使用の import / 変数 / 関数 / 型を削除した
- [ ] コメントアウトされた旧コードを残していない
- [ ] 使われなくなった props / 引数を削除した
- [ ] デバッグ用 `console.log` を残していない

## ステップ 5 — 複雑度・肥大化

- [ ] 1 関数が 1 つの責務に収まっている（長大な関数は分割した）
- [ ] ネストが深い分岐を早期 return / ガード節で平坦化した
- [ ] 200 行を超えるコンポーネントは hook / 子コンポーネントに分割を検討した
- [ ] 命名が意図を表している（`data` / `tmp` / `flag` のような曖昧名を避けた）

## ステップ 6 — テストを保つ

リファクタ後、**テストが緑のまま**であることを必ず確認する。

```bash
npm run test:run
```

- [ ] リファクタ前後でテストが緑（壊していない）
- [ ] 抽出した関数 / hook に対応するテストを追加した

## ステップ 7 — 指摘の扱い

検出した改善点は次のいずれかで処理する。

1. **その場で直す** — 差分内の小さな重複・dead code・抽出は即修正する（推奨）
2. **意図的に見送る** — 差分が大きくなる／別責務の場合は `/issue-pm capture` で
   `refactor/N-slug` issue を起票してから見送る（debt を記録に残す）

「後で」を口頭で済ませず、**直すか issue 化するかの二択**で必ず決着させること。

## ステップ 8 — レビュー完了を記録（必須）

全ステップ通過後、Stop フック（`auto-refactor-check.sh`）のブロックを解除する。

```bash
bash $CLAUDE_PROJECT_DIR/.claude/hooks/mark-review-passed.sh refactor
```

`touch /tmp/${PROJECT_NAME}-refactor-passed` は deny リストで禁止されています。
このスクリプトを経由することで、Stop フックがスキルを正規に実行したことを検証できます。

通過していない項目・未処理の指摘が残っている場合はマーカーを置かないこと。

## 他レビューとの使い分け

| | `/refactor` | `/project-review` | `/review` |
|---|---|---|---|
| タイミング | コミット前 | コミット前 | PR 作成前 |
| 内容 | 重複・dead code・再利用・複雑度 | 規約違反チェックリスト | アーキテクチャ |
