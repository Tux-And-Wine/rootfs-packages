# packages/libxshmfence/recipe.sh
# libxshmfence - X 共享内存栅栏库

PKGNAME="libxshmfence"
VERSION="1.3.3"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libxshmfence-${VERSION}.tar.xz"
SRC_HASH="d4a4df096aba96fea02c029ee3a44e11a47eb7f7213c1a729be83e85ec3fde10"
SRC_DIR="libxshmfence-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --with-shared-memory-dir=/tmp
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}