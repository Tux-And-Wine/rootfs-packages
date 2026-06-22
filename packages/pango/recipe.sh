# packages/libpango/recipe.sh
# Pango - 国际化文本布局与渲染库

PKGNAME="libpango"
VERSION="1.54.0"
SRC_URI="https://gitlab.gnome.org/GNOME/pango/-/archive/${VERSION}/pango-${VERSION}.tar.gz"
SRC_HASH="317f366bb255282d3e64ccf95b1d57cbea8636578b199c158235e1f257e5167f"
SRC_DIR="pango-${VERSION}"

build() {
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

[properties]
needs_exe_wrapper = true
c_args = ['-O2', '-pipe', '-Wno-error=redundant-decls']
cpp_args = ['-O2', '-pipe', '-Wno-error=redundant-decls']
EOF

    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --prefix="${PREFIX}" \
        -Dc_link_args="-Wl,--allow-shlib-undefined" \
        -Dintrospection=disabled \
        -Dgtk_doc=false

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}