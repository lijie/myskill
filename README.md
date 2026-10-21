# myskill

agent skill 的容器仓库：收集自己写的和外部作者的 skill，按需安装到具体工程。仓库本身不使用这些 skill。

## 结构

```
skills/        自己写的 skill
external/      外部 skill 仓库（git submodule），目录名为 owner__repo
scripts/
  skill               列出 / 安装 / 同步 skill 到工程
  add-external.sh     添加外部仓库
  update-external.sh  拉取外部仓库更新并显示变化
```

## 准备

```bash
git clone --recursive <this-repo> ~/p/myskill
# 可选：alias skill=~/p/myskill/scripts/skill
```

## 安装 skill 到工程

```bash
skill list [pattern]                                  # 查看可用 skill
skill install ~/work/app tdd grill-me                 # 按名字安装到 .claude/skills
skill install ~/work/app tdd --agent claude,codex     # 同时装到 .agents/skills（Codex）
skill install ~/work/app external/mattpocock__skills/skills/engineering   # 安装目录下全部
skill install ~/work/app tdd --link                   # 软链接而非复制（随容器实时更新，但工程依赖本机容器路径）
skill uninstall ~/work/app tdd
```

默认是复制，工程可以把 skill 提交进自己的仓库。重名时用路径指定。
安装记录在工程的 `<skills-dir>/.myskill.lock`（来源路径、commit、内容校验和）。

## 跟踪更新

```bash
scripts/update-external.sh                 # 1. 把外部仓库拉到最新，查看新增提交
git add external && git commit -m "bump external skills"

skill status ~/work/app                    # 2. 查看工程中各 skill 的状态
skill update ~/work/app [skill...]         # 3. 把 outdated 的副本同步到容器当前版本
```

`status` 状态：`ok` 与源一致；`outdated` 源有更新；`modified` 工程里改过；`conflict` 两边都改过；
`linked` 软链接；`missing` 被删除；`source-missing` 源已不存在。
有本地修改（`modified`/`conflict`）的副本，`update`/`uninstall` 默认跳过，加 `--force` 覆盖。

## 添加外部仓库

```bash
scripts/add-external.sh https://github.com/owner/repo [branch]
```

## 外部仓库

| 仓库 | 说明 |
| --- | --- |
| [mattpocock/skills](https://github.com/mattpocock/skills) | 工程/生产力 skill；`in-progress/` 下为未完成的 |
