# packages/doxygen/recipe.sh
# Doxygen - 代码文档生成工具

PKGNAME="doxygen"
VERSION="1.13.2"
SRC_URI="https://github.com/doxygen/doxygen/archive/Release_${VERSION//./_}.tar.gz"
SRC_HASH="4c9d9c8e95c2af4163ee92bcb0f3af03b2a4089402a353e4715771e8d3701c48"
SRC_DIR="doxygen-Release_${VERSION//./_}"

build() {
    local SYSROOT="$(dirname "${PREFIX}")"

    cat > toolchain-aarch64.cmake <<-CMAKE_EOF
    set(CMAKE_SYSTEM_NAME Linux)
    set(CMAKE_SYSTEM_PROCESSOR aarch64)
    set(CMAKE_SYSROOT ${SYSROOT})
    set(CMAKE_C_COMPILER ${TARGET_HOST}-gcc)
    set(CMAKE_CXX_COMPILER ${TARGET_HOST}-g++)
    set(CMAKE_FIND_ROOT_PATH ${PREFIX})
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
	CMAKE_EOF

    cmake -B build \
        -DCMAKE_TOOLCHAIN_FILE=toolchain-aarch64.cmake \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DDOC_INSTALL_DIR:PATH=share/doc/doxygen \
        -DPYTHON_EXECUTABLE:FILE=$(command -v python3) \
        -DCMAKE_BUILD_TYPE=Release

    cmake --build build --parallel $(nproc)
}

install() {
    cmake --install build --prefix "${DESTDIR}${PREFIX}"
    mkdir -p "${DESTDIR}${PREFIX}/share/man/man1"
    cp doc/doxygen.1 "${DESTDIR}${PREFIX}/share/man/man1/"
}

install_target() {
    cmake --install build
    mkdir -p "${PREFIX}/share/man/man1"
    cp doc/doxygen.1 "${PREFIX}/share/man/man1/"
}