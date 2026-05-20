# packages/xorgproto/recipe.sh
# xorgproto - Xorg 协议头文件

PKGNAME="xorgproto"
VERSION="2024.1"
SRC_URI="https://xorg.freedesktop.org/archive/individual/proto/xorgproto-${VERSION}.tar.xz"
SRC_DIR="xorgproto-${VERSION}"

prepare() {
    # 移除可能残留的 configure 文件
    rm -f configure

    # 修正 pkgconfig 安装路径
    sed -i "s|get_option('datadir') + '/pkgconfig'|'${PREFIX}/lib/pkgconfig'|g" meson.build
}

build() {
    # 交叉编译描述文件
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
        --prefix="${PREFIX}"

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir

    # 清理不需要的平台扩展头文件
    rm -rf "${PREFIX}/include/X11/extensions/apple"*
    rm -rf "${PREFIX}/include/X11/extensions/windows"*
    rm -f "${PREFIX}/include/X11/extensions/XKBgeom.h"
    rm -f "${PREFIX}/lib/pkgconfig/applewmproto.pc"
    rm -f "${PREFIX}/lib/pkgconfig/windowswmproto.pc"
}