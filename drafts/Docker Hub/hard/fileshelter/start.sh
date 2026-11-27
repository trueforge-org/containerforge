#!/usr/bin/env bash
set -euo pipefail

CONFIG_SEED=/defaults/fileshelter.conf
CONFIG=/config/fileshelter.conf
RUNTIME_CONFIG=/tmp/fileshelter.conf

mkdir -p /config

# Seed the persistent config only when missing or empty. Never overwrite user state.
if [[ ! -s "${CONFIG}" ]]; then
  cp "${CONFIG_SEED}" "${CONFIG}"
fi

# Validate env overrides before use.
if [[ -n "${FILESHELTER_MAX_SHARE_SIZE:-}" ]] && [[ ! "${FILESHELTER_MAX_SHARE_SIZE}" =~ ^[0-9]+$ ]]; then
  echo "FILESHELTER_MAX_SHARE_SIZE must be a whole number of MB" >&2
  exit 1
fi
if [[ -n "${FILESHELTER_BEHIND_REVERSE_PROXY:-}" ]] && [[ "${FILESHELTER_BEHIND_REVERSE_PROXY}" != "true" && "${FILESHELTER_BEHIND_REVERSE_PROXY}" != "false" ]]; then
  echo "FILESHELTER_BEHIND_REVERSE_PROXY must be true or false" >&2
  exit 1
fi

# libconfig string escaping for values taken from the environment (backslash and double quote).
esc() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '%s' "$s"
}

# Upload passwords are comma separated in the env and a libconfig list in the file.
# Values are never echoed.
pw_list=""
if [[ -n "${FILESHELTER_UPLOAD_PASSWORDS:-}" ]]; then
  IFS=',' read -r -a pws <<< "${FILESHELTER_UPLOAD_PASSWORDS}"
  for p in "${pws[@]}"; do
    [[ -z "${p}" ]] && continue
    pw_list+="${pw_list:+, }\"$(esc "${p}")\""
  done
fi

# Build the effective config in /tmp so env overrides never rewrite /config.
# Only the keys mapped from env are changed. Everything else is copied verbatim.
while IFS= read -r line || [[ -n "${line}" ]]; do
  case "${line}" in
    max-share-size*)
      if [[ -n "${FILESHELTER_MAX_SHARE_SIZE:-}" ]]; then
        line="max-share-size = ${FILESHELTER_MAX_SHARE_SIZE};"
      fi
      ;;
    behind-reverse-proxy*)
      if [[ -n "${FILESHELTER_BEHIND_REVERSE_PROXY:-}" ]]; then
        line="behind-reverse-proxy = ${FILESHELTER_BEHIND_REVERSE_PROXY};"
      fi
      ;;
    upload-passwords*)
      if [[ -n "${FILESHELTER_UPLOAD_PASSWORDS:-}" ]]; then
        line="upload-passwords = ( ${pw_list} );"
      fi
      ;;
  esac
  printf '%s\n' "${line}"
done < "${CONFIG}" > "${RUNTIME_CONFIG}"

export TMPDIR=/tmp

# UNVERIFIED: the binary accepts the config path as argv[1] (plan section 1). Default is /etc/fileshelter.conf.
exec /usr/local/bin/fileshelter "${RUNTIME_CONFIG}"
