# packages/libSM/recipe.sh
# libSM - X11 会话管理库

PKGNAME="libSM"
VERSION="1.2.5"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libSM-${VERSION}.tar.xz"
SRC_DIR="libSM-${VERSION}"

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