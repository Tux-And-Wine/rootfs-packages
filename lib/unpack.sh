# lib/unpack.sh
# 解压常见压缩格式到目标目录
# 支持: .tar.gz, .tar.bz2, .tar.xz, .tar.zst, .zip, .tar

# 检测解压工具是否可用
check_extract_tools() {
    local archive="$1"
    
    case "$archive" in
        *.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.tar)
            check_command "tar"
            ;;
        *.tar.zst)
            check_command "tar"
            if ! tar --help 2>&1 | grep -q "zstd"; then
                error "tar 不支持 zstd 格式，请安装 zstd 或更新 tar"
            fi
            ;;
        *.zip)
            check_command "unzip"
            ;;
        *.gz)
            check_command "gzip"
            ;;
        *.bz2)
            check_command "bzip2"
            ;;
        *.xz)
            check_command "xz"
            ;;
        *.zst)
            check_command "zstd"
            ;;
        *)
            error "不支持的压缩格式: $archive"
            ;;
    esac
}

# 解压文件到目标目录
# 参数: archive, dest_dir
extract() {
    local archive="$1"
    local dest="$2"
    
    # 检查源文件
    check_file "$archive" "压缩包"
    
    # 检查解压工具
    check_extract_tools "$archive"
    
    # 创建目标目录
    ensure_dir "$dest"
    
    info "解压: $(basename "$archive") -> $dest"
    
    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$dest"
            ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$archive" -C "$dest"
            ;;
        *.tar.xz|*.txz)
            tar -xJf "$archive" -C "$dest"
            ;;
        *.tar.zst)
            tar --zstd -xf "$archive" -C "$dest"
            ;;
        *.tar)
            tar -xf "$archive" -C "$dest"
            ;;
        *.zip)
            unzip -q "$archive" -d "$dest"
            ;;
        *.gz)
            gunzip -c "$archive" > "$dest/$(basename "${archive%.gz}")"
            ;;
        *.bz2)
            bunzip2 -c "$archive" > "$dest/$(basename "${archive%.bz2}")"
            ;;
        *.xz)
            unxz -c "$archive" > "$dest/$(basename "${archive%.xz}")"
            ;;
        *.zst)
            zstd -d "$archive" -o "$dest/$(basename "${archive%.zst}")"
            ;;
        *)
            error "不支持的压缩格式: $archive"
            ;;
    esac
    
    # 检查解压是否成功
    if [[ $? -ne 0 ]]; then
        error "解压失败: $archive"
    fi
    
    debug "解压完成: $archive"
}

# 解压并返回解压后的目录名
# 参数: archive, dest_dir
# 返回: 解压后的目录路径
extract_and_find_dir() {
    local archive="$1"
    local dest="$2"
    
    # 记录解压前的目录内容
    local before=()
    if [[ -d "$dest" ]]; then
        while IFS= read -r -d '' entry; do
            before+=("$entry")
        done < <(find "$dest" -maxdepth 1 -mindepth 1 -print0 2>/dev/null)
    fi
    
    # 解压文件
    extract "$archive" "$dest"
    
    # 查找新创建的目录
    local new_dir=""
    while IFS= read -r -d '' entry; do
        local found=false
        for old in "${before[@]:-}"; do
            if [[ "$entry" == "$old" ]]; then
                found=true
                break
            fi
        done
        if ! $found && [[ -d "$entry" ]]; then
            new_dir="$entry"
            break
        fi
    done < <(find "$dest" -maxdepth 1 -mindepth 1 -print0 2>/dev/null)
    
    if [[ -z "$new_dir" ]]; then
        # 如果没有找到新目录，返回dest本身
        echo "$dest"
    else
        echo "$new_dir"
    fi
}

# 解压到临时目录
# 参数: archive
# 返回: 临时目录路径
extract_to_temp() {
    local archive="$1"
    local temp_dir=$(mktemp -d)
    
    extract "$archive" "$temp_dir"
    
    echo "$temp_dir"
}

# 导出函数
export -f check_extract_tools extract extract_and_find_dir extract_to_temp