---
name: setup-kit
description: 按 claude-project-survival-kit 模板给新项目或现有项目建一套"救命套件"（7 件套 ONBOARDING/OFFBOARDING/CLAUDE/STATUS/RUNBOOK/.gitignore/deploy.sh + 2 个 Claude skill + 必要备份）。触发词：给新项目建救命套件 / 套用救命手册模板 / 初始化项目救命包 / setup-kit / setup survival kit / 给项目做文档骨架 / 项目交接套件。
user-invocable: true
---

# 新项目套用救命手册通用模板

## 触发时机

用户**任何一句**出现以下表达 → 主动调用这个 skill：

- "给新项目建救命套件"
- "按救命手册模板初始化"
- "套用项目救命套件"
- "给这个项目做文档骨架"
- "按 claude-project-survival-kit 模板做"
- 或用户直接打 `/setup-kit`

**歧义处理**：如果用户只说"帮我初始化项目"但没提"救命套件/文档/skill"，先确认"你是要按 claude-project-survival-kit 的通用模板给这个项目建救命套件吗？"

## 用途

给新项目或现有项目建一套标准化文档和工具，保证：
- 任何新 Claude 窗口 60 秒进入状态
- 密钥永不泄露（`.gitignore` + 三位一体）
- 数据永不丢失（git + 定期 snapshot）
- 6 个月后自己或别人能看懂状态
- 会话结束自动存档

## 执行步骤（严格按顺序）

### 第 1 步：**先问清关键信息**（一次性问完，不要边做边问）

逐条问用户，记到你的 TodoWrite 里作为参数：

```
1. 项目英文缩写（用作 skill 前缀，示例：lbc / ccr / myapp）：
2. 项目完整名称：
3. 项目中文别名（自然语言触发词用）：
4. 项目绝对路径（本地 MacBook）：
5. 项目是做啥的？（一句话）：
6. 技术栈（编程语言 + 主要框架）：
7. GitHub：要建 private 还是 public？（推荐 private，含密钥项目必选 private）
8. 部署目标：
   a. 无（本地跑就行）
   b. 远程服务器（需 SSH 信息：别名 / 路径）
   c. 云平台（Vercel / Fly.io / Heroku / 其他）
9. 记忆系统偏好（Qdrant v3 / claude-mem / 无）
10. 涉及哪些密钥？（DashScope / OpenAI / 飞书 / 钉钉 / GitHub / 其他）
```

**重要**：问清楚再动手。非程序员用户很难边做边决定。

### 第 2 步：拉最新模板

```bash
# 如果本地没有，克隆一次
if [ ! -d /tmp/claude-survival-kit ]; then
  git clone https://github.com/hailanlan0577/claude-project-survival-kit.git /tmp/claude-survival-kit
else
  cd /tmp/claude-survival-kit && git pull
fi
```

### 第 3 步：复制 7 件套到项目根 + 填占位符

```bash
PROJ_PATH="<用户第 4 题答案>"
cd /tmp/claude-survival-kit

# 复制 templates（去掉 .tpl 后缀）
cp templates/ONBOARDING.md.tpl    "$PROJ_PATH/ONBOARDING.md"
cp templates/OFFBOARDING.md.tpl   "$PROJ_PATH/OFFBOARDING.md"
cp templates/CLAUDE.md.tpl        "$PROJ_PATH/CLAUDE.md"
cp templates/STATUS.md.tpl        "$PROJ_PATH/STATUS.md"
cp templates/RUNBOOK.md.tpl       "$PROJ_PATH/RUNBOOK.md"
cp templates/.gitignore.tpl       "$PROJ_PATH/.gitignore"
mkdir -p "$PROJ_PATH/scripts"
cp templates/scripts/deploy.sh.tpl "$PROJ_PATH/scripts/deploy.sh"
chmod +x "$PROJ_PATH/scripts/deploy.sh"
```

然后**逐文件 Edit**，把所有尖括号占位符替换成用户答案：

- `<PROJ>` → 用户第 1 题答案
- `<项目名>` → 用户第 2 题答案
- `<项目中文别名>` → 用户第 3 题答案
- `<绝对路径>` → 用户第 4 题答案
- `<项目描述>` → 用户第 5 题答案
- `<技术栈>` → 用户第 6 题答案
- 等等

**对非程序员友好**：填完后让用户**检查一遍**再继续。

### 第 4 步：安装 2 个 skill 到 `~/.claude/skills/`

```bash
PROJ="<用户第 1 题答案，如 lbc>"
mkdir -p ~/.claude/skills/${PROJ}-onboard ~/.claude/skills/${PROJ}-offboard
cp /tmp/claude-survival-kit/skills/proj-onboard/SKILL.md ~/.claude/skills/${PROJ}-onboard/
cp /tmp/claude-survival-kit/skills/proj-offboard/SKILL.md ~/.claude/skills/${PROJ}-offboard/
```

然后 **Edit 两个 SKILL.md**，把 `<PROJ>` / `<项目名>` / `<绝对路径>` 替换掉。

验证安装：
```bash
cat ~/.claude/skills/${PROJ}-onboard/SKILL.md | head -5
```

### 第 5 步：`.gitignore` 检查 + `git init` + GitHub repo

按 [docs/5-git-起步-6-步.md](https://github.com/hailanlan0577/claude-project-survival-kit/blob/main/docs/5-git-起步-6-步.md) 的 6 步走：

```bash
cd "$PROJ_PATH"

# 5.1 扫敏感文件
find . -type f \( -name "*.key" -o -name "*.env" -o -name "config.yaml" -o -name "*secret*" \) 2>/dev/null

# 5.2 看 .gitignore 已经覆盖了吗
cat .gitignore

# 5.3 git init
git init -b main
git add .
git status --ignored --short | grep '!!' | grep -E 'config\.yaml|\.env|\.key'
# 敏感文件应该在 !! 列

# 5.4 commit
git -c user.email='<user@email>' -c user.name='<name>' commit -m "chore: initialize survival kit"

# 5.5 建 GitHub repo（private 或 public 按第 7 题答案）
VIS="<private 或 public>"
gh repo create <user>/<repo-name> --$VIS --description "<一句话>"

# 5.6 push
git remote add origin https://github.com/<user>/<repo-name>.git
TOKEN=$(gh auth token)
git -c credential.helper="!f() { echo username=<user>; echo password=$TOKEN; }; f" push -u origin main
```

### 第 6 步：密钥三位一体

如果项目有密钥（第 10 题）：

```bash
# 6.1 项目根建 configs/ 目录（如果没有）
mkdir -p "$PROJ_PATH/configs"

# 6.2 config.example.yaml（脱敏结构，入 git）
# 按第 10 题的密钥字段生成 YAML 结构，值用占位符
# 示例：
cat > "$PROJ_PATH/configs/config.example.yaml" <<EOF
# 复制为 config.yaml 并填真实值
# config.yaml 已 gitignore

<service1>:
  api_key: "xxx"  # 从 <控制台 URL> 获取
  ...
EOF

# 6.3 config.yaml（真实密钥，不入 git）
cp "$PROJ_PATH/configs/config.example.yaml" "$PROJ_PATH/configs/config.yaml"
# 引导用户填真实值（或者直接让用户编辑）

# 6.4 credentials.md（全局记忆备份）
# 追加到 ~/.claude/projects/*/memory/credentials.md
```

### 第 7 步：首次备份（如适用）

如果项目已有运行数据（现有项目转套件）：

- 数据库 snapshot（按项目记忆系统）
- 运行 binary 拷回本地
- 永久资产打包

如果是全新项目（第 5 题答案说"从零"），跳过。

### 第 8 步：Obsidian 落地（如用户用 Obsidian）

先检查用户用不用 Obsidian：
```bash
ls ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents 2>/dev/null || \
  ls ~/Documents/*Obsidian* 2>/dev/null
```

如果有 Obsidian vault，写一份 `<项目名>-救命手册.md` 到用户指定目录。内容参考 [examples/luxury-bag-copilot-案例分析.md](https://github.com/hailanlan0577/claude-project-survival-kit/blob/main/examples/luxury-bag-copilot-案例分析.md) 的结构。

### 第 9 步：记忆系统存一条项目记忆

调用项目用的记忆系统（第 9 题），存：
```
category: project
tags: <项目名>,setup-kit,<日期>
content: "<项目名> 2026-MM-DD 新建救命套件：源码 <绝对路径>，GitHub <URL>，skill /<PROJ>-onboard 和 /<PROJ>-offboard 已装。当前状态：<一句话>。"
```

### 第 10 步：报告用户

```
✅ 新项目救命套件已就位

**项目路径**: <绝对路径>
**GitHub**: <URL>
**已装 skill**:
  - /<PROJ>-onboard  → 新会话开场
  - /<PROJ>-offboard → 结束前存档

**文档结构**:
  ONBOARDING.md / OFFBOARDING.md / CLAUDE.md / STATUS.md / RUNBOOK.md
  scripts/deploy.sh / .gitignore
  configs/config.example.yaml（入库）/ config.yaml（本地真密钥）

**下次用法**:
  - 新窗口继续做这个项目：打 /<PROJ>-onboard 或说"继续 <项目名>"
  - 结束前存档：打 /<PROJ>-offboard 或说"下班"

**剩下你要做的**（如果第 5 题涉及代码）:
  1. 写代码 / 改代码
  2. 按需填充 STATUS.md 的 Phase 完成度
  3. 完成第一个里程碑后跑一次 /<PROJ>-offboard 存档
```

## 禁忌

- ❌ 不要跳步骤（尤其密钥管理和 gitignore 检查）
- ❌ 不要在用户没答完 10 个问题前就开干
- ❌ 不要把 config.yaml 推 git（第 5 步验证必须做）
- ❌ 不要帮用户决定 private/public（必须他选，public 需要脱敏）
- ❌ 不要用 `git add .`（只加具体文件）

## 相关资源

- 模板仓库：https://github.com/hailanlan0577/claude-project-survival-kit
- 方法论：`docs/1-为什么要救命手册.md` 到 `docs/6-10-题万无一失自检.md`
- 第一个样本：luxury-bag-copilot（对应 `examples/` 里的脱敏案例）
