# 编译产物（按项目技术栈取舍）
bin/
*.exe
dist/
build/
target/
node_modules/

# 配置（含密钥，绝不入库）
configs/config.yaml
configs/*.key
configs/*.pem
.env
.env.local
.env.*.local

# 运行时数据
data/
*.log
*.sqlite
*.db

# 系统 / IDE
.DS_Store
.vscode/
.idea/
*.swp
*.swo
/tmp/

# 语言特定
# Python
__pycache__/
*.pyc
.venv/
venv/
# Go
vendor/
# Node
.npm
.yarn

# OMC / Claude 运行时状态（如果用了这些工具）
.omc/state/
.omc/logs/

# 救命 binary 副本（手动备份到 iCloud/坚果云，不入库）
deploy/*.bin
deploy/*.tar.gz
