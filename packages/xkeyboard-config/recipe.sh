# packages/xkeyboard-config/recipe.sh
# xkeyboard-config - X Keyboard 配置数据库

PKGNAME="xkeyboard-config"
VERSION="2.43"
SRC_URI="https://xorg.freedesktop.org/archive/individual/data/xkeyboard-config/xkeyboard-config-${VERSION}.tar.xz"
SRC_DIR="xkeyboard-config-${VERSION}"

build() {
    meson setup builddir \
        --prefix="${PREFIX}" \
        -Dxkb-base="${PREFIX}/share/X11/xkb" \
        -Dcompat-rules=true \
        -Dxorg-rules-symlinks=true

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}