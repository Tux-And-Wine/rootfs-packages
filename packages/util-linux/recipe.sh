# packages/util-linux/recipe.sh
# util-linux - 常用系统工具集（交叉编译版）

PKGNAME="util-linux"
VERSION="2.40.2"
SRC_URI="https://github.com/util-linux/util-linux/archive/refs/tags/v${VERSION}.tar.gz"
SRC_DIR="util-linux-${VERSION}"

prepare() {
    # 推导 imagefs 根目录
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"

    # 应用补丁（自动替换 @@PREFIX@@ 和 @@IMAGEFS_ROOT@@）
    for patch in "${recipe_dir}/patches/"*.patch; do
        sed -e "s|@@PREFIX@@|${PREFIX}|g" \
            -e "s|@@IMAGEFS_ROOT@@|${IMAGEFS_ROOT}|g" \
            "$patch" | patch -p1
    done

    # 生成 configure 脚本（必须在补丁之后）
    if [[ -x ./autogen.sh ]]; then
        ./autogen.sh
    fi
}

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --libdir="${PREFIX}/lib" \
        --libexecdir="${PREFIX}/lib" \
        --sysconfdir="${PREFIX}/etc" \
        --localstatedir="${PREFIX}/var" \
        --runstatedir="${PREFIX}/var/run" \
        --mandir="${PREFIX}/share/man" \
        --infodir="${PREFIX}/share/info" \
        --without-ncurses \
        --without-ncursesw \
        --without-tinfo \
        --without-selinux \
        --without-audit \
        --without-udev \
        --without-systemd \
        --disable-bash-completion \
        --disable-pylibmount \
        --disable-makeinstall-chown \
        --disable-makeinstall-setuid \
        --disable-liblastlog2 \
        --without-sqlite3 \
        --disable-nls \
        ac_cv_lib_ncursesw_initscr=no \
        ac_cv_lib_tinfo_tgoto=no \
        ac_cv_header_ncursesw_h=no \
        ac_cv_header_ncurses_h=no
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR"
}

install_target() {
    make install
}