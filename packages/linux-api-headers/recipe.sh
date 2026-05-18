# packages/linux-api-headers/recipe.sh
# linux-api-headers - 内核头文件（供用户空间使用）

PKGNAME="linux-api-headers"
VERSION="6.18.7"
SRC_URI="https://www.kernel.org/pub/linux/kernel/v${VERSION%%.*}.x/linux-${VERSION}.tar.xz"
SRC_DIR="linux-${VERSION}"

build() {
    # 纯头文件，无需编译
    true
}

install_target() {
    make headers_install ARCH=arm64 INSTALL_HDR_PATH="${PREFIX}"
}