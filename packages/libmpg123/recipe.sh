# packages/libmpg123/recipe.sh
# mpg123 - MPEG 音频解码器库

PKGNAME="libmpg123"
VERSION="1.32.10"
SRC_URI="https://mpg123.org/download/mpg123-${VERSION}.tar.bz2"
SRC_HASH="87b2c17fe0c979d3ef38eeceff6362b35b28ac8589fbf1854b5be75c9ab6557c"
SRC_DIR="mpg123-${VERSION}"

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