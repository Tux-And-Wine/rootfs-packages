# packages/jbigkit/recipe.sh
# jbigkit - JBIG1 数据压缩库

PKGNAME="jbigkit"
VERSION="2.1"
SRC_URI="https://www.cl.cam.ac.uk/~mgk25/download/jbigkit-${VERSION}.tar.gz"
SRC_HASH="de7106b6bfaf495d6865c7dd7ac6ca1381bd12e0d81405ea81e7f2167263d932"
SRC_DIR="jbigkit-${VERSION}"

prepare() {
    # 安全补丁：限制最大解码图像大小，防止内存耗尽攻击
    sed -i '/^  s->xmax = 4294967295UL;/a\  s->maxmem = 2000000000;' libjbig/jbig.c
    sed -i '/^    s->options = s->buffer\[19\];/a\    if (s->maxmem / s->planes / s->yd / jbg_ceil_half(s->xd, 3) == 0)\n      return JBG_ENOMEM;' libjbig/jbig.c
    sed -i '/^  int dmax;/a\  size_t maxmem;' libjbig/jbig.h
}

build() {
    # 手动编译共享库
    cd libjbig
    ${TARGET_HOST}-gcc -O3 -pipe -fPIC -shared -Wl,-soname,libjbig.so.${VERSION} -o libjbig.so.${VERSION} jbig.c jbig_ar.c
    ${TARGET_HOST}-gcc -O3 -pipe -fPIC -shared -Wl,-soname,libjbig85.so.${VERSION} -o libjbig85.so.${VERSION} jbig85.c jbig_ar.c
    cd ..
}

install() {
    # 安装头文件
    command install -vDm 644 libjbig/*.h -t "${DESTDIR}${PREFIX}/include/"
    # 安装库文件
    command install -vDm 755 "libjbig/libjbig.so.${VERSION}" -t "${DESTDIR}${PREFIX}/lib/"
    command install -vDm 755 "libjbig/libjbig85.so.${VERSION}" -t "${DESTDIR}${PREFIX}/lib/"
    # 创建符号链接
    ln -sf "libjbig.so.${VERSION}" "${DESTDIR}${PREFIX}/lib/libjbig.so"
    ln -sf "libjbig85.so.${VERSION}" "${DESTDIR}${PREFIX}/lib/libjbig85.so"

    # 创建 pkg-config 文件
    mkdir -p "${DESTDIR}${PREFIX}/lib/pkgconfig"
    cat > "${DESTDIR}${PREFIX}/lib/pkgconfig/jbigkit.pc" <<EOF
prefix=${PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: jbigkit
Description: JBIG-KIT data compression library
Version: ${VERSION}
Libs: -L\${libdir} -ljbig
Cflags: -I\${includedir}
EOF
}

install_target() {
    # 安装头文件
    command install -vDm 644 libjbig/*.h -t "${PREFIX}/include/"
    # 安装库文件
    command install -vDm 755 "libjbig/libjbig.so.${VERSION}" -t "${PREFIX}/lib/"
    command install -vDm 755 "libjbig/libjbig85.so.${VERSION}" -t "${PREFIX}/lib/"
    # 创建符号链接
    ln -sf "libjbig.so.${VERSION}" "${PREFIX}/lib/libjbig.so"
    ln -sf "libjbig85.so.${VERSION}" "${PREFIX}/lib/libjbig85.so"

    # 创建 pkg-config 文件
    mkdir -p "${PREFIX}/lib/pkgconfig"
    cat > "${PREFIX}/lib/pkgconfig/jbigkit.pc" <<EOF
prefix=${PREFIX}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: jbigkit
Description: JBIG-KIT data compression library
Version: ${VERSION}
Libs: -L\${libdir} -ljbig
Cflags: -I\${includedir}
EOF
}