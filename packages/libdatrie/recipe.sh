# packages/libdatrie/recipe.sh
# libdatrie - 双数组字典树库

PKGNAME="libdatrie"
VERSION="0.2.13"
SRC_URI="https://linux.thai.net/pub/thailinux/software/libthai/libdatrie-${VERSION}.tar.xz"
SRC_DIR="libdatrie-${VERSION}"

build() {
    export CFLAGS="-O3 -pipe"
    export CPPFLAGS="-I${PREFIX}/include"
    export LDFLAGS="-L${PREFIX}/lib -liconv"

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