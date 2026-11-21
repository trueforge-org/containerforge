#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="${1:-${HEALTHCHECK_CONFIG:-/container-test.yaml}}"
CHECKS_RUN=0
# HEALTHCHECK_DRY_RUN=1 only parses the config and counts the checks, without probing anything.
# It is used by scripts/test-healthcheck-apps.sh to find configs this parser cannot read.
DRY_RUN="${HEALTHCHECK_DRY_RUN:-0}"

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf '%s' "$value"
}

normalize_value() {
    local value
    value="$(trim "$1")"
    value="${value#\'}"
    value="${value%\'}"
    value="${value#\"}"
    value="${value%\"}"
    printf '%s' "$value"
}

# A probed port can be redirected with HEALTHCHECK_PORT_<configured port>=<actual port>, for apps
# whose listen port is changed through the environment.
resolve_port() {
    local port="$1"
    local var
    local override
    if [[ "${port}" =~ ^[0-9]+$ ]]; then
        var="HEALTHCHECK_PORT_${port}"
        override="${!var:-}"
        if [[ -n "${override}" ]]; then
            if [[ ! "${override}" =~ ^[0-9]+$ ]]; then
                echo "healthcheck.sh: ${var} must be a port number, got '${override}'" >&2
                return 1
            fi
            port="${override}"
        fi
    fi
    printf '%s' "${port}"
}

# Fallback for images without any probe: the main process must still be running. Containers start
# under an init (tini), which stays alive on its own, so it also needs a live child process.
process_alive() {
    local stat rest state ppid pid file comm

    [[ -r /proc/1/stat ]] || return 1
    stat="$(</proc/1/stat)"
    rest="${stat##*) }"
    state="${rest%% *}"
    [[ "${state}" != "Z" ]] || return 1

    comm="$(</proc/1/comm)"
    case "${comm}" in
        tini|dumb-init|docker-init) ;;
        *) return 0 ;;
    esac

    for file in /proc/[0-9]*/stat; do
        pid="${file#/proc/}"
        pid="${pid%/stat}"
        if [[ "${pid}" == "1" || "${pid}" == "$$" ]]; then
            continue
        fi
        # The process may exit while we scan. The redirect must sit on a group: $(<file) only reads the
        # file when it is the whole command substitution.
        { stat="$(<"${file}")"; } 2>/dev/null || continue
        rest="${stat##*) }"
        read -r state ppid _ <<<"${rest}"
        if [[ "${ppid}" == "1" && "${state}" != "Z" ]]; then
            return 0
        fi
    done
    return 1
}

check_tcp() {
    local port
    port="$(resolve_port "$1")" || return 1
    if [[ "${DRY_RUN}" == "1" ]]; then
        CHECKS_RUN=$((CHECKS_RUN + 1))
        return 0
    fi
    # Use `timeout` to avoid hanging beyond Docker's healthcheck timeout when
    # the remote side accepts the SYN but never completes the handshake.
    if ! timeout 5 bash -c "exec 3<>/dev/tcp/127.0.0.1/${port}" 2>/dev/null; then
        return 1
    fi
    CHECKS_RUN=$((CHECKS_RUN + 1))
}

check_http() {
    local port
    local path="$2"
    local status_code="$3"
    local received_status
    local curl_exit

    port="$(resolve_port "$1")" || return 1
    if [[ "${DRY_RUN}" == "1" ]]; then
        CHECKS_RUN=$((CHECKS_RUN + 1))
        return 0
    fi

    set +e
    received_status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' --connect-timeout 5 --max-time 10 "http://127.0.0.1:${port}${path}")"
    curl_exit=$?
    set -e

    if [[ "${curl_exit}" -ne 0 ]]; then
        return 1
    fi

    if [[ -z "${status_code}" ]]; then
        # No explicit statusCode configured: accept any 2xx/3xx response.
        if [[ ! "${received_status}" =~ ^[23][0-9][0-9]$ ]]; then
            return 1
        fi
    else
        if [[ "${received_status}" != "${status_code}" ]]; then
            return 1
        fi
    fi

    CHECKS_RUN=$((CHECKS_RUN + 1))
}

check_command() {
    local command="$1"
    local expected_exit_code="$2"
    local expected_content="$3"
    local match_content="$4"
    local output
    local exit_code

    if [[ "${DRY_RUN}" == "1" ]]; then
        CHECKS_RUN=$((CHECKS_RUN + 1))
        return 0
    fi

    set +e
    output="$(sh -c "${command}" 2>&1)"
    exit_code=$?
    set -e

    if [[ "${exit_code}" != "${expected_exit_code}" ]]; then
        return 1
    fi

    if [[ "${match_content,,}" == "true" ]] && [[ "${output}" != *"${expected_content}"* ]]; then
        return 1
    fi

    CHECKS_RUN=$((CHECKS_RUN + 1))
}

flush_http() {
    if [[ -n "${CURRENT_HTTP_PORT}" ]]; then
        check_http "${CURRENT_HTTP_PORT}" "${CURRENT_HTTP_PATH}" "${CURRENT_HTTP_STATUS}"
    fi
}

flush_command() {
    if [[ -n "${CURRENT_COMMAND}" ]]; then
        check_command "${CURRENT_COMMAND}" "${CURRENT_COMMAND_EXIT_CODE}" "${CURRENT_COMMAND_EXPECTED_CONTENT}" "${CURRENT_COMMAND_MATCH_CONTENT}"
    fi
}

if [[ ! -f "${CONFIG_PATH}" ]]; then
    exit 1
fi

if ! grep -Eq '^[[:space:]]*(http|tcp|healthCommands):[[:space:]]*$' "${CONFIG_PATH}"; then
    # No probe configured (readiness is only covered by the container tests): fall back to
    # checking that the main process is still running, instead of always reporting healthy.
    if [[ "${DRY_RUN}" == "1" ]]; then
        echo "no-probe"
        exit 0
    fi
    if ! process_alive; then
        echo "healthcheck.sh: no probe configured and the main process is not running" >&2
        exit 1
    fi
    exit 0
fi

SECTION=""
CURRENT_HTTP_PORT=""
CURRENT_HTTP_PATH="/"
CURRENT_HTTP_STATUS=""
CURRENT_COMMAND=""
CURRENT_COMMAND_EXIT_CODE="0"
CURRENT_COMMAND_EXPECTED_CONTENT=""
CURRENT_COMMAND_MATCH_CONTENT="false"

while IFS= read -r RAW_LINE || [[ -n "${RAW_LINE}" ]]; do
    LINE="$(trim "${RAW_LINE}")"
    # Collapse tabs and runs of internal whitespace so slightly-indented
    # YAML list items (e.g. "-  port: 8080") still match the parsers below.
    LINE="${LINE//$'\t'/ }"
    while [[ "${LINE}" == *"  "* ]]; do
        LINE="${LINE//  / }"
    done

    if [[ -z "${LINE}" ]] || [[ "${LINE}" == \#* ]] || [[ "${LINE}" == timeoutSeconds:* ]]; then
        continue
    fi

    if [[ "${LINE}" =~ ^(http|tcp|healthCommands):$ ]]; then
        if [[ "${SECTION}" == "http" ]]; then
            flush_http
        elif [[ "${SECTION}" == "healthCommands" ]]; then
            flush_command
        fi
        SECTION="${BASH_REMATCH[1]}"
        continue
    fi

    case "${SECTION}" in
        tcp)
            if [[ "${LINE}" =~ ^-[[:space:]]+port:[[:space:]]+(.+)$ ]]; then
                check_tcp "$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^port:[[:space:]]+(.+)$ ]]; then
                check_tcp "$(normalize_value "${BASH_REMATCH[1]}")"
            fi
            ;;
        http)
            if [[ "${LINE}" =~ ^-[[:space:]]+(.+)$ ]]; then
                ITEM="${BASH_REMATCH[1]}"
                flush_http
                CURRENT_HTTP_PORT=""
                CURRENT_HTTP_PATH="/"
                CURRENT_HTTP_STATUS=""
                LINE="${ITEM}"
            fi
            if [[ "${LINE}" =~ ^port:[[:space:]]+(.+)$ ]]; then
                CURRENT_HTTP_PORT="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^path:[[:space:]]+(.+)$ ]]; then
                CURRENT_HTTP_PATH="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^statusCode:[[:space:]]+(.+)$ ]]; then
                CURRENT_HTTP_STATUS="$(normalize_value "${BASH_REMATCH[1]}")"
            fi
            ;;
        healthCommands)
            if [[ "${LINE}" =~ ^-[[:space:]]+(.+)$ ]]; then
                ITEM="${BASH_REMATCH[1]}"
                flush_command
                CURRENT_COMMAND=""
                CURRENT_COMMAND_EXIT_CODE="0"
                CURRENT_COMMAND_EXPECTED_CONTENT=""
                CURRENT_COMMAND_MATCH_CONTENT="false"
                LINE="${ITEM}"
            fi
            if [[ "${LINE}" =~ ^command:[[:space:]]+(.+)$ ]]; then
                CURRENT_COMMAND="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^expectedExitCode:[[:space:]]+(.+)$ ]]; then
                CURRENT_COMMAND_EXIT_CODE="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^expectedContent:[[:space:]]+(.+)$ ]]; then
                CURRENT_COMMAND_EXPECTED_CONTENT="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^matchContent:[[:space:]]+(.+)$ ]]; then
                CURRENT_COMMAND_MATCH_CONTENT="$(normalize_value "${BASH_REMATCH[1]}")"
            fi
            ;;
    esac
done <"${CONFIG_PATH}"

if [[ "${SECTION}" == "http" ]]; then
    flush_http
elif [[ "${SECTION}" == "healthCommands" ]]; then
    flush_command
fi

if [[ "${CHECKS_RUN}" -eq 0 ]]; then
    # A probe section is present but no check could be parsed. That is a broken container-test.yaml,
    # and reporting healthy would hide it, so fail.
    echo "healthcheck.sh: http/tcp/healthCommands section present in ${CONFIG_PATH} but no checks could be parsed" >&2
    exit 1
fi

if [[ "${DRY_RUN}" == "1" ]]; then
    echo "checks=${CHECKS_RUN}"
fi
