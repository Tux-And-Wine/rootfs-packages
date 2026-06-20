# packages/libthai/recipe.sh
# libthai - 泰语语言处理库

PKGNAME="libthai"
VERSION="0.1.29"
SRC_URI="https://linux.thai.net/pub/thailinux/software/libthai/libthai-${VERSION}.tar.xz"
SRC_HASH="fc80cc7dcb50e11302b417cebd24f2d30a8b987292e77e003267b9100d0f4bcd"
SRC_DIR="libthai-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --disable-dict \
        CPPFLAGS="-I${PREFIX}/include" \
        LDFLAGS="-L${PREFIX}/lib"

    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}