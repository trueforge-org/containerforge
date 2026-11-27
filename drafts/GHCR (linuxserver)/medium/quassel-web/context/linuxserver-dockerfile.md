# linuxserver/docker-quassel-web Dockerfile

Source URL (fetched 2026-11-27, default branch):
- https://api.github.com/repos/linuxserver/docker-quassel-web/contents/Dockerfile (base64 decoded)

## Base
- `# syntax=docker/dockerfile:1`
- `FROM ghcr.io/linuxserver/baseimage-alpine:3.20` (tag only, no digest).

## ARG / ENV / LABEL
- ARG: `BUILD_DATE`, `VERSION`, `QUASSELWEB_COMMIT` (no defaults).
- ENV: none.
- LABEL: `build_version`, `maintainer="chbmb"`.

## RUN (single layer)
1. `apk add --no-cache npm`
2. `mkdir -p /app/quassel-web`
3. If `QUASSELWEB_COMMIT` unset: `curl https://api.github.com/repos/magne4000/quassel-webserver/commits/master` -> sha (awk).
4. `curl -L https://github.com/magne4000/quassel-webserver/archive/${QUASSELWEB_COMMIT}.tar.gz` -> `/tmp/quassel-web.tar.gz`; extract to `/app/quassel-web` (strip-components=1).
5. `cd /app/quassel-web && npm install` (no yarn, no git clone, no `npm run build` in this file).
6. `/build_version` written (version and build date).
7. `rm -rf /root && mkdir -p /root`.

## Copy / runtime
- `COPY root/ /`
- `EXPOSE 64443`
- `VOLUME /config`
- No USER, ENTRYPOINT, CMD, HEALTHCHECK (inherited from base; s6 init).

## Gotchas
- EXPOSE 64443 (https) while the chart and Hub list 64080 (http) as the default service port. Both are served from the same app depending on `QUASSEL_HTTPS`.
- Source is `magne4000/quassel-webserver`, pinned by commit, or master HEAD if unset.
- Node/npm: `apk add npm` on Alpine 3.20 base. Node version not pinned here.
