# packages/vulkan-headers/recipe.sh
# Vulkan-Headers - Khronos Vulkan API 头文件

PKGNAME="vulkan-headers"
VERSION="1.4.309"
SRC_URI="https://github.com/KhronosGroup/Vulkan-Headers/archive/v${VERSION}.tar.gz"
SRC_DIR="Vulkan-Headers-${VERSION}"

build() {
    cmake -B build \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}"
}

install() {
    cmake --install build --prefix "${DESTDIR}${PREFIX}"
}

install_target() {
    cmake --install build
}