# packages/fontconfig/recipe.sh
# fontconfig - 字体配置与发现库

PKGNAME="fontconfig"
VERSION="2.15.0"
SRC_URI="https://gitlab.freedesktop.org/fontconfig/fontconfig/-/archive/${VERSION}/fontconfig-${VERSION}.tar.gz"
SRC_DIR="fontconfig-${VERSION}"

prepare() {
    # 应用补丁（位于 patches/ 目录下）
    for patch in "${recipe_dir}/patches/"*.patch; do
        patch -p1 < "$patch"
    done
}

build() {
    # 生成 Meson 交叉编译文件
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
        -Ddefault-fonts-dirs=/system/fonts,"${PREFIX}"/share/fonts \
        -Ddefault-hinting=slight \
        -Ddefault-sub-pixel-rendering=rgb \
        -Ddoc-html=disabled \
        -Ddoc-pdf=disabled \
        -Ddoc-txt=disabled

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}