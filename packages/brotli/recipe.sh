# packages/brotli/recipe.sh
# brotli - 通用压缩库

PKGNAME="brotli"
VERSION="1.1.0"
SRC_URI="https://github.com/google/brotli/archive/v${VERSION}.tar.gz"
SRC_DIR="brotli-${VERSION}"

build() {
    mkdir -p build && cd build
    cmake .. \
        -DCMAKE_C_COMPILER="${TARGET_HOST}-gcc" \
        -DCMAKE_CXX_COMPILER="${TARGET_HOST}-g++" \
        -DCMAKE_AR="${TARGET_HOST}-ar" \
        -DCMAKE_RANLIB="${TARGET_HOST}-ranlib" \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_SKIP_RPATH=ON
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install
}

install_target() {
    make install
    mkdir -p "${PREFIX}/share/man/man1" "${PREFIX}/share/man/man3"
    cp ../docs/brotli.1 "${PREFIX}/share/man/man1/"
    cp ../docs/*.3 "${PREFIX}/share/man/man3/"
}