#!/usr/bin/env bash




# migration
rm -rf \
    /config/lsiopy \
    /config/.local/{bin,lib}

# Add apps user to python system install owner group, lsio (7310)
if ! id -G apps | grep -qw "7310"; then
    usermod -a -G lsio apps
fi
PUID=${PUID:-911}
PY_LOCAL_PATH=$(find /usr/local/lib -maxdepth 1 -name python* -type d)
PY_LOCAL_PATH="${PY_LOCAL_PATH%.bak}"
if [[ -d "${PY_LOCAL_PATH}.bak" ]]; then
    echo "**** New container detected, fixing python package permissions. This may take a while. ****"
    mv "${PY_LOCAL_PATH}.bak" "${PY_LOCAL_PATH}"
    chown -R apps:apps "${PY_LOCAL_PATH}"
fi
# set permissions
echo "Setting permissions"

    /config





if [[ -f "/mod-repo-packages-to-install.list" ]]; then
    IFS=' ' read -ra REPO_PACKAGES <<< "$(tr '\n' ' ' < /mod-repo-packages-to-install.list)"
    if [[ ${#REPO_PACKAGES[@]} -ne 0 ]] && [[ ${REPO_PACKAGES[*]} != "" ]]; then
        echo "[mod-init] **** Installing all mod packages ****"
        apk add --no-cache \
            "${REPO_PACKAGES[@]}"
    fi
fi

if [[ -f "/mod-pip-packages-to-install.list" ]]; then
    IFS=' ' read -ra PIP_PACKAGES <<< "$(tr '\n' ' ' < /mod-pip-packages-to-install.list)"
    if [[ ${#PIP_PACKAGES[@]} -ne 0 ]] && [[ ${PIP_PACKAGES[*]} != "" ]]; then
        echo "[mod-init] **** Installing all pip packages ****"
        python3 -m pip install \
            "${PIP_PACKAGES[@]}"
    fi
fi

rm -rf \
    /mod-repo-packages-to-install.list \
    /mod-pip-packages-to-install.list





PY_LOCAL_PATH=$(find /usr/local/lib -maxdepth 1 -name python* -type d)
PY_LOCAL_BIN=$(basename "${PY_LOCAL_PATH}")
if capsh --has-p=cap_net_admin 2>/dev/null && capsh --has-p=cap_net_raw 2>/dev/null; then
  echo "Adding cap_net_admin and cap_net_raw to python binary for bt access"
  setcap 'cap_net_bind_service,cap_net_raw,cap_net_admin=+ep' "/usr/local/bin/${PY_LOCAL_BIN}"
else
  setcap 'cap_net_bind_service=+ep' "/usr/local/bin/${PY_LOCAL_BIN}"
fi

if [[ -z "${DISABLE_JEMALLOC+x}" ]]; then
  export LD_PRELOAD="/usr/local/lib/libjemalloc.so.2"
  export MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:20000,muzzy_decay_ms:20000"
fi

exec \
    
     python3 -m homeassistant -c /config

