# config.example.sh
# 复制为 config.sh 并根据你的环境修改

# 交叉编译目标
export TARGET_HOST="${TARGET_HOST:-aarch64-linux-gnu}"
export BUILD_HOST="${BUILD_HOST:-x86_64-linux-gnu}"

# 安装前缀
export PREFIX="${PREFIX:-/data/data/a.io.github.ewt45.winemulator/linbox/usr}"

# pkg-config 路径（交叉编译时使用）
export PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR:-${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig}"
export PKG_CONFIG_SYSROOT_DIR="${PKG_CONFIG_SYSROOT_DIR:-$(dirname "${PREFIX}")}"

# 传递给 make install 的额外参数
export MAKE_INSTALL_PROGRAM="${MAKE_INSTALL_PROGRAM:-INSTALL_PROGRAM=\"/usr/bin/install -c\"}"

# 远程容器构建（可通过环境变量覆盖）
export BUILD_IN_CONTAINER="${BUILD_IN_CONTAINER:-0}"
export CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-docker}"
export CONTAINER_REMOTE="${CONTAINER_REMOTE:-bazzite@192.168.0.100}"
export CONTAINER_REMOTE_DIR="${CONTAINER_REMOTE_DIR:-/home/bazzite/Documents/rootfs-packages-build}"
export CONTAINER_IMAGE="${CONTAINER_IMAGE:-tuxwine-rootfs-builder:ubuntu24}"
export CONTAINER_PROXY_URL="${CONTAINER_PROXY_URL:-http://192.168.0.102:8080}"
export CONTAINER_PROXY_MODE="${CONTAINER_PROXY_MODE:-auto}"
export CONTAINER_NO_PROXY="${CONTAINER_NO_PROXY:-localhost,127.0.0.1}"
export CONTAINER_REBUILD_IMAGE="${CONTAINER_REBUILD_IMAGE:-0}"
# CONTAINER_SSH_PASSWORD 仅从运行环境读取，不要写入 config.sh。
