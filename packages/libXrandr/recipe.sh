# packages/libXrandr/recipe.sh
# libXrandr - X RandR 扩展库

PKGNAME="libXrandr"
VERSION="1.5.4"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXrandr-${VERSION}.tar.xz"
SRC_DIR="libXrandr-${VERSION}"

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