# myskill

日常使用的 agent skills 汇总仓库。

## 结构

```
skills/            自己写的 skill，全部启用
external/          外部 skill 仓库（git submodule），目录名为 owner__repo
external.txt       从外部仓库中挑选启用的 skill 路径
scripts/
  add-external.sh     添加外部仓库
  update-external.sh  拉取外部仓库更新并显示变化
  link.sh             把启用的 skill 软链接到 ~/.claude/skills 和 ~/.codex/skills
```

## 用法

```bash
# 新机器
git clone --recursive <this-repo> && cd myskill && scripts/link.sh

# 添加外部仓库，然后把要启用的路径加入 external.txt
scripts/add-external.sh https://github.com/owner/repo [branch]
scripts/link.sh

# 跟踪外部更新：拉取到各 submodule 跟踪分支的最新提交，确认后提交指针
scripts/update-external.sh
git add external && git commit -m "bump external skills"

# 启用/禁用外部 skill：编辑 external.txt 后
scripts/link.sh            # 加 --dry-run 只预览
```

`link.sh` 只管理指向本仓库的软链接，不会覆盖目标目录里的其它文件；skill 重名时会报错。

## 外部仓库

| 仓库 | 说明 |
| --- | --- |
| [mattpocock/skills](https://github.com/mattpocock/skills) | 工程/生产力 skill；`in-progress/` 下的默认不启用 |
