# packages/libexpat/recipe.sh
# libexpat - XML 解析库

PKGNAME="libexpat"
VERSION="2.6.4"
SRC_URI="https://github.com/libexpat/libexpat/releases/download/R_${VERSION//./_}/expat-${VERSION}.tar.bz2"
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