#!/usr/bin/env bash
set -euo pipefail

# ============================================================
#  main.sh  —— 包构建系统的流程编排入口
#  用法：
#    ./start-build.sh <pkg...>         构建指定包
#    ./start-build.sh -r <pkg...>      清理后重建指定包
#    ./start-build.sh all              按顺序构建全部包
#    ./start-build.sh --clean          清理所有编译产物
#    ./start-build.sh --clean-all      清理所有内容（包括下载缓存）
#    ./start-build.sh --status         显示构建状态
#    ./start-build.sh --deps <pkg>     显示包的依赖树
#    ./start-build.sh --list           列出所有可用包
#    ./start-build.sh --log            显示最近的构建日志
# ============================================================

MAIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$MAIN_DIR")"

# 加载公共库
for lib in common fetch unpack rebuild deps log state; do
    if [[ -f "${PROJECT_ROOT}/lib/${lib}.sh" ]]; then
        source "${PROJECT_ROOT}/lib/${lib}.sh"
    else
        echo "[FATAL] 缺少公共库: ${PROJECT_ROOT}/lib/${lib}.sh" >&2
        exit 1
    fi
done

# 加载配置文件
if [[ -f "${PROJECT_ROOT}/config.sh" ]]; then
    source "${PROJECT_ROOT}/config.sh"
fi

# 设置目录路径
PACKAGES_DIR="${PROJECT_ROOT}/packages"
DOWNLOAD_DIR="${PROJECT_ROOT}/downloads"
WORK_DIR="${PROJECT_ROOT}/work"
OUTPUT_DIR="${PROJECT_ROOT}/output"
LOG_DIR="${PROJECT_ROOT}/logs"

# 确保目录存在
ensure_dir "$DOWNLOAD_DIR"
ensure_dir "$WORK_DIR"
ensure_dir "$OUTPUT_DIR"
ensure_dir "$LOG_DIR"

# 初始化状态系统
init_state

# 全局变量
declare -A PKG_RECIPE_DIR
declare -A BUILT_PKGS
REBUILD=false
VERBOSE=false
DRY_RUN=false
KEEP_GOING=false
MAX_JOBS=$(get_nproc)

# 扫描所有包配方
scan_recipes() {
    PKG_RECIPE_DIR=()
    for recipe in "$PACKAGES_DIR"/*/recipe.sh; do
        [[ -f "$recipe" ]] || continue
        local pkg_dir="$(dirname "$recipe")"
        local pkg_name="$(basename "$pkg_dir")"
        PKG_RECIPE_DIR["$pkg_name"]="$pkg_dir"
    done
    debug "扫描到 ${#PKG_RECIPE_DIR[@]} 个包配方"
}

# 列出所有可用包
list_packages() {
    scan_recipes
    
    info "可用的包:"
    echo ""
    
    # 按字母顺序显示
    for pkg in $(echo "${!PKG_RECIPE_DIR[@]}" | tr ' ' '\n' | sort); do
        local recipe_file="${PKG_RECIPE_DIR[$pkg]}/recipe.sh"
        local version=""
        
        if [[ -f "$recipe_file" ]]; then
            version=$(grep "^VERSION=" "$recipe_file" | cut -d'"' -f2 || true)
        fi
        
        if [[ -n "$version" ]]; then
            echo "  - $pkg ($version)"
        else
            echo "  - $pkg"
        fi
    done
    
    echo ""
    info "共 ${#PKG_RECIPE_DIR[@]} 个包"
}

# 显示包信息
show_package_info() {
    local pkg_name="$1"
    local recipe_file="${PACKAGES_DIR}/${pkg_name}/recipe.sh"
    
    check_file "$recipe_file" "包配方"
    
    source "$recipe_file"
    
    info "包信息: $pkg_name"
    echo ""
    echo "  版本: ${VERSION:-未知}"
    echo "  源码: ${SRC_URI:-未知}"
    echo "  目录: ${SRC_DIR:-自动检测}"
    echo "  哈希: ${SRC_HASH:-未设置}"
    
    if [[ -n "${DEPENDS:-}" ]]; then
        echo "  依赖: ${DEPENDS}"
    else
        echo "  依赖: 无"
    fi
    
    # 检查构建状态
    local state=$(get_package_state "$pkg_name")
    echo "  状态: $state"
    
    # 检查输出目录
    if [[ -d "${OUTPUT_DIR}/${pkg_name}" ]]; then
        local size=$(du -sh "${OUTPUT_DIR}/${pkg_name}" | cut -f1)
        echo "  输出: 已存在 ($size)"
    else
        echo "  输出: 未构建"
    fi
}

# 构建单个包
build_pkg() {
    local pkg_name="$1"
    local start_time=$(date +%s)
    
    # 初始化日志
    init_logging "$pkg_name"
    
    # 保存环境变量，防止包之间通过 export 泄漏
    local _entry_CFLAGS="${CFLAGS:-}"
    local _entry_CXXFLAGS="${CXXFLAGS:-}"
    local _entry_CPPFLAGS="${CPPFLAGS:-}"
    local _entry_LDFLAGS="${LDFLAGS:-}"
    local _entry_CC="${CC:-}"
    local _entry_CXX="${CXX:-}"
    local _entry_AR="${AR:-}"
    local _entry_RANLIB="${RANLIB:-}"
    local _entry_STRIP="${STRIP:-}"
    local _entry_PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR:-}"
    local _entry_PKG_CONFIG_SYSROOT_DIR="${PKG_CONFIG_SYSROOT_DIR:-}"
    
    # 如果是重建模式，先清理
    if $REBUILD; then
        clean_pkg "$pkg_name"
        reset_package_state "$pkg_name"
    fi
    
    # 检查是否已构建（非重建模式）
    if ! $REBUILD && [[ -n "${BUILT_PKGS[$pkg_name]:-}" ]]; then
        debug "包 $pkg_name 已在本次构建中完成，跳过"
        return 0
    fi
    
    # 检查包配方是否存在
    local recipe_dir="${PKG_RECIPE_DIR[$pkg_name]:-}"
    if [[ -z "$recipe_dir" ]]; then
        error "找不到包配方: $pkg_name"
    fi
    
    local recipe_file="${recipe_dir}/recipe.sh"
    check_file "$recipe_file" "配方文件"
    
    # 清除上一个包可能残留的函数
    unset -f prepare build install install_target 2>/dev/null || true
    
    # 加载配方
    source "$recipe_file"
    
    # 验证必填变量
    [[ -z "${VERSION:-}" ]] && error "$pkg_name: 配方缺少 VERSION"
    [[ -z "${SRC_URI:-}" ]] && error "$pkg_name: 配方缺少 SRC_URI"
    
    # 设置默认值
    PKGNAME="${PKGNAME:-$pkg_name}"
    local src_basename="$(basename "$SRC_URI")"
    local src_dir_name="${SRC_DIR:-${src_basename%.tar.*}}"
    
    local pkg_work="$WORK_DIR/$PKGNAME"
    local src_dir="$pkg_work/src/$src_dir_name"
    local dest_dir="$pkg_work/destdir"
    
    # 检查是否已构建（非重建模式）
    if ! $REBUILD && [[ -d "$OUTPUT_DIR/$PKGNAME" ]]; then
        info "$PKGNAME 已构建完成，跳过 (如需重编请使用 -r <包名>)"
        BUILT_PKGS["$pkg_name"]=1
        update_package_state "$pkg_name" "skipped" "已存在"
        return 0
    fi
    
    # 检查依赖
    if [[ -n "${DEPENDS:-}" ]]; then
        step "检查依赖: $DEPENDS"
        for dep in $DEPENDS; do
            if [[ ! -d "$OUTPUT_DIR/$dep" ]]; then
                error "依赖 $dep 未构建，请先构建: ./start-build.sh $dep"
            fi
        done
    fi
    
    # 记录构建开始
    log_build_start "$PKGNAME" "$VERSION"
    update_package_state "$pkg_name" "building"
    
    # 下载源码
    step "下载源码"
    local dl_path="$DOWNLOAD_DIR/$src_basename"
    download "$SRC_URI" "$dl_path" "${SRC_HASH:-}"
    
    # 解压源码
    step "解压源码"
    rm -rf "$pkg_work/src"
    extract "$dl_path" "$pkg_work/src"
    check_dir "$src_dir" "源码目录"
    
    # 进入源码目录
    safe_cd "$src_dir"
    
    # 执行准备步骤
    if declare -F prepare &>/dev/null; then
        step "执行 prepare()"
        if $DRY_RUN; then
            info "[DRY RUN] 跳过 prepare()"
        else
            log_command "prepare" "执行 prepare()"
        fi
    fi
    
    # 执行构建
    step "执行 build()"
    if $DRY_RUN; then
        info "[DRY RUN] 跳过 build()"
    else
        log_command "build" "执行 build()"
    fi
    
    # 执行安装
    step "执行 install()"
    if $DRY_RUN; then
        info "[DRY RUN] 跳过 install()"
    else
        rm -rf "$dest_dir"
        mkdir -p "$dest_dir"
        export DESTDIR="$dest_dir"
        log_command "install" "执行 install() [DESTDIR=$dest_dir]"
    fi
    
    # 收集产物
    if ! $DRY_RUN; then
        mkdir -p "$OUTPUT_DIR/$PKGNAME"
        if compgen -G "$dest_dir/*" > /dev/null 2>&1; then
            cp -a "$dest_dir"/* "$OUTPUT_DIR/$PKGNAME/"
            info "产物已收集到: $OUTPUT_DIR/$PKGNAME"
        else
            warn "$PKGNAME: install() 没有输出任何文件"
        fi
    fi
    
    # 执行目标安装（可选）
    if declare -F install_target &>/dev/null; then
        step "安装到目标 rootfs: ${PREFIX}"
        if $DRY_RUN; then
            info "[DRY RUN] 跳过 install_target()"
        else
            unset DESTDIR
            log_command "install_target" "执行 install_target()"
        fi
    else
        debug "配方未定义 install_target()，跳过直接安装到 ${PREFIX}"
    fi
    
    # 计算构建时间
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 记录构建完成
    log_build_end "$PKGNAME" "success" "$duration"
    update_package_state "$pkg_name" "success" "耗时: $(format_duration $duration)"
    
    info "$PKGNAME 编译完成，耗时: $(format_duration $duration)"
    info "产物目录: $OUTPUT_DIR/$PKGNAME"
    
    # 标记为已构建
    BUILT_PKGS["$pkg_name"]=1
    
    # 恢复环境变量，防止泄漏到下一个包
    export CFLAGS="${_entry_CFLAGS}"
    export CXXFLAGS="${_entry_CXXFLAGS}"
    export CPPFLAGS="${_entry_CPPFLAGS}"
    export LDFLAGS="${_entry_LDFLAGS}"
    export CC="${_entry_CC}"
    export CXX="${_entry_CXX}"
    export AR="${_entry_AR}"
    export RANLIB="${_entry_RANLIB}"
    export STRIP="${_entry_STRIP}"
    export PKG_CONFIG_LIBDIR="${_entry_PKG_CONFIG_LIBDIR}"
    export PKG_CONFIG_SYSROOT_DIR="${_entry_PKG_CONFIG_SYSROOT_DIR}"
    
    return 0
}

# 显示使用帮助
show_usage() {
    cat <<'USAGE'
用法: ./start-build.sh [选项] [包名...]

选项:
  -h, --help          显示此帮助信息
  -r, --rebuild       清理后重建指定包
  -v, --verbose       显示详细输出
  -n, --dry-run       模拟运行，不实际执行
  -k, --keep-going    遇到错误继续构建其他包
  -j, --jobs N        并行任务数（默认: CPU核心数）
  -l, --list          列出所有可用包
  -i, --info PKG      显示包的详细信息
  -d, --deps PKG      显示包的依赖树
  -s, --status        显示构建状态
  --clean             清理所有编译产物
  --clean-all         清理所有内容（包括下载缓存）
  --clean-pkg PKG     清理指定包
  --reset             重置所有构建状态
  --reset-pkg PKG     重置指定包的状态
  --log               显示最近的构建日志
  --log-pkg PKG       显示指定包的日志
  --disk              显示磁盘使用情况

示例:
  ./start-build.sh zlib libffi          构建zlib和libffi
  ./start-build.sh -r zlib              重建zlib
  ./start-build.sh all                  构建所有包
  ./start-build.sh --clean              清理所有编译产物
  ./start-build.sh --status             查看构建状态
  ./start-build.sh --deps glib          查看glib的依赖树
USAGE
}

# 主函数
main() {
    local packages_to_build=()
    local action="build"
    local target_pkg=""
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -r|--rebuild)
                REBUILD=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                LOG_LEVEL=4
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -k|--keep-going)
                KEEP_GOING=true
                shift
                ;;
            -j|--jobs)
                MAX_JOBS="$2"
                shift 2
                ;;
            -l|--list)
                action="list"
                shift
                ;;
            -i|--info)
                action="info"
                target_pkg="$2"
                shift 2
                ;;
            -d|--deps)
                action="deps"
                target_pkg="$2"
                shift 2
                ;;
            -s|--status)
                action="status"
                shift
                ;;
            --clean)
                action="clean"
                shift
                ;;
            --clean-all)
                action="clean-all"
                shift
                ;;
            --clean-pkg)
                action="clean-pkg"
                target_pkg="$2"
                shift 2
                ;;
            --reset)
                action="reset"
                shift
                ;;
            --reset-pkg)
                action="reset-pkg"
                target_pkg="$2"
                shift 2
                ;;
            --log)
                action="log"
                shift
                ;;
            --log-pkg)
                action="log-pkg"
                target_pkg="$2"
                shift 2
                ;;
            --disk)
                action="disk"
                shift
                ;;
            -* )
                error "未知选项: $1"
                ;;
            *)
                packages_to_build+=("$1")
                shift
                ;;
        esac
    done
    
    # 扫描包配方
    scan_recipes
    
    # 执行相应操作
    case "$action" in
        list)
            list_packages
            ;;
        info)
            [[ -z "$target_pkg" ]] && error "请指定包名"
            show_package_info "$target_pkg"
            ;;
        deps)
            [[ -z "$target_pkg" ]] && error "请指定包名"
            show_dependency_tree "$target_pkg"
            ;;
        status)
            show_state_summary
            echo ""
            show_detailed_state
            ;;
        clean)
            clean_all
            ;;
        clean-all)
            clean_all_full
            ;;
        clean-pkg)
            [[ -z "$target_pkg" ]] && error "请指定包名"
            clean_pkg "$target_pkg"
            ;;
        reset)
            reset_all_states
            ;;
        reset-pkg)
            [[ -z "$target_pkg" ]] && error "请指定包名"
            reset_package_state "$target_pkg"
            ;;
        log)
            show_recent_log 5
            ;;
        log-pkg)
            [[ -z "$target_pkg" ]] && error "请指定包名"
            local log_file=$(find "$LOG_DIR" -name "*${target_pkg}*" -type f | sort -r | head -1)
            if [[ -n "$log_file" ]]; then
                info "日志文件: $log_file"
                tail -n 100 "$log_file"
            else
                warn "没有找到包 $target_pkg 的日志"
            fi
            ;;
        disk)
            show_disk_usage
            ;;
        build)
            # 处理 "all" 参数
            if [[ " ${packages_to_build[*]:-} " == *" all "* ]]; then
                local all_recipe="${PACKAGES_DIR}/all/recipe.sh"
                if [[ -f "$all_recipe" ]]; then
                    source "$all_recipe"
                    packages_to_build=("${ALL_BUILD_ORDER[@]}")
                else
                    error "找不到 all 配方: $all_recipe"
                fi
            fi
            
            # 检查是否有包需要构建
            if [[ ${#packages_to_build[@]} -eq 0 ]]; then
                error "用法: $0 [选项] <包名...> 或 $0 [选项] all"
            fi
            
            # 验证包名
            for pkg in "${packages_to_build[@]}"; do
                if [[ -z "${PKG_RECIPE_DIR[$pkg]:-}" ]]; then
                    error "未知的包: $pkg"
                fi
            done
            
            # 检查循环依赖
            if ! check_circular_dependencies "${packages_to_build[@]}"; then
                error "检测到循环依赖"
            fi
            
            # 解析依赖并获取构建顺序
            local ordered_packages
            ordered_packages=$(get_build_order "${packages_to_build[@]}")
            
            info "构建顺序:"
            echo "$ordered_packages" | while IFS= read -r pkg; do
                echo "  - $pkg"
            done
            echo ""
            
            # 构建所有包
            local total_start_time=$(date +%s)
            local total_packages=$(echo "$ordered_packages" | wc -l)
            local current_package=0
            local failed_packages=()
            
            while IFS= read -r pkg; do
                current_package=$((current_package + 1))
                
                info "========================================="
                info "构建进度: $current_package / $total_packages"
                info "========================================="
                
                if ! build_pkg "$pkg"; then
                    if $KEEP_GOING; then
                        warn "包 $pkg 构建失败，继续构建其他包"
                        failed_packages+=("$pkg")
                    else
                        error "包 $pkg 构建失败"
                    fi
                fi
            done <<< "$ordered_packages"
            
            # 计算总构建时间
            local total_end_time=$(date +%s)
            local total_duration=$((total_end_time - total_start_time))
            
            info "========================================="
            info "所有任务完成"
            info "总耗时: $(format_duration $total_duration)"
            info "========================================="
            
            # 显示失败的包
            if [[ ${#failed_packages[@]} -gt 0 ]]; then
                warn "以下包构建失败:"
                for pkg in "${failed_packages[@]}"; do
                    warn "  - $pkg"
                done
                exit 1
            fi
            ;;
    esac
}

# 只在直接执行时调用main，source时不自动执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
