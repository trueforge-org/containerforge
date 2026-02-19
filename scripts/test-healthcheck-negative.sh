#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/healthcheck-negative-XXXXXX)"

cleanup() {
    docker rm -f hc-neg-tcp hc-neg-http hc-neg-commands hc-neg-filepaths >/dev/null 2>&1 || true
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

build_case() {
    local case_name="$1"
    local yaml_content="$2"
    local case_dir="${TMP_DIR}/${case_name}"

    mkdir -p "${case_dir}"
    cp "${REPO_ROOT}/include/healthcheck.sh" "${case_dir}/healthcheck.sh"

    cat >"${case_dir}/Dockerfile" <<'DOCKERFILE'
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:cac0b51ee72888e75bf2ff4ae1a46be0b5310663584fc54d621d0476e573f5b8
COPY --chmod=755 healthcheck.sh /healthcheck.sh
COPY container-test.yaml /container-test.yaml
USER root
RUN mkdir -p /www && printf 'ok\n' >/www/index.html && touch /existing-file && chown -R apps:apps /www /existing-file
USER apps
HEALTHCHECK --interval=1s --timeout=2s --retries=1 CMD ["/healthcheck.sh"]
CMD ["python3", "-m", "http.server", "8080", "--directory", "/www", "--bind", "127.0.0.1"]
DOCKERFILE

    printf '%s\n' "${yaml_content}" >"${case_dir}/container-test.yaml"
    docker build -t "hc-neg:${case_name}" "${case_dir}" >/dev/null
}

assert_unhealthy() {
    local case_name="$1"
    local container_name="$2"
    local status=""
    local i=0

    docker run -d --name "${container_name}" "hc-neg:${case_name}" >/dev/null

    for i in $(seq 1 20); do
        status="$(docker inspect --format '{{.State.Health.Status}}' "${container_name}")"
        if [[ "${status}" == "unhealthy" ]]; then
            return 0
        fi
        sleep 1
    done

    echo "Expected unhealthy for ${container_name}, got: ${status}" >&2
    docker inspect "${container_name}" >&2 || true
    return 1
}

build_case "tcp" "timeoutSeconds: 120
tcp:
  - port: '65535'"
build_case "http" "timeoutSeconds: 120
http:
  - port: '8080'
    path: /
    statusCode: 404"
build_case "commands" "timeoutSeconds: 120
commands:
  - command: echo healthy
    expectedExitCode: 0
    expectedContent: definitely-not-in-output
    matchContent: true"
build_case "filepaths" "timeoutSeconds: 120
filePaths:
  - /not/real/file"

assert_unhealthy "tcp" "hc-neg-tcp"
assert_unhealthy "http" "hc-neg-http"
assert_unhealthy "commands" "hc-neg-commands"
assert_unhealthy "filepaths" "hc-neg-filepaths"

echo "All negative healthcheck cases became unhealthy as expected."
