# 8. SemVer — 语义化版本号

> 给你的项目打版本号。3 条规则，终身受用。

---

## 🎯 规则（就 3 条）

版本号格式：`v主.次.修` = `v MAJOR . MINOR . PATCH`

| 位 | 什么时候 +1 | 例子 |
|----|-------------|------|
| **MAJOR** 主 | 破坏性变化（旧代码不兼容）| 改 API 签名 / 改数据库 schema / 改配置格式 |
| **MINOR** 次 | 新功能（向下兼容）| 加新页面 / 加新端点 / Phase 3 完成 |
| **PATCH** 修 | bug 修复 / 小优化 | 修 typo / 修按钮错位 |

---

## 🎭 类比：手机系统升级

- iOS **17** → **18**：大变样（MAJOR）
- iOS 18.**0** → 18.**1**：加新功能（MINOR）
- iOS 18.1.**0** → 18.1.**1**：修 bug（PATCH）

---

## 📈 个人项目典型版本线

```
v0.1.0  ─  首个能跑的原型
v0.1.1  ─  修 bug
v0.2.0  ─  加了新功能 / Phase 2 完成
v0.3.0  ─  加更多功能 / Phase 3 完成
  ...
v1.0.0  ─  ⭐ 第一个"产品级"版本（老板/用户认可）
v1.0.1  ─  上线后第一个 hotfix
v1.1.0  ─  加了新 Phase
v2.0.0  ─  大重构 / 破坏性变化
```

**关键**：`v0.x` 代表"开发中，API 可能变"，`v1.x` 才算"对外稳定"。

---

## 🛠️ 怎么打版本

### 1. 创建本地 tag

```bash
git tag -a v0.2.0 -m "Phase 2 三段筛选管线跑通"
```

### 2. 推到 GitHub

```bash
git push origin v0.2.0
```

### 3. 建 GitHub Release（网页操作）

1. 打开 `https://github.com/<user>/<repo>/releases`
2. 点 **Draft a new release**
3. **Choose a tag**：选 `v0.2.0`
4. **Release title**：`v0.2.0 — Phase 2 完成`
5. **Describe this release**：按下面 Changelog 格式写
6. **Attach binaries**：⭐ 上传编译好的 binary 作为附件（异地备份）
7. 点 **Publish release**

---

## 📝 Release Notes 标准格式（Keep a Changelog）

```markdown
# v0.2.0 — 2026-04-13

## 🎉 新增（Added）
- Phase 2 三段筛选管线（品类过滤 + 向量召回 + 价格评分）
- 飞书中转群 + 5 秒轮询
- Win mitmproxy 拦截爬虫

## 🐛 修复（Fixed）
- Excel 价格字段 ¥ 符号解析

## 🔄 变更（Changed）
- 配置字段 `feishu.chat_id` 重命名为 `feishu.relay_chat_id`（**破坏性**）

## ⚠️ 已知问题（Known Issues）
- price_sold=0 阻塞评分

## 📦 附件
- `server-phase2-20260413.bin` (24MB, MD5 2607df52...)
```

---

## 🧩 配合 Conventional Commits

你已经在用 `feat:` / `fix:` / `docs:` 前缀。SemVer 可以**从 commit message 自动推断版本号**：

| Commit 类型 | SemVer 影响 |
|-------------|-------------|
| `feat:` 新功能 | MINOR +1 |
| `fix:` 修 bug | PATCH +1 |
| `feat!:` 或 `BREAKING CHANGE:` | MAJOR +1 |
| `docs:` / `chore:` / `refactor:` | 不升版本 |

工具 [`semantic-release`](https://github.com/semantic-release/semantic-release) 能读 commit 自动：
- 推算下一个版本号
- 打 tag
- 生成 CHANGELOG
- 发 GitHub Release

---

## 💡 为什么对个人项目也有用

### 1. 老板用时能**锁版本**
老板说"v1.3 有个 bug"，你说"回滚到 v1.2" — 命令简单：
```bash
git checkout v1.2.0
bash scripts/deploy.sh
```

### 2. Binary 副本有**归宿**
你的 `deploy/server-phase2-20260413.bin` 其实就是 v0.2.0 的产物。
命名改成 `deploy/server-v0.2.0.bin` 立刻和 tag 关联，6 个月后也知道是哪个 commit 编译的。

### 3. 故障排查有**锚点**
日志说"服务器跑 v0.2.0"，你立刻 `git checkout v0.2.0` 看当时的源码。

### 4. GitHub Release 自带**异地备份**
GitHub Release 的 binary 附件可以到 **2GB/个**，你那个 24MB binary 随便传。**等于白送一份异地备份**。

---

## 📦 版本号策略（按项目成熟度）

| 阶段 | 版本 | 特点 |
|------|------|------|
| 原型 | `v0.0.x` | 天天改，不 care 兼容 |
| 开发中 | `v0.1.0 ~ v0.9.x` | 分阶段迭代 |
| 首次投产 | `v1.0.0` | ⭐ 重要里程碑 |
| 稳定迭代 | `v1.x.x` | 按需 MINOR / PATCH |
| 大重构 | `v2.0.0` | 破坏性变化才 MAJOR |

**建议**：**每完成一个 Phase 打一个 tag**。哪怕只是 `v0.1.0 → v0.2.0`，也是一个历史锚点。

---

## 🆘 紧急情况：发布后才发现有致命 bug

### 场景 A：bug 在 v1.2.0，你已经 v1.3.0

```bash
# 给 v1.2.x 补 PATCH 发布（hotfix）
git checkout v1.2.0
git checkout -b hotfix/1.2.1
# 改 bug + commit
git tag v1.2.1
```

### 场景 B：GitHub Release 发错了

1. 把 Release 改成 **Pre-release** 或 **Draft**
2. 或者直接删掉（Release 可以删，tag 保留）
3. 重新打 tag：`git tag v1.3.1`（绕过 v1.3.0）

---

## 🏢 大厂习惯

| 产品 | 版本规范 |
|------|---------|
| **Node.js** | 严格 SemVer，每年 LTS |
| **Kubernetes** | `v1.29.0` 格式，3 个月一个 MINOR |
| **Python** | `3.12.1` 格式，但 MAJOR 升级非常慎重（3 → 4 估计不会有了） |
| **Chrome** | MAJOR 每 4 周 +1，几乎是"滚动版本号" |
| **小项目** | 按需，不强制 |

---

## 🎁 luxury-bag-copilot 建议的版本线

```
v0.1.0  2026-04-08  Phase 0 基础设施 + Phase 1 首次入库跑通
v0.1.1  2026-04-09  Excel 解析 bug 修复
v0.2.0  2026-04-13  Phase 2 三段筛选管线跑通  ⭐
v0.2.1  2026-04-14  救命套件 + 文档补全
v0.3.0  2026-04-??  Phase 3 反馈闭环
v1.0.0  2026-04-??  老板实测认可（首个产品级）
```

---

## 📚 相关资源

- [Semantic Versioning 2.0 官方规范](https://semver.org/lang/zh-CN/)（中文）
- [Keep a Changelog](https://keepachangelog.com/zh-CN/)（Release Notes 格式）
- [Conventional Commits](https://www.conventionalcommits.org/zh-hans/v1.0.0/)（commit 规范）
