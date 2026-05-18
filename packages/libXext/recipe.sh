# packages/libXext/recipe.sh
# libXext - X11 扩展库

PKGNAME="libXext"
VERSION="1.3.6"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXext-${VERSION}.tar.xz"
SRC_DIR="libXext-${VERSION}"

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