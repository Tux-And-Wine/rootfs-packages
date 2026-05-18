# packages/libgmp/recipe.sh
# GMP - 高精度算术库

PKGNAME="libgmp"
VERSION="6.3.0"
SRC_URI="https://mirrors.kernel.org/gnu/gmp/gmp-${VERSION}.tar.xz"
SRC_DIR="gmp-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}