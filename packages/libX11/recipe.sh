# packages/libX11/recipe.sh
# libX11 - X11 核心客户端库

PKGNAME="libX11"
VERSION="1.8.11"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libX11-${VERSION}.tar.xz"
SRC_DIR="libX11-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --disable-xf86bigfont
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}