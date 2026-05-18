# packages/libiconv/recipe.sh
# libiconv - 字符编码转换库

PKGNAME="libiconv"
VERSION="1.18"
SRC_URI="https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${VERSION}.tar.gz"
SRC_DIR="libiconv-${VERSION}"

build() {
    # 安装到临时子目录，避免覆盖系统 iconv
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --bindir="${PREFIX}/bin/libiconv-d" \
        --includedir="${PREFIX}/include/libiconv-d" \
        --enable-extra-encodings
    make -j$(nproc)
}

# 后处理：将文件从临时子目录移到正确位置并重命名
_post_install() {
    local base="$1"   # 安装根，如 $DESTDIR$PREFIX 或 $PREFIX
    cd "$base"

    # 处理 bin 目录
    if [ -d bin/libiconv-d ]; then
        mv bin/libiconv-d/iconv bin/libiconv-d/libiconv
        mv bin/libiconv-d/libiconv bin/
        rm -rf bin/libiconv-d
    fi

    # 处理 include 目录
    if [ -d include/libiconv-d ]; then
        mv include/libiconv-d/iconv.h include/libiconv-d/libiconv.h
        mv include/libiconv-d/* include/
        rm -rf include/libiconv-d
    fi

    cd - >/dev/null
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
    _post_install "${DESTDIR}${PREFIX}"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
    _post_install "${PREFIX}"
}