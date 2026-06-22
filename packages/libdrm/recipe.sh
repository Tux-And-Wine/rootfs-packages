# packages/libdrm/recipe.sh
# libdrm - 直接渲染管理器库

PKGNAME="libdrm"
VERSION="2.4.124"
SRC_URI="https://dri.freedesktop.org/libdrm/libdrm-${VERSION}.tar.xz"
SRC_HASH="ac36293f61ca4aafaf4b16a2a7afff312aa4f5c37c9fbd797de9e3c0863ca379"
SRC_DIR="libdrm-${VERSION}"

build() {
    # 交叉编译描述文件
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
        -Dudev=false \
        -Dvalgrind=disabled \
        -Dinstall-test-programs=true \
        -Domap=enabled \
        -Dexynos=enabled \
        -Dtegra=enabled \
        -Detnaviv=enabled \
        -Dfreedreno-kgsl=true \
        -Dintel=disabled \
        -Dradeon=disabled \
        -Damdgpu=disabled \
        -Dnouveau=disabled \
        -Dvmwgfx=disabled

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}