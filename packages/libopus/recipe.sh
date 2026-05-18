# packages/libopus/recipe.sh
# Opus 音频编解码库

PKGNAME="libopus"
VERSION="1.5.2"
SRC_URI="https://downloads.xiph.org/releases/opus/opus-${VERSION}.tar.gz"
SRC_DIR="opus-${VERSION}"

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
        -Dasm=disabled \
        -Dcustom-modes=true \
        -Ddeep-plc=enabled \
        -Ddred=enabled \
        -Dosce=enabled

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}