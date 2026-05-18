# packages/pcre2/recipe.sh
# PCRE2 - Perl 兼容正则表达式库

PKGNAME="pcre2"
VERSION="10.45"
SRC_URI="https://github.com/PhilipHazel/pcre2/releases/download/pcre2-${VERSION}/pcre2-${VERSION}.tar.bz2"
SRC_DIR="pcre2-${VERSION}"

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        --disable-static \
        --enable-pcre2-16 \
        --enable-pcre2-32 \
        --enable-jit \
        --enable-pcre2grep-libz \
        --enable-pcre2grep-libbz2 \
        --enable-pcre2test-libreadline \
        --enable-malloc0returnsnull=no \
        CPPFLAGS="-I${PREFIX}/include" \
        LDFLAGS="-L${PREFIX}/lib"
    make -j$(nproc)
}

install() {
    make install DESTDIR="$DESTDIR" INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}