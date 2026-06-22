# packages/libepoxy/recipe.sh
# libepoxy - OpenGL 函数指针管理库

PKGNAME="libepoxy"
VERSION="1.5.10"
SRC_URI="https://github.com/anholt/libepoxy/archive/refs/tags/${VERSION}.tar.gz"
SRC_HASH="a7ced37f4102b745ac86d6a70a9da399cc139ff168ba6b8002b4d8d43c900c15"
SRC_DIR="libepoxy-${VERSION}"

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
        --prefix="${PREFIX}"

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}