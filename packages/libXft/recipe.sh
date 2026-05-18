# packages/libXft/recipe.sh
# libXft - X FreeType 字体绘制库

PKGNAME="libXft"
VERSION="2.3.8"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXft-${VERSION}.tar.xz"
SRC_DIR="libXft-${VERSION}"

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