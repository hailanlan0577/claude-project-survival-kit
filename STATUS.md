# CPSK 项目状态快照

> 进度持续追加，最新在上。每次 offboard 时更新。

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

**可选路径**：

- **A** — 补 5 个 GitHub Release 页面（从 CHANGELOG 抄 release notes）
- **B** — 给另一个新项目（blog / ccr / 其他）试跑 `/setup-kit` 做真实验证
- **C** — 写社区推广文（想推广时做）
- **D** — 休息

**如果默认走**：建议先 D，这个 3 小时连续 5 发版的强度已经够了。
