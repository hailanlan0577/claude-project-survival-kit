---
name: save-to-obsidian
description: 把当前会话中的某段讨论自动沉淀成 Obsidian 文档（ADR / Design Doc / Brainstorm / Retro / Learning）。Claude 回顾对话历史 → 判断文档类型 → 提取核心内容（不是占位符）→ 填好模板 → 写入 Obsidian。触发词：把这段讨论整理成文档 / 保存到 obsidian / 记录一下这次讨论 / 沉淀这段对话 / 存档 / 写个决策记录（基于刚才讨论）/ save to obsidian / save-to-obsidian / 把刚才的讨论写进 obsidian。
user-invocable: true
---

# 把讨论沉淀成 Obsidian 文档

## 触发时机

当用户说以下话时**主动调用**：

- "把刚才的讨论整理成文档"
- "保存到 Obsidian"
- "记录一下"（结合上下文判断是否在讨论结束后）
- "沉淀这段对话"
- "写个决策记录"（**基于刚才的讨论**，不是从零开始）
- "存档这段"
- "归档这个讨论"
- 或直接 `/save-to-obsidian`

**关键区别于 `/obsidian-new-doc`**：
- `/obsidian-new-doc` = 从零写（模板填 `{{占位符}}`，用户自己填内容）
- `/save-to-obsidian` = **提炼对话**（从会话历史抽真实内容，填到模板）

## 核心理念

用户的真实工作流是：
```
抛问题 → 多轮问答 → 想清楚 → "帮我整理进 Obsidian"
```

而不是：
```
先决定要写 X 文档 → 填表单 → 从头想内容
```

所以这个 skill 要**读对话**，不能让用户重新讲一遍。

## 执行步骤

### 第 1 步：确认范围 + 类型

问用户：

```
我来把讨论沉淀成 Obsidian 文档。先确认 3 件事：

1. 要整理**哪段对话**？
   a. 整个当前会话
   b. 某个具体话题（例：「今天关于 ADR/SemVer/Hooks 的讨论」）
   c. 最近 N 轮（例：最近 20 轮）

2. 目标**文档类型**？
   （可以让我自动判断，下面是提示）
   - 明确做了决策 → **ADR**（架构决策记录）
   - 设计方案讨论 → **Design Doc**
   - 想法还没定 → **Brainstorm**
   - 事后反思 → **Retro**
   - 解决了一个问题 → **Learning**（新增类型，或当 ADR 处理）

3. 存到 Obsidian 哪个位置？
   （默认：vault 根 or 某个项目文件夹）
```

### 第 2 步：自动判断类型（如果用户说"你来定"）

扫描对话历史里的关键信号：

| 信号 | 类型 |
|------|------|
| "我们决定..." / "选 A 不选 B" / "最终方案" | **ADR** |
| "问题陈述" / "方案对比" / "成功指标" | **Design Doc** |
| "我有个想法" / "可能..." / "待研究" | **Brainstorm** |
| "这次做对了什么" / "下次要改" / "教训" | **Retro** |
| "搞懂了 X 是怎么回事" / "原理" / "如何实现" | **Learning** |

如果混合，以**最新出现的决策/结论**为主类型。

### 第 3 步：从对话历史提取结构化信息

**读取当前会话的上下文**（你的 conversation history）。

按目标类型对应抽取信息：

#### 如果是 ADR

```
- **标题**：这个决策简短名（动词+对象）
- **背景**：
  - 对话里提到的约束
  - 用户提出的问题
  - 讨论过的备选
- **决策**：最终结论（用户说"选 A" "开干"那个）
- **后果**：
  - 好处（讨论中提到的）
  - 坏处（讨论中承认的）
  - 什么时候要重评估（如果提到）
```

#### 如果是 Design Doc

```
- **问题陈述**：用户描述的痛点 + 定量数据
- **方案对比**：对话中列的 A/B/C 表格
- **决策**：用户敲定的
- **风险**：讨论中提到的风险
- **成功指标**：如果讨论过
- **开放问题**：讨论中没定的
```

#### 如果是 Brainstorm

```
- **核心问题**：整场讨论围绕什么
- **初步方向**：想到的所有点子
- **方案草图**：粗略讨论过的
- **待研究**：需要验证的假设
```

#### 如果是 Retro

```
- **做了什么**：会话里做过的事
- **Keep doing**：成功的
- **Stop doing**：失败的 / 不要再犯的
- **Start doing**：未来想试的
- **教训**：核心洞察
- **行动项**：后续要做的
```

#### 如果是 Learning（新类型，不在 6 模板里）

用 brainstorm 模板的变形，加一个"解决方案"章节。

### 第 4 步：读取对应模板

```bash
TEMPLATE_DIR="/Users/chenyuanhai/claude-project-survival-kit/templates/obsidian-docs"
# 或从 GitHub 拉
```

### 第 5 步：填充模板（用真实对话内容）

**关键**：不是填 `{{占位符}}`，是填**对话里真实说过的话**。

例如 ADR 模板里的：
```markdown
## 决策 (Decision)

**{{用宣言式的主动句}}**
```

填成：
```markdown
## 决策 (Decision)

**为 claude-project-survival-kit 的 setup-kit 加入 ADR / SemVer / pre-commit hooks 三件套，
对照标准程序员工作流补齐"版本管理 / 决策沉淀 / 密钥防护"三大环节。**
```

### 第 6 步：写到 Obsidian

```bash
VAULT="/Users/chenyuanhai/Library/Mobile Documents/iCloud~md~obsidian/Documents/claude"
TARGET_DIR="$VAULT/<用户第 3 题答案>"
mkdir -p "$TARGET_DIR"

# ADR 自动编号
if [ "$TYPE" = "adr" ]; then
  LAST=$(ls "$TARGET_DIR"/adr/ADR-*.md 2>/dev/null | grep -oE '[0-9]{4}' | sort -n | tail -1)
  NEXT=$(printf "%04d" $((10#${LAST:-0} + 1)))
  FILENAME="ADR-${NEXT}-<标题>.md"
fi

# Write 文件
```

### 第 7 步：frontmatter 规范

无论什么类型，frontmatter 都包含：

```yaml
---
title: <从对话提取>
type: adr | design-doc | brainstorm | retro | learning
version: 1.0.0
status: Draft | Active | Accepted
source: "sourced-from-chat"          # 标记来源
source_session: "2026-04-15 对话"    # 可选：日期
created: 2026-04-15
last_updated: 2026-04-15
owner: <从 git user.name>
tags: [<对话主题>, 会话沉淀]
---
```

### 第 8 步：报告给用户

```
✅ 已沉淀到 Obsidian：

**文件**：<绝对路径>
**类型**：<文档类型>
**预览**：

### 标题
<从对话提取的标题>

### 主要内容（前 5 行摘要）
...

### 抽取的关键信息
- 决策: xxx
- 理由: xxx
- 备选: xxx

**Obsidian 打开**：[点击]({{obsidian:// URL}})

**审阅建议**：
- 我是根据对话理解填的，可能有偏差
- 重点看决策和后果部分，看是不是你的本意
- 要改直接告诉我"把 XX 改成 YY"
```

### 第 9 步：等用户反馈

如果用户说"改一下 X"→ Edit 相应段落。
如果用户说"OK"→ 结束。

## 核心原则（MUST）

### ✅ 必须做

- **读对话历史**，不让用户重复讲
- **用真实对话原话或接近原话**，别虚构
- **承认偏差**：提醒"我是根据对话理解填的，看看对不对"
- **保留审阅权**：最后让用户确认

### ❌ 绝对别做

- 不能**编造**对话里没说过的内容（比如用户没给数据你别自己造）
- 不能**把占位符留在正文**（必须用真实内容）
- 不能**跳过用户确认**直接写大段内容

## 与其他 Obsidian skill 的分工

| Skill | 何时用 |
|-------|--------|
| `/obsidian-new-doc` | 心里已有完整方案，要空白骨架自己填 |
| `/save-to-obsidian`（本 skill） | 讨论完了，让 Claude 提炼沉淀 |
| `/obsidian-doc-audit` | 某个目录乱了，先诊断 |
| `/obsidian-doc-setup` | 按 audit 报告一键整理 |

## 典型使用时机

- 和 Claude 讨论完一个技术决策 → "把刚才讨论整理成 ADR"
- 探索了一个产品想法 → "这段存到 Obsidian，Brainstorm 类型"
- 完成一个 Phase → "刚才的复盘整理成 Retro 文档"
- 学懂了一个新概念 → "记录下来，Learning 类型"

## 相关

- 方法论：https://github.com/hailanlan0577/claude-project-survival-kit/blob/main/docs/10-Obsidian-文档规范.md
- 模板：https://github.com/hailanlan0577/claude-project-survival-kit/tree/main/templates/obsidian-docs
- 配对 skill：`/obsidian-new-doc`（空白骨架） / `/obsidian-doc-audit`（体检） / `/obsidian-doc-setup`（整理）
