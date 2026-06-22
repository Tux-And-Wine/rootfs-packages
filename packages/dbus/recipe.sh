# packages/dbus/recipe.sh
# D-Bus - 进程间通信系统

PKGNAME="dbus"
VERSION="1.15.6"
DEPENDS="libexpat"
SRC_URI="https://dbus.freedesktop.org/releases/dbus/dbus-${VERSION}.tar.xz"
SRC_HASH="f97f5845f9c4a5a1fb3df67dfa9e16b5a3fd545d348d6dc850cb7ccc9942bd8c"
SRC_DIR="dbus-${VERSION}"

prepare() {
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"

    # 应用补丁，将临时目录路径指向 IMAGEFS_ROOT/tmp
    [[ -d "${recipe_dir}/patches" ]] || return 0
    for patch in "${recipe_dir}/patches/"*.patch; do
        sed "s|@@IMAGEFS_ROOT@@|${IMAGEFS_ROOT}|g" "$patch" | patch -p1
    done
}

build() {
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"

    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
    export PKG_CONFIG_SYSROOT_DIR="${IMAGEFS_ROOT}"

    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --libdir="${PREFIX}/lib" \
        --libexecdir="${PREFIX}/lib" \
        --sysconfdir="${PREFIX}/etc" \
        --localstatedir="${PREFIX}/var" \
        --runstatedir="${PREFIX}/var/run" \
        --disable-libaudit \
        --disable-systemd \
        --disable-tests \
        --disable-xml-docs \
        --enable-inotify \
        --enable-x11-autolaunch \
        --with-test-socket-dir="${IMAGEFS_ROOT}/tmp" \
        --with-session-socket-dir="${IMAGEFS_ROOT}/tmp" \
        --with-x=auto \
        --without-systemdsystemunitdir \
        --disable-selinux
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR"
}

install_target() {
    make install
}