# lib/fetch.sh
# 下载文件，自动选择 wget 或 curl，已存在则跳过

download() {
    local url="$1"
    local output="$2"

    mkdir -p "$(dirname "$output")"

    if [[ -s "$output" ]]; then
        info "已缓存: $output"
        return 0
    fi

    # Remove empty/corrupted file from previous failed download
    [[ -f "$output" ]] && rm -f "$output"

    info "下载: $url"
    if command -v wget &>/dev/null; then
        wget -q --show-progress -O "$output" "$url" || { rm -f "$output"; error "下载失败: $url"; }
    elif command -v curl &>/dev/null; then
        curl -L --progress-bar -o "$output" "$url" || { rm -f "$output"; error "下载失败: $url"; }
    else
        error "需要 wget 或 curl 下载源码"
    fi
}
