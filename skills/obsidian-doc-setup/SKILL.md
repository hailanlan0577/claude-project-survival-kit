---
name: obsidian-doc-setup
description: 给一个 Obsidian 目录"一键整理"：建 README 索引、给废弃文档加警告、补 frontmatter、移废弃到 archive/。类似 setup-kit 但针对 Obsidian 文档目录。触发词：整理 obsidian 目录 / 一键整理文档 / obsidian doc setup / 给 xx 目录建秩序 / obsidian-doc-setup。
user-invocable: true
---

# Obsidian 目录一键整理

> 类似 `/setup-kit` 但针对 Obsidian 文档目录。
>
> **先 `/obsidian-doc-audit` 看体检报告**，再用这个 skill 按报告自动整理。

## 触发时机

- 用户打 `/obsidian-doc-setup`
- 用户说"整理我的 XX Obsidian 目录"
- 用户说"按标准给这目录建秩序"

## 执行步骤

### 第 0 步：先让用户看 audit 报告

如果用户没跑过 audit：
```
建议先跑一次 /obsidian-doc-audit 看当前状态，再整理。
已经跑过了吗？跑过继续；没跑过我可以先跑一下给你看报告。
```

### 第 1 步：问用户要整理哪个目录 + 整理到什么程度

```
我来给 Obsidian 目录一键整理。你想到什么程度？

1. Obsidian 目录路径？
   （相对 vault 根，如 "二奢软件"）

2. 整理强度？
   a. 最小侵入（只建 README 和 archive 目录，不动文件）
   b. 中等（加废弃警告 + 补 frontmatter + 移废弃到 archive/）
   c. 激进（全套：上面 + 长文档拆分 + 重命名不规范的）

3. 保留原文件的备份？（默认：是，copy 到 archive/backup-YYYYMMDD/）
```

### 第 2 步：备份（默认开启）

```bash
BACKUP_DIR="$TARGET_DIR/archive/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$TARGET_DIR"/*.md "$BACKUP_DIR/"
echo "✅ 备份到 $BACKUP_DIR"
```

### 第 3 步：执行整理任务（按强度）

#### 任务 A：建 README.md（所有强度都做）

扫描目录所有 `.md` 文件，根据 frontmatter 或内容猜测类型，生成：

```markdown
---
title: {{目录名}} — 项目索引
type: project-readme
version: 1.0.0
status: Active
created: {{今天}}
last_updated: {{今天}}
---

# {{目录名}}

## 🔵 当前生效（Active）
| 文档 | 用途 |
|------|------|
...（扫 status=Active 的）

## ⚫ 已废弃
| 文档 | 状态 | 取代者 |
|------|------|--------|
...（扫 status=Deprecated 的）

## 📅 时间线
（按 created / last_updated 排序）
```

#### 任务 B：建 archive/ 目录（所有强度都做）

```bash
mkdir -p "$TARGET_DIR/archive"
```

#### 任务 C：给废弃文档加 callout 警告（中等+）

对 `status: Deprecated / Superseded` 的文档：

```bash
for f in "$DEPRECATED_FILES"; do
  # 在 frontmatter 后插入
  NEW_CONTENT='> [!warning] 已废弃
> 本文档已被 [[{{取代者}}]] 取代。仅为历史保留。
> 请勿以此为准。'

  # sed 技巧：在第一个 --- 闭合后插入
done
```

#### 任务 D：补 frontmatter 缺失字段（中等+）

对缺 frontmatter 的文档：
- 从文件 mtime 推 `created` 和 `last_updated`
- 从文件名猜 `type`（含"设计文档" → design-doc，"进度" → progress-log 等）
- 默认 `status: Active`
- 默认 `version: 1.0.0`
- 默认 `owner: {{git user.name 或问用户}}`

#### 任务 E：移废弃到 archive/（中等+）

```bash
for f in "$DEPRECATED_FILES"; do
  mv "$f" "$TARGET_DIR/archive/"
  echo "↪️ 移动 $(basename $f) 到 archive/"
done
```

**注意**：移动后 Obsidian 的 `[[wikilinks]]` 会自动更新（Obsidian 的特性）。

#### 任务 F：长文档拆分（激进）

对超过 800 行的文档：
```
文档 {{文件名}} 有 {{N}} 行，建议拆成：
  - 00-索引.md
  - 01-XX.md
  - 02-YY.md
  （按 H2 章节自动切分）

要拆吗？(y/N)
```

如用户确认：按 `## ` 切分，保留原文件作为"完整历史"备份。

#### 任务 G：重命名不规范（激进）

对命名不规范的文件（如 `未命名.md`）：
```
发现不规范命名：
  - 未命名.md  →  建议改成 XXX
  - ...
```

### 第 4 步：输出整理报告

```
✅ 整理完成！

## 改动摘要

- 📄 新建：README.md（目录索引）
- 📁 新建：archive/ 目录
- ⚠️ 加警告：3 个废弃文档顶部加 callout
- 📋 补字段：5 个文档补全 frontmatter
- ↪️ 归档：2 个废弃文档移到 archive/

## 备份位置

$TARGET_DIR/archive/backup-YYYYMMDD/  （原文件完整备份）

## 下次建议

- 新文档用 /obsidian-new-doc 建
- 定期跑 /obsidian-doc-audit 体检
- 每次写完文档记得更新 last_updated
```

## 禁忌

- ❌ 没备份不动手（除非用户明确说 no backup）
- ❌ 不改用户正文内容（只加 frontmatter / callout / 索引 / 移动）
- ❌ 不自动删除任何文件（最多移到 archive/）
- ❌ 激进模式要逐条确认

## 相关

- 方法论：https://github.com/hailanlan0577/claude-project-survival-kit/blob/main/docs/10-Obsidian-文档规范.md
- 配对：
  - `/obsidian-doc-audit`（先体检）
  - `/obsidian-new-doc`（建新文档）
