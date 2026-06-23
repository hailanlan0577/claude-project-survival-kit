# CPSK 项目状态快照

> 进度持续追加，最新在上。每次 offboard 时更新。

---

## 📅 2026-06-23

### 今天做了什么（v0.4.0 发版 + cbm 接管代码地图 + 全 8 项目推广）

1. ✅ **v0.4.0 发版** — onboard/offboard 模板：项目代码地图职责从 graphify 移交给 cbm（codebase-memory-mcp）
   - onboard 第 2 步：`GRAPH_REPORT.md` → cbm `get_architecture`（先 `list_projects` 查项目名）
   - offboard 第 6.5 步：`graphify --update` → cbm `index_repository` 刷新
   - 新步骤**条件触发**：未接 cbm 的项目优雅跳过、不报错（cpsk 本身就走跳过路径）
   - graphify 退出救命手册代码扫描，专心管 Obsidian 笔记图谱（proj-graphify skill 保留，仅解绑）
2. ✅ **完整走了一遍 superpowers 流程**：brainstorming → 设计文档（`docs/superpowers/specs/2026-06-23-cbm-takeover-code-graph-design.md`）→ writing-plans（`docs/superpowers/plans/2026-06-23-cbm-takeover-code-graph.md`）→ subagent-driven 7 任务 + 最终审查 + fix
3. ✅ **装 cbm 0.8.1**（`--skip-config`，没碰全局配置；`settings.json` 已备份 `.bak`）
4. ✅ **推广到全部 8 个代码项目**：cpsk·diting·infpick·kcgl·lbc·lp4·xianyu·xlyth 分身 skill 全 cbm 化（零 graphify 残留）；其中 **7 个真接线**（建项目级 `.mcp.json` + 建索引），**cpsk 只改文字不接线**（公开仓库，避免漏 /Users 路径）
5. ✅ **cbm 现管 8 项目索引**：ytst 9078节点 / lp4 985 / inference-picker 1077 / diting 736 / lbc 595 / xianyu 359 / xlyth 148 / kcgl 139
6. ✅ **一键回滚就绪**：`~/cbm-migration-backup-2026-06-23/rollback.sh`（数据驱动，覆盖 18 分身 skill + settings.json，"只还原不删除"）+ git tag `pre-cbm-migration`

### 今天踩的坑 / 给下个 Claude 的警告

1. ⚠️ **cbm 索引每进程要最多 32GB RAM**（日志 `budget_mb=32768`）→ 多项目建索引**必须串行**，并行会 OOM 撑爆 64GB
2. ⚠️ **cbm 项目名按路径派生**（如 `Users-chenyuanhai-ytst`），不是项目简称 → `get_architecture`/`index_status` 要先 `list_projects` 查名；`index_repository` 则用 `repo_path` 路径（两类工具标识符不同，正常）
3. ⚠️ **cbm v0.8.1 有 #557 静默删库 bug**（检测到"损坏"会删项目 DB 无恢复）→ `~/.cache/codebase-memory-mcp/` 不作唯一数据源
4. ⚠️ **分身 skill 改完即时生效**（live change detection），但 **MCP 工具要重启窗口才接线**（开窗时才连）；老窗口收尾不用重启（offboard 走 CLI 不靠 MCP）
5. ⚠️ **deploy.sh 故意跳过 proj-onboard/proj-offboard 模板**（给 setup-kit 用、不直接装）→ 改模板后无需 deploy；分身 skill 要直接改

### ➕ v0.4.1 收口（首次 offboard 后追加，为分享给朋友做全仓一致性）

- ✅ **README 对齐**：offboard checklist 8→9 步（补 Obsidian + cbm 6.5），加"进阶可选：接 cbm 代码图谱"小节
- ✅ **文档模板 + cpsk 根文件对齐 cbm**：`templates/ONBOARDING.md.tpl` / `OFFBOARDING.md.tpl` / 根 `ONBOARDING.md` / `OFFBOARDING.md` 的 graphify 扫代码表述全迁到 cbm
- ✅ **setup-kit 第 9.5 步**：初始 graphify 体检 → 初始 cbm 接入（建 `.mcp.json` + 索引）→ 升 **v0.4.1**
- commit：`c6752d0`(README) / `93690e8`(文档对齐) / `a65e4f7`(setup-kit+v0.4.1)，均已推 GitHub
- ⏸️ **暂不清的小尾巴**（用户选"就到这"）：`proj-graphify` skill 自述仍有"输出供 onboard 读取"的过时说法（onboard 已改读 cbm）；`CLAUDE.md` 健康检查 + `RUNBOOK.md` §5 的 graphify 痕迹保留（graphify 工具本身仍有效）

---

## 📅 2026-04-15

### 今天做了什么（5 次发版，1 个会话）

1. ✅ **v0.2.0 发版** — Obsidian 工具链（5 个 skill + 6 模板 + docs/10 规范）+ README 痛点表可导航 + 补 .gitignore（讽刺: 自己以前没有）
2. ✅ **v0.2.1 发版** — offboard checklist 8 → 9 步（加"第 8 步 Obsidian 沉淀"可选）
3. ✅ **v0.2.2 发版** — onboard 4 → 5 步（加"扫 Obsidian 最近 3 份"）
4. ✅ **v0.3.0 发版** — 接入 graphify：新 skill `/proj-graphify` + onboard 5 → 6 步加"读 GRAPH_REPORT.md (< 30 天)"
5. ✅ **v0.3.1 发版** — 补 dogfooding 尾巴：setup-kit 自动生成 `.graphifyignore` + 问是否跑初始 graphify
6. ✅ **给 cpsk 自己套用 setup-kit（dogfood）** — 生成 ONBOARDING / OFFBOARDING / CLAUDE / STATUS / RUNBOOK / deploy.sh + 安装 /cpsk-onboard /cpsk-offboard skill
7. ✅ **Obsidian 沉淀**: `复盘/2026-04-15-CPSK-graphify自诊.md` + `工具/CPSK-工具链使用手册.md`

### 今天踩的坑

1. ⚠️ graphify `--update` 有 ID 漂移问题，孤儿节点数会虚高——**是工具限制不是真实退化**
2. ⚠️ Qdrant `store_memory` 连续 2 次 400 Bad Request（DashScope API 侧）——转用 file-based memory 成功
3. ⚠️ v0.3.0 遗漏 setup-kit 对 `.graphifyignore` 的处理，在 v0.3.1 补上

### 今天的关键决策

- **graphify 是"地图"，不是"档案柜"**——派生索引，可重建，不进 offboard checklist
- **按 tag 取最近 N 个 > 按时间阈值**——跨周末长假也不会漏
- **`/proj-graphify` 输出放 `~/graphify-runs/`，软链回项目根**——不污染 git diff

---

## 📅 2026-04-14

### 做了什么

1. ✅ **v0.1.0 首版发布** — 7 件套骨架 + 3 个 skill (setup-kit, proj-onboard, proj-offboard) + 9 章 docs + luxury-bag-copilot 案例分析
2. ✅ 第一次给实际项目 lbc 套用

### 今天没做

- 没 VERSION 文件
- 没 CHANGELOG（v0.1.0 只是 git tag 没有发布说明）
- 项目自己没 `.gitignore`（讽刺中的讽刺）
- 不走自己教的 SemVer 纪律（拖到 v0.2.0 才想起来）

---

## 🎯 下次进来第一件事

**cbm 接管代码地图已全量落地（已到 v0.4.1，全仓一致、已分享朋友）**，8 个代码项目都能用了。可选下一步：

- **A** — 清掉 `proj-graphify` skill 自述里"输出供 onboard 读取"的过时说法（onboard 已改读 cbm）；想更彻底连 `CLAUDE.md` 健康检查 + `RUNBOOK.md` §5 的 graphify 痕迹一起清
- **B** — 在 lp4 / 其它项目实战用几天 cbm，验证"省 token + 查代码"的真实体感
- **C** — 给 cbm v0.8.1 的 #557 静默删库 bug 加防护（定时备份 `~/.cache/codebase-memory-mcp/` 或盯 cbm 升级）
- **D** — 把 cpsk-pro 同步问题想清楚（这次没动并行版，它还是老 graphify）
- **E** — 休息

**回滚随时可用**：`bash ~/cbm-migration-backup-2026-06-23/rollback.sh`（覆盖 18 分身 skill）。
