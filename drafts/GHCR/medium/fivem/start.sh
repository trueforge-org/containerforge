#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="${SERVER_DIR:-/config/server}"
mkdir -p "${SERVER_DIR}"
cd "${SERVER_DIR}"

# UNVERIFIED: the runtime download. SRV_ADR returns the Cfx docs HTML rather than a listing, and the
# artifact file name is not confirmed. Until the download is implemented, a runtime must already be
# extracted into ${SERVER_DIR}. Without run.sh, fail with a clear message instead of a crash loop.
if [[ ! -x ./run.sh ]]; then
  echo "fivem: runtime not found in ${SERVER_DIR} (run.sh missing); the runtime download is not implemented yet" >&2
  exit 1
fi

if [[ -z "${SERVER_KEY:-}" ]]; then
  echo "fivem: SERVER_KEY is not set; the server will not start" >&2
fi

# Keep the key out of the process list: write it to a 0600 file under /tmp and exec the server with +exec.
# UNVERIFIED: the convar name sv_licenseKey and that the server reads it from a cfg file.
# The file stays in the ephemeral /tmp after exec, so a follow-up should delete it once the server has read it.
keycfg="/tmp/fivem-key.cfg"
(
  umask 077
  escaped="${SERVER_KEY//\\/\\\\}"
  escaped="${escaped//\"/\\\"}"
  printf 'set sv_licenseKey "%s"\n' "${escaped}" > "${keycfg}"
)

# UNVERIFIED: the launch command and bind addresses. Confirm that the server listens on 0.0.0.0:30120 (tcp and udp)
# rather than localhost only.
exec ./run.sh +exec "${keycfg}" +exec "${GAME_CONFIG:-server.cfg}" ${START_VARS:-}
