# packages/libmpfr/recipe.sh
# MPFR - 多精度浮点运算库

PKGNAME="libmpfr"
VERSION="4.2.1"
SRC_URI="https://ftp.gnu.org/gnu/mpfr/mpfr-${VERSION}.tar.xz"
SRC_HASH="277807353a6726978996945af13e52829e3abd7a9a5b7fb2793894e18f1fcbb2"
SRC_DIR="mpfr-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        CPPFLAGS="-I${PREFIX}/include" \
        LDFLAGS="-L${PREFIX}/lib"

    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}