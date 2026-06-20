# packages/spirv-headers/recipe.sh
# SPIRV-Headers - SPIR-V 头文件

PKGNAME="spirv-headers"
VERSION="1.4.341.0"
SRC_URI="https://github.com/KhronosGroup/SPIRV-Headers/archive/refs/tags/vulkan-sdk-${VERSION}.tar.gz"
SRC_HASH="cab0a654c4917e16367483296b44cdb1d614e3120c721beafcd37e3a8580486c"
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