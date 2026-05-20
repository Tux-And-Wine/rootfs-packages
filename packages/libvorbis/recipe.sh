# packages/libvorbis/recipe.sh
# libvorbis - Vorbis 音频编解码库

PKGNAME="libvorbis"
VERSION="1.3.7"
SRC_URI="http://downloads.xiph.org/releases/vorbis/libvorbis-${VERSION}.tar.xz"
SRC_DIR="libvorbis-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}