# packages/liblzma/recipe.sh
# xz - 压缩工具及 liblzma 库

PKGNAME="liblzma"
VERSION="5.6.4"
SRC_URI="https://github.com/tukaani-project/xz/releases/download/v${VERSION}/xz-${VERSION}.tar.xz"
SRC_HASH="829ccfe79d769748f7557e7a4429a64d06858e27e1e362e25d01ab7b931d9c95"
SRC_DIR="xz-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --enable-sandbox=no
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}
