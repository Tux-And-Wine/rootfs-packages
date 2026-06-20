# config.example.sh
# 复制为 config.sh 并根据你的环境修改

# 交叉编译目标
export TARGET_HOST="aarch64-linux-gnu"
export BUILD_HOST="x86_64-linux-gnu"

# 安装前缀
export PREFIX="/data/data/a.io.github.ewt45.winemulator/files/imagefs/usr"

# pkg-config 路径（交叉编译时使用）
export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="$(dirname "${PREFIX}")"

# 传递给 make install 的额外参数
export MAKE_INSTALL_PROGRAM='INSTALL_PROGRAM="/usr/bin/install -c"'
