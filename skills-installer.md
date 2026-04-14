# 安装 `/setup-kit` 全局 skill

> 装一次 skill，以后每个新项目打 `/setup-kit` 就能自动套用救命手册模板。

---

## 🚀 一键安装（推荐）

在任何 Claude 窗口里贴这段：

```
请把 https://raw.githubusercontent.com/hailanlan0577/claude-project-survival-kit/main/skills/setup-kit/SKILL.md
下载并保存到 ~/.claude/skills/setup-kit/SKILL.md。
如果目录不存在就创建。装好后告诉我可以打 /setup-kit 触发。
```

Claude 会用 `curl` 或 `mkdir + Write` 工具一次搞定。

---

## 🛠️ 手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/hailanlan0577/claude-project-survival-kit.git ~/claude-survival-kit

# 2. 复制 skill 到全局
mkdir -p ~/.claude/skills/setup-kit
cp ~/claude-survival-kit/skills/setup-kit/SKILL.md ~/.claude/skills/setup-kit/
```

> **注意**：如果你从 GitHub 仓库根目录看到这个文件，`setup-kit` skill 的源文件实际在主分支 `skills/setup-kit/SKILL.md` 的位置（需要在本 repo 里加一下）。

---

## ✅ 验证安装

重启一个 Claude 窗口，打：

```
/setup-kit
```

应该能看到 skill 被触发。如果没反应，检查：

```bash
ls -la ~/.claude/skills/setup-kit/SKILL.md
cat ~/.claude/skills/setup-kit/SKILL.md | head -5
```

frontmatter 应该有 `name: setup-kit`。

---

## 🎯 用法

**场景 A：全新项目（还没写代码）**

```
mkdir ~/my-new-project && cd ~/my-new-project
```

然后开 Claude 窗口，打：

```
/setup-kit
```

Claude 会：
1. 问你 10 个问题
2. 建目录结构
3. git init + 建 GitHub repo
4. 填模板 + 装 project-specific skill
5. 给你回报

---

**场景 B：已有项目（代码有了但没文档）**

```
cd ~/existing-project
```

然后：
```
/setup-kit
```

Claude 会补齐 7 件套，不动你的代码。

---

**场景 C：已有部分文档（只想加 skill）**

直接告诉 Claude：

```
我这个项目 <路径> 已经有 CLAUDE.md 和 RUNBOOK.md 了。
请按 claude-project-survival-kit 的模板补齐 ONBOARDING / OFFBOARDING，
并装两个项目专属 skill。
```

---

## 📚 参考

- 完整 skill 内容：[skills/setup-kit/SKILL.md](./skills/setup-kit/SKILL.md)
- 被触发的 skill 里会 clone 本仓库到 `/tmp/claude-survival-kit/` 拿模板
