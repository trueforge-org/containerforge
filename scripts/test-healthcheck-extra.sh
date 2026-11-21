#!/usr/bin/env bash
# Cases for the behaviour added to include/healthcheck.sh beyond plain probes:
# a malformed section fails, an image without probes falls back to a process check,
# and a probed port can be overridden through the environment.
set -euo pipefail

BASE_IMAGE="${BASE_IMAGE:-ghcr.io/trueforge-org/python:3.13.12@sha256:cac0b51ee72888e75bf2ff4ae1a46be0b5310663584fc54d621d0476e573f5b8}"
SERVER_KIND="${SERVER_KIND:-python}"
case "${SERVER_KIND}" in
    python) SERVER_CMD='["python3", "-m", "http.server", "8080", "--directory", "/www", "--bind", "127.0.0.1"]' ;;
    node) SERVER_CMD='["node", "-e", "require(\"http\").createServer((q, r) => r.end(\"ok\")).listen(8080, \"127.0.0.1\")"]' ;;
    *) echo "Unknown SERVER_KIND: ${SERVER_KIND}" >&2; exit 1 ;;
esac

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/healthcheck-extra-XXXXXX)"
CONTAINERS=(hc-x-malformed hc-x-fallback hc-x-dead-init hc-x-port-override)

cleanup() {
    docker rm -f "${CONTAINERS[@]}" >/dev/null 2>&1 || true
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

# build_case <name> <container-test.yaml content> <Dockerfile tail>
build_case() {
    local case_name="$1"
    local yaml_content="$2"
    local dockerfile_tail="$3"
    local case_dir="${TMP_DIR}/${case_name}"

    mkdir -p "${case_dir}"
    cp "${REPO_ROOT}/include/healthcheck.sh" "${case_dir}/healthcheck.sh"
    printf '%s\n' "${yaml_content}" >"${case_dir}/container-test.yaml"

    {
        cat <<'DOCKERFILE'
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
COPY --chmod=755 healthcheck.sh /healthcheck.sh
COPY container-test.yaml /container-test.yaml
USER root
RUN mkdir -p /www && printf 'ok\n' >/www/index.html && chown -R apps:apps /www \
    && ln -s "$(command -v sleep)" /usr/local/bin/tini-sleep
USER apps
HEALTHCHECK --interval=1s --timeout=2s --retries=1 CMD ["/healthcheck.sh"]
DOCKERFILE
        printf '%s\n' "${dockerfile_tail}"
    } >"${case_dir}/Dockerfile"

    docker build --build-arg "BASE_IMAGE=${BASE_IMAGE}" -t "hc-x:${case_name}" "${case_dir}" >/dev/null
}

wait_for() {
    local expected="$1"
    local container_name="$2"
    local status=""
    local i

    for i in $(seq 1 25); do
        status="$(docker inspect --format '{{.State.Health.Status}}' "${container_name}")"
        if [[ "${status}" == "${expected}" ]]; then
            return 0
        fi
        sleep 1
    done

    echo "Expected ${expected} for ${container_name}, got: ${status}" >&2
    docker logs "${container_name}" >&2 || true
    return 1
}

CMD_LINE="CMD ${SERVER_CMD}"

# A section header without any parsable check used to be reported healthy.
build_case "malformed" "
tcp:
  - notaport: 1" "${CMD_LINE}"

# No probe at all: healthy while the main process runs under tini.
build_case "fallback" "
runners:
  - entrypoint: true" "${CMD_LINE}"

# No probe and PID 1 is an init without any child: not healthy.
# The symlink makes /proc/1/comm read "tini" while it only sleeps.
build_case "dead-init" "
runners:
  - entrypoint: true" 'ENTRYPOINT ["/usr/local/bin/tini-sleep", "infinity"]'

# The configured port has nothing behind it, the override points at the real server.
build_case "port-override" "
tcp:
  - port: '9999'" "${CMD_LINE}"

docker run -d --name hc-x-malformed "hc-x:malformed" >/dev/null
docker run -d --name hc-x-fallback "hc-x:fallback" >/dev/null
docker run -d --name hc-x-dead-init "hc-x:dead-init" >/dev/null
docker run -d --name hc-x-port-override -e HEALTHCHECK_PORT_9999=8080 "hc-x:port-override" >/dev/null

wait_for unhealthy hc-x-malformed
wait_for healthy hc-x-fallback
wait_for unhealthy hc-x-dead-init
wait_for healthy hc-x-port-override

echo "All extra healthcheck cases behaved as expected."
