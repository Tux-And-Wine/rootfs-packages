# packages/libgmp/recipe.sh
# GMP - 高精度算术库

PKGNAME="libgmp"
VERSION="6.3.0"
SRC_URI="https://mirrors.kernel.org/gnu/gmp/gmp-${VERSION}.tar.xz"
SRC_HASH="a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898"
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