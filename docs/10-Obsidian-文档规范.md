# 10. Obsidian 文档规范（给和 Claude 一起写文档的人）

> 把"救命手册"的方法论从**代码仓库**推广到 **Obsidian 笔记**。
>
> 让你写的设计文档、进度记录、决策日志都按标准来 — 新 Claude 看到能秒懂、6 个月后的自己能看懂、甚至你给朋友看也不尴尬。

---

## 😱 典型痛点

你可能有过这些时刻：

> "这个项目的最终方案是哪个文档？我怎么看到 5 个不同的设计文档…"
>
> "6 个月前写的决策，为什么选 A 不选 B 现在想不起来了"
>
> "新 Claude 窗口打开我的 vault 不知道该读哪篇"
>
> "1800 行的设计文档，想找一个决策点要 Ctrl+F 半天"

都是**信息架构（IA）问题**，不是你写得不好。

---

## 📋 文档类型分类（6 大类）

每个文档**都有固定的"角色"**。弄清类型 → 按对应模板写。

| 类型 | 用途 | 典型长度 | 变化频率 |
|------|------|---------|---------|
| **Design Doc**（设计文档）| 讲清一个产品/功能的设计 | 500-2000 行 | 🟡 阶段性重写 |
| **Project README**（项目索引）| 项目入口，告诉读者从哪开始读 | 50-200 行 | 🟢 偶尔 |
| **Progress Log**（进度日志）| 按时间记录每天/每周做了啥 | 持续滚动 | 🔴 最勤 |
| **ADR**（架构决策记录）| 一个决策 = 一篇 200 字 markdown | 100-300 行 | 🟢 几乎不变 |
| **Retro**（复盘）| 阶段结束后的反思 | 200-500 行 | 🟡 每季度 |
| **Brainstorm**（头脑风暴）| 想法还没定型时的草稿 | 无限制 | 🔴 → 成型后转 Design Doc |

---

## 🧱 每类文档的"8 件套"结构

### Design Doc 必备 8 要素（大厂标准）

1. **Problem Statement**（问题陈述）— 谁的痛？多痛？定量
2. **Goals / Non-Goals**（目标/非目标）— 明确要做啥、不做啥
3. **Design Options**（方案对比）— A/B/C/D/E 表格
4. **Decision + Rationale**（决策+理由）— 选了哪个？为什么？
5. **Alternatives Considered**（备选）— 否决的方案+原因
6. **Risks / Mitigations**（风险/缓解）— 什么会失败？怎么防？
7. **Success Metrics**（成功指标）— 怎么知道做成了？
8. **Open Questions**（待定问题）— 还没想清楚的

外加 3 个"组织性要素"：
- **Version History**（版本历史）— 每次改记一条
- **TOC**（目录）— 长文档必需
- **Related Docs**（相关文档）— 用 `[[]]` 连到 ADR / 代码仓库

---

## 🏷️ Frontmatter 规范

**所有文档顶部**统一加这段 YAML：

```yaml
---
title: {{一句话标题}}
type: design-doc | project-readme | progress-log | adr | retro | brainstorm
version: 1.0.0
status: Draft | Active | Deprecated | Superseded
supersedes: "[[老文档]]"         # 如果本文取代了其他文档
superseded_by: "[[新文档]]"      # 如果本文被其他文档取代
owner: {{你的名字}}
created: 2026-04-14
last_updated: 2026-04-14
tags: [项目名, 类型, 关键词]
---
```

**关键字段：**

- `status`:
  - `Draft`：草稿（还没确定）
  - `Active`：当前有效
  - `Deprecated`：已废弃，仅保留历史
  - `Superseded`：被新文档取代

- `supersedes` / `superseded_by`: Obsidian 双链 `[[]]`，点进去能跳

---

## 📁 文件夹组织规范

### 按项目分文件夹（不是按类型）

```
Obsidian Vault/
├── 项目A/
│   ├── 00-README.md               # 🆕 项目索引，从这里开始读
│   ├── 01-设计文档.md              # 当前 Active 设计
│   ├── 02-进度日志.md              # 滚动更新
│   ├── adr/                       # 决策记录
│   │   ├── 0001-决策一.md
│   │   └── 0002-决策二.md
│   ├── retro/                     # 复盘
│   │   └── 2026-Q2-复盘.md
│   └── archive/                   # 🆕 废弃文档放这里
│       └── 旧设计文档-v1.md
├── 项目B/
│   └── ...
└── 工具方法论/                     # 不属于具体项目的
    ├── 项目救命手册-通用模板.md
    └── 标准程序员工作流-完整参考.md
```

**核心原则**：
- **按项目分，不是按文档类型分** — 一个项目的所有文档在一起
- **每个项目根必有 README.md** — 作为导航入口
- **废弃文档移到 `archive/` 子目录** — 留着做证据，但不挡视线

---

## 🎨 Obsidian 专属特性（要用起来）

### 1. Wikilinks `[[]]`
```markdown
本方案取代 [[AI买手Copilot-设计文档]]，详见 [[ADR-0001 用 Qdrant 不用 PostgreSQL]]
```
**优势**：重命名文件自动更新所有引用，不会死链。

### 2. Callouts
```markdown
> [!warning] 已废弃
> 本文档已被 [[新文档]] 取代。仅为历史保留。

> [!info] 设计理念
> 本项目的核心是...

> [!danger] 踩过的坑
> 千万别在 Mac Mini 上 git init
```

### 3. Properties（Obsidian 1.4+ 对 frontmatter 的 UI）
上面的 frontmatter 在 Obsidian 会自动渲染成可编辑属性面板。

### 4. Dataview 查询（自动生成索引）
```markdown
## 当前所有 Active 设计文档

```dataview
TABLE version, last_updated, file.folder as "项目"
FROM ""
WHERE type = "design-doc" AND status = "Active"
SORT last_updated DESC
```
```

### 5. TOC 目录（长文档必加）
手动或用 `obsidian-toc-plugin` 自动生成。

### 6. 嵌入 `![[]]`
```markdown
![[另一文档#章节名]]   # 嵌入别的文档的某个章节
```

---

## 🚦 命名规范

### 好的命名

```
✅ AI买手Copilot-经验数据库-设计文档.md
✅ AI买手Copilot-开发进度-2026-Q2.md
✅ ADR-0001-用-Qdrant-不用-PostgreSQL.md
✅ Retro-2026-04-Phase2上线.md
```

特点：
- **项目名前缀**：避免跨项目混淆
- **类型后缀**：一眼看出是啥
- **连字符分词**：比空格更稳

### 糟糕的命名

```
❌ 未命名.md
❌ 设计文档.md               # 哪个项目？
❌ 设计文档-v2-final-FINAL.md  # 为啥有多版？用 frontmatter version
❌ 我的想法.md                # 太泛
```

---

## ⚡ 长文档处理

**超过 500 行就考虑拆**：

### 拆分前（1839 行单文件）
```
AI买手Copilot-经验数据库-设计文档.md   1839 行
```

### 拆分后（模块化）
```
AI买手Copilot-经验数据库/
├── 00-索引.md              # 导航 + 快速概览
├── 01-核心决策.md           # 决策 1-5
├── 02-技术细节.md           # Qdrant 配置、API 调用
├── 03-评审记录.md           # C1-C4 / H1-H3 / M1-M5
└── 04-进度日志.md           # 按日期追加的开发记录
```

**每个子文档独立可读**，索引页用 `[[]]` 串起来。

---

## 🧹 文档生命周期管理

### 1. 写新文档
用 `/obsidian-new-doc` skill（见本 kit 的 skills/）触发：
```
你：/obsidian-new-doc
Claude: 你要写什么类型？
  1. Design Doc
  2. Project README
  3. ADR
  4. Progress Log
  5. Retro
  6. Brainstorm
你：1
Claude: 项目名？文件放哪？
  （然后复制对应模板到指定位置，填好 frontmatter）
```

### 2. 更新文档
- 每次改内容 → `last_updated` 字段更新
- 大改 → `version` 升一位（MINOR）
- 破坏性改 → 新开一份 + 老的标 `Deprecated`

### 3. 废弃文档
**不要删**，这是历史记录。做三件事：
1. `status: Deprecated` 或 `Superseded`
2. 文档顶部加 callout 警告
3. 移到 `archive/` 子目录

### 4. 定期体检
用 `/obsidian-doc-audit` skill（见 skills/）：
```
你：/obsidian-doc-audit 二奢软件/
Claude 扫整个目录，输出报告：
  - 哪些文档没 frontmatter
  - 哪些长文档没 TOC
  - 哪些废弃文档没标 Deprecated
  - 哪些命名不规范
  - 总分 X/10
```

---

## 📚 推荐阅读

- [Google Design Doc Guide](https://www.industrialempathy.com/posts/design-docs-at-google/)
- [The Golden Rule of Design Documents](https://medium.com/swlh/how-to-write-a-good-software-design-document-3f5bc39e7aa1)
- [Obsidian 官方文档](https://help.obsidian.md/)
- [Dataview 插件](https://blacksmithgu.github.io/obsidian-dataview/)
- 相关：[docs/2-七件套骨架详解.md](./2-七件套骨架详解.md)（代码仓库文档规范）

---

## 🎯 对你的项目的评估（luxury-bag-copilot）

参考我给你的文档体检报告：
- ✅ 核心内容质量 7.5/10
- ⚠️ 组织结构 5/10
- **主要问题**：没索引、废弃文档没标、长文档没拆

用 `/obsidian-doc-audit` 跑一遍 → 拿到具体改进项。
