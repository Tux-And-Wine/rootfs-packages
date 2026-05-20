# packages/wayland/recipe.sh
# Wayland - 协议与客户端/服务端库

PKGNAME="wayland"
VERSION="1.23.1"
SRC_URI="https://gitlab.freedesktop.org/wayland/wayland/-/releases/${VERSION}/downloads/wayland-${VERSION}.tar.xz"
SRC_DIR="wayland-${VERSION}"

prepare() {
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"

    # 应用路径补丁：XDG_RUNTIME_DIR 指向 rootfs 的 /tmp
    # 补丁位于 packages/wayland/patches/setdirs.patch
    for patch in "${recipe_dir}/patches/"*.patch; do
        sed "s|@@IMAGEFS_ROOT@@|${IMAGEFS_ROOT}|g" "$patch" | patch -p1
    done
}

build() {
    # 交叉编译文件
    cat > cross-aarch64.txt <<-EOF
    [binaries]
    c = '${TARGET_HOST}-gcc'
    cpp = '${TARGET_HOST}-g++'
    ar = '${TARGET_HOST}-ar'
    strip = '${TARGET_HOST}-strip'
    pkgconfig = '${TARGET_HOST}-pkg-config'

    [host_machine]
    system = 'linux'
    cpu_family = 'aarch64'
    cpu = 'aarch64'
    endian = 'little'

    [properties]
    needs_exe_wrapper = true
	EOF

    # 原生编译文件（用于 wayland-scanner）
    cat > native.txt <<-EOF
    [binaries]
    c = 'gcc'
    cpp = 'g++'
    ar = 'ar'
    strip = 'strip'
    pkgconfig = 'pkg-config'
    wayland-scanner = '/usr/bin/wayland-scanner'
	EOF

    # pkg-config 指向宿主机的交叉编译依赖
    export PKG_CONFIG_LIBDIR="/usr/lib/${TARGET_HOST}/pkgconfig:/usr/share/pkgconfig"

    # 临时取消 sysroot，避免 native pkg-config 查询 wayland-scanner 时路径被污染
    unset PKG_CONFIG_SYSROOT_DIR

    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --native-file native.txt \
        --prefix="${PREFIX}" \
        -Ddocumentation=false

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}