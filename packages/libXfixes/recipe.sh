# packages/libXfixes/recipe.sh
# libXfixes - X Fixes 扩展库

PKGNAME="libXfixes"
VERSION="6.0.1"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXfixes-${VERSION}.tar.xz"
SRC_DIR="libXfixes-${VERSION}"

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