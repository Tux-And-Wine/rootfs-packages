# packages/libmp3lame/recipe.sh
# LAME - MP3 编码器库

PKGNAME="libmp3lame"
VERSION="3.100"
SRC_URI="https://downloads.sourceforge.net/project/lame/lame/${VERSION}/lame-${VERSION}.tar.gz"
SRC_HASH="ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e"
SRC_DIR="lame-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --enable-malloc0returnsnull=no
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"

    # 官方不提供 .pc 文件，手动生成
    mkdir -p "${DESTDIR}${PREFIX}/lib/pkgconfig"
    cat > "${DESTDIR}${PREFIX}/lib/pkgconfig/lame.pc" <<-EOF
    prefix=${PREFIX}
    exec_prefix=\${prefix}
    libdir=\${exec_prefix}/lib
    includedir=\${prefix}/include

    Name: lame
    Description: MP3 encoding library
    Requires:
    Version: ${VERSION}
    Libs: -L\${libdir} -lmp3lame
    Cflags: -I\${includedir}
	EOF
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"

    mkdir -p "${PREFIX}/lib/pkgconfig"
    cat > "${PREFIX}/lib/pkgconfig/lame.pc" <<-EOF
    prefix=${PREFIX}
    exec_prefix=\${prefix}
    libdir=\${exec_prefix}/lib
    includedir=\${prefix}/include

    Name: lame
    Description: MP3 encoding library
    Requires:
    Version: ${VERSION}
    Libs: -L\${libdir} -lmp3lame
    Cflags: -I\${includedir}
	EOF
}