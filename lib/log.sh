# lib/log.sh
# 日志管理函数

# 日志目录
LOG_DIR="${PROJECT_ROOT:-/tmp}/logs"

# 当前日志文件
CURRENT_LOG_FILE=""

# 日志文件前缀
LOG_PREFIX="build"

# 初始化日志系统
init_logging() {
    local pkg_name="${1:-global}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    # 确保日志目录存在
    ensure_dir "$LOG_DIR"
    
    # 设置当前日志文件
    CURRENT_LOG_FILE="${LOG_DIR}/${LOG_PREFIX}_${pkg_name}_${timestamp}.log"
    
    # 创建日志文件
    touch "$CURRENT_LOG_FILE"
    
    # 记录日志头
    log_header "$pkg_name"
    
    debug "日志文件: $CURRENT_LOG_FILE"
}

# 记录日志头
log_header() {
    local pkg_name="$1"
    
    cat >> "$CURRENT_LOG_FILE" <<EOF
================================================================================
构建日志
================================================================================
包名: $pkg_name
时间: $(date '+%Y-%m-%d %H:%M:%S')
主机: $(hostname)
系统: $(uname -a)
用户: $(whoami)
================================================================================

EOF
}

# 记录日志（带时间戳）
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 输出到控制台
    case "$level" in
        INFO)  info "$message" ;;
        WARN)  warn "$message" ;;
        ERROR) error "$message" ;;
        DEBUG) debug "$message" ;;
        *)     echo "$message" ;;
    esac
    
    # 写入日志文件
    if [[ -n "$CURRENT_LOG_FILE" ]]; then
        echo "[${timestamp}] [${level}] ${message}" >> "$CURRENT_LOG_FILE"
    fi
}

# 记录命令执行
log_command() {
    local cmd="$1"
    local description="${2:-执行命令}"
    
    log "INFO" "$description: $cmd"
    
    # 记录命令开始时间
    local start_time=$(date +%s)
    
    # 执行命令并捕获输出
    local output
    local exit_code
    
    if output=$(eval "$cmd" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi
    
    # 记录命令结束时间
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 记录结果
    log "INFO" "命令完成，耗时: ${duration}s，退出码: $exit_code"
    
    # 记录输出（如果失败或调试模式）
    if [[ $exit_code -ne 0 ]] || [[ "${LOG_LEVEL:-3}" -ge 4 ]]; then
        if [[ -n "$output" ]]; then
            echo "--- 命令输出 ---" >> "$CURRENT_LOG_FILE"
            echo "$output" >> "$CURRENT_LOG_FILE"
            echo "--- 输出结束 ---" >> "$CURRENT_LOG_FILE"
        fi
    fi
    
    return $exit_code
}

# 记录构建开始
log_build_start() {
    local pkg_name="$1"
    local version="$2"
    
    log "INFO" "========================================="
    log "INFO" "开始构建: $pkg_name 版本 $version"
    log "INFO" "========================================="
}

# 记录构建结束
log_build_end() {
    local pkg_name="$1"
    local status="$2"  # success, failed, skipped
    local duration="$3"
    
    log "INFO" "========================================="
    log "INFO" "构建结束: $pkg_name"
    log "INFO" "状态: $status"
    log "INFO" "耗时: $(format_duration $duration)"
    log "INFO" "========================================="
}

# 记录错误
log_error() {
    local message="$1"
    local details="${2:-}"
    
    log "ERROR" "$message"
    
    if [[ -n "$details" ]]; then
        echo "--- 错误详情 ---" >> "$CURRENT_LOG_FILE"
        echo "$details" >> "$CURRENT_LOG_FILE"
        echo "--- 详情结束 ---" >> "$CURRENT_LOG_FILE"
    fi
}

# 获取日志文件列表
list_logs() {
    local pattern="${1:-${LOG_PREFIX}_*}"
    
    if [[ ! -d "$LOG_DIR" ]]; then
        warn "日志目录不存在: $LOG_DIR"
        return 1
    fi
    
    find "$LOG_DIR" -name "${pattern}.log" -type f | sort -r
}

# 显示最近的日志
show_recent_log() {
    local count="${1:-1}"
    
    local logs
    logs=$(list_logs)
    
    if [[ -z "$logs" ]]; then
        warn "没有找到日志文件"
        return 1
    fi
    
    echo "$logs" | head -n "$count" | while IFS= read -r log_file; do
        echo "=== $log_file ==="
        tail -n 50 "$log_file"
        echo ""
    done
}

# 清理旧日志
cleanup_logs() {
    local keep_days="${1:-7}"
    
    info "清理 $keep_days 天前的旧日志..."
    
    if [[ ! -d "$LOG_DIR" ]]; then
        return 0
    fi
    
    local count
    count=$(find "$LOG_DIR" -name "${LOG_PREFIX}_*.log" -type f -mtime +$keep_days | wc -l)
    
    if [[ $count -gt 0 ]]; then
        find "$LOG_DIR" -name "${LOG_PREFIX}_*.log" -type f -mtime +$keep_days -delete
        info "已清理 $count 个旧日志文件"
    else
        debug "没有需要清理的旧日志"
    fi
}

# 归档日志
archive_logs() {
    local archive_name="${LOG_PREFIX}_logs_$(date +%Y%m%d_%H%M%S).tar.gz"
    local archive_path="${LOG_DIR}/${archive_name}"
    
    if [[ ! -d "$LOG_DIR" ]]; then
        warn "日志目录不存在: $LOG_DIR"
        return 1
    fi
    
    info "归档日志文件..."
    
    tar -czf "$archive_path" -C "$LOG_DIR" . 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        info "日志已归档: $archive_path"
        
        # 清理原始日志文件
        find "$LOG_DIR" -name "${LOG_PREFIX}_*.log" -type f -delete
        
        return 0
    else
        error "日志归档失败"
        return 1
    fi
}

# 导出函数
export -f init_logging log log_command log_build_start log_build_end log_error
export -f list_logs show_recent_log cleanup_logs archive_logs
