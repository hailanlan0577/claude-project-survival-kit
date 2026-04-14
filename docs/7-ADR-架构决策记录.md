# 7. ADR — 架构决策记录（Architecture Decision Records）

> 每做一个重要决策，写一篇 markdown 存起来。
> 6 个月后回来问"当时为什么选 X 不选 Y"，翻 ADR 就有答案。

---

## 😱 没有 ADR 的痛（真实故事）

> 2026-04-14 早上，Claude 读 luxury-bag-copilot 设计文档 1777 行，花 15 分钟才理解"为什么砍掉 PostgreSQL"。
>
> 如果当时写了一篇 **ADR-0001: 用 Qdrant 不用 PostgreSQL**（200 字），Claude 1 秒就懂。

---

## 🎯 什么是 ADR

**一种轻量级决策日志**。每个大决策一篇 markdown，放在 `docs/adr/` 目录。

特点：
- **短**：200-500 字
- **聚焦"为什么"**：不写"怎么做"（代码已经说了）
- **不可变**：决策一旦定，ADR 不删除，只标 `Deprecated` 或 `Superseded`
- **编号**：ADR-0001 / 0002 / 0003...

---

## 📄 标准格式（MADR）

```markdown
# ADR-0001: <决策标题>

## 状态
Accepted（2026-04-08）

## 背景
<当时有什么约束？有哪些备选？为什么要决定？>

## 决策
<我们决定做什么？一两句话。>

## 后果
### ✅ 好处
### ⚠️ 坏处 / 取舍
### 🔮 未来可能要改的信号
```

详细模板见 [templates/docs/adr/0000-adr-template.md.tpl](../templates/docs/adr/0000-adr-template.md.tpl)。

---

## 💡 什么决策值得写 ADR？

**值得写**：
- ✅ 选 A 技术栈而不是 B（Qdrant vs PostgreSQL）
- ✅ 部署方式（Mac Mini vs 云）
- ✅ 核心数据 schema（为什么 payload 长这样）
- ✅ 第三方集成选型（飞书 vs 钉钉 vs 企业微信）
- ✅ 安全/合规决策（为什么要加这个校验）
- ✅ 临时走不了标准路的"绕路"方案（如 mitmproxy 拦截爬虫）

**不值得写**：
- ❌ bug 修复（commit message 够了）
- ❌ 改个变量名
- ❌ 改 UI 文案
- ❌ 日常 refactor

**判断标准**：6 个月后的自己会困惑"为啥当初这么做？"的事情 → 值得写。

---

## 🔢 编号 & 生命周期

### 编号
按时间顺序 `0001 / 0002 / 0003 ...`。**永远不复用编号**，即使某个 ADR 被废弃。

### 生命周期

```
Proposed ──> Accepted
              │
              ├─> Deprecated（这个决策不再适用，但历史保留）
              │
              └─> Superseded by ADR-00XX（被更新的决策取代）
```

### 覆盖决策的例子

假如 ADR-0003 说"用 Redis 做去重"，半年后发现 Redis 太重，决定用本地文件：

1. **新写 ADR-0015**: 用本地文件去重替代 Redis
2. **修改 ADR-0003** 的状态：`Superseded by ADR-0015`
3. **保留 ADR-0003 原文**（不要删），因为它记录了当时的思考

这样历史决策链完整，6 个月后的自己能看到"**Redis → 文件**"的演变路径。

---

## 🏢 大厂怎么做

| 公司 | 做法 |
|------|------|
| **Amazon** | [6-pager](https://writingcooperative.com/the-anatomy-of-an-amazon-6-pager-fc79f31a41c9) — 大决策前写 6 页纸，会议上静默读 20 分钟再讨论 |
| **ThoughtWorks** | 发明者。在 [Technology Radar](https://www.thoughtworks.com/radar) 里公开推荐 |
| **Spotify / Netflix** | 用 RFC（Request for Comments）— 决策讨论阶段的草案 |
| **Google** | 内部 design doc 文化，类似 ADR 但更重 |
| **大多数开源项目** | ADR 在 `docs/adr/` 或 `docs/decisions/`，PR 必带 |

---

## 🛠️ 工具

### 轻量（推荐个人项目）
- 手写 markdown，按本仓库 [模板](../templates/docs/adr/0000-adr-template.md.tpl) 填

### 进阶
- [**adr-tools**](https://github.com/npryce/adr-tools) — shell 工具
  ```bash
  brew install adr-tools
  adr init docs/adr
  adr new "用 Qdrant 不用 PostgreSQL"   # 自动编号
  adr new -s 3 "用本地文件替代 Redis"    # 说明取代 ADR-0003
  ```
- [**Log4Brains**](https://github.com/thomvaill/log4brains) — 把 ADR 渲染成网站

---

## 📚 实战样本

**真实案例**：luxury-bag-copilot 项目有 3 个 ADR（参考 [examples/luxury-bag-copilot-案例分析.md](../examples/luxury-bag-copilot-案例分析.md)）：

| ADR | 决策 | 背景 |
|-----|------|------|
| 0001 | 用 Qdrant 不用 PostgreSQL | 需要多模态向量检索 + filter_rules 放飞书 |
| 0002 | 部署到 Mac Mini 不用云 | 成本 + 数据主权 + 24h 开机 |
| 0003 | 爬虫接入用 mitmproxy 不用官方 API | 商业爬虫 webhook 硬校验 URL 绕不过 |

---

## 🎁 给非程序员的建议

1. **不要追求完美**：写 100 字也比不写好
2. **写当下的理由**：6 个月后你可能不同意，但那时候的理由是真实的
3. **配合 commit**：commit message 里写"See ADR-0005"，决策和代码就串起来了
4. **每周 review**：看看最近做的决策有没有漏写 ADR
5. **配合 ONBOARDING.md**：ADR 可以放进文档读取优先顺序表里
