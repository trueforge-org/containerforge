# ich777/docker-fivem-server scripts/start.sh (entrypoint)

Source URL(s): https://raw.githubusercontent.com/ich777/docker-fivem-server/master/scripts/start.sh (fetched 2026-11-27)

## What it does (in order)
1. `usermod -u ${UID} ${USER}`; `groupmod -g ${GID}` (fallback ignored); `usermod -g ${GID}`.
2. `umask ${UMASK}`.
3. Runs optional `/opt/custom/user.sh` or `/opt/scripts/user.sh` as `start-user.sh` if present.
4. `chown -R root:${GID} /opt/scripts`; `chmod -R 750 /opt/scripts`; `chown -R ${UID}:${GID} ${DATA_DIR}`.
5. Traps SIGTERM, runs `su ${USER} -c "/opt/scripts/start-server.sh"` in background, waits on it, exits 0.

## Gotchas
- Must start as root (usermod/chown). Not compatible with `USER apps` or non-root runtime as shipped.
- Calls `/opt/scripts/start-server.sh` (not fetched; not in URL list).
- Shuts down via SIGTERM trap; exit code 143 on TERM path.
