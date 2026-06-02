#!/bin/bash
# mark-review-passed.sh: スキルを正規に完了したことを示すマーカーを書く。
# 直接 touch /tmp/*-passed するのではなくこのスクリプトを経由することで、
# Stop フックがスキップを検知できるようにする。
# Usage: bash .claude/hooks/mark-review-passed.sh <review-name>
# PROJECT_NAME は settings.json の env セクションで設定する。

PROJECT_NAME="${PROJECT_NAME:-myapp}"
REVIEW="$1"

case "$REVIEW" in
  project-review|qa-review|po-review|design-check|refactor)
    echo "REVIEWED:$(date -Iseconds)" > "/tmp/${PROJECT_NAME}-${REVIEW}-passed"
    echo "✓ ${REVIEW} 完了マーカーを記録しました"
    ;;
  *)
    echo "エラー: 不明なレビュー名 '$REVIEW'" >&2
    echo "有効な値: project-review, qa-review, po-review, design-check, refactor" >&2
    exit 1
    ;;
esac
