# packages/libpulse/recipe.sh
# PulseAudio 客户端库

PKGNAME="libpulse"
VERSION="17.0"
SRC_URI="https://github.com/pulseaudio/pulseaudio/archive/refs/tags/v${VERSION}.tar.gz"
SRC_HASH="ed36c8a0cdff7b57382a258d3e1a916f42500fbafd64dd3c2e258ed8f017ee90"
SRC_DIR="pulseaudio-${VERSION}"

prepare() {
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"

    # 创建 .tarball-version 文件，否则 git-version-gen 无法获取版本号
    echo "${VERSION}" > .tarball-version

    # 应用路径补丁（自动替换 @@PREFIX@@ 和 @@IMAGEFS_ROOT@@）
    [[ -d "${recipe_dir}/patches" ]] || return 0
    for patch in "${recipe_dir}/patches/"*.patch; do
        sed -e "s|@@PREFIX@@|${PREFIX}|g" \
            -e "s|@@IMAGEFS_ROOT@@|${IMAGEFS_ROOT}|g" \
            "$patch" | patch -p1
    done
}

build() {
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"

    # Meson 交叉编译描述文件
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

    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="${IMAGEFS_ROOT}"

    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --prefix="${PREFIX}" \
        -Ddaemon=false \
        -Dman=false \
        -Dtests=false \
        -Ddatabase=gdbm \
        -Dx11=enabled \
        -Ddbus=enabled \
        -Dalsa=enabled \
        -Ddoxygen=false

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}