# lib/common.sh
# 提供统一的信息输出函数，避免到处写颜色代码

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 普通信息
info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

# 警告（不退出）
warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

# 错误（输出后退出脚本）
error() {
    echo -e "${RED}[ERROR]${NC} $*"
    exit 1
}
