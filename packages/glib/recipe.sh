# packages/glib/recipe.sh
# glib - GLib 核心库

PKGNAME="glib"
VERSION="2.82.2"
SRC_URI="https://ftp.gnome.org/pub/gnome/sources/glib/${VERSION%.*}/glib-${VERSION}.tar.xz"
SRC_HASH="ab45f5a323048b1659ee0fbda5cecd94b099ab3e4b9abf26ae06aeb3e781fd63"
SRC_DIR="glib-${VERSION}"

prepare() {
    # 路径适配：将所有硬编码路径替换为 PREFIX 变量
    # 补丁1: locale.alias
    sed -i "s|\"/usr/share/locale/locale.alias\"|\"${PREFIX}/share/locale/locale.alias\"|" glib/gcharset.c

    # 补丁2: gspawn-posix.c - PATH 和 /bin/sh
    sed -i "s|\"/bin:/usr/bin:.\"|\"${PREFIX}/bin:.\"|" glib/gspawn-posix.c
    sed -i "s|\"/bin/sh\"|\"${PREFIX}/bin/sh\"|" glib/gspawn-posix.c

    # 补丁3: gutils.c - PATH, /tmp, os-release, XDG
    sed -i "s|\"/bin:/usr/bin:.\"|\"${PREFIX}/bin:.\"|" glib/gutils.c
    sed -i "s|\"/tmp\"|\"$(dirname "${PREFIX}")/tmp\"|" glib/gutils.c
    sed -i "s|\"/etc/os-release\", \"/usr/lib/os-release\"|\"${PREFIX}/etc/os-release\", \"${PREFIX}/lib/os-release\"|" glib/gutils.c
    sed -i "s|\"/usr/local/share/:/usr/share/\"|\"${PREFIX}/local/share/:${PREFIX}/share/\"|" glib/gutils.c

    # 补丁4: machine-id
    sed -i "s|\"/etc/machine-id\"|\"${PREFIX}/etc/machine-id\"|" gio/gdbusprivate.c

    # 补丁5: settings 路径
    sed -i "s|\"/etc/glib-2.0/settings\"|\"${PREFIX}/etc/glib-2.0/settings\"|" gio/gkeyfilesettingsbackend.c

    # 补丁6: resolv.conf
    sed -i "s|\"/etc/resolv.conf\"|\"${PREFIX}/etc/resolv.conf\"|" gio/gnetworking.h.in

    # 补丁7: XDG 数据目录
    sed -i "s|\"/usr/local/share/:/usr/share/\"|\"${PREFIX}/local/share/:${PREFIX}/share/\"|" gio/xdgmime/xdgmime.c

    # 移除 pidfd_open 检测（Android 内核不支持）
    sed -i '/^# Check for pidfd_open/,/^endif$/d' meson.build
}

build() {
    # 生成 Meson 交叉编译文件
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

    meson setup builddir \
        --cross-file cross-aarch64.txt \
        --prefix="${PREFIX}" \
        -Ddefault_library=both \
        -Druntime_dir="${PREFIX}/var/run" \
        -Dglib_debug=disabled \
        -Dselinux=disabled \
        -Dlibmount=disabled \
        -Dtests=false \
        -Ddocumentation=false \
        -Dman-pages=false \
        -Dintrospection=disabled

    meson compile -C builddir
}

install() {
    meson install --destdir "$DESTDIR" -C builddir
}

install_target() {
    meson install -C builddir
}