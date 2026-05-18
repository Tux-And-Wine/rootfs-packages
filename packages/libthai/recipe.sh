# packages/libthai/recipe.sh
# libthai - 泰语语言处理库

PKGNAME="libthai"
VERSION="0.1.29"
SRC_URI="https://linux.thai.net/pub/thailinux/software/libthai/libthai-${VERSION}.tar.xz"
SRC_DIR="libthai-${VERSION}"

build() {
    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="$(dirname "${PREFIX}")"

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