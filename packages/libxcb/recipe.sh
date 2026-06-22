# packages/libxcb/recipe.sh
# libxcb - X C Binding 库

PKGNAME="libxcb"
VERSION="1.17.0"
DEPENDS="xcb-proto libXau libXdmcp"
SRC_URI="https://xorg.freedesktop.org/archive/individual/lib/libxcb-${VERSION}.tar.xz"
SRC_HASH="599ebf9996710fea71622e6e184f3a8ad5b43d0e5fa8c4e407123c88a59a6d55"
SRC_DIR="libxcb-${VERSION}"

prepare() {
    # Unix socket 路径改为 IMAGEFS_ROOT 下的临时目录
    sed -i "s|/tmp/.X11-unix/X|$(dirname "${PREFIX}")/tmp/.X11-unix/X|g" src/xcb_util.c
}

build() {
    # 设置 Python 搜索路径，让宿主 python 找到 xcbgen 模块
    export PYTHONPATH="${PREFIX}/lib/python3/dist-packages:${PYTHONPATH:-}"

    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --enable-xinput \
        --enable-xkb \
        CPPFLAGS="-I${PREFIX}/include" \
        LDFLAGS="-L${PREFIX}/lib"

    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}