#!/usr/bin/env bash
set -euo pipefail

export HOME=/config

DROPBOX_BIN_DIR=/config/bin
DROPBOX_TMP_DIR=/tmp/dropbox
DROPBOX_DOWNLOAD_URL="https://www.dropbox.com/download/?plat=lnx.x86_64"

mkdir -p /config/Dropbox /config/.dropbox "${DROPBOX_BIN_DIR}" "${DROPBOX_TMP_DIR}"

# Runtime files left behind by an unclean stop (same list as the upstream entrypoint).
for f in command_socket iface_socket unlink.db dropbox.pid; do
    rm -f "/config/.dropbox/${f}"
done

# The redirect target is the versioned tarball, e.g. .../dropbox-lnx.x86_64-<version>.tar.gz
get_download_location() {
    curl -sI "${DROPBOX_DOWNLOAD_URL}" | tr -d '\r' | sed -n 's/^[Ll]ocation: //p' | head -n 1
}

install_daemon() {
    local url="$1" tmp_dir
    tmp_dir="$(mktemp -d "${DROPBOX_TMP_DIR}/install.XXXXXX")"
    curl -fL -o "${tmp_dir}/dropbox.tar.gz" "${url}"
    tar xzf "${tmp_dir}/dropbox.tar.gz" -C "${tmp_dir}"
    rm -rf "${DROPBOX_BIN_DIR:?}"/*
    mv "${tmp_dir}"/.dropbox-dist/* "${DROPBOX_BIN_DIR}/"
    rm -rf "${tmp_dir}"
    # Locked directory so the daemon cannot self-update in place (same idea as upstream).
    install -dm0 /config/.dropbox-dist
}

local_version=""
if [ -f "${DROPBOX_BIN_DIR}/VERSION" ]; then
    local_version="$(cat "${DROPBOX_BIN_DIR}/VERSION")"
fi

if [ ! -x "${DROPBOX_BIN_DIR}/dropboxd" ]; then
    location="$(get_download_location || true)"
    if [ -z "${location}" ]; then
        echo "Error: could not resolve the Dropbox download URL. The daemon is needed on first start." >&2
        exit 1
    fi
    echo "Installing the Dropbox daemon from ${location}"
    install_daemon "${location}"
elif [ -z "${DROPBOX_SKIP_UPDATE:-}" ]; then
    location="$(get_download_location || true)"
    remote_version="$(printf '%s' "${location}" | sed -n 's/.*x86_64-\([0-9][0-9.]*\)\.tar\.gz.*/\1/p')"
    if [ -n "${remote_version}" ] && [ "${remote_version}" != "${local_version}" ]; then
        echo "Updating the Dropbox daemon from ${local_version:-unknown} to ${remote_version}"
        install_daemon "${location}"
    fi
fi

cd /config
exec "${DROPBOX_BIN_DIR}/dropboxd"
