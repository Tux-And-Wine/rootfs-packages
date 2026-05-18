# packages/libgpg-error/recipe.sh
# libgpg-error - GPG 错误报告库

PKGNAME="libgpg-error"
VERSION="1.50"
SRC_URI="https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-${VERSION}.tar.bz2"
SRC_DIR="libgpg-error-${VERSION}"

prepare() {
    autoreconf -vfi
}

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