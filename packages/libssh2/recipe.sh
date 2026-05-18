# packages/libssh2/recipe.sh
# libssh2 - SSH2 客户端库

PKGNAME="libssh2"
VERSION="1.11.1"
SRC_URI="https://www.libssh2.org/download/libssh2-${VERSION}.tar.gz"
SRC_DIR="libssh2-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --with-openssl \
        --without-libgcrypt
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}