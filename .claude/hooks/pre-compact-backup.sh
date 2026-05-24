#!/usr/bin/env bash
# PreCompact: コンテキスト圧縮前に重要な決定事項をファイルへバックアップする
set -uo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
backup_dir="$root/.claude/session-notes"
mkdir -p "$backup_dir"

note_file="$backup_dir/$(date +%Y%m%d-%H%M%S).md"

cat > "$note_file" <<EOF
# セッションノート ($(date '+%Y-%m-%d %H:%M'))

コンテキスト圧縮前の自動バックアップ。
直近の git log や未コミット差分を記録する。

## 直近コミット
$(git log --oneline -10 2>/dev/null || echo "(git log 取得不可)")

## 未コミット変更
$(git status --short 2>/dev/null || echo "(git status 取得不可)")
EOF

echo "セッションノートを保存しました: $note_file" >&2
exit 0
