#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="${1:-${HEALTHCHECK_CONFIG:-/container-test.yaml}}"
CHECKS_RUN=0

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

check_tcp() {
    local port="$1"
    # Use `timeout` to avoid hanging beyond Docker's healthcheck timeout when
    # the remote side accepts the SYN but never completes the handshake.
    if ! timeout 5 bash -c "exec 3<>/dev/tcp/127.0.0.1/${port}" 2>/dev/null; then
        return 1
    fi
    CHECKS_RUN=$((CHECKS_RUN + 1))
}

check_http() {
    local port="$1"
    local path="$2"
    local status_code="$3"
    local received_status
    local curl_exit

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
    exit 0
fi

SECTION=""
SECTION_SEEN=0
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
        SECTION_SEEN=1
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
                flush_http
                CURRENT_HTTP_PORT=""
                CURRENT_HTTP_PATH="/"
                CURRENT_HTTP_STATUS=""
                LINE="${BASH_REMATCH[1]}"
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
                flush_command
                CURRENT_COMMAND=""
                CURRENT_COMMAND_EXIT_CODE="0"
                CURRENT_COMMAND_EXPECTED_CONTENT=""
                CURRENT_COMMAND_MATCH_CONTENT="false"
                LINE="${BASH_REMATCH[1]}"
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
    if [[ "${SECTION_SEEN}" -eq 1 ]]; then
        # A section header was present but no individual check was parsed.
        # This is almost always a malformed container-test.yaml and should
        # be surfaced, but we keep the legacy exit-0 behavior so we don't
        # flip otherwise-green images unhealthy on a parse issue alone.
        echo "healthcheck.sh: warning: http/tcp/healthCommands section was present in ${CONFIG_PATH} but no checks were executed" >&2
    fi
    # No checks configured is considered healthy for images that only use readiness smoke tests.
    exit 0
fi
