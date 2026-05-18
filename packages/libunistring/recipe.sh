# packages/libunistring/recipe.sh
# libunistring - Unicode 字符串处理库

PKGNAME="libunistring"
VERSION="1.3"
SRC_URI="https://ftp.gnu.org/gnu/libunistring/libunistring-${VERSION}.tar.xz"
SRC_DIR="libunistring-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}