# packages/libnghttp2/recipe.sh
# libnghttp2 - HTTP/2 协议库

PKGNAME="libnghttp2"
VERSION="1.65.0"
SRC_URI="https://github.com/nghttp2/nghttp2/releases/download/v${VERSION}/nghttp2-${VERSION}.tar.xz"
SRC_HASH="f1b9df5f02e9942b31247e3d415483553bc4ac501c87aa39340b6d19c92a9331"
SRC_DIR="nghttp2-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --enable-lib-only \
        --disable-static
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}