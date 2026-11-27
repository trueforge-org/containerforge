# AnalogJ/scrutiny docker/Dockerfile (commit 3ae9db2)

Source URL(s) + date:
- https://raw.githubusercontent.com/AnalogJ/scrutiny/3ae9db201f5c51751d4b6779593f90144a128bf0/docker/Dockerfile (fetched 2026-11-27)
- https://github.com/AnalogJ/scrutiny/releases/latest (redirect, fetched 2026-11-27) -> tag v0.10.0

## What it is
- Scrutiny omnibus image: web UI + collector + InfluxDB 2 + smartmontools, run under s6.

## Build stages
1. `frontendbuild` (node): `make binary-frontend` on webapp/frontend
2. `backendbuild` (golang:1.27-trixie): `make binary-clean binary-all WEB_BINARY_NAME=scrutiny COLLECTOR_BINARY_NAME=scrutiny-collector-metrics GOOS=$TARGETOS GOARCH=$TARGETARCH`; installs `file`
3. `smartmontoolsbuild` (debian:trixie-slim): smartmontools SMARTMONTOOLS_VER=7.5 from GitHub release tarball `RELEASE_7_5`; configure `--prefix=/usr LDFLAGS='-static' --without-libcap-ng --without-libsystemd`; `update-smart-drivedb`
4. `runtime` (debian:trixie-slim):
   - EXPOSE 8080; WORKDIR /opt/scrutiny; PATH += /opt/scrutiny/bin
   - ENV INFLUXD_CONFIG_PATH=/opt/scrutiny/influxdb, S6VER=3.1.6.2, INFLUXVER=2.8.0, S6_SERVICES_READYTIME=1000
   - apt: ca-certificates cron curl tzdata procps xz-utils
   - s6-overlay v3.1.6.2 noarch + arch tarball (x86_64 for amd64, aarch64 for arm64) from GitHub just-containers
   - InfluxDB: `influxdb2_2.8.0-1_${TARGETARCH}.deb` from dl.influxdata.com, `dpkg -i --force-all`
   - `COPY /rootfs /`; copies smartctl + /usr/share/smartmontools from smartmontoolsbuild
   - Binaries: /opt/scrutiny/bin/scrutiny, /opt/scrutiny/bin/scrutiny-collector-metrics; web assets /opt/scrutiny/web (from frontend dist)
   - chmod: /etc/cron.d/scrutiny 0644; removes /etc/cron.daily/*; /opt/scrutiny/config ugo+rwx; cont-init.d and services.d run/finish executable
   - CMD ["/init"]

## Runtime deps
- s6-overlay 3.1.6.2, InfluxDB 2.8.0 (deb), cron, smartctl (static build 7.5), tzdata, procps

## Entrypoint/flags
- `/init` (s6). Collector run via cron (`/etc/cron.d/scrutiny`; schedule set via COLLECTOR_CRON_SCHEDULE per chart).

## Ports
- 8080 (web UI in image); chart maps 10151 -> 8080.

## Volumes/paths
- /opt/scrutiny/config (config), /opt/scrutiny/influxdb (INFLUXD_CONFIG_PATH), /opt/scrutiny/web, /opt/scrutiny/bin

## User/UID
- Root (no USER directive in Dockerfile). Chart runs as root.

## Version/asset naming
- Smartmontools: `RELEASE_<ver with _>/smartmontools-<ver>.tar.gz`
- s6: `v<S6VER>/s6-overlay-noarch.tar.xz`, `s6-overlay-<arch>.tar.xz`
- Influx: `influxdb2_<INFLUXVER>-1_<arch>.deb`

## Arch
- TARGETARCH amd64 -> x86_64, arm64 -> aarch64 for s6 (case statement only handles these two; other arches have empty S6_ARCH).

## Healthcheck
- None in Dockerfile. Chart probes use `/api/health`.

## Gotchas
- SMART access needs SYS_RAWIO/SYS_ADMIN and host device paths at runtime (chart), not at build time.
- `dpkg -i --force-all` used for influxdb deb.
- Backend stage uses golang:1.27-trixie (Go build stage: see go-runtime instruction).
