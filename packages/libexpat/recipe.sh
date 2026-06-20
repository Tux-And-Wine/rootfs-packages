# packages/libexpat/recipe.sh
# libexpat - XML 解析库

PKGNAME="libexpat"
VERSION="2.6.4"
SRC_URI="https://github.com/libexpat/libexpat/releases/download/R_${VERSION//./_}/expat-${VERSION}.tar.bz2"
SRC_HASH="8dc480b796163d4436e6f1352e71800a774f73dbae213f1860b60607d2a83ada"
SRC_DIR="expat-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --without-docbook
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}