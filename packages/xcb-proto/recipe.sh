# packages/xcb-proto/recipe.sh
# xcb-proto - X C Binding 协议描述（原生工具，生成数据）

PKGNAME="xcb-proto"
VERSION="1.17.0"
SRC_URI="https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-${VERSION}.tar.xz"
SRC_DIR="xcb-proto-${VERSION}"

build() {
    # 创建临时 Python 模块安装目录（避免污染宿主）
    mkdir -p /tmp/xcbgen-install

    ./configure \
        --prefix="${PREFIX}" \
        PYTHON=python3 \
        am_cv_python_pythondir=/tmp/xcbgen-install
}

install() {
    make install DESTDIR="$DESTDIR"
    # make install DESTDIR=... 会把 xcbgen 安装到 $DESTDIR/tmp/xcbgen-install/xcbgen
    mkdir -p "${DESTDIR}${PREFIX}/lib/python3/dist-packages"
    cp -r "${DESTDIR}/tmp/xcbgen-install/xcbgen" "${DESTDIR}${PREFIX}/lib/python3/dist-packages/"
}

install_target() {
    make install
    mkdir -p "${PREFIX}/lib/python3/dist-packages"
    cp -r /tmp/xcbgen-install/xcbgen "${PREFIX}/lib/python3/dist-packages/"
}