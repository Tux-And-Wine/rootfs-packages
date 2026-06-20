# packages/libjpeg-turbo/recipe.sh
# libjpeg-turbo - JPEG 图像处理库

PKGNAME="libjpeg-turbo"
VERSION="3.1.0"
SRC_URI="https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/${VERSION}/libjpeg-turbo-${VERSION}.tar.gz"
SRC_HASH="9564c72b1dfd1d6fe6274c5f95a8d989b59854575d4bbee44ade7bc17aa9bc93"
SRC_DIR="libjpeg-turbo-${VERSION}"

build() {
    # 清除可能泄漏的环境变量，防止干扰 cmake 编译器检测
    unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS

    cat > toolchain-aarch64.cmake <<-CMAKE_EOF
    set(CMAKE_SYSTEM_NAME Linux)
    set(CMAKE_SYSTEM_PROCESSOR aarch64)
    set(CMAKE_SYSROOT $(dirname "${PREFIX}"))
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
        -DENABLE_SHARED=ON \
        -DENABLE_STATIC=OFF \
        -DWITH_JPEG8=ON

    cmake --build build --parallel $(nproc)
}

install() {
    cmake --install build --prefix "${DESTDIR}${PREFIX}"
}

install_target() {
    cmake --install build
}