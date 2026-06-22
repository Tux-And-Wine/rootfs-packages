# packages/libxml2/recipe.sh
# libxml2 - XML 解析库

PKGNAME="libxml2"
VERSION="2.13.6"
DEPENDS="liblzma libiconv"
SRC_URI="https://download.gnome.org/sources/libxml2/${VERSION%.*}/libxml2-${VERSION}.tar.xz"
SRC_HASH="f453480307524968f7a04ec65e64f2a83a825973bcd260a2e7691be82ae70c96"
SRC_DIR="libxml2-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --with-zlib="${PREFIX}" \
        --with-lzma="${PREFIX}" \
        --with-iconv="${PREFIX}" \
        --without-icu \
        --with-history \
        --with-threads \
        --without-python
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}