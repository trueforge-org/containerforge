#!/usr/bin/env bash

SERVER_DIR="${SERVER_DIR:-/config/serverfiles}"
SRV_ADR="${SRV_ADR:-https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/}"
mkdir -p "${SERVER_DIR}"

# First start (or missing runtime): download the artifact into /config, using /tmp as scratch.
# UNVERIFIED: the latest.txt index and the fx.tar.xz file layout are not confirmed against the artifact server.
# UNVERIFIED: no artifact checksum is verified here; the index publishes none that was fetched.
if [[ ! -x "${SERVER_DIR}/run.sh" ]]; then
    build="$(curl -fsSL "${SRV_ADR}latest.txt")" || exit 1
    scratch="$(mktemp -d /tmp/redm-XXXXXX)" || exit 1
    curl -fL -o "${scratch}/fx.tar.xz" "${SRV_ADR}${build}/fx.tar.xz" || exit 1
    tar -xJf "${scratch}/fx.tar.xz" -C "${SERVER_DIR}" || exit 1
    rm -rf "${scratch}"
fi

cd "${SERVER_DIR}" || exit 1

# UNVERIFIED: a licence key (for example sv_licenseKey) and txAdmin first-run setup are not wired in this draft.
# UNVERIFIED: run.sh as the entry point and its arguments; confirm from the extracted artifact.
exec "${SERVER_DIR}/run.sh"
