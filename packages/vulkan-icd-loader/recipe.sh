# packages/vulkan-loader/recipe.sh
# libvulkan-loader - Vulkan 加载器

PKGNAME="vulkan-loader"
VERSION="1.3.301"
SRC_URI="https://github.com/KhronosGroup/Vulkan-Loader/archive/v${VERSION}.tar.gz"
SRC_HASH="7f6895bb25faaca72b9d75325f1d225ae7f30081d3e81c8c19f2c4556b23d676"
SRC_DIR="Vulkan-Loader-${VERSION}"

build() {
    # 推导 sysroot（PREFIX 的上一级，例如 /data/.../imagefs）
    local SYSROOT="$(dirname "${PREFIX}")"

    # 生成交叉编译工具链文件
    cat > toolchain-aarch64.cmake <<-CMAKE_EOF
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

    mkdir -p build && cd build
    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE=../toolchain-aarch64.cmake \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DVULKAN_HEADERS_INSTALL_DIR="${PREFIX}" \
        -DFALLBACK_CONFIG_DIRS="${PREFIX}/etc/xdg" \
        -DFALLBACK_DATA_DIRS="${PREFIX}/local/share:${PREFIX}/share" \
        -DSYSCONFDIR="${PREFIX}/etc" \
        -DBUILD_WSI_XCB_SUPPORT=ON \
        -DBUILD_WSI_XLIB_SUPPORT=ON \
        -DBUILD_WSI_WAYLAND_SUPPORT=OFF

    make -j$(nproc)
}

install() {
    # 此时在 build 目录中
    make install DESTDIR="$DESTDIR"
}

install_target() {
    make install
}