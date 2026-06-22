# lib/common.sh
# 提供统一的信息输出函数和通用工具函数

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志级别: 0=静默, 1=错误, 2=警告, 3=信息, 4=调试
LOG_LEVEL="${LOG_LEVEL:-3}"

# 普通信息
info() {
    [[ $LOG_LEVEL -ge 3 ]] && echo -e "${GREEN}[INFO]${NC} $*"
}

# 警告（不退出）
warn() {
    [[ $LOG_LEVEL -ge 2 ]] && echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

# 错误（输出后退出脚本）
error() {
    [[ $LOG_LEVEL -ge 1 ]] && echo -e "${RED}[ERROR]${NC} $*" >&2
    exit 1
}

# 调试信息
debug() {
    [[ $LOG_LEVEL -ge 4 ]] && echo -e "${CYAN}[DEBUG]${NC} $*" || true
}

# 步骤信息（带蓝色高亮）
step() {
    [[ $LOG_LEVEL -ge 3 ]] && echo -e "${BLUE}[STEP]${NC} $*"
}

# 成功信息
success() {
    [[ $LOG_LEVEL -ge 3 ]] && echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# 检查命令是否存在
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        error "命令 '$cmd' 未找到，请先安装"
    fi
}

# 检查目录是否存在，不存在则创建
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        debug "创建目录: $dir"
    fi
}

# 检查文件是否存在
check_file() {
    local file="$1"
    local desc="${2:-文件}"
    if [[ ! -f "$file" ]]; then
        error "$desc 不存在: $file"
    fi
}

# 检查目录是否存在
check_dir() {
    local dir="$1"
    local desc="${2:-目录}"
    if [[ ! -d "$dir" ]]; then
        error "$desc 不存在: $dir"
    fi
}

# 安全的cd命令
safe_cd() {
    local dir="$1"
    if ! cd "$dir"; then
        error "无法进入目录: $dir"
    fi
    debug "进入目录: $dir"
}

# 获取CPU核心数
get_nproc() {
    if command -v nproc &>/dev/null; then
        nproc
    elif [[ -f /proc/cpuinfo ]]; then
        grep -c ^processor /proc/cpuinfo
    else
        echo 1
    fi
}

# 格式化时间
format_duration() {
    local seconds="$1"
    local hours=$((seconds / 3600))
    local minutes=$(( (seconds % 3600) / 60 ))
    local secs=$((seconds % 60))
    
    if [[ $hours -gt 0 ]]; then
        printf "%dh %dm %ds" $hours $minutes $secs
    elif [[ $minutes -gt 0 ]]; then
        printf "%dm %ds" $minutes $secs
    else
        printf "%ds" $secs
    fi
}

# 计算文件的SHA256哈希值
compute_sha256() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        error "文件不存在，无法计算哈希: $file"
    fi
    sha256sum "$file" | cut -d' ' -f1
}

# 比较两个版本号
# 返回: 0=相等, 1=第一个更大, 2=第二个更大
version_compare() {
    local ver1="$1"
    local ver2="$2"
    
    if [[ "$ver1" == "$ver2" ]]; then
        return 0
    fi
    
    local IFS=.
    local i ver1_parts=($ver1) ver2_parts=($ver2)
    
    for ((i=0; i<${#ver1_parts[@]}; i++)); do
        if [[ -z "${ver2_parts[i]:-}" ]]; then
            return 1
        fi
        if ((10#${ver1_parts[i]} > 10#${ver2_parts[i]})); then
            return 1
        fi
        if ((10#${ver1_parts[i]} < 10#${ver2_parts[i]})); then
            return 2
        fi
    done
    
    if [[ ${#ver1_parts[@]} -lt ${#ver2_parts[@]} ]]; then
        return 2
    fi
    
    return 0
}

# 导出函数供其他脚本使用
export -f info warn error debug step success
export -f check_command ensure_dir check_file check_dir safe_cd
export -f get_nproc format_duration compute_sha256 version_compare