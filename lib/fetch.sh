# lib/fetch.sh
# 下载文件，自动选择 wget 或 curl，已存在则跳过
# 支持SHA256哈希验证、断点续传、自动重试

# 验证文件哈希值
verify_hash() {
    local file="$1"
    local expected="$2"
    
    if [[ -z "$expected" ]]; then
        debug "没有预期哈希值，跳过验证"
        return 0
    fi
    
    if [[ ! -f "$file" ]]; then
        warn "文件不存在，无法验证: $file"
        return 1
    fi
    
    local actual
    actual=$(compute_sha256 "$file")
    
    if [[ "$actual" == "$expected" ]]; then
        debug "哈希验证通过: $file"
        return 0
    else
        warn "哈希验证失败: $file"
        warn "  预期: $expected"
        warn "  实际: $actual"
        return 1
    fi
}

# 检测可用的下载工具
detect_downloader() {
    if command -v wget &>/dev/null; then
        echo "wget"
    elif command -v curl &>/dev/null; then
        echo "curl"
    else
        error "需要 wget 或 curl 下载源码，请先安装其中之一"
    fi
}

# 使用wget下载
download_with_wget() {
    local url="$1"
    local output="$2"
    local max_retries="$3"
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        info "下载: $url (尝试 $((retry + 1))/$max_retries)"
        
        if wget -q --show-progress --timeout=30 --tries=1 -O "$output" "$url"; then
            return 0
        fi
        
        warn "下载失败: $url"
        rm -f "$output"
        retry=$((retry + 1))
        
        if [[ $retry -lt $max_retries ]]; then
            sleep $((retry * 2))
        fi
    done
    
    return 1
}

# 使用curl下载
download_with_curl() {
    local url="$1"
    local output="$2"
    local max_retries="$3"
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        info "下载: $url (尝试 $((retry + 1))/$max_retries)"
        
        if curl -L --progress-bar --connect-timeout 30 --retry 0 -o "$output" "$url"; then
            return 0
        fi
        
        warn "下载失败: $url"
        rm -f "$output"
        retry=$((retry + 1))
        
        if [[ $retry -lt $max_retries ]]; then
            sleep $((retry * 2))
        fi
    done
    
    return 1
}

# 主下载函数
# 参数: url, output_path, [expected_hash], [max_retries]
download() {
    local url="$1"
    local output="$2"
    local expected_hash="${3:-}"
    local max_retries="${4:-3}"
    
    # 确保输出目录存在
    ensure_dir "$(dirname "$output")"
    
    # 如果文件存在且大小大于0，验证哈希值
    if [[ -s "$output" ]]; then
        if [[ -n "$expected_hash" ]]; then
            if verify_hash "$output" "$expected_hash"; then
                info "已缓存且验证通过: $(basename "$output")"
                return 0
            else
                warn "缓存文件哈希不匹配，将重新下载"
                rm -f "$output"
            fi
        else
            info "已缓存: $(basename "$output")"
            return 0
        fi
    fi
    
    # 删除空文件或损坏的文件
    [[ -f "$output" ]] && rm -f "$output"
    
    # 检测下载工具
    local downloader
    downloader=$(detect_downloader)
    
    # 下载文件
    local success=false
    case "$downloader" in
        wget)
            if download_with_wget "$url" "$output" "$max_retries"; then
                success=true
            fi
            ;;
        curl)
            if download_with_curl "$url" "$output" "$max_retries"; then
                success=true
            fi
            ;;
    esac
    
    # 检查下载是否成功
    if ! $success; then
        error "下载失败，已重试 $max_retries 次: $url"
    fi
    
    # 检查文件是否为空
    if [[ ! -s "$output" ]]; then
        error "下载的文件为空: $output"
    fi
    
    # 验证哈希值
    if [[ -n "$expected_hash" ]]; then
        if verify_hash "$output" "$expected_hash"; then
            info "下载并验证成功: $(basename "$output")"
        else
            rm -f "$output"
            error "下载文件哈希验证失败: $url"
        fi
    else
        warn "没有提供SHA256哈希值，跳过验证: $(basename "$output")"
        info "下载成功: $(basename "$output")"
    fi
    
    return 0
}

# 批量下载
# 参数: url1 hash1 url2 hash2 ...
download_multiple() {
    local args=("$@")
    local count=$((${#args[@]} / 2))
    
    for ((i=0; i<count; i++)); do
        local url="${args[$((i*2))]}"
        local hash="${args[$((i*2+1))]}"
        local filename=$(basename "$url")
        local output="${DOWNLOAD_DIR:-/tmp}/$filename"
        
        download "$url" "$output" "$hash"
    done
}

# 导出函数
export -f verify_hash detect_downloader download_with_wget download_with_curl
export -f download download_multiple