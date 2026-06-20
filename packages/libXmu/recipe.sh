# packages/libXmu/recipe.sh
# libXmu - X11 杂项工具包库

PKGNAME="libXmu"
VERSION="1.2.1"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXmu-${VERSION}.tar.xz"
SRC_HASH="fcb27793248a39e5fcc5b9c4aec40cc0734b3ca76aac3d7d1c264e7f7e14e8b2"
SRC_DIR="libXmu-${VERSION}"

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