# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 格式，版本号遵循 [SemVer](./docs/8-SemVer-版本管理.md)。

## [Unreleased]

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

[Unreleased]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/hailanlan0577/claude-project-survival-kit/releases/tag/v0.1.0
