#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/healthcheck-positive-XXXXXX)"

cleanup() {
  docker rm -f hc-pos-tcp hc-pos-http hc-pos-healthcommands hc-pos-http-redirect hc-pos-tcp-whitespace >/dev/null 2>&1 || true
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
    docker build -t "hc-pos:${case_name}" "${case_dir}" >/dev/null
}

build_case_redirect() {
    local case_name="$1"
    local yaml_content="$2"
    local case_dir="${TMP_DIR}/${case_name}"

    mkdir -p "${case_dir}"
    cp "${REPO_ROOT}/include/healthcheck.sh" "${case_dir}/healthcheck.sh"

    cat >"${case_dir}/server.py" <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(302)
        self.send_header("Location", "/login")
        self.end_headers()

    def log_message(self, *args, **kwargs):
        return


if __name__ == "__main__":
    HTTPServer(("127.0.0.1", 8080), Handler).serve_forever()
PY

    cat >"${case_dir}/Dockerfile" <<'DOCKERFILE'
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:cac0b51ee72888e75bf2ff4ae1a46be0b5310663584fc54d621d0476e573f5b8
COPY --chmod=755 healthcheck.sh /healthcheck.sh
COPY --chmod=755 server.py /server.py
COPY container-test.yaml /container-test.yaml
HEALTHCHECK --interval=1s --timeout=5s --retries=1 CMD ["/healthcheck.sh"]
CMD ["python3", "/server.py"]
DOCKERFILE

    printf '%s\n' "${yaml_content}" >"${case_dir}/container-test.yaml"
    docker build -t "hc-pos:${case_name}" "${case_dir}" >/dev/null
}

assert_healthy() {
    local case_name="$1"
    local container_name="$2"
    local status=""
    local i=0

    docker run -d --name "${container_name}" "hc-pos:${case_name}" >/dev/null

    for i in $(seq 1 20); do
        status="$(docker inspect --format '{{.State.Health.Status}}' "${container_name}")"
        if [[ "${status}" == "healthy" ]]; then
            return 0
        fi
        sleep 1
    done

    echo "Expected healthy for ${container_name}, got: ${status}" >&2
    docker inspect "${container_name}" >&2 || true
    return 1
}

build_case "tcp" "
tcp:
  - port: '8080'"
build_case "http" "
http:
  - port: '8080'
    path: /
    statusCode: 200"
build_case "healthcommands" "
healthCommands:
  - command: echo healthy
    expectedExitCode: 0
    expectedContent: healthy
    matchContent: true"
build_case_redirect "http-redirect" "
http:
  - port: '8080'
    path: /"
build_case "tcp-whitespace" "
tcp:
  -  port:  '8080'"

assert_healthy "tcp" "hc-pos-tcp"
assert_healthy "http" "hc-pos-http"
assert_healthy "healthcommands" "hc-pos-healthcommands"
assert_healthy "http-redirect" "hc-pos-http-redirect"
assert_healthy "tcp-whitespace" "hc-pos-tcp-whitespace"

echo "All positive healthcheck cases became healthy as expected."
