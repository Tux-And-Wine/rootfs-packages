# lib/unpack.sh
# 解压常见压缩格式到目标目录

extract() {
    local archive="$1"
    local dest="$2"

    mkdir -p "$dest"
    info "解压: $archive -> $dest"

    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$dest" ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$archive" -C "$dest" ;;
        *.tar.xz|*.txz)
            tar -xJf "$archive" -C "$dest" ;;
        *.zip)
            unzip -q "$archive" -d "$dest" ;;
        *)
            error "不支持的压缩格式: $archive" ;;
    esac
}
