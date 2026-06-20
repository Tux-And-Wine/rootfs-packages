# packages/libXxf86vm/recipe.sh
# libXxf86vm - X11 视频模式扩展库

PKGNAME="libXxf86vm"
VERSION="1.1.6"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXxf86vm-${VERSION}.tar.xz"
SRC_HASH="96af414c73ce1d5449ad04be7f9f27fa8330f844b6dda843ef22e3e1befb3ee3"
SRC_DIR="libXxf86vm-${VERSION}"

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