---
name: obsidian-doc-audit
description: 给 Obsidian 目录里的文档做"规范体检"，按 claude-project-survival-kit 的标准打分并给改进建议（frontmatter 完整度 / 有无 TOC / 废弃标记 / 命名规范 / 组织架构）。触发词：给文档做体检 / obsidian 文档审计 / doc audit / obsidian-doc-audit / 给 xx 目录打分 / 检查文档规范。
user-invocable: true
---

# Obsidian 文档体检

## 触发时机

- 用户打 `/obsidian-doc-audit`
- 用户说"给我的 XX 目录文档做体检"
- 用户说"这些文档写得怎么样"
- 用户说"看看我文档够不够规范"

## 执行步骤

### 第 1 步：问用户要审计哪个目录

```
我来给 Obsidian 里的文档做体检，对照 claude-project-survival-kit
的标准。请告诉我：

1. 要审计的 Obsidian 目录路径？
   （相对于 vault 根，如 "二奢软件"，或绝对路径）

2. 重点关注什么？
   a. 整体体检（默认）— 扫所有方面
   b. 只看 frontmatter 完整度
   c. 只看组织结构（有无 README / 废弃标记）
   d. 只看命名规范
```

### 第 2 步：定位 Obsidian vault

```bash
# 优先尝试标准位置
VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
[ -d "$VAULT/claude" ] && VAULT="$VAULT/claude"

# 或者问用户
TARGET_DIR="$VAULT/<用户第 1 题答案>"
```

### 第 3 步：全面扫描（7 个维度）

#### 维度 1：Frontmatter 完整度

对每个 `.md` 文件检查：

```bash
for f in "$TARGET_DIR"/*.md; do
  # 有没有 frontmatter？
  FIRST_LINE=$(head -1 "$f")
  if [ "$FIRST_LINE" != "---" ]; then
    echo "❌ $f 无 frontmatter"
    continue
  fi

  # 缺哪些关键字段？
  for field in title type version status owner created last_updated; do
    grep -q "^${field}:" "$f" || echo "⚠️ $f 缺 $field"
  done
done
```

#### 维度 2：TOC（目录）

```bash
for f in "$TARGET_DIR"/*.md; do
  LINES=$(wc -l < "$f")
  # 超过 500 行的文档
  if [ "$LINES" -gt 500 ]; then
    # 有没有 ## 目录 章节？
    grep -q "^## 📋 目录\|^## 目录\|^## TOC" "$f" || echo "⚠️ $f 长 $LINES 行但无 TOC"
  fi
done
```

#### 维度 3：废弃标记

```bash
for f in "$TARGET_DIR"/*.md; do
  # 文档顶部有没有 callout 警告？
  if grep -qi "Deprecated\|Superseded" "$f"; then
    head -20 "$f" | grep -q "\[!warning\]\|\[!deprecated\]\|已废弃\|已被.*取代" || \
      echo "⚠️ $f 标了废弃但顶部无 callout 警告"
  fi
done
```

#### 维度 4：命名规范

```bash
for f in "$TARGET_DIR"/*.md; do
  NAME=$(basename "$f" .md)

  # 不好的命名模式
  [[ "$NAME" =~ ^未命名 ]] && echo "❌ $f 无意义命名"
  [[ "$NAME" =~ final|FINAL|v2|v3 ]] && echo "⚠️ $f 版本号在文件名里（应该在 frontmatter）"
  [[ "$NAME" =~ ^[a-zA-Z]+$ ]] && echo "⚠️ $f 命名过于简单（项目前缀呢？）"
done
```

#### 维度 5：组织架构

```bash
# 有没有 README.md / 00-索引.md？
[ ! -f "$TARGET_DIR/README.md" ] && [ ! -f "$TARGET_DIR/00-索引.md" ] && \
  echo "❌ 目录无导航（缺 README.md 或 00-索引.md）"

# 有 archive/ 子目录吗？（废弃文档归档）
DEPRECATED_COUNT=$(grep -l "status: Deprecated\|status: Superseded" "$TARGET_DIR"/*.md 2>/dev/null | wc -l)
[ "$DEPRECATED_COUNT" -gt 0 ] && [ ! -d "$TARGET_DIR/archive" ] && \
  echo "⚠️ 有 $DEPRECATED_COUNT 个废弃文档但没 archive/ 目录"
```

#### 维度 6：8 件套结构（Design Doc）

对 `type: design-doc` 的文档，检查是否有 8 要素章节：

```bash
REQUIRED_SECTIONS=(
  "问题陈述\|Problem Statement"
  "目标\|Goals"
  "方案\|Design Options\|Options"
  "决策\|Decision"
  "风险\|Risk"
  "成功指标\|Success Metric"
  "开放问题\|Open Question"
  "版本历史\|Changelog"
)

for f in $DESIGN_DOC_FILES; do
  for section in "${REQUIRED_SECTIONS[@]}"; do
    grep -qiE "^##.*($section)" "$f" || echo "⚠️ $f 缺章节：$section"
  done
done
```

#### 维度 7：时间衰减（stale 文档）

```bash
for f in "$TARGET_DIR"/*.md; do
  # 从 frontmatter 读 last_updated
  LAST=$(grep "^last_updated:" "$f" | awk '{print $2}')
  if [ -n "$LAST" ]; then
    # 超过 6 个月没更新？
    if [[ $(date -j -f "%Y-%m-%d" "$LAST" +%s 2>/dev/null) -lt $(date -v-6m +%s) ]]; then
      echo "⚠️ $f 6 个月+未更新（status 还是 Active？）"
    fi
  fi
done
```

### 第 4 步：输出体检报告（按此结构）

```markdown
# 📋 Obsidian 文档体检报告

**目录**: {{TARGET_DIR}}
**审计日期**: {{TODAY}}
**文档总数**: {{N}}

## 📊 总体评分：{{X}}/10

| 维度 | 得分 | 说明 |
|------|------|------|
| Frontmatter 完整度 | X/10 | {{具体数字：N 个文档中 M 个完整}} |
| TOC（长文档目录） | X/10 | {{长文档中 M/N 有 TOC}} |
| 废弃标记 | X/10 | {{废弃文档中 M/N 有 callout 警告}} |
| 命名规范 | X/10 | {{N 个文档中 M 个命名规范}} |
| 组织架构 | X/10 | {{有/没 README，有/没 archive}} |
| Design Doc 8 件套 | X/10 | {{对设计文档检查}} |
| 时间新鲜度 | X/10 | {{多少 stale}} |

## 🐛 发现的问题（按严重度）

### 🔴 严重（必须改）

1. ❌ **{{问题}}**
   - 影响：{{新 Claude 不知道从哪读 / 决策无法追溯}}
   - 建议：{{用 /obsidian-new-doc 建 README}}
   - 涉及文件：{{清单}}

### 🟡 中等（值得改）

1. ⚠️ **{{问题}}**
   - 涉及文件：...

### 🟢 轻微（有时间再改）

1. {{问题}}

## 💡 改进建议（按优先级排序）

### 1 小时内能做

1. **给 `{{TARGET_DIR}}/` 建 README.md**
   命令：`/obsidian-new-doc` → 选 Project README
2. **废弃文档加 callout 警告**
   手动 Edit 加：
   ```markdown
   > [!warning] 已废弃
   > 本文档已被 [[新文档]] 取代。
   ```
3. **...**

### 1 天内能做

1. **长文档拆分**（1000+ 行的文档按章节拆）
2. **...**

### 有时间再做

1. **Frontmatter 补全 version / owner / created**
2. **...**

## 📚 参考

- [Obsidian 文档规范](https://github.com/hailanlan0577/claude-project-survival-kit/blob/main/docs/10-Obsidian-文档规范.md)
- [模板库](https://github.com/hailanlan0577/claude-project-survival-kit/tree/main/templates/obsidian-docs)
```

### 第 5 步：问用户要不要自动修复

```
报告给你了，总分 {{X}}/10。

要不要我按照「1 小时内能做」的建议自动修复部分问题？
我可以：
- 自动生成 README.md（扫描文件自动填索引表）
- 自动给废弃文档加 callout 警告
- 自动补 frontmatter 缺失字段

你选（多选）：
1. 自动建 README
2. 自动加废弃警告
3. 自动补 frontmatter
4. 不用，我自己改
```

### 如果用户选自动修复

- 建 README：扫所有文档 frontmatter 汇总到表格
- 加废弃警告：读 status=Deprecated 的文档，顶部插 callout
- 补 frontmatter：读文件创建时间作 `created`，今天作 `last_updated`，默认 `type` 从文件名猜

## 禁忌

- ❌ 不要擅自修改用户的文档内容（只能加 frontmatter / callout，不改正文）
- ❌ 不要对非 Obsidian 目录做 audit（先确认是 vault 下）
- ❌ 不要报 stale 就要求删除（可能用户想保留历史）
- ❌ 不要打 10/10（总有能改进的地方）

## 相关

- 方法论：https://github.com/hailanlan0577/claude-project-survival-kit/blob/main/docs/10-Obsidian-文档规范.md
- 配对：`/obsidian-new-doc`（建新文档）
