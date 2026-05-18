# packages/libXdmcp/recipe.sh
# libXdmcp - X 显示管理器控制协议库

PKGNAME="libXdmcp"
VERSION="1.1.5"
SRC_URI="https://xorg.freedesktop.org/archive/individual/lib/libXdmcp-${VERSION}.tar.xz"
SRC_DIR="libXdmcp-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}