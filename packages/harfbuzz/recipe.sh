# packages/libharfbuzz/recipe.sh
# HarfBuzz - 文字形状库

PKGNAME="libharfbuzz"
VERSION="10.1.0"
SRC_URI="https://github.com/harfbuzz/harfbuzz/archive/${VERSION}.tar.gz"
SRC_DIR="harfbuzz-${VERSION}"

prepare() {
    # 升级 C++ 标准：c++11 → c++17
    sed -i "s/'cpp_std=c++11'/'cpp_std=c++17'/" meson.build
    sed -i "s/get_option('cpp_std') == 'c++11'/get_option('cpp_std') == 'c++17'/g" meson.build

    # 删除重复的 assert.h 包含（避免冗余声明警告）
    sed -i '/^#include <assert.h>$/d' util/ansi-print.hh
    sed -i '/^#include <assert.h>$/d' util/options.hh
}

build() {
    # 临时注释 sysroot 中 inttypes.h 的冲突行（避免 strtoimax/strtoumax 重定向声明冲突）
    local inttypes_h="${PREFIX}/include/inttypes.h"
    if [[ -f "$inttypes_h" ]]; then
        sed -i '384,386s/^/\/\//' "$inttypes_h"
        sed -i '387,389s/^/\/\//' "$inttypes_h"
        sed -i '390,393s/^/\/\//' "$inttypes_h"
        sed -i '394,397s/^/\/\//' "$inttypes_h"
    else
        warn "未找到 ${inttypes_h}，跳过注释（可能需要先安装 glibc）"
    fi

    # 生成 Meson 交叉编译文件
    cat > cross-aarch64.txt <<-EOF
    [binaries]
    c = '${TARGET_HOST}-gcc'
    cpp = '${TARGET_HOST}-g++'
    ar = '${TARGET_HOST}-ar'
    strip = '${TARGET_HOST}-strip'
    pkgconfig = 'pkg-config'

    [properties]
    c_args = ['-O2', '-pipe', '-Wno-error=redundant-decls']
    cpp_args = ['-O2', '-pipe', '-Wno-error=redundant-decls']

    [host_machine]
    system = 'linux'
    cpu_family = 'aarch64'
    cpu = 'aarch64'
    endian = 'little'
	EOF

    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --prefix="${PREFIX}" \
        -Ddocs=disabled \
        -Dglib=enabled \
        -Dgobject=enabled \
        -Dcairo=enabled \
        -Dfreetype=enabled \
        -Dgraphite2=disabled \
        -Dicu=disabled \
        -Dintrospection=disabled

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}