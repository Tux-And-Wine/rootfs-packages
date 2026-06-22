# packages/openssl/recipe.sh
# OpenSSL - 安全通信库

PKGNAME="openssl"
VERSION="3.4.1"
SRC_URI="https://github.com/openssl/openssl/releases/download/openssl-${VERSION}/openssl-${VERSION}.tar.gz"
SRC_HASH="002a2d6b30b58bf4bea46c43bdd96365aaf8daa6c428782aa4feee06da197df3"
SRC_DIR="openssl-${VERSION}"

build() {
    # OpenSSL 目标平台名（对应 aarch64-linux-gnu）
    local openssl_target="linux-aarch64"

    ./Configure "$openssl_target" \
        --prefix="${PREFIX}" \
        --openssldir="${PREFIX}/etc/ssl" \
        --libdir="${PREFIX}/lib" \
        shared \
        enable-ktls \
        no-afalgeng

    # 修正交叉编译工具
    sed -i "s|^CC=.*|CC= ${TARGET_HOST}-gcc|" Makefile
    sed -i "s|^AR=.*|AR= ${TARGET_HOST}-ar|" Makefile
    sed -i "s|^AS=.*|AS= ${TARGET_HOST}-as|" Makefile
    sed -i "s|^LD=.*|LD= ${TARGET_HOST}-ld|" Makefile
    sed -i "s|^NM=.*|NM= ${TARGET_HOST}-nm|" Makefile
    sed -i "s|^RANLIB=.*|RANLIB= ${TARGET_HOST}-ranlib|" Makefile
    sed -i "s|^STRIP=.*|STRIP= ${TARGET_HOST}-strip|" Makefile
    sed -i "s|^CROSS_COMPILE=.*|CROSS_COMPILE=|" Makefile

    make depend
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install \
        MANDIR="${PREFIX}/share/man" \
        MANSUFFIX=ssl \
        install_sw install_ssldirs
}

install_target() {
    make install \
        MANDIR="${PREFIX}/share/man" \
        MANSUFFIX=ssl \
        install_sw install_ssldirs install_man_docs
}
