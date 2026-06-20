# packages/libXrandr/recipe.sh
# libXrandr - X RandR 扩展库

PKGNAME="libXrandr"
VERSION="1.5.4"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXrandr-${VERSION}.tar.xz"
SRC_HASH="1ad5b065375f4a85915aa60611cc6407c060492a214d7f9daf214be752c3b4d3"
SRC_DIR="libXrandr-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --enable-malloc0returnsnull=no
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}