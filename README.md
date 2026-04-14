# 📕 项目救命手册（Claude Project Survival Kit）

> **给和 Claude 合作做项目的非程序员：** 一套让你的每个项目都不会"丢"的标准文档骨架 + 会话交接工具。
>
> 新项目 30 分钟套用完，以后任何 Claude 窗口接手都能 60 秒进入状态。

---

## 🎯 这是什么？

你和 Claude 一起做了个项目。**三天后再聊**，新的 Claude 窗口一脸懵：
- 项目在哪个文件夹？
- 做到哪一步了？
- 之前踩过什么坑？
- 密钥丢了怎么办？
- 服务器挂了怎么恢复？

这套工具就是**解决这个问题**。核心是 **7 个标准文档 + 2 个一键 skill**，照着填就能让项目永不失联。

---

## 🤔 为什么需要它？（真实痛点）

我见过（并亲身经历过）这些场景：

| 场景 | 痛点 |
|------|------|
| 🕳️ 早上开新窗口 | Claude 从 0 开始摸索，浪费 30 分钟上下文 |
| 💀 电脑硬盘坏了 | 配置密钥全丢，项目无法恢复 |
| 🪤 以为 Phase 2 完成了 | 其实代码根本没 commit，重启会话一查发现什么都没有 |
| 🎭 多项目名字相似 | "奢侈品库存 App" vs "AI 买手" 搞混，改错项目 |
| 🔑 密钥被 Claude 推到 GitHub | 后悔莫及 |
| 🔄 每次部署靠手敲命令 | 一紧张少打一个字，服务挂掉 |

有这套手册在 + 定期备份 + Claude 看的开场白，**这些坑都能避过**。

---

## 🧱 包含哪些东西？

### 📄 7 个标准文档骨架（放在项目根目录）

| 文件 | 给谁看 | 什么时候读 | 变化频率 |
|------|--------|----------|----------|
| `ONBOARDING.md` | 新 Claude | **开新窗口时** | 🟡 偶尔 |
| `OFFBOARDING.md` | 当前 Claude | **下班/窗口快满时** | 🟢 几乎不变 |
| `CLAUDE.md` | Claude（自动加载） | 任何时候 | 🟡 偶尔 |
| `STATUS.md` | 所有人 | **每次会话结束追加** | 🔴 最勤 |
| `RUNBOOK.md` | 用户 | **出故障/要恢复时** | 🟢 很少 |
| `scripts/deploy.sh` | 脚本自动跑 | 每次部署 | 🟢 很少 |
| `.gitignore` | git 自动读 | 每次 commit | 🟢 几乎不变 |

### 🪄 2 个 Claude Code Skill（放在 `~/.claude/skills/`）

| Skill | 触发 | 作用 |
|-------|------|------|
| `<proj>-onboard` | 打 `/` 或说"继续项目" | 新 Claude 读手册后汇报状态 |
| `<proj>-offboard` | 打 `/` 或说"下班" | 按 8 步 checklist 存档 |

### 🎬 完整会话生命周期

```
[开新窗口]
   ↓
贴开场口令 / 打 /proj-onboard / 随口说"继续项目"
   ↓
Claude 读 ONBOARDING.md → 汇报状态 → 问你下一步
   ↓
（你指示 → Claude 干活 → 逐步进展）
   ↓
[窗口快满 / 你下班]
   ↓
贴收场口令 / 打 /proj-offboard / 随口说"存档"
   ↓
Claude 跑 8 步 checklist：
  1. 更新 STATUS.md 今天做了什么
  2. 新坑进 ONBOARDING 禁忌
  3. git commit + push
  4. 部署（如需要）
  5. 密钥同步（如有变化）
  6. CLAUDE.md 代码地图（如大变动）
  7. Qdrant 记忆存进度
  8. STATUS.md 末尾留"下次第一件事"
   ↓
关窗口，所有状态都保存
   ↓
[明天 / 下周 / 下个月 再开窗口 → 继续贴开场口令 → 无缝接上]
```

---

## 🚀 5 分钟：给新项目套用

### 第 1 步：克隆本仓库到本地

```bash
cd ~
git clone https://github.com/hailanlan0577/claude-project-survival-kit.git
```

### 第 2 步：复制 templates 到你的项目根目录

```bash
cd /path/to/your/project
cp ~/claude-project-survival-kit/templates/*.tpl .
cp ~/claude-project-survival-kit/templates/scripts/*.tpl scripts/
# 改名（去掉 .tpl）
for f in *.md.tpl; do mv "$f" "${f%.tpl}"; done
mv scripts/deploy.sh.tpl scripts/deploy.sh
chmod +x scripts/deploy.sh
```

### 第 3 步：对 Claude 说

> "按照 ~/claude-project-survival-kit/ 里的模板，把 `<占位符>` 都填成我这个项目的真实信息。项目是做什么、源码在哪、GitHub 地址、部署目标、关键服务端点、密钥在哪。你填完给我看，我确认后再推 git。"

Claude 会读模板、问你关键信息、自动填充。

### 第 4 步：复制 skill 到全局

```bash
# 替换 <proj> 为你项目的缩写（比如 lbc、ccr、myapp）
PROJ=<proj>
mkdir -p ~/.claude/skills/${PROJ}-onboard ~/.claude/skills/${PROJ}-offboard
cp ~/claude-project-survival-kit/skills/proj-onboard/SKILL.md \
   ~/.claude/skills/${PROJ}-onboard/SKILL.md
cp ~/claude-project-survival-kit/skills/proj-offboard/SKILL.md \
   ~/.claude/skills/${PROJ}-offboard/SKILL.md
# 改 skill 内容里的 <proj> 和项目路径
```

或者让 Claude 帮你：
> "把 `~/claude-project-survival-kit/skills/` 里的两个 skill 复制到 `~/.claude/skills/`，项目缩写用 `<proj>`，项目路径用 `<path>`。"

### 第 5 步：首次 commit

按 Claude 填好的 `.gitignore` 扫一遍敏感文件，第一次 commit + push 到 GitHub private repo。

**✅ 完成。以后新开窗口打 `/<proj>-onboard` 即可接手。**

---

## 📚 深度阅读

| 文档 | 讲什么 |
|------|--------|
| [docs/1-为什么要救命手册.md](./docs/1-为什么要救命手册.md) | 背景故事 + 没这套工具的惨痛代价 |
| [docs/2-七件套骨架详解.md](./docs/2-七件套骨架详解.md) | 每个文件应该写什么、不该写什么 |
| [docs/3-密钥管理三位一体.md](./docs/3-密钥管理三位一体.md) | 密钥存哪不会丢、不会泄露 |
| [docs/4-备份分层.md](./docs/4-备份分层.md) | 哪些要备份、哪些不用备份、每多久 |
| [docs/5-git-起步-6-步.md](./docs/5-git-起步-6-步.md) | 新项目第一次建 git 的顺序（防密钥泄露） |
| [docs/6-10-题万无一失自检.md](./docs/6-10-题万无一失自检.md) | 10 个问题检查你准备得够不够 |

---

## 💡 真实案例

[examples/luxury-bag-copilot-案例分析.md](./examples/luxury-bag-copilot-案例分析.md) — 一个真实的 Go + Qdrant + 飞书 Bot 项目，完整走完这套方法论的全过程。

包含：
- 项目背景（二奢 AI 买手）
- 从"没有 git"到"完整交接套件"走了哪 9 步
- 中途发现的 5 个真实陷阱
- 最终文档和 skill 长啥样

---

## ❓ FAQ（非程序员常见问题）

### Q：我一个项目做不完又开了新项目，这套怎么搞？

每个项目**独立一套 7 件套 + 2 个 skill**。

```
/Users/你/
├── 项目 A/                ← 7 件套
├── 项目 B/                ← 7 件套
└── .claude/skills/
    ├── projA-onboard/    ← 项目 A 专属 skill
    ├── projA-offboard/
    ├── projB-onboard/    ← 项目 B 专属 skill
    └── projB-offboard/
```

### Q：救命手册要天天改吗？

不用。**只有 `STATUS.md` 每次会话结束追加**，其他 6 个文件只在"大事"发生时才动（加新模块、换部署方式、发现新坑）。

### Q：我不会 git 怎么办？

[docs/5-git-起步-6-步.md](./docs/5-git-起步-6-步.md) 有傻瓜步骤。或者直接让 Claude 帮你：

> "按 ~/claude-project-survival-kit/docs/5-git-起步-6-步.md 给我这个项目初始化 git 并推到 GitHub private。"

Claude 会一步步引导你。

### Q：我的密钥泄露到 GitHub 了怎么办？

立刻去看**你项目的 RUNBOOK.md § 10.9**（模板已经写好紧急处理流程：轮换 → filter-repo → 验证）。

### Q：skill 和 slash 命令是什么？

- **Skill** = 装在 Claude Code 里的"预设剧本"
- **Slash 命令** = 用 `/` 开头的快捷调用（比如 `/lbc-onboard`）
- 两者一起：你打 `/项目-onboard`，Claude 读对应剧本执行

### Q：我的项目完全没有服务器、只是本地跑，也要这套吗？

**yes**，简化版也要。至少：
- `STATUS.md` 记今天做了什么（防自己忘）
- `ONBOARDING.md` 让新 Claude 快速接手
- `CLAUDE.md` 告诉 Claude 项目在哪

可以删掉 `RUNBOOK.md` 里和"服务器运维"相关的章节，只保留 git/备份部分。

### Q：我能 fork 这个仓库吗？

可以！随便 fork、随便改、改出更好的方案欢迎发 PR。

### Q：我能推荐给朋友吗？

非常欢迎。非程序员朋友尤其需要。

---

## 🛠️ 反馈 & 改进

发现问题 / 想改进 / 不懂哪里：

- 开 issue：https://github.com/hailanlan0577/claude-project-survival-kit/issues
- 或直接让你的 Claude 看完后帮你改：
  > "Claude，我觉得 ONBOARDING 这段不够清楚，帮我改一下，并给我 fork 一份发 PR 过去。"

---

## 📜 License

MIT —— 随便用。

---

## 🙏 致谢

- Anthropic 做出了 Claude Code
- 灵感来源：YC 的"founders 要记住关键决策"文化 + 运维团队的"runbook"传统
- 本项目第一个落地案例：`luxury-bag-copilot`（二奢 AI 买手 Copilot）
