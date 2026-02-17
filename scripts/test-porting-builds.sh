#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)
PORTING_DIR="${PORTING_DIR:-${REPO_ROOT}/porting/post-processed}"
LOG_DIR="${LOG_DIR:-${REPO_ROOT}/porting/build-logs}"

mkdir -p "${LOG_DIR}"

failures=()

for docker_bake_file in "${PORTING_DIR}"/*/docker-bake.hcl; do
    [[ -f "${docker_bake_file}" ]] || continue

    container_dir=$(dirname "${docker_bake_file}")
    container_name=$(basename "${container_dir}")
    log_file="${LOG_DIR}/${container_name}.log"

    echo "Building ${container_name}..."

    if ! (
        cd "${container_dir}"
        docker buildx bake --progress=plain --set image-local.platform=linux/amd64 image-local
    ) 2>&1 | tee "${log_file}"; then
        echo "Build failed for ${container_name}. See ${log_file}"
        failures+=("${container_name}")
    fi
done

if ((${#failures[@]} > 0)); then
    echo "Build failures (${#failures[@]}): ${failures[*]}"
    exit 1
fi

echo "All porting container builds succeeded. Logs written to ${LOG_DIR}"
