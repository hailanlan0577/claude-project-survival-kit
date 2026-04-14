#!/bin/bash
# pre-commit hook: 防密钥泄露 + 大文件警告 + 敏感文件拦截
#
# 安装方法（复制到项目根后）：
#   cp templates/hooks/pre-commit.sh.tpl .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# 紧急绕过（慎用）：
#   git commit --no-verify

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "🔍 pre-commit 检查中..."

# ═══════════════════════════════════════
# 1. 扫描 staged 内容的疑似密钥
# ═══════════════════════════════════════
PATTERNS=(
  "api[_-]?key"
  "secret"
  "password"
  "passwd"
  "token"
  "bearer"
  "authorization"
  "private[_-]?key"
)

SECRET_FOUND=0
for pattern in "${PATTERNS[@]}"; do
  # 匹配形如 api_key = "xxxxxxxxxxxxxxxxxxxx" 这种（≥20 字符的值）
  HITS=$(git diff --cached | grep -iE "${pattern}.{0,3}[:=].{0,3}['\"][A-Za-z0-9_./=+-]{20,}['\"]" || true)
  if [ -n "$HITS" ]; then
    if [ $SECRET_FOUND -eq 0 ]; then
      echo -e "${RED}❌ 检测到疑似密钥${NC}"
      SECRET_FOUND=1
    fi
    echo "$HITS" | head -3
  fi
done

if [ $SECRET_FOUND -eq 1 ]; then
  echo ""
  echo -e "${YELLOW}处理建议：${NC}"
  echo "  1. 如果这是真密钥 → 别提交！从 staged 撤掉："
  echo "     git reset HEAD <文件>"
  echo "  2. 如果是 example / placeholder → 重命名值避免触发："
  echo "     api_key: \"xxx_placeholder\" （短于 20 字符）"
  echo "  3. 如果确定是误报 → git commit --no-verify"
  exit 1
fi

# ═══════════════════════════════════════
# 2. 拦截敏感文件名进 staging
# ═══════════════════════════════════════
FORBIDDEN_PATTERNS=(
  "\.env$"
  "\.env\."
  "config\.yaml$"
  "\.key$"
  "\.pem$"
  "credentials\.md$"
  "id_rsa"
  "id_ed25519"
)

FORBIDDEN_FOUND=0
for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  FILES=$(git diff --cached --name-only | grep -E "$pattern" || true)
  if [ -n "$FILES" ]; then
    # 排除 .example 和 .template 文件
    FILES=$(echo "$FILES" | grep -vE "\.example|\.tpl$|\.template$" || true)
    if [ -n "$FILES" ]; then
      if [ $FORBIDDEN_FOUND -eq 0 ]; then
        echo -e "${RED}❌ 敏感文件进了 staging${NC}"
        FORBIDDEN_FOUND=1
      fi
      echo "$FILES"
    fi
  fi
done

if [ $FORBIDDEN_FOUND -eq 1 ]; then
  echo ""
  echo -e "${YELLOW}处理建议：${NC}"
  echo "  这些文件应该在 .gitignore 里。撤掉 staging："
  echo "     git reset HEAD <文件>"
  echo "  然后确认 .gitignore 已排除。"
  exit 1
fi

# ═══════════════════════════════════════
# 3. 大文件警告（>5MB）
# ═══════════════════════════════════════
LARGE_FILES=""
for file in $(git diff --cached --name-only); do
  if [ -f "$file" ]; then
    SIZE=$(wc -c < "$file" 2>/dev/null || echo 0)
    if [ "$SIZE" -gt 5242880 ]; then  # 5MB
      LARGE_FILES="$LARGE_FILES\n  $file ($(du -h "$file" | cut -f1))"
    fi
  fi
done

if [ -n "$LARGE_FILES" ]; then
  echo -e "${YELLOW}⚠️  大文件警告（>5MB）${NC}"
  echo -e "$LARGE_FILES"
  echo ""
  echo "  git 不适合存大二进制。建议："
  echo "  - binary → 放 deploy/ 并加进 .gitignore + 用 GitHub Release 附件上传"
  echo "  - 图片视频 → 用 GitHub LFS 或外部存储"
  echo ""
  echo -n "  确认要入库吗？(y/N) "
  read -r CONFIRM </dev/tty
  if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "已取消。"
    exit 1
  fi
fi

echo -e "${GREEN}✅ pre-commit 检查通过${NC}"
