# Source: ich777/docker-nwnee scripts/start.sh (master)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-nwnee/master/scripts/start.sh (fetched 2026-11-27)

## Behaviour (ordered)
1. `usermod -u ${UID} ${USER}`; `groupmod -g ${GID}`; `usermod -g ${GID}`.
2. `umask ${UMASK}`.
3. Optional user script: cp /opt/custom/user.sh or /opt/scripts/user.sh to /opt/scripts/start-user.sh; run if present (errors logged, not fatal).
4. chown -R root:${GID} /opt/scripts; chmod 750; chown ${UID}:${GID} on /var/lib/mysql, /var/run/mysqld, /var/lib/redis, /usr/bin/redis-server, /usr/bin/redis-cli, ${SERVER_DIR}; chmod 770 on mysql and mysqld run dirs.
5. Installs trap for SIGTERM: stops screen session `nwnee` via `screen -X stuff 'exit^M'`.
6. Runs `su ${USER} -c /opt/scripts/start-server.sh &` and waits.

## Gotchas
- Start script needs root (usermod/chown/su).
- Runs as root then su to USER.

## Related
- Sub-script start-server.sh: see ich777-docker-nwnee-start-server-sh.md.
