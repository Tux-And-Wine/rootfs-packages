# packages/bzip2/recipe.sh
# bzip2 - 块排序压缩库

PKGNAME="bzip2"
VERSION="1.0.8"
SRC_URI="https://fossies.org/linux/misc/bzip2-${VERSION}.tar.xz"
SRC_DIR="bzip2-${VERSION}"

prepare() {
    # 让主 Makefile 从环境变量获取 CC/AR/RANLIB/PREFIX
    sed -i 's/^CC=gcc/## CC=gcc/' Makefile
    sed -i 's/^AR=ar/## AR=ar/' Makefile
    sed -i 's/^RANLIB=ranlib/## RANLIB=ranlib/' Makefile
    sed -i 's/^LDFLAGS=/## LDFLAGS=/' Makefile
    sed -i 's/^PREFIX=\/usr\/local/## PREFIX=\/usr\/local/' Makefile

    # 让 Makefile-libbz2_so 支持环境变量
    sed -i 's/^CC=gcc/CC ?= gcc/' Makefile-libbz2_so
    sed -i 's/^CFLAGS=/CFLAGS ?=/' Makefile-libbz2_so
    # 链接步骤带上 LDFLAGS
    sed -i 's/$(CC) -shared -Wl,-soname/$(CC) $(LDFLAGS) -shared -Wl,-soname/' Makefile-libbz2_so
    sed -i 's/$(CC) $(CFLAGS) -o bzip2-shared/$(CC) $(CFLAGS) $(LDFLAGS) -o bzip2-shared/' Makefile-libbz2_so

    # 修正 man 路径
    sed -i 's@(PREFIX)/man@(PREFIX)/share/man@g' Makefile
}

build() {
    export CC="${TARGET_HOST}-gcc"
    export AR="${TARGET_HOST}-ar"
    export RANLIB="${TARGET_HOST}-ranlib"
    export CFLAGS="-O3 -pipe -fPIC"
    export LDFLAGS=""

    # 编译共享库
    make -f Makefile-libbz2_so
    # 编译静态工具
    make bzip2 bzip2recover PREFIX="${PREFIX}"
}

install() {
    # 模拟安装到 DESTDIR
    # 使用 /usr/bin/install 避免与函数名冲突导致递归
    /usr/bin/install -dm755 "${DESTDIR}${PREFIX}/share/man/man1"
    /usr/bin/install -dm755 "${DESTDIR}${PREFIX}/bin"
    /usr/bin/install -dm755 "${DESTDIR}${PREFIX}/lib"
    /usr/bin/install -dm755 "${DESTDIR}${PREFIX}/include"

    /usr/bin/install -m755 bzip2-shared "${DESTDIR}${PREFIX}/bin/bzip2"
    /usr/bin/install -m755 bzip2recover bzdiff bzgrep bzmore "${DESTDIR}${PREFIX}/bin"
    ln -sf bzip2 "${DESTDIR}${PREFIX}/bin/bunzip2"
    ln -sf bzip2 "${DESTDIR}${PREFIX}/bin/bzcat"

    cp -a libbz2.so* "${DESTDIR}${PREFIX}/lib"
    ln -sf libbz2.so.${VERSION} "${DESTDIR}${PREFIX}/lib/libbz2.so"
    ln -sf libbz2.so.${VERSION} "${DESTDIR}${PREFIX}/lib/libbz2.so.1"

    /usr/bin/install -m644 bzlib.h "${DESTDIR}${PREFIX}/include/"

    /usr/bin/install -m644 bzip2.1 "${DESTDIR}${PREFIX}/share/man/man1/"
    ln -sf bzip2.1 "${DESTDIR}${PREFIX}/share/man/man1/bunzip2.1"
    ln -sf bzip2.1 "${DESTDIR}${PREFIX}/share/man/man1/bzcat.1"
    ln -sf bzip2.1 "${DESTDIR}${PREFIX}/share/man/man1/bzip2recover.1"
}

install_target() {
    # 直接安装到目标 rootfs
    # 使用 /usr/bin/install 避免与 install 函数名冲突导致递归
    /usr/bin/install -dm755 "${PREFIX}/share/man/man1"
    /usr/bin/install -dm755 "${PREFIX}/bin"
    /usr/bin/install -dm755 "${PREFIX}/lib"
    /usr/bin/install -dm755 "${PREFIX}/include"

    /usr/bin/install -m755 bzip2-shared "${PREFIX}/bin/bzip2"
    /usr/bin/install -m755 bzip2recover bzdiff bzgrep bzmore "${PREFIX}/bin"
    ln -sf bzip2 "${PREFIX}/bin/bunzip2"
    ln -sf bzip2 "${PREFIX}/bin/bzcat"

    cp -a libbz2.so* "${PREFIX}/lib"
    ln -sf libbz2.so.${VERSION} "${PREFIX}/lib/libbz2.so"
    ln -sf libbz2.so.${VERSION} "${PREFIX}/lib/libbz2.so.1"

    /usr/bin/install -m644 bzlib.h "${PREFIX}/include/"

    /usr/bin/install -m644 bzip2.1 "${PREFIX}/share/man/man1/"
    ln -sf bzip2.1 "${PREFIX}/share/man/man1/bunzip2.1"
    ln -sf bzip2.1 "${PREFIX}/share/man/man1/bzcat.1"
    ln -sf bzip2.1 "${PREFIX}/share/man/man1/bzip2recover.1"
}
