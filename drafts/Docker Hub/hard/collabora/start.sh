#!/usr/bin/env bash
# Starts Collabora Online (CODE) coolwsd.
#
# Runs on a read-only rootfs without added capabilities. The chroot jails are
# off (security.capabilities=false), so document conversion is less sandboxed.
# Values passed as --o: flags are visible in the process list.
set -euo pipefail

CONFIG_DIR=/config/coolwsd
CONFIG_FILE="${CONFIG_DIR}/coolwsd.xml"
RUN_DIR=/tmp/cool

mkdir -p "${CONFIG_DIR}" "${RUN_DIR}/child-roots" "${RUN_DIR}/cache"

# Seed the default config only when it is missing. Never overwrite user state.
if [[ ! -s "${CONFIG_FILE}" ]]; then
  cp /etc/coolwsd/coolwsd.xml "${CONFIG_FILE}"
fi

# UNVERIFIED: WOPI proof key. coolwsd-generate-proof-key writes under /etc/coolwsd by default, which is
# read-only here. Add a generate-if-missing step into /config/coolwsd once an output path is confirmed.

args=(
  "--o:ssl.enable=false"
  "--o:ssl.termination=true"
  "--o:net.listen=any"
  "--o:child_root_path=${RUN_DIR}/child-roots"
  "--o:cache_files.path=${RUN_DIR}/cache"
  "--o:security.capabilities=false"
  "--o:mount_jail_tree=false"
  "--o:logging.file[@enable]=false"
)

if [[ -n "${server_name:-}" ]]; then
  args+=("--o:server_name=${server_name}")
fi

if [[ -n "${dictionaries:-}" ]]; then
  # UNVERIFIED: key name for the language allow-list.
  args+=("--o:allowed_languages=${dictionaries}")
fi

# aliasgroup1, aliasgroup2, ... each become one allowed WOPI host.
# UNVERIFIED: storage.wopi.host list syntax.
idx=0
while IFS= read -r name; do
  value="${!name}"
  if [[ -n "${value}" ]]; then
    args+=("--o:storage.wopi.host[${idx}]=${value}")
    idx=$((idx + 1))
  fi
done < <(compgen -e | grep -E '^aliasgroup[0-9]+$' | sort -V)

if [[ -n "${username:-}" && -n "${password:-}" ]]; then
  # UNVERIFIED: admin console keys. The password shows in the process list.
  args+=("--o:admin_console.username=${username}" "--o:admin_console.password=${password}")
fi

if [[ -n "${extra_params:-}" ]]; then
  # Raw coolwsd flags, split on whitespace and appended last.
  read -r -a extra <<< "${extra_params}"
  args+=("${extra[@]}")
fi

# UNVERIFIED: --config-file and --disable-cool-user-checking. Confirm with `coolwsd --help`.
exec /usr/bin/coolwsd \
  --config-file="${CONFIG_FILE}" \
  --disable-cool-user-checking \
  "${args[@]}"
