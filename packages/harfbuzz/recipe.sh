# packages/libharfbuzz/recipe.sh
# HarfBuzz - 文字形状库

PKGNAME="libharfbuzz"
VERSION="10.1.0"
SRC_URI="https://github.com/harfbuzz/harfbuzz/archive/${VERSION}.tar.gz"
SRC_HASH="c758fdce8587641b00403ee0df2cd5d30cbea7803d43c65fddd76224f7b49b88"
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
    # 生成 Meson 交叉编译文件
    cat > cross-aarch64.txt <<EOF
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