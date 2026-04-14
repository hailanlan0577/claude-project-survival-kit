# 9. pre-commit hooks — 防密钥泄露的最后一道关

> git commit 时**自动运行检查**，发现敏感内容就阻止提交。
> 像机场安检，打火机上不了飞机。

---

## 🎭 类比：机场安检

- commit = 航班
- hook = 安检员
- 密钥 = 打火机
- `.gitignore` = 不让打火机进行李箱（源头防护）
- pre-commit hook = 你混过来了也拦在安检（第二道防线）
- `git-filter-repo` = 飞机降落后才发现带了打火机（善后处理）

**越早拦下成本越低**。

---

## 🚪 Git 提供的 hooks

Git 在操作的各个阶段都能插入脚本：

| Hook | 触发时机 | 典型用途 |
|------|---------|---------|
| `pre-commit` | `git commit` 后但提交前 | ⭐ **检查敏感内容、lint 代码** |
| `commit-msg` | commit message 写完后 | 检查 message 格式（feat: / fix:） |
| `pre-push` | `git push` 时 | 最后一道关（跑测试、扫密钥） |
| `post-merge` | 合并完成后 | 自动重装依赖、重启服务 |

**对非程序员，`pre-commit` 就够用了**。

---

## 🔧 三种实现方式（从轻到重）

### 方式 A：手写 bash 脚本（推荐个人项目）

**优点**：
- 零依赖
- 完全可控
- 3 分钟装好

**缺点**：
- `.git/hooks/` 不入 git，每个 clone 要重装

**装法**：
```bash
# 从本仓库复制
cp templates/hooks/pre-commit.sh.tpl /path/to/your-project/.git/hooks/pre-commit
chmod +x /path/to/your-project/.git/hooks/pre-commit

# 测试一下
cd /path/to/your-project
git commit --allow-empty -m "test"   # 应该看到 ✅ pre-commit 检查通过
```

**它检查什么**：
1. ⭐ staged 内容有没有疑似密钥（20+ 字符的 api_key / secret / password / token 值）
2. ⭐ 敏感文件名有没有进 staging（`.env` / `config.yaml` / `.key` / `credentials.md`）
3. ⚠️ 大文件警告（>5MB 提示确认，避免误推 binary）

### 方式 B：`pre-commit` 框架（Python 工具）

**优点**：
- 配置文件入 git，clone 后自动同步
- 社区贡献 300+ 检查器
- 团队统一规范

**缺点**：
- 要装 Python
- 首次运行慢（下载 hook 插件）
- 有点过度工程化对个人项目

**装法**：
```bash
brew install pre-commit

cd /path/to/project
cat > .pre-commit-config.yaml <<EOF
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-added-large-files
        args: ['--maxkb=5000']
      - id: detect-private-key
      - id: check-merge-conflict
      - id: check-yaml
      - id: end-of-file-fixer
EOF

pre-commit install
```

### 方式 C：专门密钥扫描工具（最精准）

#### `gitleaks`（推荐）

```bash
brew install gitleaks

# 扫 staged（配合 hook 用）
gitleaks protect --staged -v

# 扫整个 git 历史（一次性检查有没有泄露过）
gitleaks detect --source . -v

# 配合配置文件精调
cat > .gitleaks.toml <<EOF
[allowlist]
paths = [ ".*\\.example\\.yaml$", ".*\\.tpl$" ]
EOF
```

#### `trufflehog`（更激进，会**验证 key 是否真的有效**）

```bash
brew install trufflehog

# 扫 git 历史 + 验证
trufflehog git file://./ --only-verified
```

⚠️ `trufflehog --only-verified` 会**真的调用 API 测试 key**，跑一次不小心给你账号留"登录异常"记录，开发环境慎用。

---

## 🎯 推荐组合（按项目类型）

### 个人项目（完全自己用）
**方式 A**（手写 bash）+ 偶尔 `gitleaks detect` 扫历史一次。

### 小团队项目
**方式 B**（pre-commit 框架 + gitleaks）+ 配 CI 再扫一次（GitHub Actions）。

### 开源/商业项目
**方式 B** + **方式 C** + **CI 自动扫** + **GitHub Secret Scanning**（公开仓库 GitHub 自动扫）。

---

## 🆘 紧急场景

### 已经 commit 了敏感文件还没 push

```bash
# 撤销上次 commit（保留文件改动）
git reset --soft HEAD~1

# 把敏感文件从 staging 撤掉
git reset HEAD configs/config.yaml

# 把它加到 .gitignore
echo "configs/config.yaml" >> .gitignore

# 重新 commit
git add .gitignore
git commit -m "chore: add config.yaml to gitignore"
```

### 已经 push 到 GitHub 了

看 [RUNBOOK 模板 § 10.9](../templates/RUNBOOK.md.tpl) 或 [docs/3-密钥管理三位一体.md](./3-密钥管理三位一体.md) 里的紧急抢救 3 步：
1. 立刻轮换所有泄露的密钥
2. `git filter-repo` 从历史抠掉
3. 验证清理干净

---

## 💡 紧急绕过（慎用）

如果你 100% 确定 hook 报警是误报（比如 `config.example.yaml` 里的 placeholder 被识别成密钥）：

```bash
git commit -m "..." --no-verify
```

**别滥用这个参数**。用一次要在脑子里响警报："**我绕过了安全检查**"，不是随便打。

---

## 🧪 真实错报/漏报场景

### 错报（本来没事 hook 拦了）

- `config.example.yaml` 里写 `api_key: "example_api_key_placeholder_xxxx"` — 32 字符被识别
- **解决**：用 `api_key: "xxx"` 或 `api_key: "<your-key>"`（短于 20 字符）
- 或者用 hook 的 allowlist 排除 `*.example.yaml`

### 漏报（真密钥 hook 没拦）

- 密钥不带引号 `api_key: sk_abcdef...`
- 密钥在注释里 `# old key: sk_abcdef...`
- **解决**：升级到 gitleaks（更精准）

---

## 🎁 小确幸

装好 hook 后第一次看到 `✅ pre-commit 检查通过`，会有一种"**安全感**"。

再也不用 push 后心里打鼓"我刚才 `git add .` 了吗？有没有把 .env 搞进去？"。

—— 让安检员每次都替你检查一遍。
