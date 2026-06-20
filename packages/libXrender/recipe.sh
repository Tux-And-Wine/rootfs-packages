# packages/libXrender/recipe.sh
# libXrender - X 渲染扩展库

PKGNAME="libXrender"
VERSION="0.9.12"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXrender-${VERSION}.tar.xz"
SRC_HASH="b832128da48b39c8d608224481743403ad1691bf4e554e4be9c174df171d1b97"
SRC_DIR="libXrender-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}