# packages/libXinerama/recipe.sh
# libXinerama - X11 Xinerama 扩展库

PKGNAME="libXinerama"
VERSION="1.1.5"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXinerama-${VERSION}.tar.xz"
SRC_DIR="libXinerama-${VERSION}"

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