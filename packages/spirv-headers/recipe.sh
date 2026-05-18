# packages/spirv-headers/recipe.sh
# SPIRV-Headers - SPIR-V 头文件

PKGNAME="spirv-headers"
VERSION="1.4.341.0"
SRC_URI="https://github.com/KhronosGroup/SPIRV-Headers/archive/refs/tags/vulkan-sdk-${VERSION}.tar.gz"
SRC_DIR="SPIRV-Headers-vulkan-sdk-${VERSION}"

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