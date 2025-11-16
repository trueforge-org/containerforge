# ===== From ./processed/foldingathome/root/etc/s6-overlay//s6-rc.d/init-foldingathome-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# permissions on config root and folders
lsiown -R abc:abc \
    /config

# ===== From ./processed/foldingathome/root/etc/s6-overlay//s6-rc.d/init-foldingathome-video/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

FILES=$(find /dev/dri /dev/dvb -type c -print 2>/dev/null)

for i in $FILES
do
    VIDEO_GID=$(stat -c '%g' "${i}")
    VIDEO_UID=$(stat -c '%u' "${i}")
    # check if user matches device
    if id -u abc | grep -qw "${VIDEO_UID}"; then
        echo "**** permissions for ${i} are good ****"
    else
        # check if group matches and that device has group rw
        if id -G abc | grep -qw "${VIDEO_GID}" && [ $(stat -c '%A' "${i}" | cut -b 5,6) = "rw" ]; then
            echo "**** permissions for ${i} are good ****"
        # check if device needs to be added to video group
        elif ! id -G abc | grep -qw "${VIDEO_GID}"; then
            # check if video group needs to be created
            VIDEO_NAME=$(getent group "${VIDEO_GID}" | awk -F: '{print $1}')
            if [ -z "${VIDEO_NAME}" ]; then
                VIDEO_NAME="video$(head /dev/urandom | tr -dc 'a-z0-9' | head -c4)"
                groupadd "${VIDEO_NAME}"
                groupmod -g "${VIDEO_GID}" "${VIDEO_NAME}"
                echo "**** creating video group ${VIDEO_NAME} with id ${VIDEO_GID} ****"
            fi
            echo "**** adding ${i} to video group ${VIDEO_NAME} with id ${VIDEO_GID} ****"
            usermod -a -G "${VIDEO_NAME}" abc
        fi
        # check if device has group rw
        if [ $(stat -c '%A' "${i}" | cut -b 5,6) != "rw" ]; then
            echo -e "**** The device ${i} does not have group read/write permissions, attempting to fix inside the container. ****"
            chmod g+rw "${i}"
        fi
    fi
done

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
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 7396" \
        cd /config s6-setuidgid abc /app/fah-client \
            --http-addresses 0.0.0.0:7396 --allow 0/0 ${TOKEN_AND_NAME} \
            ${CLI_ARGS}

