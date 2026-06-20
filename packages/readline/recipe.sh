# packages/readline/recipe.sh
# readline - GNU 命令行编辑库

PKGNAME="readline"
VERSION="8.2"
SRC_URI="https://ftp.gnu.org/gnu/readline/readline-${VERSION}.tar.gz"
SRC_HASH="3feb7171f16a84ee82ca18a36d7b9be109a52c04f492a053331d7d1095007c35"
SRC_DIR="readline-${VERSION}"

prepare() {
    local patch_base="https://ftp.gnu.org/gnu/readline/readline-${VERSION}-patches"

    # 下载并应用 13 个官方补丁
    for num in 001 002 003 004 005 006 007 008 009 010 011 012 013; do
        local patch_file="readline${VERSION//./}-${num}"
        if [[ ! -f "$patch_file" ]]; then
            info "下载补丁: ${patch_base}/${patch_file}"
            if command -v wget &>/dev/null; then
                wget -q "${patch_base}/${patch_file}"
            else
                curl -sLO "${patch_base}/${patch_file}"
            fi
        fi
        patch -p0 < "$patch_file"
    done

    # 移除 lib 中的 rpath（避免交叉编译指向宿主目录）
    sed -i 's|-Wl,-rpath,$(libdir) ||g' support/shobj-conf
}

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --with-curses \
        CPPFLAGS="-I${PREFIX}/include" \
        LDFLAGS="-L${PREFIX}/lib"

    make -j$(nproc) SHLIB_LIBS="-lncurses"
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}
