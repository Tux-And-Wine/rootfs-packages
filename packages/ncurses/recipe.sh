# packages/ncurses/recipe.sh
# ncurses - 终端界面库

PKGNAME="ncurses"
VERSION="6.5"
SRC_URI="https://ftp.gnu.org/gnu/ncurses/ncurses-${VERSION}.tar.gz"
SRC_DIR="ncurses-${VERSION}"

prepare() {
    sed -i 's/^INSTALL_PROG\s*=.*/INSTALL_PROG = \$(INSTALL)/' progs/Makefile
}

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
    make -j$(nproc)
}

install() {
    # 安装到 DESTDIR 用于备份
    make DESTDIR="$DESTDIR" install
}

install_target() {
    # 直接安装到目标 rootfs
    make install

    local VER_MAJOR="6"

    # 兼容性符号链接
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

    # 头文件整理
    mkdir -p "${PREFIX}/include/ncurses"
    for i in "${PREFIX}/include/ncursesw"/*; do
        mv "$i" "${PREFIX}/include/"
        ln -s "../$(basename "$i")" "${PREFIX}/include/ncurses/"
        ln -s "../$(basename "$i")" "${PREFIX}/include/ncursesw/"
    done
}
