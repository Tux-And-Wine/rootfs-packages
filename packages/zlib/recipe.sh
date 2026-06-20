# packages/zlib/recipe.sh
# zlib - 压缩库

PKGNAME="zlib"
VERSION="1.3.1"
SRC_URI="https://github.com/madler/zlib/releases/download/v${VERSION}/zlib-${VERSION}.tar.gz"
SRC_HASH="9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"
SRC_DIR="zlib-${VERSION}"

# zlib 的 configure 不支持 --host，需要用 CC 来指定交叉编译器
prepare() {
    export CC="${TARGET_HOST}-gcc"
    export AR="${TARGET_HOST}-ar"
    export RANLIB="${TARGET_HOST}-ranlib"
}

build() {
    ./configure --prefix="${PREFIX}"
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install
}

install_target() {
    make install
}
