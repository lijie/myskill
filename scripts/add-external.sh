#!/usr/bin/env bash
# 添加外部 skill 仓库为 submodule：scripts/add-external.sh <git-url> [branch]
set -euo pipefail
cd "$(dirname "$0")/.."

url=${1:?usage: $0 <git-url> [branch]}
branch=${2:-}

# https://github.com/owner/repo(.git) 或 git@github.com:owner/repo.git -> owner__repo
slug=$(printf '%s' "$url" | sed -E 's#\.git$##; s#/$##; s#.*[:/]([^/]+)/([^/]+)$#\1__\2#')
dest="external/$slug"

if [[ -n $branch ]]; then
  git submodule add -b "$branch" "$url" "$dest"
else
  git submodule add "$url" "$dest"
  branch=$(git -C "$dest" branch --show-current)
  git config -f .gitmodules "submodule.$dest.branch" "$branch"
fi

echo
echo "已添加 $dest（跟踪分支 $branch）。其中的 skill："
(cd "$dest" && find . -name SKILL.md -not -path './.git/*' -exec dirname {} \; | sed "s#^\.#$dest#" | sort)
echo
echo "把要启用的路径加入 external.txt，然后运行 scripts/link.sh"
