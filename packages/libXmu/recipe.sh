# packages/libXmu/recipe.sh
# libXmu - X11 杂项工具包库

PKGNAME="libXmu"
VERSION="1.2.1"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXmu-${VERSION}.tar.xz"
SRC_DIR="libXmu-${VERSION}"

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