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

> **🔴 铁律：本 skill 涉及的所有文档必须 Read 完整（v0.3.5 立）**
>
> 文档清单：
> - `ONBOARDING.md`（第 1 步）
> - cbm 架构数据（第 2 步，如已接入）
> - 3 篇 Obsidian 相关文档（第 3 步）
> - `STATUS.md`（第 6 步）
>
> **全部必须用 Read tool 一次性完整读完**，不带 offset/limit（默认 2000 行兜底）。
>
> **严禁：**
> - 用 Bash `head` / `tail` / `sed` / `grep` 偷懒代替真读
> - 用会话总结里的"标题/摘要"代替真读文档内容
> - 只读前 N 行就开始汇报
>
> **必须自检：** 每读完一个文档，在汇报里**明示**「已 Read XXX.md（NN 行）」
>
> 漏报数字 = 没读 = 违反铁律 = 必须重做。

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

### 第 2 步：用 cbm 拿代码全局（如果项目接了 cbm，v0.4.0）

先判断本项目是否接入 cbm（codebase-memory-mcp，代码记忆图谱）：
- 项目根 / 全局 `.mcp.json` 含 `codebase-memory-mcp`，或能调通 cbm 工具 → 已接入
- 否则 → **一句话跳过本步**（"本项目未接 cbm，跳过代码图谱"），不读、不报错、不卡流程

已接入时：
1. 调 `list_projects` 查到本项目在 cbm 里的项目名（cbm 按路径派生，未必等于项目简称）
2. 调 `index_status`（带上项目名）看索引是否新鲜；过期/缺失则记一句"建议下班时刷新"
3. 调 `get_architecture`（带上项目名）拿：语言 / 包 / 入口 / 路由 / 热点 / 模块聚类
4. 把架构概览纳入开场中文汇报的"项目地图"小节（3-5 句）

> cbm 这些工具都在 MCP 服务 `codebase-memory-mcp` 下；`list_projects` / `index_status` / `get_architecture` 都用**项目名**（cbm 按路径派生，故先 `list_projects` 查名）。
>
> 注：graphify 不再用于扫项目代码（已交给 cbm），它专心管 Obsidian 笔记图谱。proj-graphify skill 保留，仅不再被 onboard 自动调用。

### 第 3 步：扫 Obsidian 最近相关文档（v0.2.2 新增）

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
  'head -20 "$1" | grep -q "<项目 tag>" && stat -L -f "%m %N" "$1"' _ {} \; \
  | sort -rn | head -3 | cut -d' ' -f2-
```

**跳过条件：** 扫不到任何 tag 匹配文档 → 跳过本步，直接第 4 步。

**🔴 强制要求（v0.3.4 升级，防偷懒）：**
- 找到 3 个文件名后**必须用 Read tool 真读每篇整篇**（不带 offset/limit，一篇一般 200-500 行，3 篇加起来 ~1500 行 / ~5-7K token，onboard 阶段值得这个代价）
- 严禁只 ls / find 列文件名靠会话总结里的标题瞎报内容
- 严禁只读前 N 行 / 用 head 偷懒（关键决策可能在文档中后段）
- 报告时**明示**：「已 Read 3 篇 Obsidian 文档整篇（共 NN 行）」并附**每篇真实标题 + 关键决策点 / 关键发现**（不许虚构）

### 第 4 步：用中文汇报状态（3-5 句话）

按以下结构（**第 2 步 cbm 架构数据 + 第 3 步 Obsidian 结果都纳入**）：

> 好的，我来继续 <项目名> 项目。简单汇报一下现状：
>
> **项目是**：<项目描述>
>
> **当前阻塞**：<说清楚卡在哪>
>
> **下一步候选**：<列 A/B/C 或用户上次留的"下次第一件事">
>
> **（可选）项目地图**（cbm 架构数据）：
> - 语言 / 包 / 入口：<cbm get_architecture 摘要>
> - 热点模块：<最高频访问路径>
>
> **（可选）Obsidian 最近相关文档** — 找到 N 份（按修改时间倒序）：
> 1. `<标题 1>`（<日期>）— <frontmatter 摘要>
> 2. `<标题 2>`...
> 3. `<标题 3>`...
> 要我读某一份的细节吗？
>
> 你想继续干哪件事？

### 第 5 步：等用户回复再动手

**绝对不要**自己决定走哪条路径。问用户之后**等他明确指令**再开始。

### 第 6 步：如果 `STATUS.md` 末尾有"🎯 下次进来第一件事"

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
