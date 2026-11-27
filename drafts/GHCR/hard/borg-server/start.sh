#!/usr/bin/env bash
# Adapted from AnotherStranger/docker-borg-backup entrypoint.sh (Apache-2.0).
# Rewritten for rootless operation: no usermod, groupmod, chown or password changes.
# UNVERIFIED: BORG_UID, BORG_GID and ENSURE_BACKUP_PERMISSIONS are not applied. Repos must be owned by apps.
set -eu

install -d -m 0700 /config/ssh /config/.ssh
install -d -m 0755 /config/backups

# Host key: generated once, only when missing.
if [ ! -s /config/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -q -t ed25519 -N "" -f /config/ssh/ssh_host_ed25519_key
fi

# authorized_keys: written only when BORG_AUTHORIZED_KEYS is set. Each key is restricted to borg serve.
if [ -n "${BORG_AUTHORIZED_KEYS:-}" ]; then
    tmp="$(mktemp /tmp/authorized_keys.XXXXXX)"
    while IFS= read -r line; do
        case "${line}" in
            ""|\#*) printf '%s\n' "${line}" ;;
            *) printf 'restrict,command="borg serve %s --restrict-to-path /config/backups" %s\n' \
                "${BORG_SERVE_ADDITIONAL_ARGS:-}" "${line}" ;;
        esac
    done <<< "${BORG_AUTHORIZED_KEYS}" > "${tmp}"
    install -m 0600 "${tmp}" /config/.ssh/authorized_keys
    rm -f "${tmp}"
fi

exec /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config
