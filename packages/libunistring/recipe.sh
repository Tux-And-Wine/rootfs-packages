# packages/libunistring/recipe.sh
# libunistring - Unicode 字符串处理库

PKGNAME="libunistring"
VERSION="1.3"
DEPENDS="libiconv"
SRC_URI="https://ftp.gnu.org/gnu/libunistring/libunistring-${VERSION}.tar.xz"
SRC_HASH="f245786c831d25150f3dfb4317cda1acc5e3f79a5da4ad073ddca58886569527"
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