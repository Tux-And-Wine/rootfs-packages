# packages/libXcursor/recipe.sh
# libXcursor - X 光标管理库

PKGNAME="libXcursor"
VERSION="1.2.3"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/libXcursor-${VERSION}.tar.xz"
SRC_HASH="fde9402dd4cfe79da71e2d96bb980afc5e6ff4f8a7d74c159e1966afb2b2c2c0"
SRC_DIR="libXcursor-${VERSION}"

prepare() {
    # 应用光标路径补丁，自动替换占位符为实际 PREFIX
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