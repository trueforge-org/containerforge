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
    exec 3<>"/dev/tcp/127.0.0.1/${port}" 2>/dev/null
    exec 3>&-
    exec 3<&-
    CHECKS_RUN=$((CHECKS_RUN + 1))
}

check_http() {
    local port="$1"
    local path="$2"
    local status_code="$3"
    local received_status
    local curl_exit

    set +e
    received_status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "http://127.0.0.1:${port}${path}")"
    curl_exit=$?
    set -e

    if [[ "${curl_exit}" -ne 0 ]] || [[ "${received_status}" != "${status_code}" ]]; then
        return 1
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

check_file() {
    local file_path="$1"
    [[ -f "${file_path}" ]]
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

SECTION=""
CURRENT_HTTP_PORT=""
CURRENT_HTTP_PATH="/"
CURRENT_HTTP_STATUS="200"
CURRENT_COMMAND=""
CURRENT_COMMAND_EXIT_CODE="0"
CURRENT_COMMAND_EXPECTED_CONTENT=""
CURRENT_COMMAND_MATCH_CONTENT="false"

while IFS= read -r RAW_LINE || [[ -n "${RAW_LINE}" ]]; do
    LINE="$(trim "${RAW_LINE}")"

    if [[ -z "${LINE}" ]] || [[ "${LINE}" == \#* ]] || [[ "${LINE}" == timeoutSeconds:* ]]; then
        continue
    fi

    if [[ "${LINE}" =~ ^(http|tcp|healthCommands|filePaths):$ ]]; then
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
            if [[ "${LINE}" =~ ^-\ port:\ (.+)$ ]]; then
                check_tcp "$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^port:\ (.+)$ ]]; then
                check_tcp "$(normalize_value "${BASH_REMATCH[1]}")"
            fi
            ;;
        http)
            if [[ "${LINE}" =~ ^-\ (.+)$ ]]; then
                flush_http
                CURRENT_HTTP_PORT=""
                CURRENT_HTTP_PATH="/"
                CURRENT_HTTP_STATUS="200"
                LINE="${BASH_REMATCH[1]}"
            fi
            if [[ "${LINE}" =~ ^port:\ (.+)$ ]]; then
                CURRENT_HTTP_PORT="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^path:\ (.+)$ ]]; then
                CURRENT_HTTP_PATH="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^statusCode:\ (.+)$ ]]; then
                CURRENT_HTTP_STATUS="$(normalize_value "${BASH_REMATCH[1]}")"
            fi
            ;;
        healthCommands)
            if [[ "${LINE}" =~ ^-\ (.+)$ ]]; then
                flush_command
                CURRENT_COMMAND=""
                CURRENT_COMMAND_EXIT_CODE="0"
                CURRENT_COMMAND_EXPECTED_CONTENT=""
                CURRENT_COMMAND_MATCH_CONTENT="false"
                LINE="${BASH_REMATCH[1]}"
            fi
            if [[ "${LINE}" =~ ^command:\ (.+)$ ]]; then
                CURRENT_COMMAND="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^expectedExitCode:\ (.+)$ ]]; then
                CURRENT_COMMAND_EXIT_CODE="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^expectedContent:\ (.+)$ ]]; then
                CURRENT_COMMAND_EXPECTED_CONTENT="$(normalize_value "${BASH_REMATCH[1]}")"
            elif [[ "${LINE}" =~ ^matchContent:\ (.+)$ ]]; then
                CURRENT_COMMAND_MATCH_CONTENT="$(normalize_value "${BASH_REMATCH[1]}")"
            fi
            ;;
        filePaths)
            if [[ "${LINE}" =~ ^-\ (.+)$ ]]; then
                check_file "$(normalize_value "${BASH_REMATCH[1]}")"
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
    exit 1
fi
