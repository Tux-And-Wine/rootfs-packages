# packages/freetype/recipe.sh
# freetype - 字体渲染库

PKGNAME="freetype"
VERSION="2.13.3"
SRC_URI="https://downloads.sourceforge.net/freetype/freetype-${VERSION}.tar.xz"
SRC_HASH="0550350666d427c74daeb85d5ac7bb353acba5f76956395995311a9c6f063289"
SRC_DIR="freetype-${VERSION}"

build() {
    # 生成 Meson 交叉编译文件
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
        -Ddefault_library=shared

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}