# packages/libpixman/recipe.sh
# pixman - 像素合成与操作库

PKGNAME="libpixman"
VERSION="0.44.2"
SRC_URI="https://cairographics.org/releases/pixman-${VERSION}.tar.gz"
SRC_DIR="pixman-${VERSION}"

build() {
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

    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="$(dirname "${PREFIX}")"

    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --prefix="${PREFIX}" \
        -Dloongson-mmi=disabled \
        -Dvmx=disabled \
        -Darm-simd=disabled \
        -Dneon=disabled \
        -Da64-neon=disabled \
        -Drvv=disabled \
        -Dmmx=disabled \
        -Dsse2=disabled \
        -Dssse3=disabled \
        -Dmips-dspr2=disabled \
        -Dgtk=disabled \
        -Ddefault_library=shared

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}