#!/usr/bin/env bash
# 拉取所有外部仓库的最新提交，并列出每个仓库的新增 commit。确认后自行 git commit。
set -euo pipefail
cd "$(dirname "$0")/.."

status() { git submodule status | sed 's/^[-+ U]//' | awk '{print $1, $2}'; }

git submodule update --init
before=$(status)
git submodule update --remote

changed=0
while read -r sha path; do
  old=$(echo "$before" | awk -v p="$path" '$2 == p {print $1}')
  [[ $old == "$sha" ]] && continue
  changed=1
  echo "== $path  ${old:0:7} -> ${sha:0:7}"
  git -C "$path" log --oneline --no-decorate "$old..$sha"
  # 提示新增/删除的 skill
  git -C "$path" diff --name-status "$old" "$sha" -- '*SKILL.md' | grep -E '^[AD]' | sed 's/^/   skill /' || true
  echo
done < <(status)

if (( changed )); then
  echo "确认无误后：git add external && git commit -m 'bump external skills'"
  echo "已安装到工程的 skill 用 scripts/skill status/update <project> 同步"
else
  echo "外部仓库均已是最新。"
fi
