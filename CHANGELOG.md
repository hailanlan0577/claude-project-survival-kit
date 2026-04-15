# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 格式，版本号遵循 [SemVer](./docs/8-SemVer-版本管理.md)。

## [Unreleased]

## [0.2.2] — 2026-04-15

**主题：闭合 offboard → onboard 循环 — onboard 自动读最近 Obsidian 文档**

### Changed 变更
- `skills/proj-onboard/SKILL.md` — 步骤从 4 步扩到 5 步，新增"第 2 步 扫 Obsidian 最近相关文档"
- `templates/ONBOARDING.md.tpl` — 同步扩步骤 + 修 v0.2.1 漏掉的"8 步→9 步"残留
- 新的第 2 步行为：
  - 按项目 tag 取**最近 3 个** Obsidian 文档（不设时间阈值，按 tag 取最新 N 个比"最近 N 天"更稳 — 跨周末/长假都不会漏）
  - 首选 `mcp__obsidian__obsidian_simple_search`，降级到 shell `find + head + grep + stat`
  - 扫不到就跳过，不阻塞 onboard 流程
- 第 3 步汇报时把这 3 个文档标题纳入状态汇报，问用户"要读细节吗"

### Fixed 修复
- `templates/ONBOARDING.md.tpl` 里遗留的"读 `OFFBOARDING.md` 执行 8 步收尾"已改为"9 步"（v0.2.1 漏补）

### Meta
- 补齐 v0.2.1 的对称性缺口：offboard 写 Obsidian ≠ onboard 读 Obsidian
- 原设计方案曾考虑过"48 小时阈值"，用户追问"超过 48 小时怎么办" → 改成"按 tag 取最近 N 个"，覆盖所有场景
- 本次也只改了 kit 侧 + lbc 副本；其他通过 setup-kit 生成的项目需要单独同步（未来可做 migration 脚本）

## [0.2.1] — 2026-04-15

**主题：织补 dogfooding gap — offboard 纳入 Obsidian 沉淀**

### Changed 变更
- `skills/proj-offboard/SKILL.md` — checklist 从 8 步扩到 9 步，新增"第 8 步 Obsidian 沉淀（可选）"
- `templates/OFFBOARDING.md.tpl` — 同步扩 9 步
- 新的第 8 步调用 v0.2.0 引入的 `/save-to-obsidian` skill，仅当**有实质讨论**时触发（架构决策 / 抢救事件 / 头脑风暴 / 复盘 / 深度学习 10+ 轮）
- 跟第 7 步的记忆系统互补：记忆是索引（几十字），Obsidian 文档是正文（完整内容）

### Meta
- 识别出 v0.2.0 的一个隐性债务：新增 Obsidian 工具链但没织进 offboard 工作流
- 本次 patch 只改了 kit 侧；已生成的项目 offboard（如 `/lbc-offboard`）需要单独同步（已同步 lbc）

## [0.2.0] — 2026-04-15

**主题：Obsidian 工具链 + 可导航 README**

### Added 新增
- `docs/10-Obsidian-文档规范.md` — 6 类文档标准（Design/README/Progress/ADR/Retro/Brainstorm）+ frontmatter + 命名规范 + 生命周期管理
- `templates/obsidian/` — 6 份 Obsidian 文档模板
- 3 个 Obsidian skill：
  - `/obsidian-new-doc` — 按模板空白新建文档
  - `/obsidian-doc-audit` — 给目录做规范体检打分
  - `/obsidian-doc-setup` — 一键整理目录（建索引、补 frontmatter、归档废弃）
- `/save-to-obsidian` skill — 把当前会话讨论自动沉淀成 Obsidian 文档
- `/obsidian-doc-upgrade` skill — 把旧文档升级到 MADR / Google Design Doc / Keep a Changelog 等程序员标准
- `.graphifyignore` — 配合 [graphify](https://github.com/safishamsi/graphify) 工具链，忽略 `graphify-out/`
- `.gitignore` — 项目自己以前没有（讽刺的是教别人 .gitignore），现补齐：OS/IDE 垃圾 / `.omc/` / `graphify-out/` / `.env` / `credentials.md` 等
- `VERSION` 文件 — 显式版本号追踪
- `CHANGELOG.md` — 版本变更记录（本文件）

### Changed 变更
- `README.md` 真实痛点表从 2 列扩到 3 列，每个痛点加对应 `docs/` 章节的 markdown 链接
  - 新窗口 Claude 读 README 可以一跳到密钥/备份/Git/部署等解决方案
  - graphify 图谱分析发现痛点表是"目录孤儿"——下游章节不回指，此次打通

### Meta
- 首次做版本升级 dogfooding（v0.1.0 → v0.2.0），v0.1.0 之后积了 3 个 feat 才想起来自己教的 SemVer 规则
- graphify 分析揭示：`救命手册总骨架` Community cohesion 0.13，暗示未来可考虑把"会话生命周期 / 导览页 / 部署自检 / 架构理论"四个子话题拆章节

## [0.1.0] — 2026-04-14

**主题：项目救命手册首版**

### Added
- `docs/1-为什么要救命手册.md` — 背景、真实故事、设计哲学
- `docs/2-七件套骨架详解.md` — ONBOARDING / OFFBOARDING / CLAUDE.md / STATUS.md / RUNBOOK.md / .gitignore / deploy.sh 每个文件的职责
- `docs/3-密钥管理三位一体.md` — credentials.md + config.example.yaml + 1Password 的三位一体方案
- `docs/4-备份分层.md` — 源码三地同步 / 数据库 snapshot / binary 双地副本 / 维护节奏
- `docs/5-git-起步-6-步.md` — 从 0 到 push 的 6 步（防密钥泄露）
- `docs/6-10-题万无一失自检.md` — 10 题自检 + 通关标准 + 自检频率
- `docs/7-ADR-架构决策记录.md` — MADR 格式 / 生命周期 / 工具链 / 6 个月后的自己能看懂的理由
- `docs/8-SemVer-版本管理.md` — MAJOR.MINOR.PATCH + Conventional Commits + Keep a Changelog + GitHub Release
- `docs/9-pre-commit-hooks.md` — 机场安检类比 / 手写 bash vs pre-commit framework / 防密钥泄露最后一道防线
- `examples/luxury-bag-copilot-案例分析.md` — 真实 14 小时抢救案例（5 个陷阱 + 9 步补救 + 最终装备清单）
- `templates/` — 7 份骨架模板 + ADR 模板 + pre-commit 模板 + deploy 模板
- `/setup-kit` skill — 全局通用，一键给新项目建救命套件
- `/proj-onboard` skill — 每个项目生成专属的 `/<缩写>-onboard`（新窗口 60 秒进入状态）
- `/proj-offboard` skill — 每个项目生成专属的 `/<缩写>-offboard`（8 步收场 checklist）
- `README.md` + `skills-installer.md` — 使用说明 + 手动安装指南

[Unreleased]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.2.2...HEAD
[0.2.2]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/hailanlan0577/claude-project-survival-kit/releases/tag/v0.1.0
