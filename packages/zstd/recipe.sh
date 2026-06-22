# packages/zstd/recipe.sh
# zstd - Facebook 快速压缩库

PKGNAME="zstd"
VERSION="1.5.7"
SRC_URI="https://github.com/facebook/zstd/archive/v${VERSION}.tar.gz"
SRC_HASH="37d7284556b20954e56e1ca85b80226768902e2edabd3b649e9e72c0c9012ee3"
SRC_DIR="zstd-${VERSION}"

prepare() {
    # 移除 gen_html 子目录（避免构建错误）
    sed -i "/subdir('gen_html')/d" build/meson/contrib/meson.build
}

build() {
    cd build/meson

    # 创建交叉编译描述文件
    cat > cross-aarch64.txt <<EOF
[binaries]
c = '${TARGET_HOST}-gcc'
cpp = '${TARGET_HOST}-g++'
ar = '${TARGET_HOST}-ar'
strip = '${TARGET_HOST}-strip'
ranlib = '${TARGET_HOST}-ranlib'
pkgconfig = 'pkg-config'

[host_machine]
system = 'linux'
cpu_family = 'aarch64'
cpu = 'aarch64'
endian = 'little'
EOF

    # 配置
    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --prefix="${PREFIX}" \
        --libdir=lib \
        -Ddefault_library=both \
        -Dbin_programs=true \
        -Dbin_tests=false \
        -Dbin_contrib=true \
        -Dzlib=enabled \
        -Dlzma=enabled \
        -Dlz4=enabled

    # 编译
    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}