# packages/alsa-lib/recipe.sh
# alsa-lib - ALSA 音频库

PKGNAME="alsa-lib"
VERSION="1.2.13"
SRC_URI="https://www.alsa-project.org/files/pub/lib/alsa-lib-${VERSION}.tar.bz2"
SRC_DIR="alsa-lib-${VERSION}"

build() {
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"

    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --with-tmpdir="${IMAGEFS_ROOT}/tmp" \
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