---
name: proj-graphify
description: 给当前项目做结构体检。跑 graphify 在项目根目录，输出知识图谱（HTML + 报告 + JSON），并把 GRAPH_REPORT.md 软链到项目根供 onboard 读取。触发词：给项目做体检 / 跑 graphify / 结构分析 / 看项目地图 / proj-graphify / 项目体检。
user-invocable: true
---

# 给项目做结构体检

## 触发时机

用户说以下任一句话 → 主动调用：

- "给项目做体检"
- "给 xxx 项目做体检"
- "跑 graphify"
- "结构分析"
- "看项目地图"
- "项目体检"
- "项目 cohesion 怎么样"
- 或直接打 `/proj-graphify`

## 职责边界

- ✅ 跑 `/graphify` 在当前项目根
- ✅ 输出图谱到 `~/graphify-runs/<project-slug>/graphify-out/`（**不污染项目目录**）
- ✅ 把 `GRAPH_REPORT.md` 链接到 `<project>/graphify-out/GRAPH_REPORT.md`（方便 onboard 读）
- ❌ 不改项目代码
- ❌ 不自动发版

## 执行步骤

### 第 1 步：定位项目根

按优先级探测当前项目根：
1. Git 仓库根：`git rev-parse --show-toplevel`
2. 包含 `CLAUDE.md` 的最近父目录
3. 用户明确传参的路径
4. 当前工作目录（兜底）

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) \
  || PROJECT_ROOT=$(pwd)
PROJECT_NAME=$(basename "$PROJECT_ROOT")
echo "项目根：$PROJECT_ROOT"
echo "项目名：$PROJECT_NAME"
```

**如果用户传了路径参数**（`/proj-graphify /path/to/x`）：直接用那个路径，跳过 git 探测。

### 第 2 步：准备输出目录（不污染项目）

```bash
OUT_DIR="$HOME/graphify-runs/$PROJECT_NAME"
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"
```

**为什么不写进项目根**：
- `graphify-out/` 有 100KB 级 JSON 和 HTML，污染 git diff
- 多次重跑会覆盖，对 git 不友好
- 放 `~/graphify-runs/` 就是"可重建的衍生物"，跟 `/tmp` 是一类

### 第 3 步：确保 `.graphifyignore` 存在于项目根

检查 `$PROJECT_ROOT/.graphifyignore`：
- 如果存在 → 直接跑
- 如果不存在 → 建议用户加一个，列出合理的忽略项：
  ```
  graphify-out/        # 工具自己输出
  node_modules/
  vendor/
  dist/ build/
  .venv/
  archive/             # 归档文档不算入当前图谱
  ```

如果用户说"你直接加"，就 Write 一个默认的。

### 第 4 步：调用 `/graphify`

直接调用 graphify skill，传入项目路径：

```
Skill 调用: graphify
参数: <PROJECT_ROOT>
```

（graphify 自己会做 detect → 提取 → 聚类 → 报告）

### 第 5 步：链接报告回项目根（关键）

graphify 跑完后，输出在 `$OUT_DIR/graphify-out/GRAPH_REPORT.md`。
做一个软链接到项目根，让 `/<proj>-onboard` 能读到：

```bash
mkdir -p "$PROJECT_ROOT/graphify-out"
ln -sf "$OUT_DIR/graphify-out/GRAPH_REPORT.md" "$PROJECT_ROOT/graphify-out/GRAPH_REPORT.md"
ln -sf "$OUT_DIR/graphify-out/graph.html" "$PROJECT_ROOT/graphify-out/graph.html"
ln -sf "$OUT_DIR/graphify-out/graph.json" "$PROJECT_ROOT/graphify-out/graph.json"
```

**注意**：别忘了在项目 `.gitignore` 里加 `graphify-out/`（避免符号链接误入库）。

### 第 6 步：汇报

```
✅ 项目体检完成：<PROJECT_NAME>

图谱：
  - <N> 节点 / <M> 边 / <K> 社区
  - Token 压缩 <X>x
  - Cohesion: 最高 <A> "<社区名>" / 最低 <B> "<社区名>"

🏆 Top 3 God Node：
  1. <节点>
  2. <节点>
  3. <节点>

💡 最意外的 1 条发现：
  <标最高 confidence 的 INFERRED / AMBIGUOUS 边>

📂 输出位置：
  - ~/graphify-runs/<project-name>/graphify-out/  （完整图谱）
  - <project-root>/graphify-out/  （指向上面的软链）
  - HTML 可点击：open ~/graphify-runs/<project-name>/graphify-out/graph.html

📝 30 天内：
  新 Claude 跑 /<proj>-onboard 时会自动读这份 GRAPH_REPORT.md。
  超过 30 天会提示你重跑 /proj-graphify。
```

## 使用时机

### ✅ 推荐跑

- 发 MINOR / MAJOR 版本前（看有没有结构债）
- 项目做了大重构（看结构变化）
- 新人/新 Claude 接手前（手里有地图再开工）
- 每季度一次（纯例行 checkup）

### ❌ 不要跑

- 每次 offboard 都跑（浪费 token，小改动没信息增量）
- 刚改了一个 typo
- 项目只有 <10 个文件（graphify 自己会警告"不需要图"）

## 和其他 skill 的分工

| Skill | 角色 |
|-------|------|
| `/proj-graphify`（本 skill）| 一次性结构体检 |
| `/<proj>-onboard` | 每次新窗口开场（顺带读 graphify 报告）|
| `/<proj>-offboard` | 每次会话结束收尾 |
| `/save-to-obsidian` | 沉淀具体讨论 |

**graphify 是"地图"，不是"档案柜"**——用它理解结构，不用它存内容。

## 相关

- graphify 本身：`/graphify <path>` （底层工具）
- 项目救命套件：https://github.com/hailanlan0577/claude-project-survival-kit
- graphify 上游：https://github.com/safishamsi/graphify
