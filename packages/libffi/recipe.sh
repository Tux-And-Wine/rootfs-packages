# packages/libffi/recipe.sh
# libffi - 可移植外部函数接口库

PKGNAME="libffi"
VERSION="3.4.7"
SRC_URI="https://github.com/libffi/libffi/releases/download/v${VERSION}/libffi-${VERSION}.tar.gz"
SRC_HASH="138607dee268bdecf374adf9144c00e839e38541f75f24a1fcf18b78fda48b2d"
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
