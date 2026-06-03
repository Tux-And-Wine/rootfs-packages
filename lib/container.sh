# lib/container.sh
# Optional remote Docker delegation for reproducible Linux builds.

container_truthy() {
    case "${1:-}" in
        1|true|TRUE|yes|YES|on|ON) return 0 ;;
        *) return 1 ;;
    esac
}

container_shell_join() {
    local out=""
    local arg
    for arg in "$@"; do
        printf -v arg "%q" "$arg"
        out+="${out:+ }${arg}"
    done
    printf '%s' "$out"
}

container_ssh_command_string() {
    local ssh_opts=(
        -o StrictHostKeyChecking=no
        -o UserKnownHostsFile=/dev/null
        -o LogLevel=ERROR
    )

    if [[ -n "${CONTAINER_SSH_PASSWORD:-}" ]]; then
        command -v sshpass >/dev/null 2>&1 || error "BUILD_IN_CONTAINER 需要 sshpass 或预先配置 SSH key"
        container_shell_join sshpass -e ssh "${ssh_opts[@]}"
    else
        container_shell_join ssh "${ssh_opts[@]}"
    fi
}

container_prepare_ssh_password() {
    if [[ -n "${CONTAINER_SSH_PASSWORD:-}" ]]; then
        command -v sshpass >/dev/null 2>&1 || error "BUILD_IN_CONTAINER 需要 sshpass 或预先配置 SSH key"
        export SSHPASS="${CONTAINER_SSH_PASSWORD}"
    fi
}

container_ssh() {
    local ssh_cmd
    container_prepare_ssh_password
    ssh_cmd="$(container_ssh_command_string)"
    # shellcheck disable=SC2086
    $ssh_cmd "$@"
}

container_require_local_tools() {
    command -v rsync >/dev/null 2>&1 || error "BUILD_IN_CONTAINER 需要本机安装 rsync"
    command -v ssh >/dev/null 2>&1 || error "BUILD_IN_CONTAINER 需要本机安装 ssh"
}

container_remote_prepare() {
    local remote="$1"
    local remote_dir="$2"
    local remote_command
    remote_command="$(container_shell_join bash -s -- "$remote_dir")"

    container_ssh "$remote" "$remote_command" <<'REMOTE_SCRIPT'
set -euo pipefail
remote_dir="$1"
mkdir -p \
    "$remote_dir/repo" \
    "$remote_dir/downloads" \
    "$remote_dir/work" \
    "$remote_dir/output" \
    "$remote_dir/rootfs"
REMOTE_SCRIPT
}

container_sync_repo() {
    local remote="$1"
    local remote_dir="$2"
    local ssh_cmd
    container_prepare_ssh_password
    ssh_cmd="$(container_ssh_command_string)"

    info "同步项目到 ${remote}:${remote_dir}/repo"
    rsync -az --delete \
        --exclude ".git/" \
        --exclude "downloads/" \
        --exclude "work/" \
        --exclude "output/" \
        -e "$ssh_cmd" \
        "${PROJECT_ROOT}/" \
        "${remote}:${remote_dir}/repo/"
}

container_select_proxy() {
    local remote="$1"
    local mode="${CONTAINER_PROXY_MODE:-auto}"
    local proxy_url="${CONTAINER_PROXY_URL:-}"
    local test_url="${CONTAINER_PROXY_TEST_URL:-https://ftp.gnu.org/gnu/libc/}"
    local test_command
    local proxy_command

    CONTAINER_SELECTED_PROXY=""

    case "$mode" in
        off)
            return 0
            ;;
        always)
            [[ -n "$proxy_url" ]] || error "CONTAINER_PROXY_MODE=always 需要设置 CONTAINER_PROXY_URL"
            info "强制启用代理: $proxy_url"
            CONTAINER_SELECTED_PROXY="$proxy_url"
            return 0
            ;;
        auto)
            test_command="$(container_shell_join timeout 12 curl -fsSI "$test_url") >/dev/null 2>&1"
            if container_ssh "$remote" "$test_command"; then
                info "远程网络直连可用，不启用代理"
                return 0
            fi

            [[ -n "$proxy_url" ]] || {
                warn "远程网络直连失败，但未设置 CONTAINER_PROXY_URL"
                return 0
            }

            proxy_command="$(container_shell_join timeout 12 curl -x "$proxy_url" -fsSI "$test_url") >/dev/null 2>&1"
            if container_ssh "$remote" "$proxy_command"; then
                info "远程网络直连失败，启用代理: $proxy_url"
                CONTAINER_SELECTED_PROXY="$proxy_url"
            else
                warn "远程直连和代理测试都失败，仍将不带代理运行"
            fi
            ;;
        *)
            error "CONTAINER_PROXY_MODE 仅支持 auto、always、off"
            ;;
    esac
}

container_remote_run() {
    local remote="$1"
    local remote_dir="$2"
    local runtime="$3"
    local image="$4"
    local proxy_url="$5"
    shift 5

    local prefix="${PREFIX:?PREFIX 未设置}"
    local prefix_root
    prefix_root="$(dirname "$prefix")"
    local remote_args
    local remote_command

    info "在远程 Docker 容器中构建: ${image}"
    remote_args=(
        bash -s --
        "$remote_dir" \
        "$runtime" \
        "$image" \
        "$prefix" \
        "$prefix_root" \
        "${TARGET_HOST:-aarch64-linux-gnu}" \
        "${BUILD_HOST:-x86_64-linux-gnu}" \
        "${PKG_CONFIG_LIBDIR:-${prefix}/lib/pkgconfig:${prefix}/share/pkgconfig}" \
        "${PKG_CONFIG_SYSROOT_DIR:-${prefix_root}}" \
        "${MAKE_INSTALL_PROGRAM:-}" \
        "$proxy_url" \
        "${CONTAINER_NO_PROXY:-localhost,127.0.0.1}" \
        "${CONTAINER_REBUILD_IMAGE:-0}" \
        "$@"
    )
    remote_command="$(container_shell_join "${remote_args[@]}")"

    container_ssh "$remote" "$remote_command" <<'REMOTE_SCRIPT'
set -euo pipefail

remote_dir="$1"
runtime="$2"
image="$3"
prefix="$4"
prefix_root="$5"
target_host="$6"
build_host="$7"
pkg_config_libdir="$8"
pkg_config_sysroot_dir="$9"
make_install_program="${10}"
proxy_url="${11}"
no_proxy="${12}"
rebuild_image="${13}"
shift 13

repo_dir="$remote_dir/repo"
downloads_dir="$remote_dir/downloads"
work_dir="$remote_dir/work"
output_dir="$remote_dir/output"
rootfs_dir="$remote_dir/rootfs"
home_dir="$work_dir/home"
dockerfile="$repo_dir/docker/tuxwine-builder/Dockerfile"
image_sha_file="$remote_dir/.container-image.sha"

mkdir -p "$downloads_dir" "$work_dir" "$output_dir" "$rootfs_dir" "$home_dir"

build_args=()
run_proxy_env=()
if [[ -n "$proxy_url" ]]; then
    for key in http_proxy https_proxy HTTP_PROXY HTTPS_PROXY; do
        build_args+=(--build-arg "$key=$proxy_url")
        run_proxy_env+=(-e "$key=$proxy_url")
    done
    build_args+=(--build-arg "no_proxy=$no_proxy")
    build_args+=(--build-arg "NO_PROXY=$no_proxy")
    run_proxy_env+=(-e "no_proxy=$no_proxy")
    run_proxy_env+=(-e "NO_PROXY=$no_proxy")
fi

dockerfile_sha="$(sha256sum "$dockerfile" | awk '{print $1}')"
current_image_sha="$(cat "$image_sha_file" 2>/dev/null || true)"
force_rebuild=0
case "$rebuild_image" in
    1|true|TRUE|yes|YES|on|ON) force_rebuild=1 ;;
esac

if [[ "$force_rebuild" == "0" ]] \
    && [[ "$current_image_sha" == "$dockerfile_sha" ]] \
    && "$runtime" image inspect "$image" >/dev/null 2>&1; then
    echo "[INFO] 使用已有容器镜像: $image"
else
    "$runtime" build \
        "${build_args[@]}" \
        --label "tuxwine.dockerfile-sha=$dockerfile_sha" \
        -t "$image" \
        -f "$dockerfile" \
        "$repo_dir"
    printf '%s\n' "$dockerfile_sha" > "$image_sha_file"
fi

uid="$(id -u)"
gid="$(id -g)"

"$runtime" run --rm \
    --security-opt label=disable \
    --user "$uid:$gid" \
    --workdir /work/repo \
    -e HOME=/work/work/home \
    -e TUXWINE_INSIDE_CONTAINER=1 \
    -e BUILD_IN_CONTAINER=1 \
    -e TARGET_HOST="$target_host" \
    -e BUILD_HOST="$build_host" \
    -e PREFIX="$prefix" \
    -e PKG_CONFIG_LIBDIR="$pkg_config_libdir" \
    -e PKG_CONFIG_SYSROOT_DIR="$pkg_config_sysroot_dir" \
    -e MAKE_INSTALL_PROGRAM="$make_install_program" \
    -e DOWNLOAD_DIR=/work/downloads \
    -e WORK_DIR=/work/work \
    -e OUTPUT_DIR=/work/output \
    "${run_proxy_env[@]}" \
    -v "$repo_dir:/work/repo" \
    -v "$downloads_dir:/work/downloads" \
    -v "$work_dir:/work/work" \
    -v "$output_dir:/work/output" \
    -v "$rootfs_dir:$prefix_root" \
    "$image" \
    bash ./start-build.sh "$@"
REMOTE_SCRIPT
}

maybe_delegate_to_container() {
    container_truthy "${BUILD_IN_CONTAINER:-0}" || return 0

    if [[ "${TUXWINE_INSIDE_CONTAINER:-0}" == "1" ]]; then
        return 0
    fi

    container_require_local_tools

    local remote="${CONTAINER_REMOTE:-bazzite@192.168.0.100}"
    local remote_dir="${CONTAINER_REMOTE_DIR:-/home/bazzite/Documents/rootfs-packages-build}"
    local runtime="${CONTAINER_RUNTIME:-docker}"
    local image="${CONTAINER_IMAGE:-tuxwine-rootfs-builder:ubuntu24}"

    info "BUILD_IN_CONTAINER=1，委托到 ${remote}:${remote_dir}"
    container_remote_prepare "$remote" "$remote_dir"
    container_sync_repo "$remote" "$remote_dir"
    container_select_proxy "$remote"
    container_remote_run "$remote" "$remote_dir" "$runtime" "$image" "$CONTAINER_SELECTED_PROXY" "$@"
    exit $?
}
