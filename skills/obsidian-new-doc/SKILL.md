---
name: obsidian-new-doc
description: 在 Obsidian vault 里按标准模板创建新文档（设计文档 / 项目 README / 进度日志 / ADR / 复盘 / 头脑风暴）。触发词：新建 obsidian 文档 / 写设计文档 / 写 ADR / 写复盘 / 写头脑风暴 / obsidian-new-doc / new doc。
user-invocable: true
---

# 创建新 Obsidian 文档（按标准模板）

## 触发时机

- 用户打 `/obsidian-new-doc`
- 用户说"给我写个设计文档" / "写个 ADR" / "记个复盘"
- 用户说"我想写一份 XX 的项目说明"

## 执行步骤

### 第 1 步：问用户 6 个问题（一次问完）

```
我来按标准模板建新 Obsidian 文档。先确认几件事：

1. 文档类型？
   a. Design Doc（设计文档）— 讲清一个产品/功能的设计
   b. Project README（项目索引）— 项目入口
   c. Progress Log（进度日志）— 按时间记做了啥
   d. ADR（架构决策记录）— 一个决策 200 字
   e. Retro（复盘）— 阶段复盘
   f. Brainstorm（头脑风暴）— 想法草稿

2. 项目名？（中文 / 英文均可）

3. 存到 Obsidian 哪个文件夹？
   （默认：vault/<项目名>/）

4. 文件名？（不含 .md 扩展名）

5. 一句话描述？（填进 title）

6. 你的名字？（填进 owner，默认读 git 用户名）
```

### 第 2 步：拉最新模板

**方式 A**：如果本地已有 claude-project-survival-kit 克隆
```bash
MODELS_DIR=~/claude-project-survival-kit/templates/obsidian-docs
# 或者根据用户项目位置找
```

**方式 B**：如果没有，从 GitHub 拉
```bash
if [ ! -d /tmp/claude-survival-kit ]; then
  git clone https://github.com/hailanlan0577/claude-project-survival-kit.git /tmp/claude-survival-kit
else
  cd /tmp/claude-survival-kit && git pull
fi
```

模板文件（在 `/tmp/claude-survival-kit/templates/obsidian-docs/`）：
- design-doc.md.tpl
- project-readme.md.tpl
- progress-log.md.tpl
- adr.md.tpl
- retro.md.tpl
- brainstorm.md.tpl

### 第 3 步：找 Obsidian vault 路径

```bash
# 常见位置
VAULT_CANDIDATES=(
  "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
  "$HOME/Documents/Obsidian"
  "$HOME/Obsidian"
)

for c in "${VAULT_CANDIDATES[@]}"; do
  if [ -d "$c" ]; then
    # 找到了
    break
  fi
done
```

**或者问用户**：vault 根路径是什么？

### 第 4 步：准备文件路径

```bash
TARGET_DIR="$VAULT/<用户第 3 题答案>"
mkdir -p "$TARGET_DIR"

# 如果是 ADR，默认放 adr/ 子目录并自动编号
if [ "$TYPE" = "adr" ]; then
  TARGET_DIR="$TARGET_DIR/adr"
  mkdir -p "$TARGET_DIR"
  # 找下一个 ADR 编号
  LAST=$(ls "$TARGET_DIR"/*.md 2>/dev/null | grep -oE '[0-9]{4}' | sort -n | tail -1)
  NEXT=$(printf "%04d" $((10#${LAST:-0} + 1)))
  FILENAME="ADR-${NEXT}-<用户第 4 题答案>.md"
fi

TARGET_FILE="$TARGET_DIR/<用户第 4 题答案>.md"
```

### 第 5 步：复制模板 + 替换占位符

```bash
# 读取对应模板
cp /tmp/claude-survival-kit/templates/obsidian-docs/<type>.md.tpl "$TARGET_FILE"

# 用 Edit 工具逐一替换占位符：
# {{项目名}} → 用户第 2 题答案
# {{一句话定义}} → 用户第 5 题答案
# {{你的名字}} → 用户第 6 题答案
# {{YYYY-MM-DD}} → 今天日期
# 对于 ADR：{{XXXX}} → NEXT 编号
```

### 第 6 步：在 Obsidian 中打开（可选）

```bash
open "obsidian://open?vault=<vault 名>&file=<文件路径>"
```

### 第 7 步：报告给用户

```
✅ 已建好 {{type}} 文档：
   📄 {{文件路径}}
   🔗 Obsidian 打开：[点击]({{obsidian:// URL}})

占位符已填好的字段：
   - title / owner / created / last_updated / version

还需要你手动填的字段：
   - Problem Statement / Demand Evidence / Design Options / ...
   （或对应类型的空白区）

建议：
   - 写完后状态从 Draft 改为 Active
   - 每次改大的内容后 version bump + 更新 last_updated
   - 有相关文档用 [[双链]] 连起来
```

## 禁忌

- ❌ 不要在用户没答完 6 题就开建
- ❌ 不要覆盖已有文件（检查 `[ -f "$TARGET_FILE" ] && echo "已存在"`）
- ❌ 不要忘记创建父目录
- ❌ 不要在 Obsidian vault 外乱放文件

## 相关

- 方法论：https://github.com/hailanlan0577/claude-project-survival-kit/blob/main/docs/10-Obsidian-文档规范.md
- 所有模板：https://github.com/hailanlan0577/claude-project-survival-kit/tree/main/templates/obsidian-docs
- 配对 skill：`/obsidian-doc-audit`（文档体检）
