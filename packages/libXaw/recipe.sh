# packages/libXaw/recipe.sh
# libXaw - X11 Athena 工具包库

PKGNAME="libXaw"
VERSION="1.0.16"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXaw-${VERSION}.tar.xz"
SRC_DIR="libXaw-${VERSION}"

prepare() {
    for patch in "${recipe_dir}/patches/"*.patch; do
        sed "s|@@PREFIX@@|${PREFIX}|g" "$patch" | patch -p1
    done
}

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