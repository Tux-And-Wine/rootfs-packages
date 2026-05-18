#!/bin/bash
# start-build.sh
# 构建系统入口，用法: ./start-build.sh [包名...]

cd "$(dirname "$0")"

# 静默修复必要脚本的执行权限
[ -f "./main/main.sh" ] && [ ! -x "./main/main.sh" ] && chmod +x "./main/main.sh"

# 调用主构建脚本
./main/main.sh "$@"
