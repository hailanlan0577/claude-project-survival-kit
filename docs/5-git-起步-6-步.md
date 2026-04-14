# 5. Git 起步 6 步（防密钥泄露）

> 给新项目第一次建 git 用。按这 6 步顺序走，**永不把敏感文件推公网**。

---

## 🎯 为什么要按顺序

常见错误顺序：
```
❌ 1. git init
❌ 2. git add .      ← 把密钥推进 staging
❌ 3. git commit -am "init"
❌ 4. 推 GitHub
❌ 5. 发现 config.yaml 在里面 → 抢救
```

正确顺序：
```
✅ 1. 先确认源码主分支在哪
✅ 2. 扫敏感文件
✅ 3. 写 .gitignore
✅ 4. 验证敏感文件在忽略列表
✅ 5. git init + add 具体文件 + commit
✅ 6. 建 GitHub private repo + push + 验证
```

---

## 第 1 步：确认源码主分支在哪

**常见场景**：
- 主力机 MacBook 上有一份源码
- 远程服务器（Mac Mini / VPS）上也有一份（可能是部署镜像）
- 两份内容不一样

**先搞清楚哪份是"真身"**：
```bash
# 在 MacBook 看
ls -la <项目路径>

# 在远程看
ssh <服务器> "ls -la <项目路径>"

# 对比关键文件修改时间
stat -f "%m %N" <关键文件 MacBook>
ssh <服务器> "stat -c '%Y %n' <关键文件 远程>"
```

**原则**：
- 开发地（你平时写代码的地方）是主分支
- 部署目标是**镜像**，不在这里 `git init`
- 两边不一致时，**以最新的为主**，同步另一边后再建 git

**教训来源**：luxury-bag-copilot 2026-04-14 误操作在 Mac Mini 上 git init，推了旧代码到 GitHub，又花 10 分钟纠正。

---

## 第 2 步：扫敏感文件

```bash
cd <项目路径>

# 通用扫描
find . -type f \( \
  -name "*.key" -o \
  -name "*.pem" -o \
  -name "*.env" -o \
  -name "config.yaml" -o \
  -name "*secret*" -o \
  -name "*password*" \
\) 2>/dev/null | grep -v node_modules
```

**看到任何输出 → 都要进 `.gitignore`。**

再补充扫描：

```bash
# 大文件（> 10MB）
find . -type f -size +10M | grep -v -E 'node_modules|\.git'

# 常见大目录
du -sh */ 2>/dev/null | sort -h
```

大文件（binary、数据库、node_modules、venv）也进 `.gitignore`。

---

## 第 3 步：写 `.gitignore`

从 [templates/.gitignore.tpl](../templates/.gitignore.tpl) 复制一份，按项目技术栈删减：

**保留适用的段**：
- 你用 Go？保留 `vendor/`
- 你用 Python？保留 `__pycache__/` `.venv/`
- 你用 Node？保留 `node_modules/` `.npm`

**无论什么项目都必须保留**：
- `configs/config.yaml` / `.env` / `.env.local`
- `bin/` / `dist/` / `build/`
- `data/` / `*.log`
- `.DS_Store` / `.vscode/` / `.idea/`

---

## 第 4 步：验证敏感文件被忽略

**这一步最重要，不能跳。**

```bash
# 还没 git init，先 stage 看看
git init -b main
git add -n .   # -n 是 dry-run，只看不动

# 或者完整一点：
git add .
git status --short
git status --ignored --short | grep '!!'
```

**手动检查**：
- staged 列表里**没有** `config.yaml` / `.env` / `.key`
- ignored 列表里**有** `config.yaml` / `.env` / `.key`

如果不对，撤销 `git add` 重新改 `.gitignore`：
```bash
git reset
```

**最后一道防线**：
```bash
# staged 内容扫一遍敏感文字
git diff --cached | grep -iE "api_key|secret|password|token"
```

有输出 = 有敏感内容混进去了。**停下来检查。**

---

## 第 5 步：commit（别用 `git add .`）

### ⚠️ 不要用 `git add .`

```bash
❌ git add .         # 容易误加敏感文件
❌ git add -A        # 同样问题
```

### ✅ 用具体文件

```bash
✅ git add <文件1> <文件2> <目录/>
```

或者分批：
```bash
git add README.md
git add configs/config.example.yaml  # 只加 example，不加真实 config
git add src/
git status --short
# 确认没漏、没多 → commit
git -c user.email='<you@example.com>' -c user.name='<你的名字>' commit -m "chore: initial commit"
```

### commit message 规范

| 前缀 | 用途 |
|------|------|
| `feat:` | 新功能 |
| `fix:` | 修 bug |
| `docs:` | 文档改动 |
| `refactor:` | 重构（不改功能） |
| `chore:` | 杂事（改 config、依赖等） |
| `test:` | 测试 |
| `perf:` | 性能优化 |

---

## 第 6 步：GitHub private repo + push + 验证

### 6.1 建 private repo

**推荐：含密钥的项目必选 private。**

```bash
# 确保本地 gh CLI 登录
gh auth status

# 建仓库
gh repo create <user>/<repo> --private \
  --description "<一句话描述>"
```

如果需要 public：
```bash
gh repo create <user>/<repo> --public \
  --description "..."
```

### 6.2 连接本地和远程

```bash
git remote add origin https://github.com/<user>/<repo>.git
git push -u origin main
```

如果 push 认证有问题：
```bash
TOKEN=$(gh auth token)
git -c credential.helper="!f() { echo username=<user>; echo password=$TOKEN; }; f" push -u origin main
```

### 6.3 🔴 立即在 GitHub 网页验证

打开 `https://github.com/<user>/<repo>`，**点进文件列表**：

- ✅ 看不到 `config.yaml`（只看到 `config.example.yaml`）
- ✅ 看不到 `.env`
- ✅ 看不到 `bin/` / `dist/`
- ✅ 有 `.gitignore`
- ✅ 有 README.md（哪怕先是空的）

**如果看到敏感文件** → 立刻按 RUNBOOK § 10.9 的紧急流程处理。

---

## 🎁 Bonus：建完 git 之后立刻做的事

### 建 `.gitignore` 之外的防护

1. **全局 gitignore**：
   ```bash
   git config --global core.excludesfile ~/.gitignore_global
   ```
   加入 `.DS_Store` `.vscode/` 等，全局忽略不依赖项目 `.gitignore`。

2. **pre-commit hook 扫敏感**：
   ```bash
   # .git/hooks/pre-commit
   #!/bin/bash
   if git diff --cached | grep -iE "api_key|secret|password|token" > /dev/null; then
     echo "❌ 检测到敏感内容！"
     exit 1
   fi
   ```
   别忘了 `chmod +x .git/hooks/pre-commit`。

3. **装 `git-secrets` 或 `trufflehog`**：
   ```bash
   brew install git-secrets
   git secrets --install
   git secrets --register-aws
   ```

---

## 📖 下一篇

[6-10-题万无一失自检.md](./6-10-题万无一失自检.md) — 10 个问题检查你准备得够不够。
