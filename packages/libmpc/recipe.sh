# packages/libmpc/recipe.sh
# MPC - 复数任意精度计算库

PKGNAME="libmpc"
VERSION="1.3.1"
SRC_URI="https://mirrors.kernel.org/gnu/mpc/mpc-${VERSION}.tar.gz"
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