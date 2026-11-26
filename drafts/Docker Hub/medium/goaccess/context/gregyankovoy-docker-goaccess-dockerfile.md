# gregyankovoy/docker-goaccess (Dockerfile @ efd688b)

Source URL(s): https://github.com/gregyankovoy/docker-goaccess/blob/efd688be8b6ae2991209e76de4908860a3350297/Dockerfile (raw fetched: https://raw.githubusercontent.com/gregyankovoy/docker-goaccess/efd688be8b6ae2991209e76de4908860a3350297/Dockerfile)
Date: fetched 2026-11-26

## What it is
- Alpine image: GoAccess (log analyzer) behind nginx (serves HTML report + websockets). Dockerized community build (not upstream).

## Build (Dockerfile @ efd688b)
- Single stage: `FROM gregyankovoy/alpine-base`. No ENV. No ARG in Dockerfile body beyond:
  - build_deps: build-base ncurses-dev autoconf automake git gettext-dev libmaxminddb-dev
  - runtime_deps: nginx tini ncurses libintl libmaxminddb
  - geolite_city_link, geolite_version: placeholders "filled in by the build agent"
- WORKDIR `/goaccess`.
- RUN: download GoAccess **v1.4** tarball from allinurl/goaccess (`archive/v1.4.tar.gz`, top dir stripped); `apk add` build deps; `autoreconf -fiv`; `./configure --enable-utf8 --enable-geoip=mmdb`; `make`; `make install`; remove `/tmp/goaccess/*` and `/goaccess`; `apk del` build deps.
- Runtime: apk add runtime deps; mkdir `/usr/local/share/GeoIP`; download GeoLite city archive from geolite_city_link and extract (strip 1).
- `chmod +x /usr/local/bin/goaccess.sh`; `chmod -R 777 /var/tmp/nginx`.
- COPY `/root` -> `/`.
- `EXPOSE 7889`; `VOLUME ["/config", "/opt/log"]`; `CMD sh /usr/local/bin/goaccess.sh` (shell form).
- No USER (root), no ENTRYPOINT, no HEALTHCHECK.
- goaccess.sh not fetched (starts nginx + goaccess under tini per plan; flags unknown).

## Runtime deps
- nginx, tini, ncurses, libintl, libmaxminddb (GeoIP mmdb). GeoLite city DB (download, licence-bound).

## Env vars
- None in Dockerfile. Docker Hub description: optional PUID, PGID.

## Ports
- 7889/tcp (EXPOSE; nginx front; docker run `-p 7889:7889`).

## Volumes/paths
| Path | Use |
| --- | --- |
| `/config` | reports + config/generated files |
| `/opt/log` | input logs (nginx logs dir, read) |
| `/var/tmp/nginx` | nginx temp (chmod 777) |
| `/usr/local/share/GeoIP` | GeoLite DB |

## User/UID
- root (no USER). Optional PUID/PGID per Docker Hub description.

## Config files
- goaccess.conf under /config (not fetched; goaccess man: system config `%sysconfdir%/goaccess.conf`, user `~/.goaccessrc`).

## Healthcheck
- None.

## Version/asset naming
- Builds GoAccess v1.4 (stale). Tag used by plan: v1.12.

## Arch
- Alpine/musl, amd64 on Docker Hub.

## Gotchas
- Pinned Dockerfile builds v1.4 from 2020; do not copy the build.
- GeoLite download URL is build-arg placeholder in source (not resolved).
