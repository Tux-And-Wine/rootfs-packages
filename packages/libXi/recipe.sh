# packages/libXi/recipe.sh
# libXi - X 输入扩展库

PKGNAME="libXi"
VERSION="1.8.2"
DEPENDS="libX11 libXext"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXi-${VERSION}.tar.xz"
SRC_HASH="d0e0555e53d6e2114eabfa44226ba162d2708501a25e18d99cfb35c094c6c104"
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