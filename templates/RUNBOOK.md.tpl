# <项目名> 救命手册（RUNBOOK）

> 场景驱动，遇到什么情况查哪里。非程序员友好。

## 🆘 场景索引

| 我现在... | 去看 |
|-----------|------|
| 开新 Claude 会话想继续 | [§ 1 会话交接](#-1-会话交接) |
| 改完代码想部署 | [§ 2 日常部署](#-2-日常部署) |
| 服务不响应/挂了 | [§ 3 服务故障](#-3-服务故障) |
| 部署目标换机/重装 | [§ 4 从零重建](#-4-从零重建) |
| 数据库/资产丢了 | [§ 5 备份恢复](#-5-备份恢复) |
| 密钥/配置丢了 | [§ 6 密钥恢复](#-6-密钥恢复) |
| 不确定当前系统状态 | [§ 7 健康检查](#-7-健康检查) |
| 定期该做啥 | [§ 8 定期维护](#-8-定期维护) |
| 外部依赖概览 | [§ 9 外部依赖清单](#-9-外部依赖清单) |
| 想用 git 做日常操作 | [§ 10 Git 日常速查](#-10-git-日常速查非程序员友好) |

---

## § 1 会话交接

**情景**：开新 Claude 会话，想继续这个项目。

**操作**：对 Claude 说："继续 `<项目名>`"。

**原理**：Claude Code 会自动读取仓库根的 `CLAUDE.md` 和 `STATUS.md`。

**如果 Claude 还是一头雾水，强制它读**：
> 项目在 `<绝对路径>`。先读 `CLAUDE.md`、`STATUS.md`、`RUNBOOK.md` 再说话。

---

## § 2 日常部署

### 2.1 一键部署
```bash
cd <项目路径>
bash scripts/deploy.sh
```

### 2.2 只重启
```bash
bash scripts/deploy.sh --restart
```

### 2.3 回滚上一个版本
<具体回滚命令>

---

## § 3 服务故障

### 3.1 服务还活着吗
<检查进程命令>

### 3.2 看日志
<查日志命令>

### 3.3 依赖服务检查
<docker/systemctl/其他>

### 3.4 容器挂了/服务挂了
<启动命令>

---

## § 4 从零重建

**情景**：部署目标硬盘坏了 / 换新机器 / 系统重装。

### 4.1 装基础环境
<安装步骤>

### 4.2 拉容器 / 装依赖
<步骤>

### 4.3 克隆代码
```bash
git clone <GitHub URL>
```

### 4.4 恢复 config.yaml
<恢复方式 - 从备份或 credentials.md 拼回>

### 4.5 恢复服务定义（LaunchAgent/systemd）
<复制 plist / unit 文件到系统位置>

### 4.6 恢复数据 + 资产
见 § 5

### 4.7 首次部署
```bash
bash scripts/deploy.sh
```

---

## § 5 备份恢复

### 5.1 数据库（Qdrant/Postgres/其他）

**备份**（每周一次）：
<具体备份命令>

**恢复**：
<具体恢复命令>

### 5.2 <关键资产 2>

**备份**：
<命令>

**恢复**：
<命令>

### 5.3 config.yaml
- 权威副本：<位置>
- 同步命令：<scp/rsync>
- 密钥备份：`~/.claude/projects/*/memory/credentials.md`

---

## § 6 密钥恢复

所有密钥在 `~/.claude/projects/*/memory/credentials.md`，覆盖：
- <服务 1 密钥类型>
- <服务 2 密钥类型>

### GitHub PAT 过期
```bash
gh auth token  # 取活 token
```

---

## § 7 健康检查

一键脚本：
```bash
<完整健康检查命令组合>
```

---

## § 8 定期维护

| 频率 | 动作 |
|------|------|
| 每周 | 数据库 snapshot |
| 每月 | 磁盘清理 / 日志 rotate |
| 每次 deploy | MD5 自动记录 |
| 每月 | 外部服务用量检查（防突发账单） |

---

## § 9 外部依赖清单

| 依赖 | 用途 | 挂了的影响 | 联系方式 |
|------|------|-----------|---------|
| <服务 1> | | | |
| <服务 2> | | | |

---

## § 10 Git 日常速查（非程序员友好）

> 打比方：Git 就是代码的"时光机"，每次 `commit` 等于**拍张存档快照**，`push` 是**把快照传到 GitHub 云端**，`pull` 是**从云端拉最新**。

所有命令在项目根目录执行。

### 10.1 我改了什么还没提交？
```bash
git status            # 总览
git diff              # 详细
```

### 10.2 最近做了什么？
```bash
git log --oneline -10
```

### 10.3 改错了想丢弃
**⚠️ 永久丢弃，慎用：**
```bash
git restore <文件名>    # 丢弃某个文件
git restore .           # 丢弃所有未提交
git clean -fd           # 连新建文件一起清
```

### 10.4 回到昨天某个状态
```bash
git log --oneline             # 找 hash
git revert <hash>             # 撤销（安全）
git reset --hard <hash>       # ⚠️ 危险，除非确定
```

### 10.5 对比本地 vs GitHub
```bash
git fetch
git log HEAD..origin/main --oneline   # GitHub 有本地没
git log origin/main..HEAD --oneline   # 本地有 GitHub 没
```

### 10.6 新机器克隆
```bash
brew install gh
gh auth login --hostname github.com --web
git clone <GitHub URL>
```

### 10.7 GitHub PAT 过期
```bash
gh auth token  # 或 gh auth login
```

### 10.8 看某 commit
```bash
git show <hash>
```

### 10.9 🚨 不小心把密钥推到 GitHub 了

**3 步抢救：**

1. **立刻轮换所有泄露的密钥**（去各服务控制台 revoke + 创建新的）
2. **从 git 历史里彻底抠掉**：
   ```bash
   brew install git-filter-repo
   git filter-repo --path configs/config.yaml --invert-paths --force
   git push --force
   ```
3. **验证清理干净**：
   ```bash
   git log --all --full-history -- configs/config.yaml   # 应该啥都没有
   ```

**预防**：每次 commit 前 `git status --ignored --short` 确认敏感文件在 `!!` 列表。

### 10.10 常用小抄
```bash
git status                         # 看状态
git add <具体文件>                  # 别用 git add .
git diff --cached                  # 确认待提交内容
git commit -m "type: 描述"          # 拍快照（type = feat/fix/docs/chore）
git push                           # 推 GitHub
```

**关键规则**：
- ❌ 别用 `git add .` — 容易误加敏感文件
- ❌ 别用 `git reset --hard` — 除非 100% 确定
- ❌ 别用 `git push --force` — 除非这仓库只有你一个人
- ✅ commit message 加类型前缀
- ✅ 每次 commit 前 `git status` 看一眼
