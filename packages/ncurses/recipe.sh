# packages/ncurses/recipe.sh
# ncurses - 终端界面库

PKGNAME="ncurses"
VERSION="6.5"
SRC_URI="https://ftp.gnu.org/gnu/ncurses/ncurses-${VERSION}.tar.gz"
SRC_DIR="ncurses-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-root-access \
        --disable-root-environ \
        --disable-setuid-environ \
        --enable-widec \
        --enable-pc-files \
        --with-shared \
        --with-cxx-binding \
        --with-versioned-syms \
        --with-pkg-config-libdir="${PREFIX}/lib/pkgconfig" \
        --with-xterm-kbs=del \
        --without-ada \
        --without-strip \
        --mandir="${PREFIX}/share/man"

    # 你的文档里 sed 在 configure 之后、make 之前
    sed -i 's/^INSTALL_PROG\s*=.*/INSTALL_PROG = \$(INSTALL)/' progs/Makefile

    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install
}

install_target() {
    make install

    local VER_MAJOR="6"

    # 以下完全按照你文档中的后处理步骤
    for lib in ncurses ncurses++ form panel menu; do
        printf "INPUT(-l%sw)\n" "${lib}" > "${PREFIX}/lib/lib${lib}.so"
        ln -svf "${lib}w.pc" "${PREFIX}/lib/pkgconfig/${lib}.pc"
    done

    printf 'INPUT(-lncursesw)\n' > "${PREFIX}/lib/libcursesw.so"
    ln -svf libncurses.so "${PREFIX}/lib/libcurses.so"

    for lib in tic tinfo; do
        printf "INPUT(libncursesw.so.%s)\n" "$VER_MAJOR" > "${PREFIX}/lib/lib${lib}.so"
        ln -svf "libncursesw.so.${VER_MAJOR}" "${PREFIX}/lib/lib${lib}.so.${VER_MAJOR}"
        ln -svf ncursesw.pc "${PREFIX}/lib/pkgconfig/${lib}.pc"
    done

    mkdir -p "${PREFIX}/include/ncurses"
    for i in "${PREFIX}/include/ncursesw"/*; do
        mv "$i" "${PREFIX}/include/"
        ln -s "../$(basename "$i")" "${PREFIX}/include/ncurses/"
        ln -s "../$(basename "$i")" "${PREFIX}/include/ncursesw/"
    done
}