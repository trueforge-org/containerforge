# ich777/docker-rapidphotodownloader scripts/start.sh

**Source URL(s):** https://raw.githubusercontent.com/ich777/docker-rapidphotodownloader/master/scripts/start.sh · fetched 2026-11-27

## Behaviour (as root)
1. `usermod -u ${UID} ${USER}`; `groupmod -g ${GID}` (errors ignored); `usermod -g ${GID}`.
2. `umask ${UMASK}`.
3. Runs optional `/opt/custom/user.sh` or `/opt/scripts/user.sh` (copied to `/opt/scripts/start-user.sh`).
4. `novnccheck`.
5. `chown -R root:${GID} /opt/scripts`; `chmod -R 750 /opt/scripts`.
6. `dbus-uuidgen > /var/lib/dbus/machine-id`; creates `/var/run/dbus`; chown/chmod 770.
7. `chown -R ${UID}:${GID} ${DATA_DIR}`.
8. Traps SIGTERM, then `su ${USER} -c "/opt/scripts/start-server.sh" &` (start-server.sh not fetched).

## Gotchas
- Needs root for usermod, groupmod, chown, dbus setup; then drops to `${USER}` via su.
- Not compatible with read-only rootfs or `USER apps` as-is.
