# Difegue/LANraragi tools/build/docker/Dockerfile (commit add16039)

Source URL(s): https://raw.githubusercontent.com/Difegue/LANraragi/add16039b89726afa1cdd92b6dab548191bac987/tools/build/docker/Dockerfile (blob: https://github.com/Difegue/LANraragi/blob/add16039b89726afa1cdd92b6dab548191bac987/tools/build/docker/Dockerfile). Fetched 2026-11-26. Header comment: DOCKER-VERSION 0.3.4.

## Base / labels
- Single stage `FROM alpine:3.20`; LABEL git=https://github.com/Difegue/LANraragi
- ARG `INSTALL_PARAMETER` (no default)

## ENV
- S6_KEEP_ENV=1, S6_BEHAVIOUR_IF_STAGE2_FAILS=1, S6_KILL_GRACETIME=10000, S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0
- LC_ALL/LANG/LANGUAGE=en_US.UTF-8
- LRR_UID=9001, LRR_GID=9001, LRR_NETWORK=http://*:3000
- EV_EXTRA_DEFS=-DEV_NO_ATFORK, MOJO_PROXY=1, MOJO_REVERSE_PROXY=1, LRR_AUTOFIX_PERMISSIONS=1

## RUN
- User: if group 9001 exists -> `adduser -D -u ${LRR_UID} koyomi`; else `addgroup -g ${LRR_GID} koyomi` then `adduser -D -u ${LRR_UID} -G koyomi koyomi`
- Install as ROOT: `sh ./tools/install-everything.sh $INSTALL_PARAMETER` (script contents not shown; apk/cpan/npm lists not visible here)

## Layout
- WORKDIR `/home/koyomi/lanraragi`
- COPY (chown koyomi): `tools/cpanfile`, `tools/install.pl`, `tools/build/docker/install-everything.sh`, `package.json`, `package-lock.json`; after install: `lib`, `public`, `script`, `templates`, `locales`, `tests`, `lrr.conf`; `tools/build/docker/redis.conf`
- COPY (no chown): `tools/build/docker/wsl.conf` -> `/etc/wsl.conf`; `s6/s6-rc.d/` -> `/etc/s6-overlay/s6-rc.d/`; `s6/cont-init.d/01-lrr-setup` -> `/etc/s6-overlay/s6-rc.d/init/`

## Entrypoint / ports / volumes
- No USER (install and runtime as root; s6 drops privileges)
- VOLUME: `/home/koyomi/lanraragi/content`, `.../thumb`, `.../database`, `.../lib/LANraragi/Plugin/Sideloaded`
- EXPOSE 3000
- ENTRYPOINT `["//init"]` (s6-overlay from Alpine package), no CMD
- HEALTHCHECK interval 1m, timeout 10s, retries 3: `wget --quiet --tries=1 --no-check-certificate --spider -Y off http://127.0.0.1:3000 || exit 1`
