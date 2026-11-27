# linuxserver/docker-fleet Dockerfile

Source URL (fetched 2026-11-27, pinned commit):
- https://raw.githubusercontent.com/linuxserver/docker-fleet/68995eabc52afa0c3a1fddf3c5dbc803d6943c36/Dockerfile

## Base
- `FROM ghcr.io/linuxserver/baseimage-alpine:3.21` (tag only, no digest).
- `# syntax=docker/dockerfile:1`

## ARG / ENV
- ARG: `BUILD_DATE`, `VERSION`, `FLEET_RELEASE`.
- ENV: `fleet_database_driver=org.mariadb.jdbc.Driver`, `fleet_app_port=8080`.

## Build steps (single RUN, `&&`-chained)
1. `apk -U --no-cache add openjdk11-jre-headless` (only runtime package).
2. If `FLEET_RELEASE` unset: resolve via `curl https://api.github.com/repos/linuxserver/fleet/releases/latest`, parse `tag_name` with awk.
3. `mkdir -p /app/fleet`
4. `curl -o /app/fleet/fleet.jar -L https://github.com/linuxserver/fleet/releases/download/${FLEET_RELEASE}/fleet-${FLEET_RELEASE}.jar`
5. Writes `/build_version` ("Linuxserver.io version: ${VERSION} Build-date: ${BUILD_DATE}").
6. `rm -rf /tmp/*`

## Copy / runtime
- `COPY root/ /`
- `WORKDIR /app/fleet`
- `EXPOSE 8080`
- No VOLUME, ENTRYPOINT, CMD, HEALTHCHECK, USER (inherited from base).
- LABEL: `build_version`, `maintainer="Josh Stark,Thelamer"`.

## Gotchas
- Java runtime: OpenJDK 11 headless. The jar is run from the `root/` s6 services (svc-fleet, svc-cron per readme-vars).
- Root filesystem and user are inherited from baseimage (s6, runs as root then drops via PUID/PGID).
