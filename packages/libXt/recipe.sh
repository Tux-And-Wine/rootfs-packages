# packages/libXt/recipe.sh
# libXt - X11 工具包库

PKGNAME="libXt"
VERSION="1.3.1"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXt-${VERSION}.tar.xz"
SRC_DIR="libXt-${VERSION}"

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