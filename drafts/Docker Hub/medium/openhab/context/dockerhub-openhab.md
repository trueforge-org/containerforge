# Docker Hub: openhab/openhab
Source URL(s): https://hub.docker.com/v2/repositories/openhab/openhab/ , .../tags?page_size=10 (fetched 2026-11-27)

## What it is
- Official-style image of openHAB (home automation). Description: "openHAB - a vendor and technology agnostic open source automation software for your home."
- License EPL-2.0 (OCI label). Source: https://github.com/openhab/openhab-docker (Dockerfile per variant)
- 63,155,932 pulls, 449 stars, status active
- Tags: `latest` (= debian variant, digest sha256:78bb11...), `snapshot-alpine`, `5.2.5`, `5.1.4`, `5.3.0.M5`, `5.3.0.M4`; 650 tags total
- Variants: `debian` (Debian 13 trixie, default when no suffix) and `alpine` (Alpine 3.24)
- Multi-arch: amd64, arm64

## Install/build (openhab-docker debian/Dockerfile, see github-openhab-docker-debian-dockerfile.md)
- Base: debian:13-slim (ARG BASE_IMAGE); su-exec built in builder stage (pinned commit, sha256 checked)
- JRE: openjdk-${JAVA_VERSION}-jre-headless, fallback temurin-${JAVA_VERSION}-jre (Adoptium apt repo)
- Node.js installed only if OPENHAB_VERSION major >= 5
- Distro zip downloaded from openhab.jfrog.io (release/milestone) or ci.openhab.org (5.x SNAPSHOT), unzipped into /openhab

## Runtime deps (apt)
adduser arping ca-certificates curl fontconfig iputils-ping libcap2-bin locales locales-all netbase procps tini unzip wget zip

## Entrypoint/CMD
- ENTRYPOINT ["/entrypoint"] (COPY entrypoint /entrypoint)
- CMD ["su-exec", "openhab", "tini", "-s", "./start.sh"]
- WORKDIR /openhab (OPENHAB_HOME)

## Env vars
| Var | Default |
| --- | --- |
| CRYPTO_POLICY | limited (set "unlimited" to enable) |
| EXTRA_JAVA_OPTS | "" |
| EXTRA_SHELL_OPTS | "" |
| GROUP_ID | 9001 |
| USER_ID | 9001 |
| KARAF_EXEC | exec |
| OPENHAB_HTTP_PORT | 8080 |
| OPENHAB_HTTPS_PORT | 8443 |
| OPENHAB_CONF | /openhab/conf |
| OPENHAB_USERDATA | /openhab/userdata |
| OPENHAB_LOGDIR | /openhab/userdata/logs |
| OPENHAB_BACKUPS | /openhab/userdata/backup |
| OPENHAB_HOME | /openhab |
| LANG/LC_ALL/LANGUAGE | en_US.UTF-8 |
| TZ | Etc/UTC |

## Ports
- EXPOSE 8080 (HTTP), 8443 (HTTPS), 8101 (Karaf SSH console), 5007 (LSP rule validation)

## Volumes/paths
- VOLUME /openhab/conf, /openhab/userdata, /openhab/addons
- Dist copies of conf/userdata at /openhab/dist (seeded on start)

## User/UID
- Default user openhab uid/gid 9001 (USER_ID/GROUP_ID); container starts as root, entrypoint drops via su-exec
- /bin/ping and /usr/sbin/arping setuid (for non-root ping/arping)

## Healthcheck
- HEALTHCHECK --interval=1m --timeout=10s --retries=3 --start-period=20m: curl -f http://localhost:${OPENHAB_HTTP_PORT}/

## Version/asset naming
- Distro zip: openhab-${version}.zip; release tags like 5.2.5 (distro releases on GitHub)
- Milestone: openhab.jfrog.io/openhab/libs-milestone-local/.../openhab-5.3.0.M5.zip

## Arch
- amd64, arm64 (per Docker Hub tag images)

## Gotchas
- UPnP discovery needs --net=host (Linux only)
- Serial device names must follow Linux naming (ttyACM0/ttyUSB0) for some addons; symlinks may fail
- Console logging needs log4j2.xml edit (chart init script does this)
- Docker README: user uid 9001 must match host if bind-mounting; or set USER_ID/GROUP_ID
