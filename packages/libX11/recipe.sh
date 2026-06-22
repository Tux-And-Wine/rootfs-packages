# packages/libX11/recipe.sh
# libX11 - X11 核心客户端库

PKGNAME="libX11"
VERSION="1.8.11"
DEPENDS="libxcb xtrans"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libX11-${VERSION}.tar.xz"
SRC_HASH="3b74e82943924b45a0b778cc6842976909c3010d9445a8fd185e1dca4d380e88"
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