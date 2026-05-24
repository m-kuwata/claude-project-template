---
name: issue-progress
description: GitHub Projects を使った issue 進捗管理スキル。ボード表示・ステータス更新・マイルストーン進捗・ issue の自動同期を行う。
disable-model-invocation: true
argument-hint: "[board | sync N | update N <ステータス> | milestone | setup]"
allowed-tools: Bash(gh *) Bash(git *)
---

# issue-progress スキル

> **前提**: `gh auth status` でログイン済みであること。

## `update N <ステータス>` — ステータスを更新

有効なステータス: `未着手` / `作業中` / `レビュー中` / `完了`

```bash
CACHE=.claude/skills/issue-progress/project-cache.json
OWNER=$(jq -r .owner "$CACHE")
PROJECT_NUM=$(jq -r .projectNumber "$CACHE")
PROJECT_ID=$(jq -r .projectId "$CACHE")
FIELD_ID=$(jq -r .statusFieldId "$CACHE")
OPTION_ID=$(jq -r --arg s "$STATUS" '.statusOptions[$s]' "$CACHE")

ITEM_ID=$(gh project item-list "$PROJECT_NUM" --owner "$OWNER" --format json \
  | jq -r ".items[] | select(.content.number == $ISSUE_NUM) | .id")

gh project item-edit \
  --id "$ITEM_ID" \
  --project-id "$PROJECT_ID" \
  --field-id "$FIELD_ID" \
  --single-select-option-id "$OPTION_ID"
```

## `setup` — `project-cache.json` を再生成する

Projects の Status フィールドを作り直したときに実行。

```bash
OWNER=<owner>
PROJECT_NUM=<number>
CACHE=.claude/skills/issue-progress/project-cache.json

PROJECT_ID=$(gh project list --owner "$OWNER" --format json \
  | jq -r ".projects[] | select(.number==$PROJECT_NUM) | .id")
STATUS=$(gh project field-list "$PROJECT_NUM" --owner "$OWNER" --format json \
  | jq '.fields[] | select(.name=="Status")')
FIELD_ID=$(echo "$STATUS" | jq -r .id)

jq -n \
  --arg owner "$OWNER" --argjson num "$PROJECT_NUM" \
  --arg pid "$PROJECT_ID" --arg fid "$FIELD_ID" \
  --argjson opts "$(echo "$STATUS" | jq '[.options[] | {(.name): .id}] | add')" \
  '{_comment:"GitHub Projects v2 の解決済み ID キャッシュ。`/issue-progress setup` で再生成する。",
    owner:$owner, projectNumber:$num, projectId:$pid,
    statusFieldId:$fid, statusOptions:$opts}' > "$CACHE"

cat "$CACHE"
```

## GitHub Actions での自動化

`.github/workflows/project-sync.yml` が PR イベントに連動してステータスを自動更新する。

| イベント | 自動アクション |
|---|---|
| issue オープン | プロジェクトに追加（未着手） |
| draft PR オープン | `Closes #N` → 「作業中」 |
| PR オープン（非 draft） | `Closes #N` → 「レビュー中」 |
| PR マージ | `Closes #N` → 「完了」 |
