# packages/libsndfile/recipe.sh
# libsndfile - 音频文件处理库

PKGNAME="libsndfile"
VERSION="1.2.2"
SRC_URI="https://github.com/libsndfile/libsndfile/archive/refs/tags/${VERSION}.tar.gz"
SRC_HASH="ffe12ef8add3eaca876f04087734e6e8e029350082f3251f565fa9da55b52121"
SRC_DIR="libsndfile-${VERSION}"

prepare() {
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"
    # 将临时目录路径改为 Android rootfs 内的 /tmp
    sed -i "s|@TERMUX_PREFIX_CLASSICAL@/tmp|${IMAGEFS_ROOT}/tmp|" src/common.c
}

build() {
    local SYSROOT="$(dirname "${PREFIX}")"

    # CMake 交叉工具链文件
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

    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="${SYSROOT}"

    cmake -B build \
        -DCMAKE_TOOLCHAIN_FILE=toolchain-aarch64.cmake \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DBUILD_SHARED_LIBS=ON \
        -DENABLE_EXTERNAL_LIBS=ON \
        -DENABLE_MPEG=ON

    cmake --build build --parallel $(nproc)
}

install() {
    cmake --install build --prefix "${DESTDIR}${PREFIX}"
}

install_target() {
    cmake --install build
}