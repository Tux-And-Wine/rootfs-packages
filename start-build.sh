#!/bin/bash
# start-build.sh
# 构建系统入口脚本
# 用法: ./start-build.sh [选项] [包名...]

set -euo pipefail

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 主脚本路径
MAIN_SCRIPT="${SCRIPT_DIR}/main/main.sh"

# 检查主脚本是否存在
if [[ ! -f "$MAIN_SCRIPT" ]]; then
    echo "[FATAL] 找不到主脚本: $MAIN_SCRIPT" >&2
    exit 1
fi

# 确保主脚本有执行权限
if [[ ! -x "$MAIN_SCRIPT" ]]; then
    chmod +x "$MAIN_SCRIPT"
fi

# 显示帮助信息
show_help() {
    cat <<'HELP'
TuxWine 构建系统 - 包交叉编译工具

用法: ./start-build.sh [选项] [包名...]

常用命令:
  ./start-build.sh <包名...>        构建指定的包
  ./start-build.sh all              构建所有包（按依赖顺序）
  ./start-build.sh -r <包名>        清理后重建指定包

选项:
  -h, --help          显示此帮助信息
  -r, --rebuild       清理后重建指定包
  -v, --verbose       显示详细输出
  -n, --dry-run       模拟运行，不实际执行
  -k, --keep-going    遇到错误继续构建其他包
  -j, --jobs N        并行任务数（默认: CPU核心数）

管理命令:
  -l, --list          列出所有可用包
  -i, --info PKG      显示包的详细信息
  -d, --deps PKG      显示包的依赖树
  -s, --status        显示构建状态

清理命令:
  --clean             清理所有编译产物
  --clean-all         清理所有内容（包括下载缓存）
  --clean-pkg PKG     清理指定包

日志命令:
  --log               显示最近的构建日志
  --log-pkg PKG       显示指定包的日志
  --disk              显示磁盘使用情况

状态管理:
  --reset             重置所有构建状态
  --reset-pkg PKG     重置指定包的状态

示例:
  ./start-build.sh zlib libffi          构建zlib和libffi
  ./start-build.sh -r zlib              重建zlib
  ./start-build.sh all                  构建所有包
  ./start-build.sh --clean              清理所有编译产物
  ./start-build.sh --status             查看构建状态
  ./start-build.sh --deps glib          查看glib的依赖树
  ./start-build.sh --list               列出所有可用包
  ./start-build.sh --info zlib          查看zlib的详细信息

环境变量:
  LOG_LEVEL           日志级别 (0-4，默认3)
                      0=静默, 1=错误, 2=警告, 3=信息, 4=调试
  PREFIX              安装前缀（可在config.sh中设置）
  TARGET_HOST         交叉编译目标（可在config.sh中设置）

配置文件:
  config.sh           全局配置文件（可选）
                      可复制 config.example.sh 作为模板

更多信息请参考:
  md.txt              开发者参考文档
  README.md           项目说明
HELP
}

# 检查是否需要显示帮助
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# 调用主构建脚本
exec "$MAIN_SCRIPT" "$@"