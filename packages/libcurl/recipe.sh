# packages/libcurl/recipe.sh
# libcurl - URL 传输库及命令行工具

PKGNAME="libcurl"
VERSION="8.12.1"
SRC_URI="https://github.com/curl/curl/releases/download/curl-${VERSION//./_}/curl-${VERSION}.tar.xz"
SRC_HASH="0341f1ed97a26c811abaebd37d62b833956792b7607ea3f15d001613c76de202"
SRC_DIR="curl-${VERSION}"

prepare() {
    sed -i 's/cross_compiling=no/cross_compiling=yes/' configure
}

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --with-openssl \
        --with-nghttp2 \
        --with-zlib \
        --with-libssh2 \
        --with-brotli \
        --with-libpsl \
        --without-gssapi \
        --disable-ldap \
        --disable-ldaps \
        --enable-ipv6 \
        --with-ca-bundle="${PREFIX}/etc/ssl/certs/ca-certificates.crt" \
        --with-ca-path="${PREFIX}/etc/ssl/certs"
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}