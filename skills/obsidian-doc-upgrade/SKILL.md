---
name: obsidian-doc-upgrade
description: 把旧的 Obsidian 文档"升级"到程序员标准（按 MADR / Google Design Doc / Sprint Board / Keep-a-Changelog 重组章节）。和 obsidian-doc-setup 区别：setup 只补 frontmatter/加 callout/不动正文；upgrade 重组正文章节结构。触发词：升级文档 / 把 xx 文档改成程序员标准 / 重组文档结构 / obsidian-doc-upgrade / 文档升级 / 现有文档升级。
user-invocable: true
---

# 把旧 Obsidian 文档升级到程序员标准

## 触发时机

用户说以下话时主动调用：

- "升级 XX 文档到程序员标准"
- "把 XX 改成标准格式"
- "重组 XX 文档"
- "我这个文档不够规范"
- "/obsidian-doc-upgrade"

## 与其他 Obsidian skill 的区别

| Skill | 改 frontmatter | 加 callout | 重组**正文章节** |
|-------|--------------|-----------|----------------|
| `/obsidian-doc-setup` | ✅ | ✅ | ❌ |
| `/obsidian-doc-upgrade`（本 skill）| ✅ | ✅ | ⭐ **✅ 核心功能** |

**setup** = 修元数据 / **upgrade** = 重组正文。

## 核心原则（MUST）

### ✅ 必须做

- **100% 保留原内容**：每一行原文必须出现在新版本里（除非用户明确说删）
- **先备份**：写新版前 cp 原文件到 `archive/upgrade-backup-YYYYMMDD-HHMM/`
- **给用户预览**：写之前先展示"我打算这样重组"，让用户确认
- **缺失章节标占位**：原文没有"风险分析"，新版加 `## 风险` 时填 `{{待补充}}` 不编造

### ❌ 绝对别做

- **不能丢内容**（原文 1839 行不能升级成 800 行）
- **不能编造**原文没说过的事
- **不动用户已有的 frontmatter**（除非加新字段）
- **不删原文件**（最多移到 archive/）

## 执行步骤

### 第 1 步：用户输入

```
我来升级文档到程序员标准。请告诉我：

1. 要升级哪个文档？（绝对路径或相对 vault 路径）
2. 想升级到哪种类型？
   a. 自动判断（看文件名 / 内容）
   b. design-doc（设计文档 8 件套）
   c. progress-log（进度日志，按时间倒序）
   d. project-readme（项目索引）
   e. adr（架构决策记录 MADR 格式）
   f. retro（复盘 Keep/Stop/Start）
   g. brainstorm（头脑风暴）
3. 缺失章节怎么处理？
   a. 留 `{{待补充}}` 占位（默认）
   b. 我从对话历史尝试提取（你和我聊过这个项目时）
   c. 留空（不显示这个章节）
```

### 第 2 步：备份原文件

```bash
SOURCE="<原文件绝对路径>"
DIR=$(dirname "$SOURCE")
BACKUP_DIR="$DIR/archive/upgrade-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$SOURCE" "$BACKUP_DIR/"
echo "✅ 备份到 $BACKUP_DIR"
```

### 第 3 步：判断目标类型（如果用户选 a 自动）

| 文件名信号 | 推断类型 |
|-----------|---------|
| 含"设计文档" / "design" | design-doc |
| 含"进度" / "开发" / "progress" | progress-log |
| 含"决策" / "ADR" | adr |
| 含"复盘" / "retro" | retro |
| 含"脑图" / "brainstorm" / "想法" | brainstorm |
| 含"README" / "索引" | project-readme |
| 都不像 | 询问用户 |

**内容信号**：
- 有 "Phase 1 / Phase 2" 章节 → progress-log 可能性高
- 有 "Problem Statement" / "决策" → design-doc
- 有 "做对的 / 做错的" → retro

### 第 4 步：扫描原文档，提取已有内容

读全文，按章节解析（`## ` 一级 / `### ` 二级）。

提取：
- 已有章节标题
- 每章内容
- 已有 frontmatter
- 列表 / 表格 / 代码块

### 第 5 步：拉对应模板

```bash
TEMPLATE_DIR="$HOME/claude-project-survival-kit/templates/obsidian-docs"
# 或从 GitHub 拉
[ ! -d "$TEMPLATE_DIR" ] && git clone https://github.com/hailanlan0577/claude-project-survival-kit.git /tmp/ckit && TEMPLATE_DIR=/tmp/ckit/templates/obsidian-docs
```

### 第 6 步：映射原内容到新模板章节

**关键**：尽量复用原文，只是搬到对应章节。

#### 例：升级 progress-log 时的映射

| 原文章节 | 新模板章节 |
|---------|-----------|
| `## Phase 1 — XX ✅` | `## 🎯 Phase 完成度` 表里加一行 + `## 📝 YYYY-MM-DD（最新）` 章节填详情 |
| `## 待完成` | `## 🎯 下次进来第一件事` |
| `## 关键技术决策` | `## 🧩 技术决策汇总` 表 |
| `## 代码结构` | 移到引用（CLAUDE.md 链接）或保留为附录 |

#### 例：升级 design-doc 时的映射

| 原文章节 | 新模板章节 |
|---------|-----------|
| `## Problem Statement` | `## 1. 问题陈述 (Problem Statement)` |
| `## Demand Evidence` | `## 2. 需求证据 (Demand Evidence)` |
| `## Status Quo` | `## 3. 现状 (Status Quo)` |
| `## 决策 X` 系列 | `## 6. 决策 & 理由 (Decision & Rationale)` |
| `## 评审 C1/C2/...` | `## 7. 风险 & 缓解 (Risks & Mitigations)` |
| `## 验证标准` | `## 8. 成功指标 (Success Metrics)` |
| `## 实施顺序` | 拆到对应 Phase 或 progress-log |

### 第 7 步：识别"缺失章节"

对比"模板必有 8 件套" vs "原文已有"，列出缺失。

例如 design-doc：
```
✅ 已有：Problem Statement / Demand Evidence / 决策
❌ 缺失：Goals/Non-Goals / Open Questions / Changelog
```

### 第 8 步：生成升级方案给用户预览

```markdown
我打算这样升级 `XX 文档`：

## 类型判断
当前：（猜的类型）→ 目标：design-doc

## 章节映射
- `## Problem Statement`（原 9-30 行）→ `## 1. 问题陈述`
- `## 决策 1` ~ `## 决策 5`（原 108-300 行）→ 合并到 `## 6. 决策 & 理由`
- `## 评审 C1-C4`（原 700-900 行）→ `## 7. 风险 & 缓解`
（继续列）

## 新增章节（缺失补齐）
- `## 4. 目标 / 非目标`（原文没有，留 `{{待补充}}`）
- `## 9. 开放问题`（原文没有，留 `{{待补充}}`）
- `## 10. 版本历史`（自动从 git/frontmatter 推断，加历史）
- 顶部加 `> [!info] 当前生效` callout

## Frontmatter 升级
新增字段：
- changelog: 加一条 v2.0.0 升级记录
- related: 自动扫 `[[]]` 链接

## 不动的部分
- 所有原文内容（100% 保留，只是重组位置）
- 现有 frontmatter 字段（保留 + 增加）

## 备份位置
$BACKUP_DIR/原文件名

确认升级吗？(y/n)
```

### 第 9 步：用户确认后写新版

按方案执行 + 写入原文件（原文件已经备份）。

### 第 10 步：给 diff 摘要

```
✅ 升级完成：XX 文档

## 改动摘要

- 章节数：原 8 个 → 新 12 个（+4 个补缺）
- 行数：原 X 行 → 新 Y 行（+ 26%，新增的是结构性章节）
- 新增章节：
  - ## 4. 目标 / 非目标（占位待补）
  - ## 9. 开放问题（占位待补）
  - ## 10. 版本历史（自动生成）
- 移动的章节：
  - `决策 1-5` 合并到 `## 6. 决策 & 理由`
- Frontmatter 新增：changelog / related

## 备份位置

$BACKUP_DIR/

## 还需你手动做的

- 填 `{{待补充}}` 的 2 个章节（目标 / 开放问题）
- 审阅决策章节是否合并合理
```

### 第 11 步：等用户反馈

如果用户说"改一下 X" → 再 Edit。
如果说"OK" → 结束。

## 边界情况

### 文档已经是新格式
检测 frontmatter 已有 `version >= 2.0.0` 或 `changelog` 字段 → 提示"看起来已经是程序员格式了，是否仍要升级？"

### 文档过短（< 50 行）
建议用 `/obsidian-new-doc` 重写，不值得升级。

### 文档过长（> 2000 行）
建议先拆分，然后逐个升级。

### 类型判断失败
直接问用户：这是什么类型的文档？

## 与 obsidian-doc-setup 的协作

**典型流程**：
```
1. /obsidian-doc-audit                   ← 看哪些文档要升级
2. /obsidian-doc-setup                   ← 先一键修元数据 / 加 callout
3. /obsidian-doc-upgrade <文档>          ← 再一份份升级正文
```

## 相关

- 方法论：https://github.com/hailanlan0577/claude-project-survival-kit/blob/main/docs/10-Obsidian-文档规范.md
- 模板：https://github.com/hailanlan0577/claude-project-survival-kit/tree/main/templates/obsidian-docs
- 配对 skill：
  - `/obsidian-new-doc`（从零建）
  - `/save-to-obsidian`（沉淀讨论）
  - `/obsidian-doc-audit`（体检）
  - `/obsidian-doc-setup`（修元数据）
