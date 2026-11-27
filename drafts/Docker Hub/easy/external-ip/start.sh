#!/usr/bin/env bash
# Own loop, replacing upstream scripts/start.sh (saved-IP path moved to /config, case handling fixed).
# Uses the upstream provider and notify libraries from /app/scripts/lib.
# No exec: this is a loop. tini (PID 1) forwards signals, and the trap ends the loop.
# No "set -u": the sourced upstream notify.sh reads unset NOTIFICATION_TYPE and *_TITLE variables.
set -o pipefail

trap 'exit 0' TERM INT

source /app/scripts/lib/ipv4.sh
source /app/scripts/lib/notify.sh

old_ip=0
recovery=0
sleep_for="5m"
recoveryAlert="[RECOVERY]"
changeAlert="[CHANGE]"
savedIPFile="/config/ip.saved"
regex='^([0-9]+[dsmh]?)$'

if [[ "${DELAY:-}" =~ ${regex} ]]; then
  sleep_for="${DELAY}"
else
  echo "Bad parameter for DELAY, using default ${sleep_for}..."
fi

# Saving is only done when SAVE_IP is true (any case), the same test that loads it.
save_ip=false
[[ "${SAVE_IP:-}" =~ ^[Tt][Rr][Uu][Ee]$ ]] && save_ip=true
if $save_ip && [ -f "${savedIPFile}" ]; then
  old_ip=$(tr -d ' \t\n\r' < "${savedIPFile}")
fi

while :; do
  case "${PROVIDER:-CLOUDFLARE}" in
    GOOGLE) ip=$(google_ipv4) ;;
    OPENDNS) ip=$(opendns_ipv4) ;;
    IPIFY) ip=$(ipify_ipv4) ;;
    *) ip=$(cloudflare_ipv4) ;;
  esac

  if valid_ipv4 "${ip}"; then
    if [[ "${old_ip}" != "${ip}" || ${recovery} == 1 ]]; then
      old_ip="${ip}"
      if [[ ${recovery} == 1 ]]; then
        echo -e "IP: ${ip} ${recoveryAlert}"
        if [[ "${RECOVERY_ALERT:-}" =~ ^[Tt][Rr][Uu][Ee]$ ]]; then
          notify "IP: ${ip} ${recoveryAlert}"
        fi
      else
        echo -e "IP: ${ip} ${changeAlert}"
        notify "IP: ${ip} ${changeAlert}"
      fi
    else
      echo -e "IP: ${ip}"
    fi
    if $save_ip; then
      printf '%s\n' "${ip}" > "${savedIPFile}"
    fi
    recovery=0
  else
    echo -e "\n[Error or Invalid IP address]"
    recovery=1
  fi

  # Background sleep plus wait, so TERM is handled while sleeping.
  # OPEN (decide before PR): upstream notify.sh passes the Pushover token and Apprise URLs as arguments,
  # which show in the process list. That behaviour is inherited from the fetched library and is not changed here.
  sleep "${sleep_for}" & wait $!
done
