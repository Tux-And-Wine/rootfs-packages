# lib/rebuild.sh
# 清理函数：删除指定包的编译产物，支持多种清理模式

# 清理单个包的编译产物（保留源码缓存）
# 参数: pkg_name
clean_pkg() {
    local pkg_name="$1"
    local pkg_work="${WORK_DIR:?}/${pkg_name}"
    
    info "清理包: $pkg_name"
    
    # 删除输出
    if [[ -d "${OUTPUT_DIR:?}/${pkg_name}" ]]; then
        rm -rf "${OUTPUT_DIR:?}/${pkg_name}"
        debug "删除输出目录: ${OUTPUT_DIR}/${pkg_name}"
    fi
    
    # 删除解压后的源码目录
    if [[ -d "$pkg_work/src" ]]; then
        rm -rf "$pkg_work/src"
        debug "删除源码目录: $pkg_work/src"
    fi
    
    # 删除构建目录
    if [[ -d "$pkg_work/build" ]]; then
        rm -rf "$pkg_work/build"
        debug "删除构建目录: $pkg_work/build"
    fi
    
    # 删除临时安装目录
    if [[ -d "$pkg_work/destdir" ]]; then
        rm -rf "$pkg_work/destdir"
        debug "删除临时安装目录: $pkg_work/destdir"
    fi
    
    # 删除状态文件
    if [[ -f "$pkg_work/.build_state" ]]; then
        rm -f "$pkg_work/.build_state"
        debug "删除状态文件: $pkg_work/.build_state"
    fi
    
    info "已清理: $pkg_name (保留源码缓存)"
}

# 清理单个包的所有内容（包括源码缓存）
# 参数: pkg_name
clean_pkg_all() {
    local pkg_name="$1"
    local pkg_work="${WORK_DIR:?}/${pkg_name}"
    
    info "完全清理包: $pkg_name"
    
    # 先清理编译产物
    clean_pkg "$pkg_name"
    
    # 删除源码缓存
    if [[ -d "$pkg_work" ]]; then
        rm -rf "$pkg_work"
        debug "删除工作目录: $pkg_work"
    fi
    
    # 删除下载的源码包
    local recipe_file="${PACKAGES_DIR:?}/${pkg_name}/recipe.sh"
    if [[ -f "$recipe_file" ]]; then
        local src_uri=$(grep "^SRC_URI=" "$recipe_file" | cut -d'"' -f2)
        if [[ -n "$src_uri" ]]; then
            local src_file="${DOWNLOAD_DIR:?}/$(basename "$src_uri")"
            if [[ -f "$src_file" ]]; then
                rm -f "$src_file"
                debug "删除源码包: $src_file"
            fi
        fi
    fi
    
    info "已完全清理: $pkg_name"
}

# 清理所有包的编译产物
clean_all() {
    info "清理所有包的编译产物..."
    
    if [[ -d "${OUTPUT_DIR:?}" ]]; then
        rm -rf "${OUTPUT_DIR:?}"/*
        info "已清理输出目录"
    fi
    
    if [[ -d "${WORK_DIR:?}" ]]; then
        find "${WORK_DIR}" -maxdepth 2 -name "src" -type d -exec rm -rf {} + 2>/dev/null
        find "${WORK_DIR}" -maxdepth 2 -name "build" -type d -exec rm -rf {} + 2>/dev/null
        find "${WORK_DIR}" -maxdepth 2 -name "destdir" -type d -exec rm -rf {} + 2>/dev/null
        find "${WORK_DIR}" -maxdepth 2 -name ".build_state" -type f -exec rm -f {} + 2>/dev/null
        info "已清理工作目录"
    fi
    
    info "所有包的编译产物已清理"
}

# 清理所有内容（包括下载缓存）
clean_all_full() {
    info "完全清理所有内容..."
    
    # 清理编译产物
    clean_all
    
    # 清理下载缓存
    if [[ -d "${DOWNLOAD_DIR:?}" ]]; then
        rm -rf "${DOWNLOAD_DIR:?}"/*
        info "已清理下载缓存"
    fi
    
    # 清理工作目录
    if [[ -d "${WORK_DIR:?}" ]]; then
        rm -rf "${WORK_DIR:?}"/*
        info "已清理工作目录"
    fi
    
    info "所有内容已清理"
}

# 清理旧的构建产物（保留最近N次的）
# 参数: keep_count (默认保留最近3次)
clean_old_builds() {
    local keep_count="${1:-3}"
    
    info "清理旧的构建产物（保留最近 $keep_count 次）..."
    
    # 这里可以扩展为支持版本化的构建
    # 目前只是简单清理
    warn "此功能尚未完全实现"
}

# 显示磁盘使用情况
show_disk_usage() {
    info "磁盘使用情况:"
    
    if [[ -d "${DOWNLOAD_DIR:-}" ]]; then
        local dl_size=$(du -sh "${DOWNLOAD_DIR}" 2>/dev/null | cut -f1)
        echo "  下载缓存: ${dl_size:-0}"
    fi
    
    if [[ -d "${WORK_DIR:-}" ]]; then
        local work_size=$(du -sh "${WORK_DIR}" 2>/dev/null | cut -f1)
        echo "  工作目录: ${work_size:-0}"
    fi
    
    if [[ -d "${OUTPUT_DIR:-}" ]]; then
        local out_size=$(du -sh "${OUTPUT_DIR}" 2>/dev/null | cut -f1)
        echo "  输出目录: ${out_size:-0}"
    fi
    
    local total=0
    [[ -d "${DOWNLOAD_DIR:-}" ]] && total=$((total + $(du -sb "${DOWNLOAD_DIR}" 2>/dev/null | cut -f1)))
    [[ -d "${WORK_DIR:-}" ]] && total=$((total + $(du -sb "${WORK_DIR}" 2>/dev/null | cut -f1)))
    [[ -d "${OUTPUT_DIR:-}" ]] && total=$((total + $(du -sb "${OUTPUT_DIR}" 2>/dev/null | cut -f1)))
    
    echo "  总计: $(numfmt --to=iec $total 2>/dev/null || echo "${total}B")"
}

# 导出函数
export -f clean_pkg clean_pkg_all clean_all clean_all_full clean_old_builds show_disk_usage
