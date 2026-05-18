# packages/libtiff/recipe.sh
# libtiff - TIFF 图像处理库

PKGNAME="libtiff"
VERSION="4.7.0"
SRC_URI="https://download.osgeo.org/libtiff/tiff-${VERSION}.tar.xz"
SRC_DIR="tiff-${VERSION}"

build() {
    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="$(dirname "${PREFIX}")"

    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --enable-ld-version-script
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}