# packages/libXxf86vm/recipe.sh
# libXxf86vm - X11 视频模式扩展库

PKGNAME="libXxf86vm"
VERSION="1.1.6"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXxf86vm-${VERSION}.tar.xz"
SRC_DIR="libXxf86vm-${VERSION}"

build() {
    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="$(dirname "${PREFIX}")"

    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --enable-malloc0returnsnull=no
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}