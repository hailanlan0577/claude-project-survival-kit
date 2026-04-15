# claude-project-survival-kit (CPSK) — Claude 操作手册

> **如果用户说"继续 cpsk"或贴了 ONBOARDING 口令，优先读 `ONBOARDING.md`。**
>
> 新 Claude 进门先读这份，30 秒掌握地形。详细进度见 `STATUS.md`，完整使用说明见 Obsidian `工具/CPSK-工具链使用手册.md`。

## 一句话

CPSK 是给 Claude Code 用户的"项目救命套件"：一套标准文档骨架 + 9 个 skill + 智能工作流。让任何项目文档不失联、新窗口 60 秒进入状态、密钥不误推 GitHub。

**特殊性**：CPSK 本身**不是**可部署的服务，它是**模板供应商 + skill 发布源**——其他项目 clone/copy 它，它自己不 run。

## 🔴 地理：源码 + 使用位置

| 位置 | 角色 | 路径 |
|------|------|------|
| **本地开发机** | 源码主分支（唯一） | `/Users/chenyuanhai/claude-project-survival-kit` |
| **GitHub** | 公开发布 | https://github.com/hailanlan0577/claude-project-survival-kit（**public**）|
| **部署目标** | 无 — Skill 靠 `cp` 到 `~/.claude/skills/` 生效 | N/A |

**禁忌：**
- ❌ 不要用 `git push --force`（这是公开仓库，会砸到用户的 fork）
- ❌ 不要把 `/Users/chenyuanhai/...` 绝对路径硬编码进模板（用占位符）
- ❌ 发 public 前**必须脱敏**：没有真实密钥、真实域名、真实用户名

## 🔧 "部署"工作流（不是传统部署）

CPSK 没有服务器。改动要"生效"靠 3 条路径：

```bash
# 1. 本地开发 → commit → push GitHub（供别人 clone）
git add <具体文件>
git commit -m "feat: ..."
git push

# 2. 本地开发 → 跑 scripts/deploy.sh 把 skill 同步到 ~/.claude/skills/（自己用）
bash scripts/deploy.sh

# 3. 打版本（SemVer + CHANGELOG + tag）
# 详见 docs/8-SemVer-版本管理.md
```

## 🧱 技术栈

- **Markdown**（所有文档）
- **Shell 脚本**（deploy.sh / pre-commit hooks）
- **Claude Skills**（frontmatter + 自然语言 prompt）
- **graphify**（可选，结构分析）

无编程语言运行时、无数据库、无服务。

## 🗂️ 代码地图

```
claude-project-survival-kit/
├── README.md                    # 入门页（含命令速查）
├── CLAUDE.md                    # 本文件
├── ONBOARDING.md                # 新 Claude 进门
├── OFFBOARDING.md               # 下班 checklist
├── STATUS.md                    # 进度快照
├── RUNBOOK.md                   # 故障处理
├── VERSION                      # SemVer 版本号
├── CHANGELOG.md                 # Keep a Changelog 格式
├── .gitignore
├── .graphifyignore
├── docs/                        # 方法论 10 章
├── templates/                   # 给别人用的骨架模板
│   ├── *.tpl                    # 7 件套 + .graphifyignore.tpl
│   └── obsidian-docs/           # 6 个 Obsidian 模板
├── skills/                      # 9 个 skill（给别人安装用）
│   ├── setup-kit/               # 一键初始化
│   ├── proj-onboard/            # onboard 模板
│   ├── proj-offboard/           # offboard 模板
│   ├── proj-graphify/           # 结构体检 (v0.3.0+)
│   └── obsidian-*/              # 5 个 Obsidian skill (v0.2.0+)
├── examples/                    # 脱敏真实案例
├── scripts/
│   └── deploy.sh                # 同步 skill 到 ~/.claude/skills/
└── graphify-out/                # 本项目图谱（gitignore，软链）
```

## 🧪 检查 CPSK 自身健康

```bash
# 版本 / 发布状态
cat VERSION
git tag -l | tail -5
git status --short

# skill 是否同步到 ~/.claude/skills/
diff -q skills/proj-onboard/SKILL.md ~/.claude/skills/proj-onboard/SKILL.md 2>/dev/null

# 图谱新鲜度
[ -L graphify-out/GRAPH_REPORT.md ] && \
  echo "图谱: $(( ($(date +%s) - $(stat -f %m graphify-out/GRAPH_REPORT.md)) / 86400 )) 天前"
```

## 🔑 敏感文件

**CPSK 没有真实密钥/数据**（这是 public 仓库）。但要特别注意：
- 写 examples/ 时**彻底脱敏**（项目名可留，密钥/域名/用户名替换）
- `.graphifyignore` 不扫 archive/
- `.gitignore` 排除 graphify-out/ .omc/

## 📚 权威文档位置

| 文档 | 路径 | 用途 |
|------|------|------|
| README | 本仓库 | 对外宣传 + 命令速查 |
| ONBOARDING | 本仓库 | 维护者新会话 |
| STATUS | 本仓库 | 维护进度 |
| 使用手册（详细）| Obsidian `工具/CPSK-工具链使用手册.md` | 完整工作流 + FAQ |
| 方法论 | 本仓库 `docs/1-10` | 为什么/如何 |
| 真实案例 | 本仓库 `examples/luxury-bag-copilot-案例分析.md` | 14 小时抢救 |
