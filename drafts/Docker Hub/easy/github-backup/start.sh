#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="${GITHUB_USER:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
GITHUB_ORGANIZATION="${GITHUB_ORGANIZATION:-false}"
BACKUP_ARGS="${BACKUP_ARGS:---all}"
OUTPUT_DIR="${OUTPUT_DIR:-/config/backups}"
SCHEDULE="${SCHEDULE:-86400}"
BIN=/app/venv/bin/github-backup

mkdir -p "${OUTPUT_DIR}"

if [ -z "${GITHUB_USER}" ] || [ -z "${GITHUB_TOKEN}" ]; then
  echo "[github-backup] GITHUB_USER and GITHUB_TOKEN are not set; nothing to back up. Idling."
  exec sleep infinity
fi

export XDG_CACHE_HOME=/tmp/.cache
read -r -a EXTRA_ARGS <<< "${BACKUP_ARGS}"

# The token goes to a 0600 file under /tmp: never on the command line, never under /config.
# UNVERIFIED: github-backup accepts file:// token paths (per the tool's --help), test on run.
case "${GITHUB_TOKEN}" in
  github_pat_*) TOKEN_OPT=--token-fine ;;
  *)            TOKEN_OPT=--token ;;
esac
TOKEN_FILE=/tmp/github-token
( umask 077; printf '%s' "${GITHUB_TOKEN}" > "${TOKEN_FILE}" )
unset GITHUB_TOKEN

ORG_ARGS=()
if [ "${GITHUB_ORGANIZATION}" = "true" ]; then ORG_ARGS=(--organization); fi

backup_cmd=("${BIN}" "${TOKEN_OPT}" "file://${TOKEN_FILE}" "${ORG_ARGS[@]}" \
  --output-directory "${OUTPUT_DIR}" "${EXTRA_ARGS[@]}" "${GITHUB_USER}")

# SCHEDULE=0 means one run, and the container exits with the tool's status.
if [ "${SCHEDULE}" = "0" ]; then
  exec "${backup_cmd[@]}"
fi

# The loop is the long-running process. A failed run must not stop the container, and TERM/INT are
# forwarded to the running child so the container stops promptly.
child=""
trap 'if [ -n "${child}" ]; then kill "${child}" 2>/dev/null || true; fi; exit 0' TERM INT
while true; do
  "${backup_cmd[@]}" &
  child=$!
  wait "${child}" || echo "[github-backup] run failed, retrying next cycle"
  sleep "${SCHEDULE}" &
  child=$!
  wait "${child}" || true
done
