# packages/libXcomposite/recipe.sh
# libXcomposite - X11 Composite 扩展库

PKGNAME="libXcomposite"
VERSION="0.4.6"
DEPENDS="libX11 libXext"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXcomposite-${VERSION}.tar.xz"
SRC_HASH="fe40bcf0ae1a09070eba24088a5eb9810efe57453779ec1e20a55080c6dc2c87"
SRC_DIR="libXcomposite-${VERSION}"

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