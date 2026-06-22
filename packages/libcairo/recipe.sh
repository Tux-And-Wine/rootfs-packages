# packages/libcairo/recipe.sh
# cairo - 2D 图形库

PKGNAME="libcairo"
VERSION="1.18.2"
SRC_URI="https://gitlab.freedesktop.org/cairo/cairo/-/archive/${VERSION}/cairo-${VERSION}.tar.bz2"
SRC_HASH="0b895967abfae888ecad9ace4bce475a27e1b9aaeedaaf334b97c96f13ccc604"
SRC_DIR="cairo-${VERSION}"

prepare() {
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"

    # 补丁1：cairo-script 临时字体路径
    sed -i "s|char template\[\] = \"/tmp/csi-font.XXXXXX\";|char template[] = \"${IMAGEFS_ROOT}/tmp/csi-font.XXXXXX\";|" \
        util/cairo-script/cairo-script-operators.c

    # 补丁2：fdr 跟踪文件路径
    sed -i "s|ctx = DLCALL (cairo_script_create, \"/tmp/fdr.trace\");|ctx = DLCALL (cairo_script_create, \"${IMAGEFS_ROOT}/tmp/fdr.trace\");|" \
        util/cairo-fdr/fdr.c
}

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
EOF

    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --prefix="${PREFIX}" \
        -Ddwrite=disabled \
        -Dspectre=disabled \
        -Dsymbol-lookup=disabled \
        -Dtests=disabled \
        -Dfontconfig=enabled \
        -Dfreetype=enabled \
        -Dglib=enabled \
        -Dpng=enabled \
        -Dxlib=enabled \
        -Dxcb=enabled \
        -Dtee=enabled \
        -Ddefault_library=shared

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}