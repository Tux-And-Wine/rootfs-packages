# packages/libXt/recipe.sh
# libXt - X11 工具包库

PKGNAME="libXt"
VERSION="1.3.1"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXt-${VERSION}.tar.xz"
SRC_HASH="e0a774b33324f4d4c05b199ea45050f87206586d81655f8bef4dba434d931288"
SRC_DIR="libXt-${VERSION}"

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