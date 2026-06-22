# packages/libxkbcommon/recipe.sh
# libxkbcommon - 键盘公共处理库

PKGNAME="libxkbcommon"
VERSION="1.8.0"
DEPENDS="xorgproto libxcb xkeyboard-config"
SRC_URI="https://github.com/xkbcommon/libxkbcommon/archive/xkbcommon-${VERSION}.tar.gz"
SRC_HASH="025c53032776ed850fbfb92683a703048cd70256df4ac1a1ec41ed3455d5d39c"
SRC_DIR="libxkbcommon-xkbcommon-${VERSION}"

build() {
    cat > cross-aarch64.txt <<EOF
[binaries]
c = '${TARGET_HOST}-gcc'
cpp = '${TARGET_HOST}-g++'
ar = '${TARGET_HOST}-ar'
strip = '${TARGET_HOST}-strip'
pkgconfig = 'pkg-config'

[host_machine]
system = 'linux'
cpu_family = 'aarch64'
cpu = 'aarch64'
endian = 'little'
EOF

    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --prefix="${PREFIX}" \
        -Denable-wayland=false \
        -Denable-x11=true \
        -Denable-docs=false

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}