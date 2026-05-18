# packages/libidn2/recipe.sh
# libidn2 - 国际化域名库 (IDNA2008)

PKGNAME="libidn2"
VERSION="2.3.7"
SRC_URI="https://mirrors.kernel.org/gnu/libidn/libidn2-${VERSION}.tar.gz"
SRC_DIR="libidn2-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
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