# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 格式，版本号遵循 [SemVer](./docs/8-SemVer-版本管理.md)。

## [Unreleased]

## [0.3.5] — 2026-05-05

**主题：onboard 加 umbrella 铁律——本 skill 所有文档必须 Read 完整，零例外**

### Added 新增
- `skills/proj-onboard/SKILL.md` 在「执行步骤」段开头加 **🔴 铁律段**，明确列出本 skill 涉及的全部 4 类文档（ONBOARDING / GRAPH_REPORT / 3 篇 Obsidian / STATUS），全部必须 Read 完整 + 自报行数

### Why 为什么
- v0.3.3 / v0.3.4 只覆盖第 2/3 步（GRAPH_REPORT + Obsidian）
- 用户立刻指出：第 1 步（ONBOARDING）和第 6 步（STATUS 末尾便条）还是软描述「读它」/「如果末尾有...」 → 同样会被偷懒
- 修复：加 umbrella 铁律覆盖全部 4 类文档，未来加新文档也自动落入铁律

### 文档清单（铁律覆盖范围）
| 步骤 | 文档 | 完整读法 |
|---|---|---|
| 1 | ONBOARDING.md | 完整（200+ 行，含全部禁忌） |
| 2 | graphify-out/GRAPH_REPORT.md | 完整（22KB / 600+ 行） |
| 3 | 3 篇 Obsidian 文档 | 每篇整篇（v0.3.4 已落地） |
| 6 | STATUS.md | 完整（含末尾便条 + 历史时间线） |

### Lesson 教训
- 写"防偷懒"规则时不能只覆盖部分步骤，要 umbrella 一刀切
- 用户的"通通完整读"诉求 = 不留协商空间 = skill 不留软描述

## [0.3.4] — 2026-05-05

**主题：onboard 第 3 步 Obsidian 改"读整篇"——v0.3.3 的"前 30 行"折中被否决**

### Changed 改动
- `skills/proj-onboard/SKILL.md` 第 3 步：从「读每篇前 30 行（frontmatter + 第一段）」升级为**「读每篇整篇」**（不带 offset/limit）

### Why 为什么
- v0.3.3 用"前 30 行"是为了省 token（约 30 × 3 = 90 行）
- 但用户立刻反馈：「obsidian 文档不是读整篇？」—— 关键决策可能写在文档中后段（如 5-05 v2.2 复盘 405 行，"晚段拍板"在 200+ 行处）
- 取舍重新评估：onboard 是关键决策点，漏决策的代价远大于多花 5-7K token；3 篇 × 200-500 行 ≈ 1500 行总量在 onboard 阶段可接受

### Meta
- 学习：写 skill 时「省 token」直觉不能凌驾于「不漏关键信息」之上，特别是 onboard / 复盘 这种"关键节点"
- 已先在 ytst/lbc/cpsk 项目专用 onboard skill 同步落地

## [0.3.3] — 2026-05-05

**主题：onboard 防偷懒——读图谱和 Obsidian 文档加强制 + 自检要求**

### Changed 改动
- `skills/proj-onboard/SKILL.md` 第 2 步加**强制要求**：必须用 Read tool 一次性读完整篇 GRAPH_REPORT.md（不带 offset/limit），严禁用 Bash head/sed 偷懒；汇报必须明示「已 Read NN 行 / NN KB」+ 至少 4 节内容（上帝节点 / 社区结构 / 意外连接 / 弱连接节点）
- `skills/proj-onboard/SKILL.md` 第 3 步加**强制要求**：找到 3 个 Obsidian 文件名后必须真用 Read tool 读每篇前 30 行，严禁只 ls 文件名靠会话总结瞎报；汇报明示「已 Read 3 篇（每篇 30 行）」+ 真实 frontmatter

### Why 为什么
- 用户在另一窗口跑 `/ytst-onboard`，问"你刚才有读图谱吗"，那个 Claude 诚实承认：**只读了 GRAPH_REPORT.md 前 120 行（全文 600+ 行）+ Obsidian 文档只列了文件名没读内容**
- 根因：旧 skill 用「读它」「读每个的 frontmatter」这种**软描述**，模型本能偷懒就钻空子
- 新逻辑加强制语气 + 自检报告（"已 Read NN 行"自报数字让用户能验证），偷懒就被自报数字暴露

### Meta
- 已先在三个项目专用 onboard skill 落地（`~/.claude/skills/ytst-onboard` / `lbc-onboard` / `cpsk-onboard`），验证模式后回流模板

## [0.3.2] — 2026-05-05

**主题：offboard 自动跑 `graphify --update` — 图谱永远跟代码同步，零思考**

### Added 新增
- `skills/proj-offboard/SKILL.md` 新增**第 6.5 步**：每次 offboard 必跑 `graphify --update`（增量，30-60 秒），保证图谱永远新鲜
- 第 6.5 步带兜底逻辑：如果 `~/graphify-runs/<项目>/graphify-out` 不存在 → 全量首跑；否则增量更新

### Changed 改动
- `templates/OFFBOARDING.md.tpl` 的"配套体检 skill"段：把"何时跑"从"手动判断（发版前 / 大重构后 / 每季度）"改为"每次 offboard 自动跑 --update"
- `skills/proj-offboard/SKILL.md` 的"相关文档"段：把 `/proj-graphify` 定位从"日常体检"改为"重建图谱（强制全量）"

### Why 为什么
- 旧逻辑（v0.3.0/0.3.1）：onboard 自动读图谱，但 offboard 不更新 → 图谱永远落后代码 1 个会话
- ytst 5-05 实战发现：上次 offboard 没跑 graphify，第二天 onboard 读到的是 14 天前的图，不反映新加的 4 个实验脚本 + 决策
- 新逻辑：offboard 每次跑增量 update（30-60 秒成本可忽略），onboard 直接读现成的，永远新鲜

### Meta
- 已先在三个项目专用 offboard skill 落地（`~/.claude/skills/ytst-offboard` / `lbc-offboard` / `cpsk-offboard`），验证逻辑可行后再回流到 cpsk 模板
- 此版本只改 cpsk 模板源，未来用 setup-kit 创建的新项目会自带这能力

## [0.3.1] — 2026-04-15

**主题：补 v0.3.0 的 dogfooding 尾巴 — setup-kit 终于会自动生成 `.graphifyignore`**

### Added 新增
- `templates/.graphifyignore.tpl` — 按技术栈分段的 graphify 排除模板（Go / Node / Python / Rust / Java 等，默认全注释，setup-kit 按 Q6 答案取消对应段）
- `skills/setup-kit/SKILL.md` 新增第 3.5 步：按技术栈定制 `.graphifyignore`
- `skills/setup-kit/SKILL.md` 新增第 9.5 步：问用户要不要跑初始 `/proj-graphify`（建第一份图谱，让首次 onboard 就能读到）

### Fixed 修复
- v0.3.0 遗留的 dogfooding gap：`/proj-graphify` 建了、onboard 会读图谱了，但 setup-kit 新建项目时不生成 `.graphifyignore`——每次都要用户手动补（今晚给 lbc 和二奢软件各补了一次）

### Meta
- 3 小时发了第 5 个版本（v0.2.0/.1/.2 + v0.3.0/.1），但每一次都是真实 gap 触发的，没有灌水
- "新功能闭环"原则：新加一个能力（比如 /proj-graphify），要检查对应的"生成路径"（setup-kit）、"使用路径"（onboard）、"失效路径"（>30 天提示）都搞定
- 下次新项目 `/setup-kit` 会自带 `.graphifyignore` + 初始 graphify 图谱，不用手打补丁

## [0.3.0] — 2026-04-15

**主题：接入 graphify 做项目结构体检 — 新 skill `/proj-graphify` + onboard 自动读图谱报告**

### Added 新增
- **新 skill `skills/proj-graphify/SKILL.md`** — 给当前项目做结构体检
  - 自动定位项目根（git rev-parse / 包含 CLAUDE.md 的目录）
  - 输出到 `~/graphify-runs/<project>/` 而非项目内（不污染 git diff）
  - 用软链回项目根的 `graphify-out/`，让 onboard 能读
  - 内置使用时机指南（推荐：发版前 / 大重构后 / 季度；不推荐：每次 offboard）
- `skills/proj-onboard/SKILL.md` 新增第 2 步：读项目图谱报告（< 30 天）
- `templates/ONBOARDING.md.tpl` 同步加图谱读取步骤
- `skills/proj-offboard/SKILL.md` 和 `templates/OFFBOARDING.md.tpl` 加 `/proj-graphify` 引用（仅作 related skill 提示，不进 checklist）

### Changed 变更
- proj-onboard 步骤从 5 步扩到 6 步（第 2 步新加图谱读取）
- 汇报模板加可选段落"项目地图（图谱报告 N 天前跑的）"，把 God Nodes / Communities 纳入

### Fixed 修复
- `templates/OFFBOARDING.md.tpl` 末尾"配套体检 skill"段落明确"不要每次 offboard 都跑"——避免误把它当成日常工作流强制项

### Meta
- 设计哲学：graphify 是**派生索引**（地图），不是**权威存储**（档案柜）
  - 输出放 `~/graphify-runs/` 而非项目内：可重建产物不污染源码
  - onboard 读软链：享受 30 天内的图谱地图，不用每次重跑
  - 写进 offboard 配套引用而非 checklist：避免把"地图"当"档案"过度使用
- v0.2.x 是档案柜思路（offboard 写 → onboard 读）；v0.3.0 加上"地图"层
- 这是从 PATCH(v0.2.2) 升到 MINOR(v0.3.0)：新功能 `/proj-graphify` + onboard 行为变更

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

[Unreleased]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/hailanlan0577/claude-project-survival-kit/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/hailanlan0577/claude-project-survival-kit/releases/tag/v0.1.0
