# AnotherStranger/docker-borg-backup Dockerfile + entrypoint.sh (commit 2737b502e67417e06a791c10df33d38726df98dd)

Source URL(s) + date: https://raw.githubusercontent.com/AnotherStranger/docker-borg-backup/2737b502e67417e06a791c10df33d38726df98dd/Dockerfile ; .../entrypoint.sh (fetched 2026-11-27). The API contents URL from urls.txt was not called; the raw file at the same commit was used.

## Pinned versions (ARG, renovate-annotated)
| ARG | Value |
| --- | --- |
| BORGBACKUP_VERSION | 1.4.5 (pip) |
| OPENSSH_VERSION | 10.3_p1-r1 |
| SED / BASH / SHADOW | 4.9-r2 / 5.3.9-r1 / 4.18.0-r1 |
| OPENSSL_VERSION | 3.5.9-r0 |
| PKG_CONF / BUILD_BASE / LINUX_HEADERS | 2.5.1-r0 / 0.5-r4 / 7.0.0-r1 |
| ACL / XXHASH / ZSTD / LZ4 | 2.3.2-r1 / 0.8.3-r1 / 1.5.7-r2 / 1.10.0-r1 |

## Stages
- `base`: `FROM python:3.15.2-alpine3.24@sha256:20a82d...` (Alpine, musl).
- `builder`: apk build deps (pkgconf, openssl-dev, build-base, acl-dev, zstd-dev, lz4-dev, xxhash-dev, linux-headers); `pip wheel borgbackup==1.4.5 -w /wheel`.
- `runtime-image`: apk runtime (openssh-server, sed, bash, shadow, openssl, xxhash, acl, zstd, lz4, linux-headers plus -dev variants); `adduser -D -u 500 borg borg`; `pip install /wheel/*.whl`.

## Runtime
- LABELs: authors André Büsgen; title borg-server; source/url/documentation github AnotherStranger/docker-borg-backup.
- ENV defaults: BORG_SERVE_ADDITIONAL_ARGS="", BORG_UID="", BORG_GID="", ENSURE_BACKUP_PERMISSIONS=true.
- sshd config: PasswordAuthentication no, PermitRootLogin no, X11Forwarding no, LogLevel ERROR, ClientAliveInterval 10, ClientAliveCountMax 30.
- Dirs: /var/run/sshd, /var/backups/borg, /var/lib/docker-borg/ssh, /home/borg/.ssh (700, borg), /home/borg/backups.
- `VOLUME ["/home/borg/backups/", "/var/lib/docker-borg", "/home/borg/.ssh/"]`
- `EXPOSE 22`
- `CMD ["/entrypoint.sh"]` (no ENTRYPOINT, no USER: entrypoint runs as root).

## Entrypoint (entrypoint.sh, 86 lines)
- Randomises borg user password hash and unlocks account (usermod -p / -U).
- SSH host keys: `ssh-keygen -A` on first run, moved to /var/lib/docker-borg/ssh/, symlinked into /etc/ssh.
- BORG_UID -> `usermod -u`; BORG_GID -> `groupmod -o -g` and `usermod -g`.
- BORG_AUTHORIZED_KEYS (if set) written to /home/borg/.ssh/authorized_keys, each line prefixed with `restrict,command="borg serve ${BORG_SERVE_ADDITIONAL_ARGS} --restrict-to-path /home/borg/backups"`.
- ENSURE_BACKUP_PERMISSIONS=true: `chown -R borg:borg /home/borg/backups`.
- Ends with `exec /usr/sbin/sshd -D -e`.

## Env (summary)
| Env | Default | Use |
| --- | --- | --- |
| BORG_UID | "" | borg user UID |
| BORG_GID | "" | borg group GID |
| BORG_AUTHORIZED_KEYS | unset | authorized_keys content (restricted borg serve) |
| BORG_SERVE_ADDITIONAL_ARGS | "" | extra args to borg serve |
| ENSURE_BACKUP_PERMISSIONS | true | chown backups on start |

## Gotchas
- Container runs as root (sshd and usermod need root). Chart runAsUser 0 matches.
- Borg is installed with pip from source wheel (not a distro package).
