# CPSK 运维救命手册

> 维护 CPSK 时遇到问题就翻这份。9 个场景 + 发版速查 + git 抢救。

---

## § 1. 发版速查（最常用）

### PATCH 版（v0.3.1 → v0.3.2）— 修 bug / 补小 gap

```bash
cd /Users/chenyuanhai/claude-project-survival-kit

# 1. 改文件
# 2. 改 VERSION
echo "0.3.2" > VERSION

# 3. 改 CHANGELOG.md（加 [0.3.2] 段 + 底部 compare URL）

# 4. 验证
git status --short

# 5. 发版
git add VERSION CHANGELOG.md <改动文件>
git commit -m "fix(<scope>): v0.3.2 — <描述>"
git tag -a v0.3.2 -m "v0.3.2 — <主题>"
git push origin main
git push origin v0.3.2
```

### MINOR 版（v0.3.x → v0.4.0）— 加新功能

同上，commit message 用 `feat(<scope>):`。v0.y.0 时候**必须**在 CHANGELOG 写清楚"新增什么 / 迁移指南（若有）"。

### MAJOR 版（v0.x.x → v1.0.0）— 破坏性改动

- **必须**补完整 GitHub Release notes
- **必须**列出 breaking changes 清单
- 建议先 tag `v1.0.0-rc.1` candidate 给自己试

---

## § 2. 改了 skill 之后忘记同步到 `~/.claude/skills/`

**症状**：改了 `skills/proj-onboard/SKILL.md`，但 `/lbc-onboard` 跑起来还是老行为。

**原因**：`~/.claude/skills/` 里是**当初 setup-kit 装的快照**，不会自动同步 git 改动。

**解决**：
```bash
bash scripts/deploy.sh     # CPSK 自己的 deploy.sh 会重装所有 skill
```

**或者手动同步单个 skill**：
```bash
cp skills/proj-onboard/SKILL.md ~/.claude/skills/proj-onboard/SKILL.md
cp skills/proj-graphify/SKILL.md ~/.claude/skills/proj-graphify/SKILL.md
```

**注意**：per-project skill（`/lbc-onboard`）是 setup-kit 生成时**已填好占位符的副本**，改 `skills/proj-onboard/` 的模板不会自动回流到 `/lbc-onboard`——那是历史快照，要单独改。

---

## § 3. 紧急：密钥泄露到 public 仓库

**不要慌**：CPSK 是 public，任何 commit push 后都可能被扫描到。

### 🚨 抢救 3 步

```bash
# 1. 立刻 rotate key（去对应服务控制台换新的）
#    比如 DashScope / 飞书 app / GitHub PAT 等

# 2. git filter-repo 从历史抠掉
pip install git-filter-repo
git filter-repo --path-glob '*密钥所在文件*' --invert-paths
git push --force origin main   # ⚠️ 这是唯一允许的 --force 场景

# 3. 发通知
# - 如果 CPSK 有 star/fork 用户，在 GitHub Issues 发警告
# - 如果你自己其他项目的 key，全部 rotate
```

### 🛡️ 未来预防

CPSK 根目录有 `pre-commit` hook（docs/9-pre-commit-hooks.md）。**启用它**：
```bash
cp templates/hooks/pre-commit.sh.tpl .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

---

## § 4. GitHub push 401 Unauthorized

**症状**：`git push` 报 `remote: Invalid username or password`

**原因**：GitHub 密码登录早就废了，要用 PAT（Personal Access Token）。

**解决**：
```bash
TOKEN=$(gh auth token)
git -c credential.helper="!f() { echo username=hailanlan0577; echo password=$TOKEN; }; f" push
```

**永久方案**：装 macOS Keychain credential helper。

---

## § 5. graphify 图谱产不出（自诊）

**症状**：跑 `/proj-graphify` 报错或图谱为空。

**排查**：
```bash
# 1. graphify 装了吗
which graphify

# 2. graphify Python 能跑吗
python3 -c "import graphify"

# 3. 目标目录有文件吗
ls -la /Users/chenyuanhai/claude-project-survival-kit | head

# 4. .graphifyignore 是不是把全部文件都排除了
cat .graphifyignore
```

**常见原因**：
- `.graphifyignore` 写错了把所有 `*.md` 都排除
- 子代理 timeout（graphify extract 步骤）→ 手动跑 `graphify <path>`

---

## § 6. 改了 CHANGELOG 格式坏了

**症状**：Keep a Changelog 解析器（如果有自动化）报错。

**速查规则**：
- `## [Unreleased]` 永远在最上
- `## [x.y.z] — YYYY-MM-DD` 格式严格
- 每个版本下只用这 5 个标签：`Added` / `Changed` / `Deprecated` / `Removed` / `Fixed` / `Security`
- 底部 compare URL 格式：`[x.y.z]: https://.../compare/vOld...vNew`

**参考**：https://keepachangelog.com/zh-CN/1.1.0/

---

## § 7. 要回到某个历史版本查看文件

```bash
# 看 v0.1.0 时的 ONBOARDING.md 长啥样
git show v0.1.0:templates/ONBOARDING.md.tpl

# checkout 到 v0.1.0 对比差异（临时）
git checkout v0.1.0 -- templates/ONBOARDING.md.tpl
# 看完后恢复
git checkout HEAD -- templates/ONBOARDING.md.tpl
```

---

## § 8. 新加一个 skill，要做哪几件事

以加 `/new-skill` 为例：

1. 在 `skills/new-skill/` 建 `SKILL.md`（frontmatter + 内容）
2. 如果是**全局 skill**：`cp skills/new-skill/SKILL.md ~/.claude/skills/new-skill/`
3. 如果是**项目模板 skill**：改 setup-kit 流程，让它在新项目时装
4. 在 README.md 的命令速查加一行
5. 改 CHANGELOG.md 的 `[Unreleased]` 段（Added 一条）
6. 改 Obsidian `工具/CPSK-工具链使用手册.md`（装备清单表加一行）
7. 发版 MINOR（新 skill 属于新功能）

---

## § 9. 把 CPSK 分享给别人

**目前最简版**：
```
https://github.com/hailanlan0577/claude-project-survival-kit
```

**引导语** 3 版本（长中短）见 README.md 末尾，或 Obsidian 手册的"推广段"。

---

## § 10. 换电脑 / 重装 Claude Code

**恢复 CPSK 步骤**：
```bash
# 1. clone 项目
cd ~
git clone https://github.com/hailanlan0577/claude-project-survival-kit.git

# 2. 装 graphify（可选）
pip install graphifyy && graphify install

# 3. 装 CPSK 自己的 skill（dogfood）
cd claude-project-survival-kit
bash scripts/deploy.sh

# 4. 验证
ls ~/.claude/skills/ | grep -E "(setup-kit|proj-|obsidian-)"
```

---

## 附：git 速查表

```bash
# 撤销未 commit 的改动
git checkout -- <文件>

# 撤销已 commit 但未 push 的
git reset --soft HEAD~1        # 保留改动
git reset --hard HEAD~1        # 彻底撤销 ⚠️

# 改最近一次 commit message（未 push）
git commit --amend -m "新消息"

# 查某个文件谁在哪一行改的
git blame <文件>

# 谁改了这个函数
git log -p --all -S "functionName"
```
