# lib/rebuild.sh
# 清理函数：删除指定包的编译产物，保留源码

clean_pkg() {
    local pkg_name="$1"
    local pkg_work="${WORK_DIR:?}/${pkg_name}"

    # 删除输出
    rm -rf "${OUTPUT_DIR:?}/${pkg_name}"

    # 删除解压后的源码目录（但不删 work/ 下的可能存在的裸 git 仓库）
    if [[ -d "$pkg_work/src" ]]; then
        rm -rf "$pkg_work/src"
    fi
    # 删除构建目录（glibc 那种 mkdir build && cd build）
    if [[ -d "$pkg_work/build" ]]; then
        rm -rf "$pkg_work/build"
    fi
    # 删除临时安装目录
    if [[ -d "$pkg_work/destdir" ]]; then
        rm -rf "$pkg_work/destdir"
    fi

    info "已清理: $pkg_name (保留源码缓存)"
}