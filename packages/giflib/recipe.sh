# packages/giflib/recipe.sh
# giflib - GIF 图像处理库

PKGNAME="giflib"
VERSION="5.2.2"
SRC_URI="https://sourceforge.net/projects/giflib/files/giflib-${VERSION}.tar.gz"
SRC_HASH="be7ffbd057cadebe2aa144542fd90c6838c6a083b5e8a9048b8ee3b66b29d5fb"
SRC_DIR="giflib-${VERSION}"

prepare() {
    # Makefile 默认 PREFIX 改为可接受环境变量覆盖
    sed -i 's/^PREFIX = \/usr\/local/PREFIX ?= \/usr\/local/' Makefile
    # 跳过 HTML 文档生成，只构建 man 手册
    sed -i 's/^all: allhtml manpages/all: manpages/' doc/Makefile
}

build() {
    make -j$(nproc) \
        CC="${TARGET_HOST}-gcc" \
        AR="${TARGET_HOST}-ar" \
        RANLIB="${TARGET_HOST}-ranlib" \
        PREFIX="${PREFIX}"
}

install() {
    # Makefile 不支持 DESTDIR，手动安装到临时目录
    make install DESTDIR="$DESTDIR" PREFIX="${PREFIX}"
}

install_target() {
    make install PREFIX="${PREFIX}"
}