# packages/linux-api-headers/recipe.sh
# linux-api-headers - 内核头文件（供用户空间使用）

PKGNAME="linux-api-headers"
VERSION="6.18.7"
SRC_URI="https://www.kernel.org/pub/linux/kernel/v${VERSION%%.*}.x/linux-${VERSION}.tar.xz"
SRC_HASH="b726a4d15cf9ae06219b56d87820776e34d89fbc137e55fb54a9b9c3015b8f1e"
SRC_DIR="linux-${VERSION}"

build() {
    # 清理源码树（必须，否则 headers_install 可能失败）
    make mrproper
}

install() {
    make headers_install ARCH=arm64 INSTALL_HDR_PATH="${DESTDIR}${PREFIX}"
}

install_target() {
    make headers_install ARCH=arm64 INSTALL_HDR_PATH="${PREFIX}"
}