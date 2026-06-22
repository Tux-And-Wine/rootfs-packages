# lib/state.sh
# 构建状态管理函数

# 状态文件目录
STATE_DIR="${WORK_DIR:-/tmp}/.state"

# 状态文件
STATE_FILE="${STATE_DIR}/build_state.json"

# 初始化状态系统
init_state() {
    ensure_dir "$STATE_DIR"
    
    # 如果状态文件不存在，创建空状态
    if [[ ! -f "$STATE_FILE" ]]; then
        echo '{"packages":{},"last_updated":""}' > "$STATE_FILE"
    fi
}

# 更新包状态
# 参数: pkg_name, status, [details]
update_package_state() {
    local pkg_name="$1"
    local status="$2"  # pending, building, success, failed, skipped
    local details="${3:-}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    init_state
    
    # 读取当前状态
    local current_state
    current_state=$(cat "$STATE_FILE")
    
    # 使用python3更新JSON（更可靠）
    local new_state
    new_state=$(python3 -c "
import json
import sys

try:
    state = json.loads('''$current_state''')
except:
    state = {'packages': {}, 'last_updated': ''}

state['packages']['$pkg_name'] = {
    'status': '$status',
    'details': '$details',
    'timestamp': '$timestamp'
}
state['last_updated'] = '$timestamp'

print(json.dumps(state, indent=2))
")
    
    echo "$new_state" > "$STATE_FILE"
    
    debug "更新包状态: $pkg_name -> $status"
}

# 获取包状态
# 参数: pkg_name
# 返回: status
get_package_state() {
    local pkg_name="$1"
    
    init_state
    
    local state
    state=$(cat "$STATE_FILE")
    
    python3 -c "
import json
import sys

try:
    state = json.loads('''$state''')
    status = state.get('packages', {}).get('$pkg_name', {}).get('status', 'unknown')
    print(status)
except:
    print('unknown')
"
}

# 获取包状态详情
# 参数: pkg_name
# 返回: details
get_package_details() {
    local pkg_name="$1"
    
    init_state
    
    local state
    state=$(cat "$STATE_FILE")
    
    python3 -c "
import json
import sys

try:
    state = json.loads('''$state''')
    details = state.get('packages', {}).get('$pkg_name', {}).get('details', '')
    print(details)
except:
    print('')
"
}

# 获取包状态时间戳
# 参数: pkg_name
# 返回: timestamp
get_package_timestamp() {
    local pkg_name="$1"
    
    init_state
    
    local state
    state=$(cat "$STATE_FILE")
    
    python3 -c "
import json
import sys

try:
    state = json.loads('''$state''')
    timestamp = state.get('packages', {}).get('$pkg_name', {}).get('timestamp', '')
    print(timestamp)
except:
    print('')
"
}

# 检查包是否已构建成功
# 参数: pkg_name
# 返回: 0=成功, 1=未成功
is_package_built() {
    local pkg_name="$1"
    
    local status
    status=$(get_package_state "$pkg_name")
    
    [[ "$status" == "success" ]]
}

# 获取所有包状态
get_all_states() {
    init_state
    
    cat "$STATE_FILE"
}

# 显示状态摘要
show_state_summary() {
    init_state
    
    info "构建状态摘要:"
    
    local state
    state=$(cat "$STATE_FILE")
    
    python3 -c "
import json
import sys

try:
    state = json.loads('''$state''')
    packages = state.get('packages', {})
    
    if not packages:
        print('  没有包状态记录')
        sys.exit(0)
    
    # 统计各状态数量
    status_counts = {}
    for pkg, info in packages.items():
        status = info.get('status', 'unknown')
        status_counts[status] = status_counts.get(status, 0) + 1
    
    for status, count in sorted(status_counts.items()):
        print(f'  {status}: {count}')
    
    print(f'  总计: {len(packages)}')
    
except Exception as e:
    print(f'  读取状态失败: {e}')
"
}

# 显示详细状态
show_detailed_state() {
    init_state
    
    info "详细构建状态:"
    
    local state
    state=$(cat "$STATE_FILE")
    
    python3 -c "
import json
import sys

try:
    state = json.loads('''$state''')
    packages = state.get('packages', {})
    
    if not packages:
        print('  没有包状态记录')
        sys.exit(0)
    
    # 按状态分组显示
    status_groups = {}
    for pkg, info in packages.items():
        status = info.get('status', 'unknown')
        if status not in status_groups:
            status_groups[status] = []
        status_groups[status].append((pkg, info))
    
    for status in ['success', 'building', 'failed', 'skipped', 'pending']:
        if status in status_groups:
            print(f'\n  [{status.upper()}]')
            for pkg, info in status_groups[status]:
                details = info.get('details', '')
                timestamp = info.get('timestamp', '')
                line = f'    - {pkg}'
                if details:
                    line += f': {details}'
                if timestamp:
                    line += f' ({timestamp})'
                print(line)
    
except Exception as e:
    print(f'  读取状态失败: {e}')
"
}

# 重置包状态
# 参数: pkg_name
reset_package_state() {
    local pkg_name="$1"
    
    init_state
    
    local state
    state=$(cat "$STATE_FILE")
    
    local new_state
    new_state=$(python3 -c "
import json
import sys

try:
    state = json.loads('''$state''')
    if '$pkg_name' in state.get('packages', {}):
        del state['packages']['$pkg_name']
    state['last_updated'] = '$(date -u +"%Y-%m-%dT%H:%M:%SZ")'
    print(json.dumps(state, indent=2))
except:
    print('''$state''')
")
    
    echo "$new_state" > "$STATE_FILE"
    
    info "已重置包状态: $pkg_name"
}

# 重置所有状态
reset_all_states() {
    init_state
    
    echo '{"packages":{},"last_updated":"'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"}' > "$STATE_FILE"
    
    info "已重置所有包状态"
}

# 导出函数
export -f init_state update_package_state get_package_state get_package_details
export -f get_package_timestamp is_package_built get_all_states
export -f show_state_summary show_detailed_state reset_package_state reset_all_states
