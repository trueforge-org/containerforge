#!/bin/bash
set -euo pipefail

# Server files live in /config (persistent). /app stays read-only.
DATA="/config/vintagestory"
mkdir -p "${DATA}/data"

channel="${VS_CHANNEL:-stable}"
# UNVERIFIED: feed is plain http as in the plan; https was not tested
json="$(curl -fsSL "http://api.vintagestory.at/${channel}.json")"
latest="$(printf '%s' "${json}" | jq -r 'keys_unsorted[0]')"
version="${STATIC_V:-${latest}}"
url="$(printf '%s' "${json}" | jq -r --arg v "${version}" '.[$v].linuxserver.urls.cdn // empty')"

if [ ! -f "${DATA}/installed-${version}" ]; then
  if [ -z "${url}" ]; then
    echo "no linux server download found for version ${version}" >&2
    exit 1
  fi
  tarball="/tmp/vs-${version}.tar.gz"
  curl -fL -o "${tarball}" "${url}"
  tar -xzf "${tarball}" -C "${DATA}"
  rm -f "${tarball}"
  touch "${DATA}/installed-${version}"
fi

cd "${DATA}"
# shellcheck disable=SC2086
# UNVERIFIED: launcher name and dotnet invocation are taken from the ich777 wrapper and not checked in the tarball yet
exec dotnet VintagestoryServer.dll --dataPath "${DATA}/data" ${GAME_PARAMS:-}
