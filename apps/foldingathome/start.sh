# ===== From ./processed/foldingathome/root/etc/s6-overlay//s6-rc.d/init-foldingathome-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# permissions on config root and folders


# ===== From ./processed/foldingathome/root/etc/s6-overlay//s6-rc.d/init-foldingathome-video/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# ===== From ./processed/foldingathome/root/etc/s6-overlay//s6-rc.d/svc-foldingathome/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -n "${ACCOUNT_TOKEN}" ]] && [[ -n "${MACHINE_NAME}" ]]; then
    TOKEN_AND_NAME="--account-token ${ACCOUNT_TOKEN} --machine-name ${MACHINE_NAME}"
else
    echo '
***************************************************************************
***************************************************************************
****                                                                   ****
****                                                                   ****
****    On first run, both the ACCOUNT_TOKEN and the MACHINE_NAME      ****
**** env vars are required. Please set them and recreate the container ****
****    unless the instance was previously added to online account.    ****
****                                                                   ****
****                                                                   ****
***************************************************************************
***************************************************************************
'
fi


exec \
            cd /config /app/fah-client \
            --http-addresses 0.0.0.0:7396 --allow 0/0 ${TOKEN_AND_NAME} \
            ${CLI_ARGS}

