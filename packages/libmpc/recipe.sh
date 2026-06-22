# packages/libmpc/recipe.sh
# MPC - 复数任意精度计算库

PKGNAME="libmpc"
VERSION="1.3.1"
DEPENDS="libmpfr"
SRC_URI="https://mirrors.kernel.org/gnu/mpc/mpc-${VERSION}.tar.gz"
SRC_HASH="ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8"
SRC_DIR="mpc-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --with-gmp="${PREFIX}" \
        --with-mpfr="${PREFIX}" \
        --disable-static
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}