# packages/glibc/recipe.sh
# glibc - Android 适配版

PKGNAME="glibc"
VERSION="2.42"
SRC_URI="https://ftp.gnu.org/gnu/libc/glibc-${VERSION}.tar.xz"
SRC_HASH="d1775e32e4628e64ef930f435b67bb63af7599acb6be2b335b9f19f16509f17f"
SRC_DIR="glibc-${VERSION}"

prepare() {
    # 推导 imagefs 根目录（PREFIX 的父目录，比如 /data/.../imagefs）
    local IMAGEFS_ROOT="$(dirname "${PREFIX}")"

    # 1. 应用通用补丁（patches/ 目录下所有 .patch）
    [[ -d "${recipe_dir}/patches" ]] || return 0
    for patch in "${recipe_dir}/patches/"*.patch; do
        sed -e "s|@@PREFIX@@|${PREFIX}|g" \
            -e "s|@@IMAGEFS_ROOT@@|${IMAGEFS_ROOT}|g" \
            "$patch" | patch -p1
    done

    # 2. 应用手动补丁（同级目录下的 posix.patch）
    local manual_patch="${recipe_dir}/posix.patch"
    if [[ -f "$manual_patch" ]]; then
        sed -e "s|@@PREFIX@@|${PREFIX}|g" \
            -e "s|@@IMAGEFS_ROOT@@|${IMAGEFS_ROOT}|g" \
            "$manual_patch" | patch -p1
    else
        warn "未找到手动补丁: $manual_patch"
    fi

    # 3. 复制额外文件到对应位置
    cp "${recipe_dir}/files/"*.c sysdeps/unix/sysv/linux/
    cp "${recipe_dir}/files/"*.h sysdeps/unix/sysv/linux/

    cp "${recipe_dir}/files/android_passwd_group.c" nss/
    cp "${recipe_dir}/files/android_passwd_group.h" nss/
    cp "${recipe_dir}/files/android_ids.h" nss/
    cp "${recipe_dir}/files/android_system_user_ids.h" nss/

    cp "${recipe_dir}/files/syslog.c" misc/

    cp "${recipe_dir}/files/shmem-android.c" sysvipc/
    cp "${recipe_dir}/files/shmem-android.h" sysvipc/
    cp "${recipe_dir}/files/android_sysvshm.c" sysvipc/
    cp "${recipe_dir}/files/android_sysvshm.h" sysvipc/

    cp "${recipe_dir}/files/disabled-syscall.h" sysdeps/unix/sysv/linux/aarch64/

    # 4. 删除不兼容文件并重命名
    rm -f sysdeps/unix/sysv/linux/aarch64/clone3.S
    (cd sysdeps/unix/sysv/linux/aarch64 && mv -n syscall.S syscallS.S 2>/dev/null || true)
}

build() {
    mkdir -p build && cd build
    ../configure \
        --prefix="${PREFIX}" \
        --libdir="${PREFIX}/lib" \
        --libexecdir="${PREFIX}/libexec" \
        --includedir="${PREFIX}/include" \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --target="${TARGET_HOST}" \
        --with-bugurl=https://github.com/moze30/winlator-glibc/issues \
        --with-pkgversion="GNU libc for Winlator-Glibc" \
        --enable-bind-now \
        --enable-fortify-source \
        --disable-multi-arch \
        --enable-stack-protector=strong \
        --disable-systemtap \
        --disable-nscd \
        --disable-profile \
        --disable-werror \
        --disable-default-pie \
        --enable-memory-tagging
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR"
}

install_target() {
    make install
}
