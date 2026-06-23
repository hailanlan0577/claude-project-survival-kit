# cbm 接管代码地图 — 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把项目代码地图职责从 graphify 移交给 cbm（codebase-memory-mcp），改 CPSK 两个模板 + 试点 ytst，全程可一键回滚。

**Architecture:** cbm 在 onboard（`get_architecture` 拿代码全局）和 offboard（刷新索引）两头各接一步，条件优雅跳过未接 cbm 的项目；graphify 退出救命手册的代码扫描。先改模板（git 管控）+ 试点 ytst（分身 skill 手动备份），验证后再推广。

**Tech Stack:** Markdown（SKILL.md 模板）、Shell（rollback.sh、cbm install.sh）、cbm MCP 工具（get_architecture / index_status / index_repository）、git（tag 回滚）。

## Global Constraints

- 装 cbm **只用** `curl … | bash -s -- --skip-config`，绝不用官方全局自动配置（不碰 `~/.claude/settings.json` 的 hook）。
- cbm 仅接入**项目级** `.mcp.json`，不挂全局 Grep/Glob hook。
- 任何文件改动前必须先进备份目录 `~/cbm-migration-backup-2026-06-23/`，并保证 `rollback.sh` 能一键还原。
- 改 skill/模板**必须**同步升 `VERSION`（0.3.5 → 0.4.0）+ 追加 `CHANGELOG.md`（CPSK 禁忌 #4）。
- 新增的 cbm 步骤**必须**条件触发：未接 cbm 的项目一句话跳过、绝不报错、绝不卡流程。
- cbm 缓存 `~/.cache/codebase-memory-mcp/` 可重建，不作唯一数据源（v0.8.1 有 #557 静默删库 bug）。
- git 提交无署名（用户全局规矩）；`git add <具体文件>` 不用 `git add .`。

---

## Task 0: 安全装 cbm 二进制 + 给 ytst 接入

**Files:**
- Backup: `~/.claude/settings.json` → `~/.claude/settings.json.bak`
- Create: `~/ytst/.mcp.json`
- Binary: `~/.local/bin/codebase-memory-mcp`（install.sh 装）

**Interfaces:**
- Produces: 可用的 `codebase-memory-mcp` 二进制；ytst 项目级 cbm MCP；ytst 已建初始索引。

- [ ] **Step 1: 备份全局 settings.json**

```bash
cp ~/.claude/settings.json ~/.claude/settings.json.bak && ls -la ~/.claude/settings.json.bak
```

- [ ] **Step 2: 装 cbm 二进制（跳过自动配置）**

```bash
curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash -s -- --skip-config
```
Expected: 输出 `Installed: ...` 版本号；二进制落在 `~/.local/bin/codebase-memory-mcp`。

- [ ] **Step 3: 验证二进制能跑**

```bash
~/.local/bin/codebase-memory-mcp --version
```
Expected: 打印版本号（如 `0.8.1`），无报错。

- [ ] **Step 4: 给 ytst 建项目级 .mcp.json**

```json
{
  "mcpServers": {
    "codebase-memory-mcp": {
      "command": "/Users/chenyuanhai/.local/bin/codebase-memory-mcp",
      "args": []
    }
  }
}
```
写入 `~/ytst/.mcp.json`（若已存在则合并，不覆盖其它 server）。

- [ ] **Step 5: 给 ytst 建初始代码索引**

```bash
~/.local/bin/codebase-memory-mcp cli index_repository '{"repo_path": "/Users/chenyuanhai/ytst"}'
```
Expected: 返回节点/边数量，无报错。

- [ ] **Step 6: 验证索引存在**

```bash
~/.local/bin/codebase-memory-mcp cli index_status '{}'
~/.local/bin/codebase-memory-mcp cli list_projects '{}'
```
Expected: 列出 ytst，含 node/edge count。

- [ ] **Step 7: 不提交（本 Task 无 git 改动，ytst 的 .mcp.json 是否进 git 由 ytst 自己的 .gitignore 决定，本步不碰）**

---

## Task 1: 建全量备份 + 一键 rollback.sh

**Files:**
- Create: `~/cbm-migration-backup-2026-06-23/`（备份目录）
- Create: `~/cbm-migration-backup-2026-06-23/rollback.sh`
- Copy: `~/.claude/skills/ytst-onboard/SKILL.md`、`~/.claude/skills/ytst-offboard/SKILL.md` → 备份目录
- Tag: cpsk 仓库 `pre-cbm-migration`

**Interfaces:**
- Produces: 一条 `bash ~/cbm-migration-backup-2026-06-23/rollback.sh` 还原全部改动。

- [ ] **Step 1: 建备份目录并拷入试点分身 skill 原件**

```bash
B=~/cbm-migration-backup-2026-06-23
mkdir -p "$B/ytst-onboard" "$B/ytst-offboard"
cp ~/.claude/skills/ytst-onboard/SKILL.md "$B/ytst-onboard/SKILL.md"
cp ~/.claude/skills/ytst-offboard/SKILL.md "$B/ytst-offboard/SKILL.md"
ls -R "$B"
```

- [ ] **Step 2: cpsk 仓库打 tag 并推 GitHub（回滚锚点）**

```bash
cd /Users/chenyuanhai/claude-project-survival-kit
git tag pre-cbm-migration
git push origin pre-cbm-migration
git tag -l | grep pre-cbm
```
Expected: tag 创建并推送成功。

- [ ] **Step 3: 写 rollback.sh**

```bash
cat > ~/cbm-migration-backup-2026-06-23/rollback.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
B="$HOME/cbm-migration-backup-2026-06-23"
echo "== 还原试点 ytst 分身 skill =="
cp "$B/ytst-onboard/SKILL.md"  "$HOME/.claude/skills/ytst-onboard/SKILL.md"
cp "$B/ytst-offboard/SKILL.md" "$HOME/.claude/skills/ytst-offboard/SKILL.md"
echo "== 还原全局 settings.json（如有 .bak）=="
[ -f "$HOME/.claude/settings.json.bak" ] && cp "$HOME/.claude/settings.json.bak" "$HOME/.claude/settings.json" && echo "settings.json 已还原"
echo "== cpsk 仓库回滚（手动确认）=="
echo "   cd ~/claude-project-survival-kit && git checkout pre-cbm-migration -- skills/ VERSION CHANGELOG.md"
echo "完成。分身 skill 与 settings.json 已还原；仓库改动用上面那行 git 命令切回。"
EOF
chmod +x ~/cbm-migration-backup-2026-06-23/rollback.sh
```

- [ ] **Step 4: 干跑校验 rollback.sh 语法**

```bash
bash -n ~/cbm-migration-backup-2026-06-23/rollback.sh && echo "rollback.sh 语法 OK"
```
Expected: `rollback.sh 语法 OK`。

---

## Task 2: 改 proj-onboard 模板（onboard 第 2 步 → cbm）

**Files:**
- Modify: `/Users/chenyuanhai/claude-project-survival-kit/skills/proj-onboard/SKILL.md`

**Interfaces:**
- Consumes: cbm 工具 `index_status` / `get_architecture`。
- Produces: onboard 模板用 cbm 替代 graphify 代码图谱步骤。

- [ ] **Step 1: 读现状定位 graphify 步骤**

```bash
grep -n "graphify\|GRAPH_REPORT" /Users/chenyuanhai/claude-project-survival-kit/skills/proj-onboard/SKILL.md
```
Expected: 找到读 `GRAPH_REPORT.md` 的那一步（约第 2 步）。

- [ ] **Step 2: 用下面这段替换原 graphify 代码图谱步骤**

```markdown
### 第 2 步：用 cbm 拿代码全局（如果项目接了 cbm，v0.4.0）

先判断本项目是否接入 cbm（代码记忆图谱）：
- 项目根/全局 `.mcp.json` 含 `codebase-memory-mcp`，或能调通 cbm 工具 → 已接入
- 否则 → **一句话跳过本步**（"本项目未接 cbm，跳过代码图谱"），不读、不报错、不卡流程

已接入时：
1. 调 `index_status`（本项目）看索引是否新鲜；过期/缺失则记一句"建议下班时刷新"
2. 调 `get_architecture`（本项目）拿：语言 / 包 / 入口 / 路由 / 热点 / 模块聚类
3. 把架构概览纳入第 4 步开场中文汇报的"项目地图"小节（3-5 句）

> 注：graphify 不再用于扫项目代码（已交给 cbm）；它专心管 Obsidian 笔记图谱。proj-graphify skill 保留，仅不再被 onboard 自动调用。
```

- [ ] **Step 3: 校验改动**

```bash
grep -n "cbm\|get_architecture\|index_status" /Users/chenyuanhai/claude-project-survival-kit/skills/proj-onboard/SKILL.md
grep -c "GRAPH_REPORT" /Users/chenyuanhai/claude-project-survival-kit/skills/proj-onboard/SKILL.md
```
Expected: cbm 步骤出现；`GRAPH_REPORT` 在代码图谱步骤处已移除（文档读取优先级表里若仍提及可保留或一并删，确保不再"自动读"）。

---

## Task 3: 改 proj-offboard 模板（offboard 第 6.5 步 → cbm）

**Files:**
- Modify: `/Users/chenyuanhai/claude-project-survival-kit/skills/proj-offboard/SKILL.md`

**Interfaces:**
- Consumes: cbm 工具 `index_repository` / watcher。
- Produces: offboard 模板用 cbm 刷新替代 graphify --update。

- [ ] **Step 1: 定位 graphify 第 6.5 步**

```bash
grep -n "graphify\|第 6.5 步\|6.5" /Users/chenyuanhai/claude-project-survival-kit/skills/proj-offboard/SKILL.md
```

- [ ] **Step 2: 用下面这段替换原"第 6.5 步：graphify --update"**

```markdown
### 第 6.5 步：刷新 cbm 代码索引（替代原 graphify，v0.4.0）

先判断本项目是否接入 cbm：
- 没接入 → **跳过本步**，不报错
- 接入了 →
  1. 确认 cbm 后台 watcher 已同步（它自动保鲜）；不确定就手动刷新：
     `codebase-memory-mcp cli index_repository '{"repo_path": "<项目根>"}'`
  2. （可选）需团队共享 → 导出/提交 `.codebase-memory/graph.db.zst`

> 说明：cbm 索引存 `~/.cache/codebase-memory-mcp/`，可重建，不作唯一数据源。
> 最后汇报里把原"✅ 6.5 graphify"那行改成"✅ 6.5 cbm 索引已刷新（或：本项目未接 cbm，跳过）"。
```

- [ ] **Step 3: 校验改动**

```bash
grep -n "cbm\|index_repository" /Users/chenyuanhai/claude-project-survival-kit/skills/proj-offboard/SKILL.md
grep -c "graphify --update" /Users/chenyuanhai/claude-project-survival-kit/skills/proj-offboard/SKILL.md
```
Expected: cbm 刷新步骤出现；`graphify --update` 计数为 0。

---

## Task 4: 升版本 + CHANGELOG（守自己的 SemVer 纪律）

**Files:**
- Modify: `/Users/chenyuanhai/claude-project-survival-kit/VERSION`
- Modify: `/Users/chenyuanhai/claude-project-survival-kit/CHANGELOG.md`

**Interfaces:**
- Consumes: Task 2/3 的模板改动。
- Produces: 版本号 0.4.0 + changelog 记录 + 一次 commit。

- [ ] **Step 1: 升 VERSION**

```bash
echo "0.4.0" > /Users/chenyuanhai/claude-project-survival-kit/VERSION
cat /Users/chenyuanhai/claude-project-survival-kit/VERSION
```

- [ ] **Step 2: CHANGELOG 顶部追加条目**

```markdown
## [0.4.0] - 2026-06-23

### Changed
- onboard/offboard 模板：项目代码地图职责从 graphify 移交给 cbm（codebase-memory-mcp）
  - onboard 第 2 步：`GRAPH_REPORT.md` → cbm `get_architecture`
  - offboard 第 6.5 步：`graphify --update` → cbm 索引刷新
- 新步骤条件触发：未接 cbm 的项目优雅跳过、不报错
- graphify 退出救命手册代码扫描（proj-graphify skill 保留，仅解绑）；专注 Obsidian 笔记图谱
```

- [ ] **Step 3: 提交模板 + 版本（Task 2/3/4 一起）**

```bash
cd /Users/chenyuanhai/claude-project-survival-kit
git add skills/proj-onboard/SKILL.md skills/proj-offboard/SKILL.md VERSION CHANGELOG.md
git diff --cached --stat
git commit -m "feat: cbm 接管代码地图，onboard/offboard 模板从 graphify 迁到 cbm (v0.4.0)"
```

- [ ] **Step 4: 验证 commit**

```bash
git log --oneline -1
```
Expected: 看到该 commit。

---

## Task 5: 同步改试点 ytst 分身 skill

**Files:**
- Modify: `~/.claude/skills/ytst-onboard/SKILL.md`
- Modify: `~/.claude/skills/ytst-offboard/SKILL.md`

**Interfaces:**
- Consumes: Task 2/3 模板里的新 cbm 步骤文本（同样内容，把 `<项目根>` 等占位换成 ytst 实路径 `/Users/chenyuanhai/ytst`）。
- Produces: ytst 分身 skill 与新模板一致。

- [ ] **Step 1: 改 ytst-onboard 的代码图谱步骤**

把 Task 2 Step 2 那段 cbm onboard 文本套进 `~/.claude/skills/ytst-onboard/SKILL.md` 的对应步骤（替换原 graphify/GRAPH_REPORT 步骤）。项目名填 `ytst`。

- [ ] **Step 2: 改 ytst-offboard 的第 6.5 步**

把 Task 3 Step 2 那段 cbm offboard 文本套进 `~/.claude/skills/ytst-offboard/SKILL.md`，`<项目根>` 换成 `/Users/chenyuanhai/ytst`。

- [ ] **Step 3: 校验两文件**

```bash
grep -n "cbm\|get_architecture\|index_repository" ~/.claude/skills/ytst-onboard/SKILL.md ~/.claude/skills/ytst-offboard/SKILL.md
grep -c "GRAPH_REPORT\|graphify --update" ~/.claude/skills/ytst-onboard/SKILL.md ~/.claude/skills/ytst-offboard/SKILL.md
```
Expected: cbm 步骤出现；旧 graphify 代码步骤计数 0。

---

## Task 6: 端到端验证（试点 ytst）

**Files:** 无改动（纯验证）

- [ ] **Step 1: 验证 onboard 路径（cbm 架构概览可用）**

```bash
codebase-memory-mcp cli get_architecture '{"project": "ytst"}'
```
Expected: 返回 ytst 的语言/包/入口/热点等结构化概览，无报错。

- [ ] **Step 2: 验证 offboard 路径（索引刷新可用）**

```bash
codebase-memory-mcp cli index_repository '{"repo_path": "/Users/chenyuanhai/ytst"}'
codebase-memory-mcp cli index_status '{}'
```
Expected: 刷新成功，索引状态正常。

- [ ] **Step 2.5: 验证条件跳过（未接 cbm 的项目不报错）**

人工核对模板/分身 skill 文本：未接 cbm 分支是否明确写了"跳过、不报错"。任取一个未接 cbm 的项目名调 `get_architecture`，确认 skill 逻辑是跳过而非崩。

- [ ] **Step 3: 验证一键回滚可用（不实际回滚，只确认脚本就绪）**

```bash
bash -n ~/cbm-migration-backup-2026-06-23/rollback.sh && echo "rollback 就绪"
ls ~/cbm-migration-backup-2026-06-23/ytst-onboard/SKILL.md ~/cbm-migration-backup-2026-06-23/ytst-offboard/SKILL.md
git -C /Users/chenyuanhai/claude-project-survival-kit tag -l | grep pre-cbm-migration
```
Expected: 脚本语法 OK、分身 skill 备份在、tag 在 → 随时能一键回滚。

- [ ] **Step 4: 向用户汇报验收结果**

逐条报告：cbm 装好、ytst 接入并建索引、模板 + 分身改完并 commit、备份+回滚就绪、端到端验证通过。问用户是否推广到其它代码项目。

---

## Self-Review（写完后自检）

**1. Spec 覆盖：**
- D1（onboard+offboard 都接）→ Task 2 + Task 3 ✅
- D2（cbm 接管代码、graphify 退回管笔记）→ Task 2/3 文本含"graphify 不再扫代码"备注 ✅
- D3（先模板 + 1 试点）→ Task 2/3/4 模板 + Task 5 ytst 试点 ✅
- D4（备份 + 一键回滚）→ Task 1 + Task 6 Step 3 ✅
- D5（原地替换非叠加）→ Task 2/3 均"替换原步骤" ✅
- 条件优雅跳过 → Task 2/3 文本 + Task 6 Step 2.5 ✅
- 安全装法（--skip-config / 项目级 .mcp.json）→ Task 0 + Global Constraints ✅
- SemVer 纪律 → Task 4 ✅

**2. 占位符扫描：** 无 TBD/TODO；`<项目根>` 在 Task 5 明确换成 ytst 实路径。✅

**3. 类型/命名一致：** cbm 工具名全程统一 `get_architecture` / `index_status` / `index_repository` / `list_projects`；备份目录名全程 `~/cbm-migration-backup-2026-06-23/`；版本号全程 0.4.0。✅
