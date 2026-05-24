---
name: config-audit
description: classly の Claude Code 設定ファイル群（CLAUDE.md・skills・hooks・settings.json）の健全性を定期チェックする。設定ドリフトを検出し、修正案を提示する。
disable-model-invocation: true
allowed-tools: Bash(bash scripts/config-audit.sh) Bash(git *) Read
---

# config-audit スキル

> **使うタイミング**: スキル追加・フック変更後、または月次の定期チェック時。

## 実行

```bash
bash scripts/config-audit.sh
```

終了コード:
- `1` — FATAL あり（フック実行不可/シバンなし、settings.json 不正、jq 未導入、スキルに name/description なし）
- `0` — FATAL なし（WARN / INFO は表示のみ）

## チェック内容

| # | 内容 | 重大度 |
|---|---|---|
| 0 | jq 等の前提ツール | FATAL |
| 1 | 全スキルに name / description、自動呼び出し設定 | FATAL / WARN |
| 2 | フックが実行可能・シバンありセjq 整合 | FATAL |
| 3 | settings.json が valid・deny あり・必須フック登録 | FATAL / WARN |
| 4 | settings.local.json に一時ファイル操作の残鼸なし | WARN |
| 5 | CLAUDE.md 200 行以内・スキルテーブル整合 | WARN |

## 問題があった場合の修正手順

| 問題 | 修正コマンド |
|---|---|
| フックに実行権限なし | `chmod +x .claude/hooks/*.sh` |
| jq 未インストール | `sudo apt-get install -y jq` |
| settings.json 不正 | `jq . .claude/settings.json` でエラー箇所を特定 |
| frontmatter 不足 | `when_to_use:` か `disable-model-invocation: true` を追加 |

## 完了条件

- [ ] `bash scripts/config-audit.sh` が FATAL=0（終了コード 0）
- [ ] WARN は内容を確認し、許容するか修正する
