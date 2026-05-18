# packages/libXi/recipe.sh
# libXi - X 输入扩展库

PKGNAME="libXi"
VERSION="1.8.2"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXi-${VERSION}.tar.xz"
SRC_DIR="libXi-${VERSION}"

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