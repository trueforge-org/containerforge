# homebridge/docker-homebridge: Dockerfile (tag 2026-11-15)

Source URL(s): https://raw.githubusercontent.com/homebridge/docker-homebridge/2026-11-15/Dockerfile (fetched 2026-11-27; blob/ and tree/ variants same tag). homebridge.io/docs (fetched; SPA shell, no usable text). github.com/oznu/docker-homebridge (listed, not fetched; legacy repo name).

## Build
- ARG BASE_IMAGE=ubuntu:24.04; FROM ${BASE_IMAGE}.
- Build args required (no defaults in Dockerfile): HOMEBRIDGE_APT_PKG_VERSION, FFMPEG_FOR_HOMEBRIDGE_VERSION, DOCKER_HOMEBRIDGE_VERSION. HOMEBRIDGE_APT_PKG_FILE defaults to HOMEBRIDGE_APT_PKG_VERSION.
- Labels: title "Homebridge in Docker", licenses GPL-3.0, url github.com/homebridge/docker-homebridge, version=DOCKER_HOMEBRIDGE_VERSION.
- apt (step 1): curl wget tzdata locales psmisc procps iputils-ping logrotate libatomic1 apt-transport-https apt-utils jq openssl sudo nano net-tools; then python3 python3-pip pipx python3-setuptools git make g++ libnss-mdns avahi-discover libavahi-compat-libdnssd-dev python3-venv python3-dev vim; `pipx install tzupdate`; chmod 0755 /bin/ping.
- s6-overlay: S6_OVERLAY_VERSION=3.2.0.2; noarch + arch tarball from just-containers/s6-overlay releases. Arch map: x86_64, armv7l->armhf, aarch64.
- ffmpeg: homebridge/ffmpeg-for-homebridge release `${FFMPEG_FOR_HOMEBRIDGE_VERSION}`, ffmpeg-alpine-<x86_64|arm32v7|aarch64>.tar.gz extracted to /.
- Homebridge: homebridge/homebridge-apt-pkg release `${HOMEBRIDGE_APT_PKG_VERSION}`, file homebridge_<ver>_<amd64|armhf|arm64>.deb, installed with apt-get; then rm /var/lib/homebridge.
- Writes /opt/homebridge/Docker.manifest (versions table) and /opt/homebridge/source-docker.sh.
- COPY rootfs /.

## Env (image)
| Name | Value |
| --- | --- |
| DEBIAN_FRONTEND | noninteractive |
| S6_OVERLAY_VERSION | 3.2.0.2 |
| S6_CMD_WAIT_FOR_SERVICES_MAXTIME | 0 |
| S6_KEEP_ENV | 1 |
| ENABLE_AVAHI | 1 |
| USER | root |
| HOMEBRIDGE_APT_PACKAGE | 1 |
| UIX_CUSTOM_PLUGIN_PATH | /var/lib/homebridge/node_modules |
| PATH | /opt/homebridge/bin:/var/lib/homebridge/node_modules/.bin:$PATH |
| HOME | /home/homebridge |
| npm_config_prefix | /opt/homebridge |

## Entrypoint / ports / volumes
- ENTRYPOINT ["/init"] (s6). EXPOSE 8581/tcp. VOLUME /homebridge. WORKDIR /homebridge.
- No HEALTHCHECK in Dockerfile.

## User/UID
- Runs as root (USER=root env; no USER directive).

## Runtime deps
- Node (bundled via homebridge apt package), avahi/libnss-mdns, ffmpeg-for-homebridge, python3/pipx, s6-overlay, jq, sudo.

## Arch
- x86_64, armv7l (armhf), aarch64 only; others exit 1.

## Gotchas
- Build fails without the three version build args.
- Chart and urls.txt both pin the same tag 2026-11-15 (aligned).
- rootfs/ overlay (s6 services) not fetched.
