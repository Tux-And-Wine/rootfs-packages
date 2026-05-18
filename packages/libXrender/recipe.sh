# packages/libXrender/recipe.sh
# libXrender - X 渲染扩展库

PKGNAME="libXrender"
VERSION="0.9.12"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXrender-${VERSION}.tar.xz"
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