# packages/libunwind/recipe.sh
# libunwind - 可移植堆栈展开库

PKGNAME="libunwind"
VERSION="1.8.1"
SRC_URI="https://github.com/libunwind/libunwind/releases/download/v${VERSION}/libunwind-${VERSION}.tar.gz"
SRC_HASH="ddf0e32dd5fafe5283198d37e4bf9decf7ba1770b6e7e006c33e6df79e6a6157"
SRC_DIR="libunwind-${VERSION}"

build() {
    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="$(dirname "${PREFIX}")"

    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-tests \
        --enable-shared \
        CFLAGS="-O2"
    make -j$(nproc) || make -j1
}

install() {
    make install DESTDIR="$DESTDIR"
}

install_target() {
    make install
}