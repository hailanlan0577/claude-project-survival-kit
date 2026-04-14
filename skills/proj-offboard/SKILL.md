---
name: <PROJ>-offboard
description: <项目名> 项目会话结束收尾。读 OFFBOARDING.md 按 8 步 checklist 执行：更新 STATUS / 记新坑 / git commit+push / 部署 / 密钥同步 / 代码地图 / 记忆存进度 / 留便条。触发词：<项目名> 下班 / <项目名> 存档 / 窗口快满了 / 写交接 / 今天就到这 / <PROJ>-offboard。
user-invocable: true
---

# <项目名> 下班收尾

<!--
  模板占位符：同 proj-onboard
-->

## 触发时机

当用户**正在做 <项目名> 项目**时，出现以下表达 → 主动调用这个 skill：

- "下班" / "今天就到这" / "存档" / "记录一下" / "写个交接"
- "窗口快满了"
- "我要去睡/休息/吃饭了"
- 或用户直接打 `/<PROJ>-offboard`

**自检主动提醒**：如果你（Claude）感觉到以下任一情况，**主动**提议调用这个 skill：
- 被提示"context 快满了"
- 频繁 summarize 之前内容
- 文件引用变得模糊
- 连续 30+ 轮对话没有结束

提议话术：
> "感觉上下文接近满了，要不要我按 OFFBOARDING.md 做一次收尾，让下一个窗口无缝接上？"

**歧义处理**：用户只说"下班"但不清楚在做哪个项目时，先问"是 <项目名> 项目收尾吗？"

## 执行步骤（严格按顺序）

### 第 0 步：读 OFFBOARDING.md

```
Read tool: <绝对路径>/OFFBOARDING.md
```

完整的 8 步 checklist 在这个文件里。严格按顺序执行。

### 第 1 步：更新 STATUS.md "今天做了什么"

在 `<绝对路径>/STATUS.md` 的"📝 YYYY-MM-DD 做了什么"段**追加**（不要覆盖之前日期）。

规则：
- 按时间顺序
- 写**结果**不写过程
- 用 ✅ / ⚠️ / ❌ 标状态
- 失败的事也要记

### 第 2 步：今天踩的新坑 → ONBOARDING.md 禁忌清单

格式：`不要 X，因为 Y（日期）`

### 第 3 步：git commit + push

```bash
cd <绝对路径>
git status --short
git add <具体文件>   # 别用 git add .
git diff --cached
git commit -m "<type>: <描述>"
git push
```

`<type>` 用：`feat` / `fix` / `docs` / `refactor` / `chore`。

### 第 4 步：改了代码需要上线吗？

```bash
bash <绝对路径>/scripts/deploy.sh
# 或只重启
bash scripts/deploy.sh --restart
```

验证：按 RUNBOOK § 7 的健康检查命令。

### 第 5 步：密钥/config 变化同步

今天有改 `config.yaml` 或涉及新密钥吗？

**有** → 同步到 `~/.claude/projects/*/memory/credentials.md` + 多地 config MD5 校验一致。

**没有** → 跳过。

### 第 6 步：大变动？更新 CLAUDE.md 代码地图

### 第 7 步：记忆系统存一条进度

调用项目约定的记忆系统（Qdrant / claude-mem 等）：

```
category: project
tags: <项目名>,progress,YYYY-MM-DD
content: "<项目名> YYYY-MM-DD 进展：<今天关键结果>。下次第一件事：<X>。当前阻塞：<Y 或 无>。"
```

### 第 8 步：给下个 Claude 留便条

在 `STATUS.md` 末尾追加/更新：

```markdown
## 🎯 下次进来第一件事

<一句话明确告诉下个 Claude 做什么>
```

### 最后：逐条报告给用户

```
✅ 1. STATUS.md 已更新
✅ 2. 新坑已加进 ONBOARDING 禁忌（或：无新坑）
✅ 3. git 已 commit + push：commit abc1234
✅ 4. 部署已完成（或：无代码改动，跳过）
✅ 5. 密钥已同步（或：无变化，跳过）
✅ 6. CLAUDE.md 代码地图已更新（或：无大变动，跳过）
✅ 7. 记忆已存 [ID: xxxxxxxx]
✅ 8. STATUS.md 末尾便条已留："下次第一件事做 X"

下次新开窗口，贴开场口令或打 /<PROJ>-onboard 就能无缝接上。
```

## 禁忌

- ❌ 不要跳过任何一步（每步都要做，做不了要说明原因）
- ❌ 不要自作主张修改 OFFBOARDING.md 内容
- ❌ 不要用 `git add .`（容易误提敏感文件）
- ❌ 不要 `git push --force`（除非密钥紧急清理，见 RUNBOOK § 10.9）

## 相关文档

- 仓库根：`OFFBOARDING.md`（权威 checklist）
- 配对 skill：`/<PROJ>-onboard`
- 密钥表：`~/.claude/projects/*/memory/credentials.md`
