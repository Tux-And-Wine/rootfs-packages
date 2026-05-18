#!/usr/bin/env bash
set -euo pipefail

# ============================================================
#  main.sh  —— 包构建系统的流程编排入口
#  参数：
#    -r <pkg...>     清理指定包的 output 和 work 目录后强制重建
#    <pkg...>         要构建的包名，不指定则构建全部
# ============================================================

# ----- 0. 确定根目录 -----
MAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$MAIN_DIR")"

# ----- 1. 加载公共函数库 -----
for lib in common fetch unpack rebuild; do
    if [[ -f "${PROJECT_ROOT}/lib/${lib}.sh" ]]; then
        source "${PROJECT_ROOT}/lib/${lib}.sh"
    else
        echo "[FATAL] 缺少公共库: ${PROJECT_ROOT}/lib/${lib}.sh" >&2
        exit 1
    fi
done

# ----- 2. 加载可选全局配置 -----
if [[ -f "${PROJECT_ROOT}/config.sh" ]]; then
    source "${PROJECT_ROOT}/config.sh"
fi

# ----- 3. 路径常量 -----
PACKAGES_DIR="${PROJECT_ROOT}/packages"
DOWNLOAD_DIR="${PROJECT_ROOT}/downloads"
WORK_DIR="${PROJECT_ROOT}/work"
OUTPUT_DIR="${PROJECT_ROOT}/output"

# ----- 4. 内部状态 -----
declare -A PKG_RECIPE_DIR
declare -A BUILT_PKGS
REBUILD=false

# ----- 5. 扫描所有配方 -----
scan_recipes() {
    PKG_RECIPE_DIR=()
    for recipe in "$PACKAGES_DIR"/*/recipe.sh; do
        [[ -f "$recipe" ]] || continue
        local pkg_dir="$(dirname "$recipe")"
        local pkg_name="$(basename "$pkg_dir")"
        PKG_RECIPE_DIR["$pkg_name"]="$pkg_dir"
    done
}

# ----- 6. 构建单个包（流程模板） -----
build_pkg() {
    local pkg_name="$1"

    # 重建模式下，先清理旧产物和工作目录
    if $REBUILD; then
        clean_pkg "$pkg_name"
    fi

    # 已构建则跳过（非重建模式）
    if ! $REBUILD && [[ -n "${BUILT_PKGS[$pkg_name]:-}" ]]; then
        return 0
    fi

    local recipe_dir="${PKG_RECIPE_DIR[$pkg_name]}"
    if [[ -z "$recipe_dir" ]]; then
        error "找不到包配方: $pkg_name"
    fi

    local recipe_file="${recipe_dir}/recipe.sh"
    [[ -f "$recipe_file" ]] || error "配方文件不存在: $recipe_file"

    source "$recipe_file"

    [[ -z "${VERSION:-}" ]] && error "$pkg_name: 配方缺少 VERSION"
    [[ -z "${SRC_URI:-}" ]] && error "$pkg_name: 配方缺少 SRC_URI"

    PKGNAME="${PKGNAME:-$pkg_name}"
    local src_basename="$(basename "$SRC_URI")"
    local src_dir_name="${SRC_DIR:-${src_basename%.tar.*}}"

    local pkg_work="$WORK_DIR/$PKGNAME"
    local src_dir="$pkg_work/src/$src_dir_name"
    local dest_dir="$pkg_work/destdir"

    # 非重建模式且 output 已存在，跳过
    if ! $REBUILD && [[ -d "$OUTPUT_DIR/$PKGNAME" ]]; then
        info "$PKGNAME 已构建完成，跳过 (如需重编请使用 -r <包名>)"
        BUILT_PKGS["$pkg_name"]=1
        return 0
    fi

    info "========================================="
    info "开始构建: $PKGNAME 版本 $VERSION"
    $REBUILD && info "（强制重建模式）"
    info "========================================="

    # 下载
    local dl_path="$DOWNLOAD_DIR/$src_basename"
    download "$SRC_URI" "$dl_path"

    # 解压
    rm -rf "$pkg_work/src"
    extract "$dl_path" "$pkg_work/src"
    [[ -d "$src_dir" ]] || error "源码目录不存在: $src_dir"
    cd "$src_dir"

    # 可选钩子: prepare()
    if declare -F prepare &>/dev/null; then
        info "执行 prepare()"
        prepare
    fi

    # 构建
    info "执行 build()"
    build

    # 安装到 DESTDIR（用于收集到 output）
    rm -rf "$dest_dir"
    mkdir -p "$dest_dir"
    export DESTDIR="$dest_dir"
    info "执行 install() [DESTDIR=$dest_dir]"
    install

    # 收集产物到 output/
    mkdir -p "$OUTPUT_DIR/$PKGNAME"
    if compgen -G "$dest_dir/*" > /dev/null; then
        cp -a "$dest_dir"/* "$OUTPUT_DIR/$PKGNAME/"
    else
        warn "$PKGNAME: install() 没有输出任何文件"
    fi

    # 直接安装到目标 rootfs (PREFIX)
    if declare -F install_target &>/dev/null; then
        info "安装到目标 rootfs: ${PREFIX}"
        unset DESTDIR 
        install_target
    else
        warn "配方未定义 install_target()，跳过直接安装到 ${PREFIX}"
    fi

    info "$PKGNAME 编译完成，产物目录: $OUTPUT_DIR/$PKGNAME"
    BUILT_PKGS["$pkg_name"]=1
}

# ----- 7. 主入口 -----
main() {
    local packages_to_build=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r)
                REBUILD=true
                shift
                # 必须提供至少一个包名
                if [[ $# -eq 0 ]]; then
                    error "-r 参数后必须指定包名"
                fi
                ;;
            *)
                packages_to_build+=("$1")
                shift
                ;;
        esac
    done

    mkdir -p "$DOWNLOAD_DIR" "$WORK_DIR" "$OUTPUT_DIR"
    scan_recipes

    if [[ ${#PKG_RECIPE_DIR[@]} -eq 0 ]]; then
        warn "packages/ 下没有找到任何配方"
        exit 0
    fi

    if [[ ${#packages_to_build[@]} -eq 0 ]]; then
        # 构建全部（此时 REBUILD 必定为 false，因为 -r 必须带包名）
        info "将构建全部包: ${!PKG_RECIPE_DIR[*]}"
        local sorted_pkgs=$(printf '%s\n' "${!PKG_RECIPE_DIR[@]}" | sort)
        for pkg in $sorted_pkgs; do
            build_pkg "$pkg"
        done
    else
        # 构建指定包
        for pkg in "${packages_to_build[@]}"; do
            build_pkg "$pkg"
        done
    fi

    info "所有任务完成。"
}

main "$@"