# ===== From ./processed/build-agent/root/etc/s6-overlay//s6-rc.d/init-adduser/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

USER_NAME=${USER_NAME:-jenkins}

PUID=${PUID:-911}
PGID=${PGID:-911}

if [[ "$USER_NAME" != "abc" ]]; then
    usermod -l "$USER_NAME" abc
    groupmod -n "$USER_NAME" abc
fi

groupmod -o -g "$PGID" "$USER_NAME"
usermod -o -u "$PUID" "$USER_NAME"

cat /etc/s6-overlay/s6-rc.d/init-adduser/branding

if [[ -f /donate.txt ]]; then
    echo '
To support the app dev(s) visit:'
    cat /donate.txt
fi
echo '
To support LSIO projects visit:
https://www.linuxserver.io/donate/

───────────────────────────────────────
GID/UID
───────────────────────────────────────'
echo "
User UID:    $(id -u "${USER_NAME}")
User GID:    $(id -g "${USER_NAME}")
───────────────────────────────────────"
if [[ -f /build_version ]]; then
    cat /build_version
    echo '
───────────────────────────────────────
    '
fi

lsiown "${USER_NAME}":"${USER_NAME}" /app
lsiown "${USER_NAME}":"${USER_NAME}" /config
lsiown "${USER_NAME}":"${USER_NAME}" /defaults

# ===== From ./processed/build-agent/root/etc/s6-overlay//s6-rc.d/init-build-agent-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# create folders
mkdir -p \
    /etc/docker \
    /config/{.ssh,ssh_host_keys,logs/openssh,logs/dockerd,var/lib/docker}

USER_NAME=${USER_NAME:-jenkins}
echo "User name is set to $USER_NAME"

USER_PASSWORD=${USER_PASSWORD:-$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c"${1:-8}";echo;)}
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

# symlink out ssh config directory
if [[ ! -L /etc/ssh ]]; then
    if [[ ! -f /config/ssh_host_keys/sshd_config ]]; then
        sed -i '/#PidFile/c\PidFile \/config\/sshd.pid' /etc/ssh/sshd_config
        cp -a /etc/ssh/sshd_config /config/ssh_host_keys/
    fi
    rm -Rf /etc/ssh
    ln -s /config/ssh_host_keys /etc/ssh
    ssh-keygen -A
fi

# custom port
if [[ -n "${LISTEN_PORT}" ]]; then
    sed -i "s/^#Port [[:digit:]]\+/Port ${LISTEN_PORT}"/ /etc/ssh/sshd_config
    sed -i "s/^Port [[:digit:]]\+/Port ${LISTEN_PORT}"/ /etc/ssh/sshd_config
    echo "sshd is listening on port ${LISTEN_PORT}"
else
    sed -i "s/^#Port [[:digit:]]\+/Port 2222"/ /etc/ssh/sshd_config
    sed -i "s/^Port [[:digit:]]\+/Port 2222"/ /etc/ssh/sshd_config
    echo "sshd is listening on port 2222"
fi

# password access
if [[ "$PASSWORD_ACCESS" == "true" ]]; then
    sed -i '/^#PasswordAuthentication/c\PasswordAuthentication yes' /etc/ssh/sshd_config
    sed -i '/^PasswordAuthentication/c\PasswordAuthentication yes' /etc/ssh/sshd_config
    chown root:"${USER_NAME}" \
        /etc/shadow
    echo "User/password ssh access is enabled."
else
    sed -i '/^PasswordAuthentication/c\PasswordAuthentication no' /etc/ssh/sshd_config
    chown root:root \
        /etc/shadow
    echo "User/password ssh access is disabled."
fi

# set umask for sftp
UMASK=${UMASK:-022}
sed -i "s|/usr/lib/ssh/sftp-server$|/usr/lib/ssh/sftp-server -u ${UMASK}|g" /etc/ssh/sshd_config

# set key auth in file
if [[ ! -f /config/.ssh/authorized_keys ]]; then
    touch /config/.ssh/authorized_keys
fi

if [[ -n "$PUBLIC_KEY" ]]; then
    if ! grep -q "${PUBLIC_KEY}" /config/.ssh/authorized_keys; then
        echo "$PUBLIC_KEY" >> /config/.ssh/authorized_keys
        echo "Public key from env variable added"
    fi
fi

if [[ -n "$PUBLIC_KEY_URL" ]]; then
    PUBLIC_KEY_DOWNLOADED=$(curl -s "$PUBLIC_KEY_URL")
    if ! grep -q "$PUBLIC_KEY_DOWNLOADED" /config/.ssh/authorized_keys; then
        echo "$PUBLIC_KEY_DOWNLOADED" >> /config/.ssh/authorized_keys
        echo "Public key downloaded from '$PUBLIC_KEY_URL' added"
    fi
fi

if [[ -n "$PUBLIC_KEY_FILE" ]] && [[ -f "$PUBLIC_KEY_FILE" ]]; then
    PUBLIC_KEY2=$(cat "$PUBLIC_KEY_FILE")
    if ! grep -q "$PUBLIC_KEY2" /config/.ssh/authorized_keys; then
        echo "$PUBLIC_KEY2" >> /config/.ssh/authorized_keys
        echo "Public key from file added"
    fi
fi

if [[ -d "$PUBLIC_KEY_DIR" ]]; then
    for F in "${PUBLIC_KEY_DIR}"/*; do
        PUBLIC_KEYN=$(cat "$F")
        if ! grep -q "$PUBLIC_KEYN" /config/.ssh/authorized_keys; then
            echo "$PUBLIC_KEYN" >> /config/.ssh/authorized_keys
            echo "Public key from file '$F' added"
        fi
    done
fi

# add log file info
if [[ ! -f /config/logs/loginfo.txt ]]; then
    echo "The current log file is named \"current\". The rotated log files are gzipped, named with a TAI64N timestamp and a \".s\" extension" > /config/logs/loginfo.txt
fi

# delete Docker PID if exists
find /run /var/run -iname 'docker*.pid' -delete || :

# create docker group and add abc to it
groupadd -f docker
if ! id -nG "$(id -nu "${PUID:-911}")" | grep -q "docker"; then
    usermod -aG docker "$(id -nu "${PUID:-911}")"
fi

HOME=/config git config --global user.email "ci@linuxserver.io"
HOME=/config git config --global user.name "LinuxServer-CI"

# Remove old Docker image store
if [[ -d "/config/var/lib/docker/overlay2/" ]]; then
    rm -rf "/config/var/lib/docker/overlay2/"
fi

if [[ -d "/config/var/lib/docker/image/" ]]; then
    rm -rf "/config/var/lib/docker/image/"
fi

# Enable containerd image store
cat <<EOF >/etc/docker/daemon.json
{
    "features": {
        "containerd-snapshotter": true
    }
}
EOF

# permissions
lsiown -R "${USER_NAME}":"${USER_NAME}" \
    /config
chmod go-w \
    /config
chmod 700 \
    /config/.ssh
chmod 600 \
    /config/.ssh/authorized_keys

# ===== From ./processed/build-agent/root/etc/s6-overlay//s6-rc.d/init-buildx-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

docker pull docker.io/moby/buildkit:buildx-stable-1
HOME=/config docker buildx rm container >/dev/null 2>&1
HOME=/config docker buildx create --driver docker-container --name container --bootstrap >/dev/null 2>&1
docker image prune -f >/dev/null 2>&1

USER_NAME=${USER_NAME:-jenkins}
lsiown -R "${USER_NAME}:${USER_NAME}" /config/.docker

# ===== From ./processed/build-agent/root/etc/s6-overlay//s6-rc.d/init-qemu/run =====
#!/usr/bin/with-contenv bash

echo "┌─────────────────────────────────────────────────────────────────────────────────┐"
echo "│                   Make sure you enable you enable QEMU. Run:                    │"
echo "│                                                                                 │"
echo "│ docker run --rm -it --privileged ghcr.io/linuxserver/qemu-static --reset -p yes │"
echo "│                                                                                 │"
echo "│                                   on the host                                   │"
echo "└─────────────────────────────────────────────────────────────────────────────────┘"

# ===== From ./processed/build-agent/root/etc/s6-overlay//s6-rc.d/svc-docker-in-docker/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# apparmor sucks and Docker needs to know that it's in a container (c) @tianon
export container=docker

if [[ -d /sys/kernel/security ]] && ! mountpoint -q /sys/kernel/security; then
	mount -t securityfs none /sys/kernel/security || {
		echo 'Could not mount /sys/kernel/security.'
		echo 'AppArmor detection and --privileged mode might break.'
	}
fi

# Mount /tmp (conditionally)
if ! mountpoint -q /tmp; then
	mount -t tmpfs none /tmp
fi

# cgroup v2: enable nesting
if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then
	# move the processes from the root group to the /init group,
	# otherwise writing subtree_control fails with EBUSY.
	# An error during moving non-existent process (i.e., "cat") is ignored.
	mkdir -p /sys/fs/cgroup/init
	xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
	# enable controllers
	sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers \
		> /sys/fs/cgroup/cgroup.subtree_control || :
fi

mount --make-rshared /

exec 2>&1 \
    s6-notifyoncheck -d -n 300 -w 1000 -c "docker version" \
    /usr/bin/dockerd --data-root "/config/var/lib/docker" --experimental

# ===== From ./processed/build-agent/root/etc/s6-overlay//s6-rc.d/svc-openssh-server/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

USER_NAME=${USER_NAME:-jenkins}

exec 2>&1 \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost ${LISTEN_PORT:-2222}" \
    s6-setuidgid "${USER_NAME}" /usr/sbin/sshd.pam -D -e

