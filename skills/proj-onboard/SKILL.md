---
name: <PROJ>-onboard
description: 继续 <项目名> 项目。新会话开场交接，读仓库 ONBOARDING.md 后用中文汇报项目状态，然后等用户指示下一步。触发词：继续 <项目名> / 接手 <项目名> / 读 ONBOARDING / <PROJ>-onboard。
user-invocable: true
---

# <项目名> 开场交接

<!--
  模板占位符：
  - <PROJ>       = skill 缩写（比如 lbc / ccr / myapp），不含 -onboard 后缀
  - <项目名>      = 项目完整名称（比如 luxury-bag-copilot）
  - <绝对路径>    = 项目本地绝对路径
  - <项目描述>    = 一句话说项目做啥
-->

## 触发时机

用户**任何一句**出现以下表达 → 主动调用这个 skill：

- "继续 <项目名>"
- "继续 <项目中文别名>"
- "接手 <项目名>"
- "读 ONBOARDING"
- 或用户直接打 `/<PROJ>-onboard`

**歧义处理**：用户只说"继续项目"但有多个项目时，先问"你是指 <项目名> 吗？"

## 执行步骤（严格按顺序）

### 第 1 步：读仓库 ONBOARDING.md

```
Read tool: <绝对路径>/ONBOARDING.md
```

这份文件包含：
- 项目地形（源码路径 / GitHub / 部署目标）
- N 大禁忌
- 当前 Phase 完成度 + 阻塞状态
- 下一步候选（A/B/C）
- 文档读取优先顺序
- 上一次会话踩的坑

### 第 2 步：扫 Obsidian 最近相关文档（v0.2.2 新增）

上次会话的 `/save-to-obsidian` 可能在 Obsidian vault 写过本项目的 ADR / Design Doc / Retro / Brainstorm / Learning。**不读就会漏掉最新决策**（STATUS.md 写不下的细节都在这些文档里）。

**做法（有 Obsidian MCP 时）：**
1. 调 `mcp__obsidian__obsidian_simple_search`，query 传项目 tag（例：`<项目 tag>`，通常就是项目名或简写）
2. 过滤 frontmatter `tags:` 包含该 tag 的文档
3. 按 `last_updated` / 文件 mtime **降序取前 3 个**（按 tag 取最新 N 个，不按"最近 N 天"——跨周末/长假也不会漏）
4. 读每个的 frontmatter + 第一段摘要

**Fallback（MCP 不可用时）：**
```bash
VAULT="<用户 Obsidian vault 路径>"  # 默认 /Users/<你>/Library/Mobile Documents/iCloud~md~obsidian/Documents/<vault 名>
find "$VAULT" -name "*.md" -exec sh -c \
  'head -20 "$1" | grep -q "<项目 tag>" && stat -f "%m %N" "$1"' _ {} \; \
  | sort -rn | head -3 | awk '{print $2}'
```

**跳过条件：** 扫不到任何 tag 匹配文档 → 跳过本步，直接第 3 步。

### 第 3 步：用中文汇报状态（3-5 句话）

按以下结构（**有第 2 步的 Obsidian 结果就加一段**）：

> 好的，我来继续 <项目名> 项目。简单汇报一下现状：
>
> **项目是**：<项目描述>
>
> **当前阻塞**：<说清楚卡在哪>
>
> **下一步候选**：<列 A/B/C 或用户上次留的"下次第一件事">
>
> **（可选）Obsidian 最近相关文档** — 找到 N 份（按修改时间倒序）：
> 1. `<标题 1>`（<日期>）— <frontmatter 摘要>
> 2. `<标题 2>`...
> 3. `<标题 3>`...
> 要我读某一份的细节吗？
>
> 你想继续干哪件事？

### 第 4 步：等用户回复再动手

**绝对不要**自己决定走哪条路径。问用户之后**等他明确指令**再开始。

### 第 5 步：如果 `STATUS.md` 末尾有"🎯 下次进来第一件事"

那是**上个 Claude 留给你的便条**，优先参考。在汇报里提一句：

> 上次 Claude 留了便条说下次第一件事做 X，你要按这个走吗？

## 禁忌

- ❌ 不自作主张开始改代码
- ❌ 不绕过 ONBOARDING.md 自己凭印象汇报
- ❌ <项目专属禁忌，从 ONBOARDING.md 的禁忌清单复制最关键的两三条>

## 相关文档

- 仓库根：`CLAUDE.md` / `STATUS.md` / `RUNBOOK.md` / `OFFBOARDING.md`
- 设计文档：<位置>
- 配对 skill：`/<PROJ>-offboard`（会话结束时收尾）
