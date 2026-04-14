#!/usr/bin/env bash
# 一键部署 <项目名> 到 <部署目标>
# 用法：
#   bash scripts/deploy.sh            # 完整部署：编译 + 推送 + 重启 + 验证
#   bash scripts/deploy.sh --dry-run  # 只编译，不推送
#   bash scripts/deploy.sh --restart  # 不编译，只重启
#
# 前提：
#   - ssh <SERVER> 可直连
#   - 本地装有编译工具链
#   - 部署目标上 <服务管理工具，如 LaunchAgent/systemd> 已配置

set -euo pipefail

# ══════════ 配置（按项目填）══════════
PROJECT_NAME="<项目名>"
SERVER_ALIAS="<ssh 别名，如 macmini>"
REMOTE_PATH="<部署目标绝对路径，如 ~/your-project>"
SERVICE_NAME="<服务标识，如 com.xxx.your-project>"
LOG_PATH="<远程日志路径>"

# 编译命令（按语言改）
# Go 示例：
BUILD_CMD="GOOS=darwin GOARCH=arm64 go build -o bin/server ./cmd/server"
BINARY_PATH="bin/server"

# Python 示例（无需编译，打包 venv 或直接 rsync 源码）：
# BUILD_CMD="echo 'Python no build needed'"
# BINARY_PATH="src/"

# Node 示例：
# BUILD_CMD="npm run build"
# BINARY_PATH="dist/"

# 服务重启命令（按系统改）
# macOS LaunchAgent：
RESTART_CMD_STOP="launchctl unload ~/Library/LaunchAgents/${SERVICE_NAME}.plist"
RESTART_CMD_START="launchctl load ~/Library/LaunchAgents/${SERVICE_NAME}.plist"
RESTART_CMD_VERIFY="launchctl list | grep ${SERVICE_NAME}"

# Linux systemd：
# RESTART_CMD_STOP="sudo systemctl stop ${SERVICE_NAME}"
# RESTART_CMD_START="sudo systemctl start ${SERVICE_NAME}"
# RESTART_CMD_VERIFY="systemctl is-active ${SERVICE_NAME}"

# ══════════ 脚本主体（一般不改）══════════

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

MODE="${1:-full}"

log()  { printf "\033[1;36m[deploy]\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m✅\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m⚠️\033[0m  %s\n" "$*"; }
fail() { printf "\033[1;31m❌\033[0m %s\n" "$*" >&2; exit 1; }

# 只重启模式
if [[ "$MODE" == "--restart" ]]; then
  log "只重启 ${SERVER_ALIAS} 服务..."
  ssh "$SERVER_ALIAS" "
    $RESTART_CMD_STOP 2>/dev/null || true
    sleep 1
    $RESTART_CMD_START
    sleep 2
    $RESTART_CMD_VERIFY && echo '✅ 服务已启动' || echo '❌ 未见服务'
  "
  exit 0
fi

# 步骤 1：本地编译
log "本地编译..."
eval "$BUILD_CMD"
LOCAL_MD5=$(md5 -q "$BINARY_PATH" 2>/dev/null || md5sum "$BINARY_PATH" | awk '{print $1}')
LOCAL_SIZE=$(du -h "$BINARY_PATH" | awk '{print $1}')
ok "本地编译完成：${BINARY_PATH} ($LOCAL_SIZE, MD5=$LOCAL_MD5)"

if [[ "$MODE" == "--dry-run" ]]; then
  warn "--dry-run 模式，到此为止"
  exit 0
fi

# 步骤 2：scp 到部署目标（-C 加压缩）
log "scp -C 传输到 ${SERVER_ALIAS}..."
scp -C "$BINARY_PATH" "${SERVER_ALIAS}:${REMOTE_PATH}/${BINARY_PATH}.new"
REMOTE_MD5=$(ssh "$SERVER_ALIAS" "md5 -q ${REMOTE_PATH}/${BINARY_PATH}.new")
if [[ "$LOCAL_MD5" != "$REMOTE_MD5" ]]; then
  fail "传输后 MD5 不一致！本地=$LOCAL_MD5 远端=$REMOTE_MD5"
fi
ok "传输完整性校验通过"

# 步骤 3：原子替换 + 重启
log "原子替换 + 重启服务..."
ssh "$SERVER_ALIAS" "
  set -e
  $RESTART_CMD_STOP 2>/dev/null || true
  sleep 1
  # 备份上一版
  if [ -f ${REMOTE_PATH}/${BINARY_PATH} ]; then
    cp ${REMOTE_PATH}/${BINARY_PATH} ${REMOTE_PATH}/${BINARY_PATH}.prev
  fi
  mv ${REMOTE_PATH}/${BINARY_PATH}.new ${REMOTE_PATH}/${BINARY_PATH}
  $RESTART_CMD_START
  sleep 3
  if $RESTART_CMD_VERIFY > /dev/null; then
    echo '✅ 服务进程存在'
  else
    echo '❌ 服务未启动'
    exit 1
  fi
"

# 步骤 4：健康检查（日志）
log "查看最新日志..."
ssh "$SERVER_ALIAS" "tail -20 $LOG_PATH 2>/dev/null | grep -v '^$' || echo '(日志暂空)'"

ok "部署完成：${SERVER_ALIAS} 正在运行新版本 (MD5=$REMOTE_MD5)"
log "回滚命令：ssh $SERVER_ALIAS '$RESTART_CMD_STOP && cp ${REMOTE_PATH}/${BINARY_PATH}.prev ${REMOTE_PATH}/${BINARY_PATH} && $RESTART_CMD_START'"
