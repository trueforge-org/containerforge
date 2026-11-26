# Sagit-chu/mosdns-container (third-party Dockerfile behind Docker Hub 601096721/mosdns)

**Source URL(s) + fetch date:** https://github.com/Sagit-chu/mosdns-container/blob/HEAD/Dockerfile (fetched via https://raw.githubusercontent.com/Sagit-chu/mosdns-container/HEAD/Dockerfile) · fetched 2026-11-26

## What it is
Community Dockerfile that builds the image `601096721/mosdns` (also `sagit.io/601096721/mosdns`). Not upstream; not the ContainerForge build.

## Install/build steps and build deps
- Stage 1 `golang:alpine` (pinned to TARGETPLATFORM): build args `CGO_ENABLED` (default 0), `TAG`, `REPOSITORY`. Installs git via apk, clones `https://github.com/${REPOSITORY}`, checks out `tags/${TAG}`, runs `go build` with `-trimpath -ldflags "-s -w -X main.version=${TAG}"`, output `mosdns`.
- Stage 2 `alpine:latest` (pinned to TARGETPLATFORM): copies `/root/mosdns/mosdns` to `/usr/bin/`; installs `ca-certificates`; creates `/etc/mosdns`.
- Adds files: `entrypoint.sh` -> `/entrypoint.sh`, `config.yaml` -> `/config.yaml`, `hosts` -> `/hosts`.
- Remote ADDs (rule lists): China IP list (IceCodeNew/4Share `china_ip_list.txt`) -> `/geoip_cn.txt`; Loyalsoldier `reject-list.txt` -> `/geosite_category-ads-all.txt`; `proxy-list.txt` -> `/geosite_geolocation-!cn.txt`; `direct-list.txt` -> `/geosite_cn.txt`. Commented-out ADDs for Loyalsoldier `geoip.dat` / `geosite.dat`.

## Runtime deps
ca-certificates (alpine).

## Binaries/entrypoint/CLI flags
- Binary `/usr/bin/mosdns`.
- ENTRYPOINT none; CMD `["sh", "/entrypoint.sh"]`.

## Env vars
None declared.

## Ports
EXPOSE 53/udp and 53/tcp.

## Volumes/paths and persistent data
VOLUME `/etc/mosdns`. Config built into image at `/config.yaml`; rule lists at root paths above.

## User/UID & permissions
No USER declared: runs as root.

## Config files and formats
Bundled `config.yaml` (YAML, mosdns format).

## Version/release info
Built from whatever `TAG` build-arg is supplied; Docker Hub tag `latest` only.

## Gotchas
- Image is alpine-based and runs as root: not a model for ContainerForge (ubuntu base, `apps` user).
- The Docker Hub page says geoip/geosite data are refreshed on each image build, even if `/etc/mosdns` is mounted. The draft/chart use `/etc/mosdns` as persistence; ContainerForge plan uses `/config`.
- Plan.md says the TrueCharts chart runs as UID 0 and that port 53 needs NET_BIND_SERVICE; this Dockerfile also runs as root and exposes 53 (consistent).
