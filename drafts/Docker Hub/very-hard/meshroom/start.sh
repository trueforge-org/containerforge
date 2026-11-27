#!/bin/bash
set -euo pipefail

# /config holds user data and the SSH key list; /tmp holds ephemeral host keys and runtime files.
mkdir -p /config/meshroom /config/.config /config/.ssh /tmp/cache /tmp/ssh
chmod 700 /config/.ssh

# Host key is regenerated on each start because /etc is read-only.
if [[ ! -f /tmp/ssh/ssh_host_ed25519_key ]]; then
  ssh-keygen -q -t ed25519 -N "" -f /tmp/ssh/ssh_host_ed25519_key
fi

# Key-based login only, no root login and no fixed password.
# UNVERIFIED: non-root sshd with -D; check `sshd -t` and a real login in the build round.
cat > /tmp/ssh/sshd_config <<EOF
Port 2222
ListenAddress 0.0.0.0
HostKey /tmp/ssh/ssh_host_ed25519_key
PidFile /tmp/ssh/sshd.pid
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile /config/.ssh/authorized_keys
X11Forwarding yes
EOF

exec /usr/sbin/sshd -D -e -f /tmp/ssh/sshd_config
