# pi-hole/docker-pi-hole src/Dockerfile

**Source URL(s):** https://raw.githubusercontent.com/pi-hole/docker-pi-hole/7a8d396/src/Dockerfile · fetched 2026-11-27 (pinned commit 7a8d396)

## What it is
Official Pi-hole v6 image (upstream of `ghcr.io/pi-hole/pihole` and `pihole/pihole`). Multi-stage, FTL selectable via `FTL_SOURCE`.

## Build
- Base: `alpine:3.24.3@sha256:be265606...` (AS base).
- ARGs: `FTL_SOURCE=remote` (values `remote` | `local`), `WEB_BRANCH`/`CORE_BRANCH`/`FTL_BRANCH` = `development`, `PIHOLE_DOCKER_TAG=dev-localbuild`, `PADD_BRANCH=development`, forks `pi-hole`, `PIHOLE_UID=1000`, `PIHOLE_GID=1000`.
- apk: bash, bash-completion, bind-tools, binutils, coreutils, curl, git, grep, iproute2, jq, libcap, logrotate, ncurses, procps-ng, psmisc, setpriv, shadow, tzdata, unzip, wget.
- ADD macvendor.db from https://ftl.pi-hole.net/macvendor.db; ADD padd.sh from PADD repo.
- Clones web (`/var/www/html/admin`) and core (`/etc/.pihole`) from GitHub. If branch is `master`, clones latest release tag via api.github.com releases/latest.
- Creates user/group `pihole` (`addgroup -S pihole -g ${PIHOLE_GID}`, `adduser -S pihole -G pihole -u ${PIHOLE_UID}`).
- Installs scripts to /opt/pihole, `pihole` to /usr/local/bin, logrotate config to /etc/logrotate.d/pihole.
- git `safe.directory` set system-wide for /etc/.pihole and /var/www/html/admin.
- Copies `bash_functions.sh`, `prefix-time.sh`, `start.sh` (to /usr/bin), `crontab.txt` (to /).

## FTL install stages
- `remote-ftl-install`: `curl` `pihole-FTL-${FTLARCH}`. If FTL_BRANCH=master: `https://github.com/pi-hole/ftl/releases/latest/download/`; else `https://ftl.pi-hole.net/${FTL_BRANCH}/`.
- FTLARCH map: amd64, 386, armv6, armv7, arm64, riscv64 (default amd64).
- `local-ftl-install`: COPY `pihole-FTL` from build context.

## Runtime
- ENV DNSMASQ_USER=pihole, FTL_CMD=no-daemon.
- ENTRYPOINT `["start.sh"]` (in PATH via /usr/bin).

## Ports
- EXPOSE 53, 53/udp, 67/udp, 80, 123/udp, 443.

## Healthcheck
- `dig -p $(pihole-FTL --config dns.port) +short +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1`

## Gotchas
- Nightly tag installs gdb/screen only when PIHOLE_DOCKER_TAG=nightly.
- Image is built as root; the unprivileged `pihole` user is used by updatecheck.sh (GHSA-xch2-4qxw-g5vj).
