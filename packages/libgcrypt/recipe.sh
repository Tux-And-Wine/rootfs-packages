# packages/libgcrypt/recipe.sh
# libgcrypt - GNU 加密库

PKGNAME="libgcrypt"
VERSION="1.11.0"
SRC_URI="https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${VERSION}.tar.bz2"
SRC_HASH="09120c9867ce7f2081d6aaa1775386b98c2f2f246135761aae47d81f58685b9c"
SRC_DIR="libgcrypt-${VERSION}"

prepare() {
    # 1. 修正配置文件路径
    sed -i "s|/etc/gcrypt/random.conf|${PREFIX}/etc/gcrypt/random.conf|g" random/random.c
    sed -i "s|/etc/gcrypt/fips_enabled|${PREFIX}/etc/gcrypt/fips_enabled|g" src/fips.c
    sed -i "s|/etc/gcrypt/hwf.deny|${PREFIX}/etc/gcrypt/hwf.deny|g" src/hwfeatures.c

    # 2. 添加 Android/Termux 随机源
    cat > .android_sources <<EOF
// Android sources
{   "/system/bin/vmstat", "-s", SC(-3), NULL, 0, 0, 0, 1    },
{   "/system/xbin/vmstat", "-s", SC(-3), NULL, 0, 0, 0, 1    },
{   "/system/bin/netstat", "-s", SC(2), NULL, 0, 0, 0, 1 },
{   "/system/xbin/netstat", "-s", SC(2), NULL, 0, 0, 0, 1 },
{   "/system/bin/mpstat", NULL, SC(1), NULL, 0, 0, 0, 0     },
{   "/system/xbin/mpstat", NULL, SC(1), NULL, 0, 0, 0, 0     },
{   "/system/bin/df", NULL, SC(1), NULL, 0, 0, 0, 0         },
{   "/system/xbin/df", NULL, SC(1), NULL, 0, 0, 0, 0         },
{   "/system/bin/iostat", NULL, SC(SC_0), NULL, 0, 0, 0, 0  },
{   "/system/xbin/iostat", NULL, SC(SC_0), NULL, 0, 0, 0, 0  },
{   "/system/bin/uptime", NULL, SC(SC_0), NULL, 0, 0, 0, 1   },
{   "/system/xbin/uptime", NULL, SC(SC_0), NULL, 0, 0, 0, 1  },
{   "/system/bin/ps", "aux", SC(0.3), NULL, 0, 0, 0, 1       },
{   "/system/xbin/ps", "aux", SC(0.3), NULL, 0, 0, 0, 1      },
{   "/system/bin/arp", "-a", SC(0.1), NULL, 0, 0, 0, 1       },
{   "/system/xbin/arp", "-a", SC(0.1), NULL, 0, 0, 0, 1      },
// Termux sources
{   "${PREFIX}/bin/vmstat", "-s", SC(-3), NULL, 0, 0, 0, 1 },
{   "${PREFIX}/bin/netstat", "-s", SC(2), NULL, 0, 0, 0, 1 },
{   "${PREFIX}/bin/mpstat", NULL, SC(1), NULL, 0, 0, 0, 0 },
{   "${PREFIX}/bin/df", NULL, SC(1), NULL, 0, 0, 0, 0 },
{   "${PREFIX}/bin/iostat", NULL, SC(SC_0), NULL, 0, 0, 0, 0 },
{   "${PREFIX}/bin/uptime", NULL, SC(SC_0), NULL, 0, 0, 0, 1 },
{   "${PREFIX}/bin/ps", "aux", SC(0.3), NULL, 0, 0, 0, 1 },
{   "${PREFIX}/bin/arp", "-a", SC(0.1), NULL, 0, 0, 0, 1 },
EOF

    # 插入到 dataSources[] = { 之后
    sed -i '/dataSources\[\] = {/ r .android_sources' random/rndunix.c
    rm -f .android_sources

    # 3. 重新生成构建系统
    autoreconf -vfi
}

build() {
    ./configure \
        --host="${TARGET_HOST}" \
        --build="${BUILD_HOST}" \
        --prefix="${PREFIX}" \
        CPPFLAGS="-I${PREFIX}/include" \
        LDFLAGS="-L${PREFIX}/lib" \
        --disable-padlock-support \
        --disable-static
    make -j$(nproc)
}

install() {
    make DESTDIR="$DESTDIR" install INSTALL_PROGRAM="/usr/bin/install -c"
}

install_target() {
    make install INSTALL_PROGRAM="/usr/bin/install -c"
}