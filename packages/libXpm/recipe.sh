# packages/libXpm/recipe.sh
# libXpm - X11 像素图库

PKGNAME="libXpm"
VERSION="3.5.17"
DEPENDS="libX11 libXext"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXpm-${VERSION}.tar.xz"
SRC_HASH="64b31f81019e7d388c822b0b28af8d51c4622b83f1f0cb6fa3fc95e271226e43"
SRC_DIR="libXpm-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --disable-open-zfile \
        ac_cv_path_XPM_PATH_COMPRESS="${PREFIX}/bin/compress" \
        ac_cv_path_XPM_PATH_UNCOMPRESS="${PREFIX}/bin/uncompress" \
        ac_cv_path_XPM_PATH_GZIP="${PREFIX}/bin/gzip"
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}