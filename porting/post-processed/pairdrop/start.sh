#!/usr/bin/env bash
# NONROOT_COMPAT
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  shopt -s expand_aliases
  alias apk=':'
  alias apt-get=':'
  alias chown=':'
  alias chmod=':'
  alias usermod=':'
  alias groupadd=':'
  alias adduser=':'
  alias useradd=':'
  alias setcap=':'
  alias mount=':'
  alias sysctl=':'
  alias service=':'
  alias s6-svc=':'
fi

if [[ ${RATE_LIMIT,,} = "true" ]]; then
    OPT_RATE_LIMIT="--rate-limit"
fi

if [[ ${WS_FALLBACK,,} = "true" ]]; then
    OPT_WS_FALLBACK="--include-ws-fallback"
fi


HOME=/config

cd /app
exec npm start -- "${OPT_RATE_LIMIT}" "${OPT_WS_FALLBACK}"
