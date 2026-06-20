# packages/gdbm/recipe.sh
# GDBM - GNU 数据库管理器

PKGNAME="gdbm"
VERSION="1.24"
SRC_URI="https://mirrors.kernel.org/gnu/gdbm/gdbm-${VERSION}.tar.gz"
SRC_HASH="695e9827fdf763513f133910bc7e6cfdb9187943a4fec943e57449723d2b8dbf"
SRC_DIR="gdbm-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --enable-libgdbm-compat \
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