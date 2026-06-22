# packages/xcb-proto/recipe.sh
# xcb-proto - X C Binding 协议描述（原生工具，生成数据）

PKGNAME="xcb-proto"
VERSION="1.17.0"
SRC_URI="https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-${VERSION}.tar.xz"
SRC_HASH="2c1bacd2110f4799f74de6ebb714b94cf6f80fb112316b1219480fd22562148c"
SRC_DIR="xcb-proto-${VERSION}"

build() {
    ./configure \
        --prefix="${PREFIX}" \
        PYTHON=python3 \
        am_cv_python_pythondir="${PREFIX}/lib/python3/dist-packages"
}

install() {
    make install DESTDIR="$DESTDIR"
}

install_target() {
    make install
}