#!/usr/bin/env bash
# 把 skills/* 和 external.txt 中启用的 skill 软链接到各 agent 的 skills 目录。
# 只管理指向本仓库的软链接：会清理本仓库中已失效/已禁用的链接，不会动其它文件。
# 用法：scripts/link.sh [--dry-run]
set -euo pipefail
cd "$(dirname "$0")/.."
repo=$(pwd -P)

dry=0
[[ ${1:-} == --dry-run ]] && dry=1
run() { if (( dry )); then echo "[dry-run] $*"; else "$@"; fi; }

targets=("$HOME/.claude/skills" "$HOME/.codex/skills")

sources=()
for d in skills/*/; do [[ -f $d/SKILL.md ]] && sources+=("${d%/}"); done
while IFS= read -r line; do
  line=${line%%#*}; line=$(echo "$line" | xargs)
  [[ -z $line ]] && continue
  if [[ ! -f $line/SKILL.md ]]; then
    echo "warn: $line/SKILL.md 不存在（未 init submodule 或上游已删除？），跳过" >&2
    continue
  fi
  sources+=("$line")
done < external.txt

# 检查重名
dups=$(for s in "${sources[@]}"; do basename "$s"; done | sort | uniq -d)
if [[ -n $dups ]]; then
  echo "error: 以下 skill 名重复，请在 external.txt 中只保留一个：" >&2
  echo "$dups" >&2
  exit 1
fi

for t in "${targets[@]}"; do
  run mkdir -p "$t"
  # 清理指向本仓库、但已不在启用列表中的链接
  for l in "$t"/*; do
    [[ -L $l ]] || continue
    dest=$(readlink "$l")
    [[ $dest == "$repo"/* ]] || continue
    keep=0
    for s in "${sources[@]}"; do [[ $dest == "$repo/$s" ]] && keep=1 && break; done
    (( keep )) || { echo "unlink $l"; run rm "$l"; }
  done
  for s in "${sources[@]}"; do
    name=$(basename "$s")
    link="$t/$name"
    if [[ -e $link && ! -L $link ]]; then
      echo "warn: $link 已存在且不是软链接，跳过" >&2
      continue
    fi
    if [[ -L $link && $(readlink "$link") == "$repo/$s" ]]; then
      continue
    fi
    echo "link $link -> $s"
    run ln -sfn "$repo/$s" "$link"
  done
done
