# packages/libglvnd/recipe.sh
# libglvnd - 供应商中立 GL 分派库

PKGNAME="libglvnd"
VERSION="1.7.0"
SRC_URI="https://gitlab.freedesktop.org/glvnd/libglvnd/-/archive/v${VERSION}/libglvnd-v${VERSION}.tar.gz"
SRC_HASH="2b6e15b06aafb4c0b6e2348124808cbd9b291c647299eaaba2e3202f51ff2f3d"
SRC_DIR="libglvnd-v${VERSION}"

build() {
    # 生成 Meson 交叉编译描述文件
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