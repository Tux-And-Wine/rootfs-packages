# packages/libpango/recipe.sh
# Pango - 国际化文本布局与渲染库

PKGNAME="libpango"
VERSION="1.54.0"
SRC_URI="https://gitlab.gnome.org/GNOME/pango/-/archive/${VERSION}/pango-${VERSION}.tar.gz"
SRC_DIR="pango-${VERSION}"

build() {
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

    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --prefix="${PREFIX}" \
        -Dc_link_args="-Wl,--allow-shlib-undefined" \
        -Dintrospection=disabled \
        -Dgtk_doc=false

    # glibc 2.42: __REDIRECT 宏触发 redundant-decls 错误，c_args 靠前会被后面的 -Werror= 覆盖
    sed -i 's/-Werror=redundant-decls/-Wno-error=redundant-decls/g' builddir/build.ninja

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}