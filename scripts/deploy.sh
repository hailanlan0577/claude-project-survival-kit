#!/usr/bin/env bash
# CPSK 的 "deploy" 脚本 —— 不是传统部署
# 作用：把本仓库的 skill 同步到 ~/.claude/skills/，让本地 Claude Code 立即能用最新版
#
# 用法：
#   bash scripts/deploy.sh              # 全量同步所有 skill
#   bash scripts/deploy.sh --dry-run    # 只列出会同步什么，不真动手
#   bash scripts/deploy.sh --skill setup-kit  # 只同步某个 skill

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
SKILLS_DEST="$HOME/.claude/skills"

DRY_RUN=false
ONLY_SKILL=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --skill) ONLY_SKILL="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [ ! -d "$SKILLS_SRC" ]; then
  echo "❌ Source dir not found: $SKILLS_SRC" >&2
  exit 1
fi

mkdir -p "$SKILLS_DEST"

echo "🔄 CPSK skill 同步"
echo "   从: $SKILLS_SRC/"
echo "   到: $SKILLS_DEST/"
echo ""

COUNT=0
SKIPPED=0

for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  # 只同步指定 skill
  if [ -n "$ONLY_SKILL" ] && [ "$skill_name" != "$ONLY_SKILL" ]; then
    continue
  fi

  if [ ! -f "$skill_file" ]; then
    echo "  ⚠️  跳过 $skill_name（无 SKILL.md）"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  dest_dir="$SKILLS_DEST/$skill_name"
  dest_file="$dest_dir/SKILL.md"

  # per-project skills 不覆盖（proj-onboard / proj-offboard 是模板，不直接装）
  # 但 setup-kit / proj-graphify / obsidian-* 是全局可用的
  case "$skill_name" in
    proj-onboard|proj-offboard)
      echo "  ⏭  跳过 $skill_name（这是给 setup-kit 用的模板，不直接装）"
      SKIPPED=$((SKIPPED + 1))
      continue
      ;;
  esac

  if $DRY_RUN; then
    if [ -f "$dest_file" ]; then
      if cmp -s "$skill_file" "$dest_file"; then
        echo "  ✓  $skill_name（已同步）"
      else
        echo "  📝 $skill_name（会更新）"
        COUNT=$((COUNT + 1))
      fi
    else
      echo "  ✨ $skill_name（会新装）"
      COUNT=$((COUNT + 1))
    fi
  else
    mkdir -p "$dest_dir"
    cp "$skill_file" "$dest_file"
    echo "  ✅ $skill_name"
    COUNT=$((COUNT + 1))
  fi
done

echo ""
if $DRY_RUN; then
  echo "🏁 Dry-run: 会改动 $COUNT 个 skill，跳过 $SKIPPED 个"
  echo "   实际同步请去掉 --dry-run"
else
  echo "🏁 同步完成：$COUNT 个 skill，跳过 $SKIPPED 个"
  echo ""
  echo "验证："
  echo "  ls $SKILLS_DEST/"
fi
