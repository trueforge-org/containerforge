#!/bin/bash
set -euo pipefail

if [[ "${1:-}" == "/start.sh" ]]; then
  shift
fi

XMRIG_HTTP_PORT="${XMRIG_HTTP_PORT:-8080}"
XMRIG_DONATE_LEVEL="${XMRIG_DONATE_LEVEL:-1}"
XMRIG_HUGE_PAGES="${XMRIG_HUGE_PAGES:-true}"
XMRIG_PASS="${XMRIG_PASS:-x}"

args=(
  --no-color
  --http-host 0.0.0.0
  --http-port "$XMRIG_HTTP_PORT"
  --donate-level "$XMRIG_DONATE_LEVEL"
)

if [[ -n "${XMRIG_HTTP_ACCESS_TOKEN:-}" ]]; then
  args+=(--http-access-token "$XMRIG_HTTP_ACCESS_TOKEN")
fi
if [[ "$XMRIG_HUGE_PAGES" == "false" ]]; then
  args+=(--no-huge-pages)
fi
if [[ -n "${XMRIG_THREADS:-}" ]]; then
  args+=(--threads "$XMRIG_THREADS")
fi

if [[ -s /config/config.json ]]; then
  # A user supplied config wins over the XMRIG_URL/USER/PASS variables.
  args+=(--config /config/config.json)
else
  json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
  }

  if [[ -z "${XMRIG_URL:-}" ]]; then
    # Without a pool xmrig exits. Idle against a closed local port instead, it never mines.
    echo "WARNING: XMRIG_URL not set; xmrig is idling against a closed local port" >&2
  fi

  # Pool credentials go in a private config in /tmp so they stay out of the process list.
  umask 077
  conf=/tmp/xmrig.json
  tls=false
  [[ -n "${XMRIG_TLS:-}" ]] && tls=true
  rig_id=null
  [[ -n "${XMRIG_RIG_ID:-}" ]] && rig_id="\"$(json_escape "$XMRIG_RIG_ID")\""
  {
    printf '{\n  "pools": [\n    {\n'
    printf '      "url": "%s",\n' "$(json_escape "${XMRIG_URL:-127.0.0.1:1}")"
    printf '      "user": "%s",\n' "$(json_escape "${XMRIG_USER:-}")"
    printf '      "pass": "%s",\n' "$(json_escape "$XMRIG_PASS")"
    printf '      "rig-id": %s,\n' "$rig_id"
    printf '      "tls": %s,\n' "$tls"
    printf '      "keepalive": true\n'
    printf '    }\n  ]\n}\n'
  } > "$conf"
  args+=(--config "$conf")
fi

exec xmrig "${args[@]}" "$@"
