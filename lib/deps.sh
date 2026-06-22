# lib/deps.sh
# 依赖解析和管理函数

# 解析包的依赖关系
# 参数: pkg_name
# 返回: 依赖列表（按构建顺序）
resolve_dependencies() {
    local pkg_name="$1"
    local resolved=()
    local visited=()
    
    _resolve_deps_recursive "$pkg_name" resolved visited
    
    # 返回去重后的依赖列表
    printf '%s\n' "${resolved[@]}" | awk '!seen[$0]++'
}

# 递归解析依赖（内部函数）
_resolve_deps_recursive() {
    local pkg_name="$1"
    local -n resolved_ref=$2
    local -n visited_ref=$3
    
    # 检查是否已访问
    for visited in "${visited_ref[@]:-}"; do
        if [[ "$visited" == "$pkg_name" ]]; then
            return 0
        fi
    done
    
    visited_ref+=("$pkg_name")
    
    # 获取包的依赖
    local deps
    deps=$(get_package_deps "$pkg_name")
    
    # 递归处理依赖
    if [[ -n "$deps" ]]; then
        while IFS= read -r dep; do
            [[ -z "$dep" ]] && continue
            _resolve_deps_recursive "$dep" resolved_ref visited_ref
        done <<< "$deps"
    fi
    
    # 添加当前包
    resolved_ref+=("$pkg_name")
}

# 获取包的依赖列表
# 参数: pkg_name
# 返回: 依赖列表（每行一个）
get_package_deps() {
    local pkg_name="$1"
    local recipe_file="${PACKAGES_DIR:?}/${pkg_name}/recipe.sh"
    
    if [[ ! -f "$recipe_file" ]]; then
        return 0
    fi
    
    # 从recipe.sh中提取DEPENDS变量
    local deps_line
    deps_line=$(grep "^DEPENDS=" "$recipe_file" 2>/dev/null | head -1)
    
    if [[ -z "$deps_line" ]]; then
        return 0
    fi
    
    # 解析DEPENDS变量
    local deps_value
    deps_value=$(echo "$deps_line" | sed 's/^DEPENDS=//' | sed 's/^"//' | sed 's/"$//')
    
    if [[ -z "$deps_value" ]]; then
        return 0
    fi
    
    # 返回依赖列表
    echo "$deps_value" | tr ' ' '\n' | grep -v '^$'
}

# 检查依赖是否满足
# 参数: pkg_name
# 返回: 0=满足, 1=不满足
check_dependencies() {
    local pkg_name="$1"
    local missing_deps=()
    
    local deps
    deps=$(get_package_deps "$pkg_name")
    
    if [[ -z "$deps" ]]; then
        return 0
    fi
    
    while IFS= read -r dep; do
        [[ -z "$dep" ]] && continue
        
        # 检查依赖包是否已构建
        if [[ ! -d "${OUTPUT_DIR:?}/${dep}" ]]; then
            missing_deps+=("$dep")
        fi
    done <<< "$deps"
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        warn "包 $pkg_name 缺少依赖: ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# 获取包的构建顺序（考虑依赖关系）
# 参数: pkg_names...
# 返回: 按构建顺序排列的包列表
get_build_order() {
    local packages=("$@")
    local all_ordered=()
    local visited=()
    
    # 首先解析所有包的依赖
    for pkg in "${packages[@]}"; do
        _resolve_deps_recursive "$pkg" all_ordered visited
    done
    
    # 过滤出需要构建的包
    local result=()
    for pkg in "${all_ordered[@]}"; do
        # 检查是否在请求的包列表中或者是它们的依赖
        for requested in "${packages[@]}"; do
            if [[ "$pkg" == "$requested" ]]; then
                result+=("$pkg")
                break
            fi
        done
    done
    
    printf '%s\n' "${result[@]}"
}

# 验证所有依赖关系
# 参数: pkg_names...
# 返回: 0=所有依赖满足, 1=有依赖缺失
validate_all_dependencies() {
    local packages=("$@")
    local all_ok=true
    
    for pkg in "${packages[@]}"; do
        if ! check_dependencies "$pkg"; then
            all_ok=false
        fi
    done
    
    $all_ok
}

# 显示依赖树
# 参数: pkg_name
show_dependency_tree() {
    local pkg_name="$1"
    local indent="${2:-0}"
    local -a visited=("${@:3}")
    
    # 检查是否已访问（防止循环）
    for v in "${visited[@]:-}"; do
        if [[ "$v" == "$pkg_name" ]]; then
            local prefix=""
            for ((i=0; i<indent; i++)); do
                prefix+="  "
            done
            echo "${prefix}${pkg_name} (已访问)"
            return 0
        fi
    done
    
    visited+=("$pkg_name")
    
    local prefix=""
    for ((i=0; i<indent; i++)); do
        prefix+="  "
    done
    
    echo "${prefix}${pkg_name}"
    
    local deps
    deps=$(get_package_deps "$pkg_name")
    
    if [[ -n "$deps" ]]; then
        while IFS= read -r dep; do
            [[ -z "$dep" ]] && continue
            show_dependency_tree "$dep" $((indent + 1)) "${visited[@]}"
        done <<< "$deps"
    fi
}

# 检查循环依赖
# 参数: pkg_names...
# 返回: 0=无循环, 1=有循环
check_circular_dependencies() {
    local packages=("$@")
    
    for pkg in "${packages[@]}"; do
        if _has_circular_dep "$pkg" ""; then
            return 1
        fi
    done
    
    return 0
}

# 检查循环依赖（内部函数）
_has_circular_dep() {
    local pkg="$1"
    local path="$2"
    
    # 检查是否在路径中
    if [[ "$path" == *"|$pkg|"* ]]; then
        warn "检测到循环依赖: ${path}|${pkg}|"
        return 0
    fi
    
    local deps
    deps=$(get_package_deps "$pkg")
    
    if [[ -n "$deps" ]]; then
        while IFS= read -r dep; do
            [[ -z "$dep" ]] && continue
            if _has_circular_dep "$dep" "${path}|${pkg}|"; then
                return 0
            fi
        done <<< "$deps"
    fi
    
    return 1
}

# 导出函数
export -f resolve_dependencies get_package_deps check_dependencies
export -f get_build_order validate_all_dependencies show_dependency_tree
export -f check_circular_dependencies
