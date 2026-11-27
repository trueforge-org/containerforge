# Source: ich777/docker-nwnee Dockerfile (master)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-nwnee/master/Dockerfile (fetched 2026-11-27; blob variant = same)

## Build
- `FROM ich777/debian-baseimage:bullseye_amd64` (amd64 only in tag name).
- LABEL authors (admin@minenet.at), source https://github.com/ich777/docker-nwnee.
- apt install (no-recommends): gcc-10 g++-10 default-libmysqlclient-dev libpq-dev libseccomp-dev ruby-dev ant libluajit-5.1-2 curl unzip mariadb-server screen redis-server jq libbsd0.
- Downloads libsndio6.1_1.1.0-3_amd64.deb from debian-archive.at.mirror.anexia.com (wget), dpkg -i, removes it.
- Removes /usr/share/man/man1 and apt lists.
- Build-time DB setup: starts mariadb, creates user nwnee (password nwnee) with DB nwnee; grants root@% password `nwneeroot`.
- `useradd -d $SERVER_DIR -s /bin/bash $USER`; chown SERVER_DIR.
- COPY /scripts/ -> /opt/scripts/, chmod -R 770.
- `ENTRYPOINT ["/opt/scripts/start.sh"]`. No EXPOSE, no USER, no HEALTHCHECK.

## Env vars (ENV defaults)
| Var | Default |
| --- | --- |
| SERVER_DIR | /nwnee |
| NWNEE_V | latest |
| MOD_NAME | "" |
| MAX_CLIENTS | 4 |
| MINLEVEL | 1 |
| MAXLEVEL | 40 |
| PAUSEAPLAY | 0 |
| PVP | 0 |
| SERVERVAULT | 0 |
| ELC | 0 |
| ILR | 0 |
| ONEPARTY | 0 |
| DIFF | 1 |
| AUTO_SAV_I | 5 |
| PPW | Docker |
| APWD | adminDocker |
| SRV_NAME | Docker NWN:EE |
| PUBLIC_SRV | 0 |
| RLD_W_E | 1 |
| GAME_PARAMS | "" |
| GAME_PORT | 5121 |
| LOG_LVL | 6 |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | nwnee |

## Runtime deps
- MariaDB, Redis, screen, jq, unzip, curl, libluajit, libseccomp, ruby.

## Gotchas
- start.sh runs `usermod -u ${UID}` and `groupmod`; root-start, chowns /var/lib/mysql, /var/run/mysqld, /var/lib/redis, /usr/bin/redis-*.
- Requires root at start (usermod, chown, mysqld).
- Build-time mariadb start inside RUN; creds are hard-coded.
