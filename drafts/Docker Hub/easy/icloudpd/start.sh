#!/usr/bin/env bash
set -euo pipefail

: "${ICLOUDPD_WATCH_INTERVAL:=3600}"
: "${ICLOUDPD_PASSWORD_PROVIDER:=webui}"
: "${ICLOUDPD_MFA_PROVIDER:=webui}"
: "${ICLOUDPD_EXTRA_ARGS:=}"

mkdir -p /config/cookies /data

# Idle without a username so an empty /config and no env still starts cleanly (no crash loop).
if [ -z "${ICLOUDPD_USERNAME:-}" ]; then
  echo "ICLOUDPD_USERNAME is not set; idling. Set it and restart." >&2
  exec sleep infinity
fi

case "${ICLOUDPD_EXTRA_ARGS}" in
  *$'\n'*) echo "ICLOUDPD_EXTRA_ARGS must be a single line." >&2; exit 1 ;;
esac

# Keyring first so a saved password is reused. Upstream requires console/webui providers to come last.
args=(
  --directory /data
  --cookie-directory /config/cookies
  --username "${ICLOUDPD_USERNAME}"
  --watch-with-interval "${ICLOUDPD_WATCH_INTERVAL}"
  --password-provider keyring
)
if [ "${ICLOUDPD_PASSWORD_PROVIDER}" != "keyring" ]; then
  args+=(--password-provider "${ICLOUDPD_PASSWORD_PROVIDER}")
fi
args+=(--mfa-provider "${ICLOUDPD_MFA_PROVIDER}")

# Split on whitespace on purpose. The password is never passed as a flag (it would show in the process list).
read -r -a extra_args <<< "${ICLOUDPD_EXTRA_ARGS}" || true

# No --webui-host: upstream binds 0.0.0.0, which other containers need.
# UNVERIFIED: keyring file location under /config (HOME=/config); check after the first login.
exec /app/icloudpd "${args[@]}" ${extra_args[@]+"${extra_args[@]}"}
