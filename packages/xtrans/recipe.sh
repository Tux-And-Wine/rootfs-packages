# packages/xtrans/recipe.sh
# xtrans - X 传输层抽象库（纯头文件/配置）

PKGNAME="xtrans"
VERSION="1.5.2"
DEPENDS="xorgproto"
SRC_URI="https://xorg.freedesktop.org/releases/individual/lib/xtrans-${VERSION}.tar.xz"
SRC_HASH="5c5cbfe34764a9131d048f03c31c19e57fb4c682d67713eab6a65541b4dff86c"
SRC_DIR="xtrans-${VERSION}"

prepare() {
    # 应用补丁，自动将 @@PREFIX@@ 替换为实际 PREFIX 值
    local patches_dir="${recipe_dir}/patches"

    for p in patch1-xtrans-root.patch \
             patch2-xtrans-pipe.patch \
             patch3-xtrans-sock.patch; do
        sed "s|@@PREFIX@@|${PREFIX}|g" "${patches_dir}/${p}" | patch -p1
    done
}

build() {
    ./configure --prefix="${PREFIX}"
    # 无需编译，纯头文件/数据
}

install() {
    make install DESTDIR="$DESTDIR"
}

install_target() {
    make install
}