# 🛑 CPSK 会话结束前 Claude 必做（收场手册）

> **触发时机**：用户说"存档 / 记录一下 / 今天就到这 / 下班 / 窗口快满了"等。
>
> **目标**：下一个窗口贴开场口令（读 `ONBOARDING.md`）能**无缝接上**。

## 💡 触发方式

1. **最快** —— `/cpsk-offboard`
2. **随口说** —— "下班" / "存档" / "今天就到这"
3. **完整口令**：
   ```
   窗口快满了。
   请按 /Users/chenyuanhai/claude-project-survival-kit/OFFBOARDING.md 的 9 步收尾：
   STATUS 更新 / 新坑 / commit+push / 部署（cpsk 无）/ 密钥（cpsk 无）/ 代码地图 / 记忆 / Obsidian 沉淀可选 / 留便条
   做完逐条报告。
   ```

---

## ✅ Checklist（Claude 按顺序执行）

### ① 记今天做了什么 → 更新 `STATUS.md`

在 STATUS.md 的"📝 YYYY-MM-DD 做了什么"段**追加**：

- 发了哪些版本？（每版 1 行）
- 加/改/删了哪些 skill / docs / templates？
- 踩了什么坑（写给下个 Claude 看的警告）

### ② 新坑 → 进 `ONBOARDING.md` 禁忌清单

CPSK 的禁忌特别注意：
- 发现 public 仓库某处有真实密钥/域名泄露 → **立即**加禁忌
- 某个 skill 在某个场景炸了 → 加禁忌

格式：`不要 X，因为 Y（日期）`

### ③ git commit + push

```bash
cd /Users/chenyuanhai/claude-project-survival-kit
git status --short
git add <具体文件>   # 别用 git add .
git diff --cached
git commit -m "<type>: <描述>"
git push
```

`<type>`: `feat` / `fix` / `docs` / `refactor` / `chore`

### ④ "部署" — CPSK 没传统部署

CPSK 改动生效靠 2 条路径：
- **改了 `skills/`**：跑 `bash scripts/deploy.sh` 把 skill 同步到 `~/.claude/skills/`
- **改了 `templates/`**：不用同步（下次 `/setup-kit` 会拉最新的）

如果本次只改了 docs / README / CHANGELOG → 跳过本步。

### ⑤ 密钥同步 — CPSK 无密钥

CPSK 是 public + 无后端，**无密钥同步需求**。永远跳过。

**唯一情况**：如果你不小心把真实密钥/token 写进了 examples/ 或 docs/，**立即 revert + rotate key + git filter-repo**。见 RUNBOOK § 紧急密钥泄露。

### ⑥ 大变动？更新 `CLAUDE.md` 代码地图

遇到下列情况更新 CLAUDE.md：
- 新增了一个 skill → `skills/` 代码地图加一行
- 新增了 docs 章节 → `docs/` 代码地图加一行
- 新增了 template 文件 → `templates/` 代码地图加一行

### ⑦ 记忆系统存一条进度

调用 Qdrant v3：

```
category: project
tags: cpsk,claude-project-survival-kit,progress,YYYY-MM-DD
content: "CPSK YYYY-MM-DD: 发了 vX.Y.Z（主题）。下次第一件事：<X>。当前阻塞：<Y 或 无>。"
```

**注意**：Qdrant 如果 400 了（DashScope 侧偶尔会），存到 `~/.claude/projects/*/memory/` file-based memory 当 fallback。

### ⑧ Obsidian 沉淀（可选，仅当今天有实质讨论）

如果今天有**架构决策 / 大版本发布 / 复盘 / 深度学习**：

```
/save-to-obsidian
```

自动判断类型（ADR / Retro / Design Doc），填模板存进 Obsidian vault。

**判断**：
- ✅ 适合：v0.x.0 MINOR 发版后复盘 / 做了大方向决策
- ❌ 跳过：小 typo 修复 / 仅仅改了一行 CHANGELOG

### ⑨ 留便条 → `STATUS.md` 末尾

```markdown
## 🎯 下次进来第一件事

<一句话明确说下次做什么>

例如：
- "补 v0.3.0/v0.3.1 的 GitHub Release notes"
- "给另一个新项目试跑 /setup-kit 做真实验证"
- "写推广文到 GitHub Discussions"
```

---

## 最后：逐条报告用户

按 1-9 步逐条报告：

```
✅ 1. STATUS.md 已更新：追加 YYYY-MM-DD 做了 X/Y/Z
✅ 2. 新坑已加进 ONBOARDING 禁忌（或：无新坑）
✅ 3. git 已 commit + push：commit abc1234
✅ 4. skill 已同步 ~/.claude/skills/（或：本次没改 skill，跳过）
✅ 5. 密钥：CPSK 无密钥，跳过
✅ 6. CLAUDE.md 代码地图已更新（或：无大变动，跳过）
✅ 7. Qdrant 记忆已存（或：400 了，存到 file memory）
✅ 8. Obsidian 文档已沉淀：[文档名]（或：无值得沉淀的讨论，跳过）
✅ 9. STATUS.md 末尾便条已留："下次第一件事做 X"

下次贴 ONBOARDING 口令或打 /cpsk-onboard 就能无缝接上。
```

---

## 🔁 完整会话生命周期

```
开新窗口 → /cpsk-onboard
   ↓
读 ONBOARDING.md → 读图谱 → 扫 Obsidian → 汇报
   ↓
用户说做什么 → 干活
   ↓
窗口快满 → /cpsk-offboard
   ↓
跑 9 步 checklist
   ↓
下次开新窗口 → 无缝接上
```

---

## 🗺️ 配套体检 skill（v0.3.0）

- **`/proj-graphify`** — 给 CPSK 做结构体检
- **何时跑**：发 MINOR / MAJOR 版本前、大重构后、每季度一次
- **不要跑**：每次 offboard（小改动无信息增量）
- 跑完后 `/cpsk-onboard` 会**自动读** `graphify-out/GRAPH_REPORT.md`（<30 天的）
