# packages/libXcomposite/recipe.sh
# libXcomposite - X11 Composite 扩展库

PKGNAME="libXcomposite"
VERSION="0.4.6"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXcomposite-${VERSION}.tar.xz"
SRC_DIR="libXcomposite-${VERSION}"

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