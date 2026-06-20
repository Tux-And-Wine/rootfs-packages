# packages/libXau/recipe.sh
# libXau - X11 授权协议库

PKGNAME="libXau"
VERSION="1.0.12"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXau-${VERSION}.tar.xz"
SRC_HASH="74d0e4dfa3d39ad8939e99bda37f5967aba528211076828464d2777d477fc0fb"
SRC_DIR="libXau-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}