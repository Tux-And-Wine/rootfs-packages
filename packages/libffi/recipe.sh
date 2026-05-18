# packages/libffi/recipe.sh
# libffi - 可移植外部函数接口库

PKGNAME="libffi"
VERSION="3.4.7"
SRC_URI="https://github.com/libffi/libffi/releases/download/v${VERSION}/libffi-${VERSION}.tar.gz"
SRC_DIR="libffi-${VERSION}"

build() {
    ./configure \
        --prefix="${PREFIX}" \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --disable-multi-os-directory \
        --disable-exec-static-tramp \
        --enable-pax_emutramp
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install
}

install_target() {
    make install
}
