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

# Pass gpu flags if mounted
if ls /dev/dri/renderD* 1> /dev/null 2>&1 && [ -z ${DISABLE_DRI+x} ] && ! which nvidia-smi; then
  HW3D="-hw3d"
fi
if [ -z ${DRINODE+x} ]; then
  DRINODE="/dev/dri/renderD128"
fi

# Use a default resolution if unset
if [ -z ${RESOLUTION+x} ]; then
  RESOLUTION="1920x1080"
fi

exec  \
  /usr/local/bin/Xvnc $DISPLAY \
    ${HW3D} \
    -PublicIP 127.0.0.1 \
    -drinode ${DRINODE} \
    -disableBasicAuth \
    -SecurityTypes None \
    -AlwaysShared \
    -http-header Cross-Origin-Embedder-Policy=require-corp \
    -http-header Cross-Origin-Opener-Policy=same-origin \
    -geometry ${RESOLUTION} \
    -sslOnly 0 \
    -RectThreads 0 \
    -websocketPort 6901 \
    -interface 0.0.0.0 \
    -Log *:stdout:10

