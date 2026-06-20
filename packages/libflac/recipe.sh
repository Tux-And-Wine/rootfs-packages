# packages/libflac/recipe.sh
# FLAC - 自由无损音频编解码库

PKGNAME="libflac"
VERSION="1.5.0"
SRC_URI="https://downloads.xiph.org/releases/flac/flac-${VERSION}.tar.xz"
SRC_HASH="f2c1c76592a82ffff8413ba3c4a1299b6c7ab06c734dee03fd88630485c2b920"
SRC_DIR="flac-${VERSION}"

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