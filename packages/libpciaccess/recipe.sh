# packages/libpciaccess/recipe.sh
# libpciaccess - 通用 PCI 访问库

PKGNAME="libpciaccess"
VERSION="0.17"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libpciaccess-${VERSION}.tar.xz"
SRC_DIR="libpciaccess-${VERSION}"

build() {
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