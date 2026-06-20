# packages/gcc-libs/recipe.sh
# gcc-libs - GCC 运行时库 (libgcc, libstdc++ 等)

PKGNAME="gcc-libs"
VERSION="14.2.0"
SRC_URI="https://ftp.gnu.org/gnu/gcc/gcc-${VERSION}/gcc-${VERSION}.tar.xz"
SRC_HASH="a7b39bc69cbf9e25826c5a60ab26477001f7c08d85cec04bc0e29cabed6f3cc9"
SRC_DIR="gcc-${VERSION}"

prepare() {
    # 1. 应用补丁（自动替换 @@PREFIX@@）
    for patch in "${recipe_dir}/patches/"*.patch; do
        sed "s|@@PREFIX@@|${PREFIX}|g" "$patch" | patch -p1
    done

    # 2. 源码微调
    sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in
    sed -i '/m64=/s/lib64/lib/' gcc/config/i386/t-linux64
    sed -i '/lp64=/s/lib64/lib/' gcc/config/aarch64/t-aarch64-linux
    echo "${VERSION}" > gcc/BASE-VER
    echo "" > gcc/DEV-PHASE
}

build() {
    mkdir -p build && cd build
    ../configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --target="${TARGET_HOST}" \
        --prefix="${PREFIX}" \
        --libdir="${PREFIX}/lib" \
        --libexecdir="${PREFIX}/lib" \
        --enable-languages=c,c++ \
        --with-arch=armv8-a \
        --disable-multilib \
        --disable-bootstrap \
        --disable-nls \
        --disable-plugin \
        --enable-default-pie \
        --enable-default-ssp \
        --enable-__cxa_atexit \
        --disable-werror \
        --disable-checking \
        --disable-libssp \
        --disable-libstdcxx-pch \
        --with-linker-hash-style=gnu \
        --with-system-zlib \
        LD_FOR_TARGET="${TARGET_HOST}-ld"

    make -j$(nproc) || make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR"
}

install_target() {
    make install
}