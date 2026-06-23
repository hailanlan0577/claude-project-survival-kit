# 设计文档：cbm 接管代码地图，融入救命手册

- **日期**：2026-06-23
- **作者**：Claude (Opus 4.8) × 陈源海
- **状态**：已批准（待写实施计划）
- **影响仓库**：`claude-project-survival-kit`（模板）+ 1 个试点项目（ytst）

---

## 1. 背景与动机

救命手册（CPSK）的 onboard / offboard 流程当前用 **graphify** 给项目代码画"地图"：

- onboard 第 2 步：读 `graphify-out/GRAPH_REPORT.md`（代码结构概览，< 30 天才读）
- offboard 第 6.5 步：`graphify --update` 增量刷新代码图谱

实践中暴露两个问题：

1. **保鲜难**：本次会话开窗时，graphify 报告 68 天未更新、已过期跳过——说明这套"项目代码地图"在真实使用中没怎么保鲜。
2. **更强的替代品出现**：`codebase-memory-mcp`（下称 **cbm**）是一个高性能代码知识图谱 MCP 服务器（C 语言、单二进制、158 语言、自带后台 watcher 自动保鲜），能让 AI **现场查代码**（`trace_path` 谁调用谁、`get_architecture` 全局概览、Cypher 查询），官方实测查代码省 ~99% token。

cbm 与 graphify 在"给代码建图"上高度重叠。继续两套并行属于冗余。

## 2. 目标

让每个用救命手册的**代码项目**，新窗口都能用 cbm 又快又省 token 地理解代码，下班时索引保持新鲜——同时**不破坏**非代码项目、不破坏用户重度定制的全局配置、可一键回滚。

## 3. 核心决策（已与用户敲定）

| # | 决策 | 选择 |
|---|------|------|
| D1 | cbm 在生命周期哪个环节 | **onboard + offboard 都接** |
| D2 | 与 graphify 的关系 | **cbm 接管代码；graphify 退回只管 Obsidian 笔记图谱**（救命手册内不再用 graphify 扫项目代码）|
| D3 | 改动范围 | **先只改模板 + 1 个试点项目（ytst）**，验证稳了再推广 |
| D4 | 安全 | **改动前全量备份 + 一键回滚脚本**（用户硬要求）|
| D5 | 替换方式 | **原地替换**原 graphify 代码步骤，而非末尾叠加新步 |

## 4. 详细设计

### 4.1 onboard 改动（proj-onboard 模板）

将原"第 2 步：读 `GRAPH_REPORT.md`"替换为 **cbm 代码全局步骤**：

- 检测本项目是否接了 cbm（见 §4.3）。
- **接了** → 调 `get_architecture`（语言 / 包 / 入口 / 路由 / 热点 / 模块聚类）拿全局；调 `index_status` 看索引新鲜度，过期则提示或触发刷新；把架构概览纳入开场中文汇报的"项目地图"小节。
- **没接** → 一句话跳过，不报错。

### 4.2 offboard 改动（proj-offboard 模板）

将原"第 6.5 步：`graphify --update`"替换为 **cbm 索引刷新步骤**：

- 检测本项目是否接了 cbm。
- **接了** → 确认后台 watcher 已同步（或手动 `index_repository` 刷新）；可选导出 / 提交团队工件 `.codebase-memory/graph.db.zst`。
- **没接** → 跳过。

> 编号保持原位（onboard 第 2 步 / offboard 第 6.5 步），不引入"第 10 步"新编号，避免全流程重排。

### 4.3 条件触发（优雅跳过，关键安全设计）

救命手册被很多项目共用，不是每个都装了 cbm。新步骤必须自判断、优雅跳过：

- **检测方式**：项目根 / 全局 `.mcp.json` 是否注册了 cbm，或 `index_status` 能否查到本项目。
- **未接 cbm**（非代码项目 / 尚未接入）→ 输出"本项目未接 cbm，跳过代码图谱步骤"，**绝不报错、绝不卡流程**。
- proj-graphify skill 本身保留（用户偶尔仍可手动用），只是不再被 onboard/offboard 自动调用。

### 4.4 备份 + 一键回滚

动手前建 `~/cbm-migration-backup-<日期>/`，含：

1. **cpsk 仓库**：先 `git tag pre-cbm-migration` 并推 GitHub（回滚 = 切回 tag）。
2. **试点项目分身 skill**（`~/.claude/skills/ytst-onboard`、`ytst-offboard`，不归 git 管）→ 原文件整份拷入备份目录。
3. **`rollback.sh`**：一条命令 `bash ~/cbm-migration-backup-<日期>/rollback.sh` 还原所有改动（复原分身 skill + 提示/执行仓库切回 tag）。
4. 装 cbm 前先 `cp ~/.claude/settings.json ~/.claude/settings.json.bak`。

### 4.5 cbm 安装（前置，沿用已商定的安全装法）

- 只装二进制：`curl … | bash -s -- --skip-config`（**不**用官方全局自动配置，不碰用户全局 hook/settings）。
- 仅在试点项目接入：把 cbm 写进 ytst 的**项目级** `.mcp.json`，避免全局 Grep/Glob hook 在非代码项目空转。
- ⚠️ 已知风险：cbm v0.8.1 存在"检测到损坏时静默删库"bug（issue #557）——其缓存目录 `~/.cache/codebase-memory-mcp/` 不作唯一数据源，定期可重建。

## 5. 落地顺序

1. 安全装 cbm 二进制（`--skip-config`）。
2. 建备份目录 + `rollback.sh` + 备份 settings.json。
3. 改 2 个模板（proj-onboard / proj-offboard）→ commit 进 cpsk 仓库。
4. 试点 ytst：接 cbm（项目级 `.mcp.json` + `index_repository` 首次建图）+ 同步改 ytst 的 onboard/offboard 分身 skill。
5. 验证：ytst 跑一次开窗（看架构概览是否出来）+ 一次下班（看索引是否刷新）。
6. 稳定后按需推广到其他代码项目（diting / luxury-bag …）。

## 6. 非目标（YAGNI）

- **不**全局自动配置 cbm（不装全局 Grep/Glob hook）。
- **不**改 cpsk-pro（本轮不同步并行版）。
- **不**批量改所有已部署项目 skill（仅试点 ytst）。
- **不**删除 proj-graphify skill（保留，仅解绑）。

## 7. 验收标准

- 试点 ytst 开窗时，开场汇报含 cbm 给出的代码架构概览；下班时 cbm 索引被刷新。
- 任意未接 cbm 的项目跑 onboard/offboard，**优雅跳过**该步、无报错。
- `bash ~/cbm-migration-backup-<日期>/rollback.sh` 能把全部改动还原到今天之前状态。

## 8. 风险与回滚

| 风险 | 缓解 |
|------|------|
| 改坏全局 settings.json | 装 cbm 用 `--skip-config` 根本不碰它；仍先 `.bak` 备份 |
| 模板改动影响存量项目 | 模板只影响**未来** setup；存量项目分身 skill 不变（除试点 ytst）|
| cbm 索引/缓存损坏 | 缓存可重建，不作唯一数据源；保留 graph 工件 |
| 想退回 | 一键 `rollback.sh` + 仓库 git tag 切回 |
