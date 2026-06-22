# packages/spirv-tools/recipe.sh
# SPIRV-Tools - SPIR-V 工具和库

PKGNAME="spirv-tools"
VERSION="2026.1"
SRC_URI="https://github.com/KhronosGroup/SPIRV-Tools/archive/refs/tags/v${VERSION}.tar.gz"
SRC_HASH="35dc16cf2dc64be5b6bbbe86d210e6f4a82b070cffd751605a3365cd8bce2d7e"
SRC_DIR="SPIRV-Tools-${VERSION}"

build() {
    local SYSROOT="$(dirname "${PREFIX}")"

    # 交叉编译工具链文件
    cat > toolchain-aarch64.cmake <<CMAKE_EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)
set(CMAKE_SYSROOT ${SYSROOT})
set(CMAKE_C_COMPILER ${TARGET_HOST}-gcc)
set(CMAKE_CXX_COMPILER ${TARGET_HOST}-g++)
set(CMAKE_FIND_ROOT_PATH ${PREFIX})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
CMAKE_EOF

    cmake -B build \
        -DCMAKE_TOOLCHAIN_FILE=toolchain-aarch64.cmake \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DSPIRV-Headers_SOURCE_DIR="${PREFIX}" \
        -DSPIRV_WERROR=OFF \
        -DSPIRV_SKIP_TESTS=ON \
        -DCMAKE_BUILD_TYPE=Release

    cmake --build build --parallel $(nproc)
}

install() {
    cmake --install build --prefix "${DESTDIR}${PREFIX}"
}

install_target() {
    cmake --install build
}