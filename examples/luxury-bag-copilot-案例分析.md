# 真实案例：luxury-bag-copilot（脱敏版）

> 本仓库方法论的**第一个落地案例**：一个已运行 2 个月的 Go + Qdrant + 飞书 Bot 项目，在 **2026-04-14 单日内**走完"从没 git"到"完整救命套件"的全过程。
>
> 本文已脱敏（密钥、用户名、路径 user 部分、公司名），保留方法论原貌。

---

## 📝 项目背景

- **领域**：帮某二手奢侈品店老板做 AI 买手（判断爬虫推来的二手包价格是否合理、是否可能是假货）
- **技术栈**：Go 后端 + Qdrant 多模态向量 + DashScope embedding + 飞书 Bot
- **部署**：本地 MacBook 开发，Mac Mini 作为部署目标（通过 Cloudflare Tunnel 对外暴露）
- **数据**：166 条经验库（从奢当家 ERP Excel 导入）+ 爬虫实时数据

---

## 😱 2026-04-14 早上发现的问题

和 Claude 对话时发现：

> "我觉得我们做到现在，还没建立 git 文件夹"

一句话打开潘多拉魔盒：

| 问题 | 严重度 |
|------|--------|
| ❌ 项目没 git | 🔴 严重 |
| ❌ 代码没备份 | 🔴 严重 |
| ❌ 密钥没分离 | 🔴 严重 |
| ❌ 部署靠手敲 | 🟡 中等 |
| ❌ 新 Claude 窗口要 30 分钟才能进入状态 | 🟡 中等 |

---

## 🛠️ 9 步补救顺序（14 小时内完成）

### Step 1-3：Git 起步（上午）

1. ✅ 确认源码主分支位置（**本地 MacBook** 不是 Mac Mini）
2. ✅ 扫敏感文件 + 写 `.gitignore`
3. ✅ `git init` + commit + 建 GitHub **private** repo + push

**踩的第一个坑**：一开始不小心在 Mac Mini 上 `git init`，把旧源码推到 GitHub。
**教训**：**新 Claude 进来后一定要先确认源码主分支在哪**，别直接在用户说的第一个位置操作。

### Step 4：救命资产抢救（下午）

4. ✅ 抢救 Mac Mini 上正在运行的 Phase 2 binary（24MB，**源码丢了它就是唯一活版本**）
   → 拷回本地 `deploy/server-phase2-<日期>.bin`
5. ✅ LaunchAgent plist 入 git（系统崩了能复活）
6. ✅ Qdrant 首次 snapshot 107MB
7. ✅ 经验库图片（永久资产）打包 33MB（**不包括**爬虫缓存 11GB 临时资产）

### Step 5：密钥三位一体（下午）

8. ✅ 对比两地 `config.yaml` 发现**不一致**（本地是 Phase 2 之前的旧版！）
   → 从部署目标拷回覆盖本地
9. ✅ 把所有密钥（飞书 / 钉钉 / 企业微信）备份到 `credentials.md`

**踩的第二个坑**：以为两地 config.yaml 总是一致的。**实际**：没有自动同步机制的话，改了一边不动另一边会出错。
**教训**：每次改 config 必须 MD5 校验两地。

### Step 6-7：文档四件套（下午 - 晚上）

10. ✅ 写 `CLAUDE.md` + `STATUS.md` + `RUNBOOK.md`（9 章）+ `ONBOARDING.md` + `OFFBOARDING.md`
11. ✅ 写 `scripts/deploy.sh`（一键部署 + MD5 校验 + 自动备份上一版）
12. ✅ RUNBOOK 加 § 10 Git 日常速查（10 个场景，含密钥推错紧急抢救）

### Step 8-9：会话交接系统（晚上）

13. ✅ 写两个 Claude skill：`/lbc-onboard` + `/lbc-offboard`
14. ✅ Obsidian 落地项目专属手册 + 通用模板
15. ✅ 记忆系统写项目指针 + 通用模板 + 清理旧矛盾记忆
16. ✅ 跑一次 `/lbc-offboard` 验证 8 步 checklist 完整

---

## 🕳️ 踩到的 5 个真实陷阱

### 陷阱 1：部署目标的源码副本是**滞后**的

Mac Mini 上有一份源码，但只是旧版本（没有 Phase 2 的 `poller.go`）。**真正运行的是 binary 不是源码**。
**防御**：用 MD5 对比本地编译产物和部署目标跑的 binary，不一致要警惕。

### 陷阱 2：记忆系统说 "Phase 2 已上线"，代码却找不到

记忆里记着"Phase 2 三段管线跑通了"，但本地源码没有 `poller.go`。**原因**：会话当时被 Anthropic Usage Policy 拦截中断，代码没 commit 就丢了。
**防御**：会话结束必 commit + push，用 git 留痕。

### 陷阱 3：`sync-to-macmini.sh` 字面意思具有误导性

这个脚本听起来像"同步源码到 Mac Mini"，**实际**是同步爬虫数据文件（`intercepted.jsonl`）。
**防御**：脚本名和实际功能要一致，不一致就改名。

### 陷阱 4：GitHub PAT 过期了

`credentials.md` 里存的 PAT 用不了，但没标"已失效"。
**防御**：用 `gh auth token` 实时取活 token；credentials.md 存密钥要标"失效日期"。

### 陷阱 5：图片目录 11GB，以为要全备份

其实只有 165 张（< 50MB）是永久资产（经验库），其他 18000+ 张是爬虫运行时缓存（能重抓）。
**防御**：区分永久 vs 临时资产，只备永久的。

---

## 📦 一天的 commit 历程

```
4a03d8d docs: 2026-04-14 会话下班收尾（offboard 跑的 commit）
76f3e09 docs: 开场/下班手册接入 skill 系统
29e8424 docs: RUNBOOK § 10 Git 日常速查
e9bd6fd docs: OFFBOARDING.md
a79e17f docs: ONBOARDING.md
9f3b6ab docs+ops: 救命资产入库 + RUNBOOK 首版
db9ad8c docs: CLAUDE.md + STATUS.md
fa14523 feat: Phase 1 + 2 完整代码  ← 首次 commit
```

8 次 commit，全部 push 到 GitHub private repo。

---

## 🎁 最终装备清单

### 项目根（仓库里）

```
luxury-bag-copilot/
├── README.md（无）             # 这个项目没写 README，对 Claude 来说 CLAUDE.md 够用
├── CLAUDE.md                   # Claude Code 自动加载
├── ONBOARDING.md               # 新会话开场
├── OFFBOARDING.md              # 收场 checklist
├── STATUS.md                   # 进度快照
├── RUNBOOK.md                  # 9 章 + § 10 Git 速查
├── .gitignore                  # 扫得仔细
├── scripts/
│   └── deploy.sh               # 一键部署
└── deploy/
    ├── <服务>.plist             # LaunchAgent 入 git
    └── server-phase2-*.bin     # 黄金 binary（不入 git，本地 24MB）
```

### Mac Mini 侧（未入 git，通过 rsync 同步）

```
~/luxury-qdrant-backups/
├── luxury_bags_v1-*.snapshot         # 107MB Qdrant snapshot
└── experience-images-*.tar.gz        # 33MB 经验库图

~/Library/LaunchAgents/
└── <服务>.plist                      # 部署时从仓库 deploy/ 复制
```

### Claude 全局（`~/.claude/`）

```
~/.claude/skills/
├── lbc-onboard/SKILL.md         # /lbc-onboard
└── lbc-offboard/SKILL.md        # /lbc-offboard

~/.claude/projects/<session>/memory/
├── MEMORY.md                    # 全局索引
├── credentials.md               # 密钥全量备份
├── luxury-bag-copilot.md        # 项目指针
└── project-onboarding-template.md  # 通用模板
```

### Obsidian（用户自己翻看）

```
二奢软件/
├── AI买手Copilot-经验数据库-设计文档.md   # 完整设计 1700+ 行
└── AI买手Copilot-救命手册.md              # 项目专属救命手册

根目录/
└── 项目救命手册-通用模板.md                # 通用模板
```

### 记忆系统

Qdrant v3 存了 4 条 high 重要度记忆，标签 `luxury-bag-copilot`：
- 项目状态校准
- 避坑清单
- skill 落地记录
- 当日进展

---

## 🎬 使用效果

### 开新窗口

打 `/lbc-onboard` 或说"继续二奢 AI 买手"：

```
Claude:
> 好的，我来继续 luxury-bag-copilot 项目。简单汇报一下现状：
> 
> 项目是：AI 买手 Copilot — 二奢经验库 + 爬虫三段筛选管线，Go 后端跑 Mac Mini，飞书 Bot 做老板端 UI。
> 
> 当前阻塞：price_sold=0 空转。166 条经验数据全是 for_sale 状态，老板上传的是在售库存不是已售订单，价格中位数算不出来。
> 
> 下一步候选：
>   A. 让老板导"已售订单"Excel
>   B. 改代码用 price_asked 挂牌价
>   C. B 先跑起来 + 并行 A 补数据（推荐）
> 
> 你想继续干哪件事？
```

### 下班

打 `/lbc-offboard`：

```
Claude 跑 8 步 checklist：
✅ 1. STATUS.md 已更新
✅ 2. 新坑已加进 ONBOARDING 禁忌
✅ 3. git 已 commit + push：commit xxxx
✅ 4. 无代码改动，跳过部署
...
```

---

## 🧪 10 题自检结果

首次通过 **7/10**：
- ✅ 代码能恢复（GitHub）
- ✅ 部署目标能重建（RUNBOOK § 4）
- ✅ 密钥能恢复（credentials.md）
- ✅ snapshot 有了（Qdrant 107MB + 图 33MB）
- ✅ 新 Claude 能进入状态（ONBOARDING + skill）
- ✅ git 历史完整
- ✅ 密钥无泄露风险
- ✅ STATUS 能看懂
- ✅ 外部依赖清单有
- ⚠️ 手动命令还有（deploy.sh 了但部分命令还是手敲）

剩下 3 分接下来几天补。

---

## 💡 复盘

### 做对的事

1. **先确认源码主分支**（避免在错的位置 `git init`）
2. **抢救运行中的 binary**（源码丢了也有活版本）
3. **密钥三位一体**（永不泄露也永不丢失）
4. **区分永久 vs 临时资产**（不盲目全备份）
5. **分批 commit**（每次小步，8 次 commit 覆盖完整脉络）

### 下次会改进

1. **跑 offboard 前先跑 onboard**（测试完整的交接闭环）
2. **RUNBOOK § 10.9（密钥紧急抢救）早点写**（别等已经泄露才想）
3. **部署脚本写得更完整**（现在第一版还有一些手动步骤）

---

## 🎯 对其他项目的启示

1. **任何项目，建 git 是第一件事**，不管多小
2. **部署目标不是开发地**
3. **Claude 记忆不是代码**（记忆可能和代码状态不一致，以 git 为准）
4. **会话结束必 offboard**（不然下次还得从头解释）
5. **手册不是一次性任务**（STATUS.md 要持续更新）

---

## 🔗 本案例相关链接

*（本仓库是 public，案例内的具体 repo 地址和实际项目已脱敏，只保留方法论。）*

---

## 📖 想套用？

回到仓库根 [README.md](../README.md) 的"🚀 5 分钟：给新项目套用"章节。
