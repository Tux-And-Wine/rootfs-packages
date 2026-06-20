#!/bin/bash
# setup-environment.sh
# 构建系统环境配置脚本
# 安装交叉编译所需的所有构建工具和依赖

set -euo pipefail

# ============================================================
#  颜色与输出
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ============================================================
#  辅助函数
# ============================================================

# 检查是否以 root 运行
check_root() {
    [[ $EUID -eq 0 ]] || error "此脚本需要 root 权限，请使用 sudo 执行"
}

# 检测发行版
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO="${ID:-unknown}"
        DISTRO_VERSION="${VERSION_ID:-unknown}"
    else
        error "无法检测操作系统类型"
    fi
    info "检测到系统: ${DISTRO} ${DISTRO_VERSION}"
}

# ============================================================
#  安装函数
# ============================================================

# 基本构建工具
install_build_essentials() {
    info "安装基本构建工具..."
    apt-get install -y \
        build-essential \
        gcc g++ make \
        autoconf automake libtool \
        pkg-config \
        bison flex gawk \
        gettext autopoint \
        intltool \
        help2man \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
        zlib1g-dev
}

# CMake 和 Meson 构建系统
install_build_systems() {
    info "安装构建系统 (cmake, meson, ninja)..."
    apt-get install -y \
        cmake \
        meson \
        ninja-build
}

# 下载和解压工具
install_archive_tools() {
    info "安装下载和解压工具..."
    apt-get install -y \
        wget curl \
        tar unzip \
        xz-utils gzip bzip2 \
        patch rsync
}

# 脚本和辅助工具
install_script_tools() {
    info "安装脚本运行所需工具..."
    apt-get install -y \
        python3 \
        coreutils \
        findutils \
        sed grep
}

# 交叉编译工具链
install_cross_toolchain() {
    info "安装交叉编译工具链 (aarch64-linux-gnu)..."
    apt-get install -y \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        binutils-aarch64-linux-gnu
}

# GCC 构建所需的 aarch64 架构依赖
install_gcc_cross_deps() {
    info "安装 GCC 构建所需的 aarch64 架构依赖..."

    # 添加 aarch64 架构支持
    dpkg --add-architecture arm64
    apt-get update

    # 安装 aarch64 版本的 GMP、MPFR、MPC、zlib
    # GCC configure 在交叉编译时会检测这些库
    apt-get install -y \
        libgmp-dev:arm64 \
        libmpfr-dev:arm64 \
        libmpc-dev:arm64 \
        zlib1g-dev:arm64

    # 安装 meson 交叉编译所需的 aarch64 架构依赖
    # pango、glib、cairo、wayland 等使用 meson 构建的包需要这些
    apt-get install -y \
        libfribidi-dev:arm64 \
        libharfbuzz-dev:arm64 \
        libcairo2-dev:arm64 \
        libpango1.0-dev:arm64 \
        libfontconfig-dev:arm64 \
        libfreetype-dev:arm64 \
        libglib2.0-dev:arm64 \
        libxml2-dev:arm64 \
        libexpat-dev:arm64 \
        libffi-dev:arm64 \
        libwayland-dev:arm64
}

# 宿主机原生工具（构建过程中代码生成所需）
install_host_codegen_tools() {
    info "安装宿主机原生代码生成工具..."

    # libwayland-bin: 提供 wayland-scanner（libwayland 配方需要）
    apt-get install -y libwayland-bin
}

# ============================================================
#  验证
# ============================================================

verify_installation() {
    info "验证安装..."

    local missing=()

    # 核心构建工具
    for cmd in gcc g++ make autoconf automake libtoolize pkg-config cmake meson ninja; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    # 交叉编译器
    for cmd in aarch64-linux-gnu-gcc aarch64-linux-gnu-g++ aarch64-linux-gnu-ld; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    # 下载工具
    command -v wget &>/dev/null || command -v curl &>/dev/null || missing+=("wget/curl")

    # 解压工具
    for cmd in tar unzip xz; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    # 其他必要工具
    for cmd in patch rsync python3 bison flex sha256sum nproc; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    # 宿主机原生工具
    command -v wayland-scanner &>/dev/null || missing+=("wayland-scanner")

    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "以下工具可能未正确安装: ${missing[*]}"
        warn "请检查上面的安装输出是否有错误"
        return 1
    fi

    info "所有工具已成功安装"
    return 0
}

# ============================================================
#  使用说明
# ============================================================

show_usage() {
    cat <<'USAGE'
用法: sudo ./setup-environment.sh [选项]

选项:
  -h, --help     显示此帮助信息
  -y, --yes      跳过确认提示，直接安装

此脚本将安装交叉编译构建系统所需的所有工具：

  构建工具:
    gcc, g++, make, autoconf, automake, libtool, pkg-config
    cmake, meson, ninja-build, bison, flex, gawk

  下载/解压工具:
    wget, curl, tar, unzip, xz-utils, gzip, bzip2, patch

  交叉编译工具链:
    aarch64-linux-gnu-gcc, aarch64-linux-gnu-g++, aarch64-linux-gnu-ld

  宿主机原生代码生成工具:
    wayland-scanner (libwayland-bin)
USAGE
}

# ============================================================
#  主函数
# ============================================================

main() {
    local auto_confirm=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_usage; exit 0 ;;
            -y|--yes)  auto_confirm=true; shift ;;
            *)         error "未知选项: $1" ;;
        esac
    done

    check_root
    detect_distro

    if ! $auto_confirm; then
        echo ""
        show_usage
        echo ""
        read -p "是否开始安装? (y/N): " -n 1 -r
        echo ""
        [[ $REPLY =~ ^[Yy]$ ]] || { info "已取消"; exit 0; }
    fi

    info "开始安装依赖..."

    apt-get update
    install_build_essentials
    install_build_systems
    install_archive_tools
    install_script_tools
    install_cross_toolchain
    install_gcc_cross_deps
    install_host_codegen_tools

    echo ""
    if verify_installation; then
        info "========================================="
        info "环境配置完成！"
        info "现在可以运行构建系统:"
        info "  ./start-build.sh <包名...>"
        info "  ./start-build.sh all"
        info "========================================="
    else
        error "环境验证未通过，请检查安装输出"
    fi
}

main "$@"
