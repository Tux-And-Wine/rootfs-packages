# packages/liblz4/recipe.sh
# lz4 - 快速压缩库

PKGNAME="liblz4"
VERSION="1.10.0"
SRC_URI="https://github.com/lz4/lz4/archive/v${VERSION}.tar.gz"
SRC_DIR="lz4-${VERSION}"

build() {
    make -j$(nproc) \
        CC="${TARGET_HOST}-gcc" \
        AR="${TARGET_HOST}-ar" \
        RANLIB="${TARGET_HOST}-ranlib" \
        PREFIX="${PREFIX}"
}

install() {
    make install DESTDIR="$DESTDIR" PREFIX="${PREFIX}"
}

install_target() {
    make install PREFIX="${PREFIX}"
}
