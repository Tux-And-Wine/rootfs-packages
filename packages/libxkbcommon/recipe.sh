# packages/libxkbcommon/recipe.sh
# libxkbcommon - 键盘公共处理库

PKGNAME="libxkbcommon"
VERSION="1.8.0"
SRC_URI="https://github.com/xkbcommon/libxkbcommon/archive/xkbcommon-${VERSION}.tar.gz"
SRC_DIR="libxkbcommon-xkbcommon-${VERSION}"

build() {
    cat > cross-aarch64.txt <<-EOF
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

    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="$(dirname "${PREFIX}")"

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