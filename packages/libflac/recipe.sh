# packages/libflac/recipe.sh
# FLAC - 自由无损音频编解码库

PKGNAME="libflac"
VERSION="1.5.0"
SRC_URI="https://downloads.xiph.org/releases/flac/flac-${VERSION}.tar.xz"
SRC_DIR="flac-${VERSION}"

build() {
    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="$(dirname "${PREFIX}")"

    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static

    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}