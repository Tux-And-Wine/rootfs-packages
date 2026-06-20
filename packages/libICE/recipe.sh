# packages/libICE/recipe.sh
# libICE - X11 进程间通信库

PKGNAME="libICE"
VERSION="1.1.2"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libICE-${VERSION}.tar.xz"
SRC_HASH="974e4ed414225eb3c716985df9709f4da8d22a67a2890066bc6dfc89ad298625"
SRC_DIR="libICE-${VERSION}"

prepare() {
    # 应用补丁：将硬链接改为符号链接（避免安卓内核限制）
    for patch in "${recipe_dir}/patches/"*.patch; do
        patch -p1 < "$patch"
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