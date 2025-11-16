# ===== From ./processed/pylon/root/etc/s6-overlay//s6-rc.d/init-pylon-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# check for lock file to only run git operations once
if [[ ! -e /lock.file ]]; then
    # Give abc a sudo shell for development
    sed -e 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' \
        -i /etc/sudoers
    sed -e 's/^wheel:\(.*\)/wheel:\1,abc/g' -i /etc/group
    # create directory for project
    mkdir -p /code
    # make sure URL is set and folder is empty to clone code 
    if [[ ${GITURL+x} ]] && [[ ! "$(/bin/ls -A /code 2>/dev/null)" ]] ; then \
        # clone the url the user passed to this directory
        git clone "${GITURL}" /code
        lsiown -R abc:abc \
            /code
    else
        lsiown abc:abc \
            /code
    fi

else
    # lock exists not importing project this is a restart
    echo "Lock exists just starting pylon"
fi

# create lock file after first run
touch /lock.file

# permissions
mkdir -p /config/sessions

lsiown -R abc:abc \
    /config

# ===== From ./processed/pylon/root/etc/s6-overlay//s6-rc.d/svc-pylon/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ -n ${PYUSER+x} ]] && [[ -n ${PYPASS+x} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 3131" \
            cd /app/pylon s6-setuidgid abc \
            node server.js -l 0.0.0.0 -p 3131 -w /code \
            --username "${PYUSER}" --password "${PYPASS}"
elif [[ -z ${PYUSER+x} ]] && [[ -z ${PYPASS+x} ]]; then
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 3131" \
            cd /app/pylon s6-setuidgid abc \
            node server.js -l 0.0.0.0 -p 3131 -w /code
else
    echo "**** You must specify both PYUSER _and_ PYPASS or neither ****"
    echo "****         Starting without a username/password         ****"
    exec \
        s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost 3131" \
            cd /app/pylon s6-setuidgid abc \
            node server.js -l 0.0.0.0 -p 3131 -w /code
fi

