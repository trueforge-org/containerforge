#!/usr/bin/env bash
set -euo pipefail

# defaults match settings.yaml
PORT="${PORT:-8080}"
SERVER_NAME="${SERVER_NAME:-localhost}"
BACKEND="${BACKEND:-http://localhost:80}"
MODSEC_RULE_ENGINE="${MODSEC_RULE_ENGINE:-on}"
PARANOIA="${PARANOIA:-1}"
BLOCKING_PARANOIA="${BLOCKING_PARANOIA:-1}"
ANOMALY_INBOUND="${ANOMALY_INBOUND:-5}"
ANOMALY_OUTBOUND="${ANOMALY_OUTBOUND:-4}"

# values are written into Apache and ModSecurity config, so accept only safe shapes
[[ "${PORT}" =~ ^[0-9]{1,5}$ ]] || { echo "invalid PORT" >&2; exit 1; }
[[ "${SERVER_NAME}" =~ ^[A-Za-z0-9.-]+$ ]] || { echo "invalid SERVER_NAME" >&2; exit 1; }
[[ "${BACKEND}" =~ ^https?://[A-Za-z0-9._:/-]+$ ]] || { echo "invalid BACKEND" >&2; exit 1; }
for v in "${PARANOIA}" "${BLOCKING_PARANOIA}" "${ANOMALY_INBOUND}" "${ANOMALY_OUTBOUND}"; do
    [[ "${v}" =~ ^[0-9]{1,3}$ ]] || { echo "invalid numeric setting: ${v}" >&2; exit 1; }
done
case "${MODSEC_RULE_ENGINE,,}" in
    on) rule_engine=On ;;
    off) rule_engine=Off ;;
    detectiononly) rule_engine=DetectionOnly ;;
    *) echo "invalid MODSEC_RULE_ENGINE" >&2; exit 1 ;;
esac

# user state lives on /config; the CRS install stays read-only under /app
mkdir -p /config/rules
if [[ ! -f /config/crs-setup.conf ]]; then
    cp /app/owasp-crs/crs-setup.conf.example /config/crs-setup.conf
fi

# runtime, data and temp paths are ephemeral
mkdir -p /tmp/apache2 /tmp/modsecurity/data /tmp/modsecurity/tmp /tmp/modsecurity/upload

# ID 900500 is UNVERIFIED as free in CRS 4.31; a duplicate ID stops Apache at start
cat > /tmp/apache2/rendered.conf <<EOF
Listen ${PORT}
ServerName ${SERVER_NAME}

ProxyPreserveHost On
ProxyPass / ${BACKEND%/}/
ProxyPassReverse / ${BACKEND%/}/

SecRuleEngine ${rule_engine}
SecDataDir /tmp/modsecurity/data
SecTmpDir /tmp/modsecurity/tmp
SecUploadDir /tmp/modsecurity/upload
SecAuditLog /dev/stdout

Include /config/crs-setup.conf
SecAction "id:900500,phase:1,pass,nolog,setvar:tx.detection_paranoia_level=${PARANOIA},setvar:tx.blocking_paranoia_level=${BLOCKING_PARANOIA},setvar:tx.inbound_anomaly_score_threshold=${ANOMALY_INBOUND},setvar:tx.outbound_anomaly_score_threshold=${ANOMALY_OUTBOUND}"
IncludeOptional /config/rules/*.conf
Include /app/owasp-crs/rules/*.conf
EOF

# foreground so the container lives with Apache, and logs go to stdout
exec /usr/sbin/apache2 -DFOREGROUND -f /etc/apache2/apache2.conf
