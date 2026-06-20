# packages/libxslt/recipe.sh
# libxslt - XSLT 处理库

PKGNAME="libxslt"
VERSION="1.1.42"
SRC_URI="https://download.gnome.org/sources/libxslt/${VERSION%.*}/libxslt-${VERSION}.tar.xz"
SRC_HASH="85ca62cac0d41fc77d3f6033da9df6fd73d20ea2fc18b0a3609ffb4110e1baeb"
SRC_DIR="libxslt-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --without-python \
        --with-libxml-prefix="${PREFIX}" \
        CPPFLAGS="-I${PREFIX}/include" \
        LDFLAGS="-L${PREFIX}/lib"
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}