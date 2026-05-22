#!/usr/bin/env bash
set -euo pipefail

# ============================================================
#  main.sh  —— 包构建系统的流程编排入口
#  用法：
#    ./start-build.sh <pkg...>         构建指定包
#    ./start-build.sh -r <pkg...>      清理后重建指定包
#    ./start-build.sh all              按顺序构建全部包
# ============================================================

MAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$MAIN_DIR")"

for lib in common fetch unpack rebuild; do
    if [[ -f "${PROJECT_ROOT}/lib/${lib}.sh" ]]; then
        source "${PROJECT_ROOT}/lib/${lib}.sh"
    else
        echo "[FATAL] 缺少公共库: ${PROJECT_ROOT}/lib/${lib}.sh" >&2
        exit 1
    fi
done

if [[ -f "${PROJECT_ROOT}/config.sh" ]]; then
    source "${PROJECT_ROOT}/config.sh"
fi

PACKAGES_DIR="${PROJECT_ROOT}/packages"
DOWNLOAD_DIR="${PROJECT_ROOT}/downloads"
WORK_DIR="${PROJECT_ROOT}/work"
OUTPUT_DIR="${PROJECT_ROOT}/output"

declare -A PKG_RECIPE_DIR
declare -A BUILT_PKGS
REBUILD=false

scan_recipes() {
    PKG_RECIPE_DIR=()
    for recipe in "$PACKAGES_DIR"/*/recipe.sh; do
        [[ -f "$recipe" ]] || continue
        local pkg_dir="$(dirname "$recipe")"
        local pkg_name="$(basename "$pkg_dir")"
        PKG_RECIPE_DIR["$pkg_name"]="$pkg_dir"
    done
}

build_pkg() {
    local pkg_name="$1"

    # ---- 保存环境变量，防止包之间通过 export 泄漏 ----
    local _entry_CFLAGS="${CFLAGS:-}"
    local _entry_CXXFLAGS="${CXXFLAGS:-}"
    local _entry_CPPFLAGS="${CPPFLAGS:-}"
    local _entry_LDFLAGS="${LDFLAGS:-}"
    local _entry_CC="${CC:-}"
    local _entry_CXX="${CXX:-}"

    if $REBUILD; then
        clean_pkg "$pkg_name"
    fi

    if ! $REBUILD && [[ -n "${BUILT_PKGS[$pkg_name]:-}" ]]; then
        return 0
    fi

    local recipe_dir="${PKG_RECIPE_DIR[$pkg_name]}"
    if [[ -z "$recipe_dir" ]]; then
        error "找不到包配方: $pkg_name"
    fi

    local recipe_file="${recipe_dir}/recipe.sh"
    [[ -f "$recipe_file" ]] || error "配方文件不存在: $recipe_file"

    # ----- 清除上一个包可能残留的函数 -----
    unset -f prepare build install install_target 2>/dev/null || true

    source "$recipe_file"

    [[ -z "${VERSION:-}" ]] && error "$pkg_name: 配方缺少 VERSION"
    [[ -z "${SRC_URI:-}" ]] && error "$pkg_name: 配方缺少 SRC_URI"

    PKGNAME="${PKGNAME:-$pkg_name}"
    local src_basename="$(basename "$SRC_URI")"
    local src_dir_name="${SRC_DIR:-${src_basename%.tar.*}}"

    local pkg_work="$WORK_DIR/$PKGNAME"
    local src_dir="$pkg_work/src/$src_dir_name"
    local dest_dir="$pkg_work/destdir"

    if ! $REBUILD && [[ -d "$OUTPUT_DIR/$PKGNAME" ]]; then
        info "$PKGNAME 已构建完成，跳过 (如需重编请使用 -r <包名>)"
        BUILT_PKGS["$pkg_name"]=1
        return 0
    fi

    info "========================================="
    info "开始构建: $PKGNAME 版本 $VERSION"
    $REBUILD && info "（强制重建模式）"
    info "========================================="

    local dl_path="$DOWNLOAD_DIR/$src_basename"
    download "$SRC_URI" "$dl_path"

    rm -rf "$pkg_work/src"
    extract "$dl_path" "$pkg_work/src"
    [[ -d "$src_dir" ]] || error "源码目录不存在: $src_dir"
    cd "$src_dir"

    if declare -F prepare &>/dev/null; then
        info "执行 prepare()"
        prepare
    fi

    info "执行 build()"
    build

    rm -rf "$dest_dir"
    mkdir -p "$dest_dir"
    export DESTDIR="$dest_dir"
    info "执行 install() [DESTDIR=$dest_dir]"
    install

    mkdir -p "$OUTPUT_DIR/$PKGNAME"
    if compgen -G "$dest_dir/*" > /dev/null; then
        cp -a "$dest_dir"/* "$OUTPUT_DIR/$PKGNAME/"
    else
        warn "$PKGNAME: install() 没有输出任何文件"
    fi

    if declare -F install_target &>/dev/null; then
        info "安装到目标 rootfs: ${PREFIX}"
        unset DESTDIR
        install_target
    else
        warn "配方未定义 install_target()，跳过直接安装到 ${PREFIX}"
    fi

    info "$PKGNAME 编译完成，产物目录: $OUTPUT_DIR/$PKGNAME"
    BUILT_PKGS["$pkg_name"]=1

    # ---- 恢复环境变量，防止泄漏到下一个包 ----
    export CFLAGS="${_entry_CFLAGS}"
    export CXXFLAGS="${_entry_CXXFLAGS}"
    export CPPFLAGS="${_entry_CPPFLAGS}"
    export LDFLAGS="${_entry_LDFLAGS}"
    export CC="${_entry_CC}"
    export CXX="${_entry_CXX}"
}

main() {
    local packages_to_build=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r) REBUILD=true; shift ;;
            *)  packages_to_build+=("$1"); shift ;;
        esac
    done

    if [[ " ${packages_to_build[*]} " == *" all "* ]]; then
        local all_recipe="${PACKAGES_DIR}/all/recipe.sh"
        if [[ -f "$all_recipe" ]]; then
            source "$all_recipe"
            packages_to_build=("${ALL_BUILD_ORDER[@]}")
        else
            error "找不到 all 配方: $all_recipe"
        fi
    fi

    if [[ ${#packages_to_build[@]} -eq 0 ]]; then
        error "用法: $0 [-r] <包名...> 或 $0 [-r] all"
    fi

    mkdir -p "$DOWNLOAD_DIR" "$WORK_DIR" "$OUTPUT_DIR"
    scan_recipes

    for pkg in "${packages_to_build[@]}"; do
        build_pkg "$pkg"
    done

    info "所有任务完成。"
}

main "$@"