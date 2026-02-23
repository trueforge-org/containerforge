#!/usr/bin/env bash

set -euo pipefail

LISTEN_PORT=${LISTEN_PORT:-2222}
PASSWORD_ACCESS=${PASSWORD_ACCESS:-false}
UMASK=${UMASK:-022}

mkdir -p /config/{.ssh,logs/openssh,sshd,ssh_host_keys}

if [[ ! -f /config/sshd/sshd_config ]]; then
    cp /etc/ssh/sshd_config /config/sshd/sshd_config
fi

sed -i 's/Include \/etc\/ssh\/sshd_config.d\/\*.conf/#Include \/etc\/ssh\/sshd_config.d\/\*.conf/' /config/sshd/sshd_config
sed -i "s/^#Port .*/Port ${LISTEN_PORT}/; s/^Port .*/Port ${LISTEN_PORT}/" /config/sshd/sshd_config
sed -i "s|/usr/lib/ssh/sftp-server$|/usr/lib/ssh/sftp-server -u ${UMASK}|g" /config/sshd/sshd_config
sed -i '/^#PidFile/c\PidFile \/config\/sshd.pid' /config/sshd/sshd_config

if [[ "${PASSWORD_ACCESS}" == "true" ]]; then
    sed -i '/^#PasswordAuthentication/c\PasswordAuthentication yes' /config/sshd/sshd_config
    sed -i '/^PasswordAuthentication/c\PasswordAuthentication yes' /config/sshd/sshd_config
else
    sed -i '/^#PasswordAuthentication/c\PasswordAuthentication no' /config/sshd/sshd_config
    sed -i '/^PasswordAuthentication/c\PasswordAuthentication no' /config/sshd/sshd_config
fi

[[ -f /config/ssh_host_keys/ssh_host_rsa_key ]] || ssh-keygen -q -t rsa -b 4096 -N "" -f /config/ssh_host_keys/ssh_host_rsa_key
[[ -f /config/ssh_host_keys/ssh_host_ecdsa_key ]] || ssh-keygen -q -t ecdsa -b 521 -N "" -f /config/ssh_host_keys/ssh_host_ecdsa_key
[[ -f /config/ssh_host_keys/ssh_host_ed25519_key ]] || ssh-keygen -q -t ed25519 -N "" -f /config/ssh_host_keys/ssh_host_ed25519_key

touch /config/.ssh/authorized_keys
chmod 600 /config/ssh_host_keys/ssh_host_*_key /config/.ssh/authorized_keys
chmod 644 /config/ssh_host_keys/ssh_host_*_key.pub

SSH_HOST_KEYS=""
for key in /config/ssh_host_keys/ssh_host_*_key; do
    SSH_HOST_KEYS="${SSH_HOST_KEYS} -h ${key}"
done

exec /usr/sbin/sshd -D -e -f /config/sshd/sshd_config ${SSH_HOST_KEYS}
