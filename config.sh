# config.sh
# TuxWine 构建系统配置文件
# 此文件包含本地环境配置，不应纳入版本控制

# 交叉编译目标三元组
export TARGET_HOST="aarch64-linux-gnu"

# 宿主机三元组
export BUILD_HOST="x86_64-linux-gnu"

# 安装前缀
export PREFIX="/data/data/a.io.github.ewt45.winemulator/files/imagefs/usr"

# pkg-config 路径（交叉编译时使用）
export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="$(dirname "${PREFIX}")"

# 传递给 make install 的额外参数
export MAKE_INSTALL_PROGRAM='INSTALL_PROGRAM="/usr/bin/install -c"'