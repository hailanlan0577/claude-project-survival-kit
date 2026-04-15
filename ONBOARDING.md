# 🆘 新 Claude 会话开场 — 60 秒进入 CPSK 维护状态

> **你是新 Claude，用户刚让你读这份文件。读完后用中文汇报你理解的 CPSK 当前状态，然后问用户下一步要做什么。**
>
> 用户（陈源海）是非程序员，请用生活化中文解释技术细节。

## 💡 触发方式

1. **最快** —— 打 `/cpsk-onboard`
2. **随口说** —— "继续 cpsk" / "继续做救命套件" / "接手 cpsk"
3. **完整口令**：
   ```
   继续之前的 claude-project-survival-kit 项目。
   请先读 /Users/chenyuanhai/claude-project-survival-kit/ONBOARDING.md
   读完用中文汇报当前状态，然后问我下一步。
   ```

## 📍 地形（30 秒必读）

| 维度 | 答案 |
|------|------|
| **源码唯一主分支** | `/Users/chenyuanhai/claude-project-survival-kit` |
| **远程** | https://github.com/hailanlan0577/claude-project-survival-kit（**public**）|
| **部署目标** | 无 — CPSK 是模板提供者，靠 `cp` 进 `~/.claude/skills/` 生效 |
| **用户操作系统** | macOS Darwin 25，MacBook Pro M1 Max 64GB |

### 🚫 N 大禁忌（CPSK 专属）

1. **不要 `git push --force` 到 main** — public 仓库，会砸别人的 fork
2. **不要在模板里硬编码 `/Users/chenyuanhai/...`** — 用 `<绝对路径>` 占位
3. **不要在 README/templates/examples 里留真实密钥/域名/用户名** — 脱敏后才推
4. **改 skill/templates 要配套改 CHANGELOG.md + VERSION**（自己教的 SemVer 自己先守）

---

## 🎯 CPSK 是什么（10 秒）

**Claude Project Survival Kit** —— 给 Claude Code 用户的"项目救命套件"。9 个 skill + 7 件文档骨架 + 智能工作流，让非程序员也能和 Claude 顺畅跨会话合作。

2026-04-14 起做，2026-04-15 晚完成 5 次迭代发版（v0.2.0 → v0.3.1）。

---

## 📊 当前状态（截至 2026-04-15 晚）

| 维度 | 状态 | 说明 |
|------|------|------|
| 最新版本 | ✅ **v0.3.1** | 5 个 tag 推到 GitHub |
| 文档骨架 | ✅ 7 件套完整 | templates/ 下 |
| Skill 数量 | ✅ 9 个 | 3 项目级 + 1 全局（setup-kit / proj-graphify）+ 5 Obsidian |
| 方法论文档 | ✅ 10 章 docs | 为什么到怎么做 |
| 自身 dogfood | ✅ 刚装好 | 今晚刚跑 setup-kit 给 cpsk 自己装上 ONBOARDING 等 |
| 使用手册 | ✅ | Obsidian `工具/CPSK-工具链使用手册.md` |
| GitHub Release（UI）| ⏳ | 只有 tag，没做 Release notes 页面 |
| 测试覆盖 | ⏳ | 只在 lbc / 二奢软件 / cpsk 本身 3 个项目跑过 |

---

## 🚦 下一步候选（用户还没拍板）

| 选项 | 动作 | 代价 | 推荐 |
|------|------|------|------|
| **A** | 补 GitHub Release（给 5 个 tag 各写 release notes）| 30 分钟 | ⭐ 做 1.0.0 时再补 |
| **B** | 在其他新项目（blog / ccr）试一次 `/setup-kit` 验证流程 | 10 分钟 | 真实打磨 |
| **C** | 修 Qdrant 400 bug（今晚存 memory 时触发）| 看情况 | 非 CPSK 本身问题 |
| **D** | 写社区推广文（B 站 / 小红书 / GitHub Discussions）| 1-2 小时 | 想推广时做 |
| **E** | 休息 | 0 | 🛏️ |

**你要做的**：问用户选哪个，不要自己拍板。

---

## 📚 更多信息去哪找

读这些文档的**优先顺序**：

| 文档 | 什么时候读 |
|------|-----------|
| `STATUS.md`（本仓库） | 想知道最近做了什么、哪个版本改了啥 |
| `CHANGELOG.md`（本仓库） | 想看每个版本的具体变化 |
| `CLAUDE.md`（本仓库） | 想知道 CPSK 的技术"地形" |
| `RUNBOOK.md`（本仓库） | 要做 release / 遇到 git 问题 / 要改某个 skill |
| `docs/`（10 章）| 想知道"为什么这样设计" |
| Obsidian `工具/CPSK-工具链使用手册` | 想知道所有 9 个 skill 怎么协同 |
| `graphify-out/GRAPH_REPORT.md` | 想看项目结构图（30 天内有效）|

---

## 🛠️ 常用操作速查

```bash
cd /Users/chenyuanhai/claude-project-survival-kit

# 查版本
cat VERSION

# 查最近 commit
git log --oneline -5

# 同步 skill 到 ~/.claude/skills/（改了 skill 后一定跑）
bash scripts/deploy.sh

# 本地跑一次 graphify（30 天更新一次）
/proj-graphify

# 发新 patch 版
# 1. 改完代码
# 2. 改 VERSION 文件
# 3. 追加 CHANGELOG.md [x.y.z] 段
# 4. git commit + tag + push（见 RUNBOOK § 发版流程）
```

---

## ⚠️ 上一次会话 Claude 踩的坑

1. **4-15 晚**：`--update` 后孤儿节点数飙升，是工具 ID 漂移问题不是真实退化，不要慌
2. **4-15 晚**：Qdrant memory store 连续 2 次 400（DashScope API 侧问题）— 存到 file-based memory 就行
3. **4-14**：自己项目居然没 `.gitignore` / 没 SemVer —— 已在 v0.2.0 补齐

---

## 🎬 你现在该做什么

按顺序：

1. **读项目图谱报告**（如新鲜）：
   - 检查 `graphify-out/GRAPH_REPORT.md` 存在且 < 30 天
   - 有就读 God Nodes / Communities 三节
2. **扫 Obsidian** 最近 tag 匹配 `cpsk` / `claude-project-survival-kit` / `CPSK` 的文档
3. **用中文**汇报状态（含最新版本、今天做了啥、下一步候选）
4. 问用户：选 A/B/C/D/E 哪条
5. **等用户回复再动手**

---

## 🛑 会话结束前的职责

如果上下文接近满，主动提醒：

> "感觉上下文接近满了，要不要我按 OFFBOARDING.md 做一次收尾？"

用户确认后，跑 `/cpsk-offboard` 的 9 步收尾 checklist。
