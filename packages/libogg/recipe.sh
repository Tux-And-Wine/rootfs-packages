# packages/libogg/recipe.sh
# libogg - Ogg 容器格式库

PKGNAME="libogg"
VERSION="1.3.5"
SRC_URI="https://github.com/xiph/ogg/releases/download/v${VERSION}/libogg-${VERSION}.tar.xz"
SRC_HASH="c4d91be36fc8e54deae7575241e03f4211eb102afb3fc0775fbbc1b740016705"
SRC_DIR="libogg-${VERSION}"

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