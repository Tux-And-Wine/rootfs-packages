# packages/libXext/recipe.sh
# libXext - X11 扩展库

PKGNAME="libXext"
VERSION="1.3.6"
DEPENDS="libX11"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXext-${VERSION}.tar.xz"
SRC_HASH="edb59fa23994e405fdc5b400afdf5820ae6160b94f35e3dc3da4457a16e89753"
SRC_DIR="libXext-${VERSION}"

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