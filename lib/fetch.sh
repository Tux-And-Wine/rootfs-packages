# lib/fetch.sh
# 下载文件，自动选择 wget 或 curl，已存在则跳过

# 计算文件的 SHA256 哈希值
compute_hash() {
    local file="$1"
    sha256sum "$file" | cut -d' ' -f1
}

# 验证文件哈希值
verify_hash() {
    local file="$1"
    local expected="$2"
    
    if [[ -z "$expected" ]]; then
        return 0  # 没有预期哈希值，跳过验证
    fi
    
    if [[ ! -f "$file" ]]; then
        return 1  # 文件不存在
    fi
    
    local actual
    actual=$(compute_hash "$file")
    
    if [[ "$actual" == "$expected" ]]; then
        return 0  # 哈希匹配
    else
        warn "哈希验证失败: $file"
        warn "  预期: $expected"
        warn "  实际: $actual"
        return 1  # 哈希不匹配
    fi
}

download() {
    local url="$1"
    local output="$2"
    local expected_hash="${3:-}"  # 可选的第三个参数：预期的 SHA256 哈希值
    
    mkdir -p "$(dirname "$output")"
    
    # 如果文件存在且大小大于0，验证哈希值
    if [[ -s "$output" ]]; then
        if [[ -n "$expected_hash" ]]; then
            if verify_hash "$output" "$expected_hash"; then
                info "已缓存且验证通过: $output"
                return 0
            else
                warn "缓存文件哈希不匹配，将重新下载: $output"
                rm -f "$output"
            fi
        else
            info "已缓存: $output"
            return 0
        fi
    fi
    
    # 删除空文件或损坏的文件
    [[ -f "$output" ]] && rm -f "$output"
    
    # 下载文件（最多重试3次）
    local max_retries=3
    local retry=0
    
    while [[ $retry -lt $max_retries ]]; do
        info "下载: $url (尝试 $((retry + 1))/$max_retries)"
        
        if command -v wget &>/dev/null; then
            wget -q --show-progress -O "$output" "$url" || { rm -f "$output"; warn "下载失败: $url"; retry=$((retry + 1)); continue; }
        elif command -v curl &>/dev/null; then
            curl -L --progress-bar -o "$output" "$url" || { rm -f "$output"; warn "下载失败: $url"; retry=$((retry + 1)); continue; }
        else
            error "需要 wget 或 curl 下载源码"
        fi
        
        # 下载成功，验证哈希值
        if [[ -n "$expected_hash" ]]; then
            if verify_hash "$output" "$expected_hash"; then
                info "下载并验证成功: $output"
                return 0
            else
                warn "下载文件哈希不匹配，将重试"
                rm -f "$output"
                retry=$((retry + 1))
            fi
        else
            # 没有哈希验证，下载成功即可
            info "下载成功: $output"
            return 0
        fi
    done
    
    error "下载失败，已重试 $max_retries 次: $url"
}
