# mpepping/docker-cyberchef Dockerfile (upstream image build)

Source URL(s) + fetch date:
- https://github.com/mpepping/docker-cyberchef/blob/master/Dockerfile (fetched as raw master) · 2026-11-26

## What it is
Upstream community image `mpepping/cyberchef`. Not used by ContainerForge; cited for reference.

## Install/build steps and build deps
- Build stage: `FROM --platform=$BUILDPLATFORM node:26-alpine AS build`. `ARG VERSION` (no default). `NODE_OPTIONS=--max-old-space-size=4096`. WORKDIR `/srv`.
- `apk add --no-cache git`, `chown -R node:node /srv`, `USER node`.
- `git clone -b "$VERSION" --depth=1 https://github.com/gchq/CyberChef.git .`
- `npm ci --ignore-scripts && npm run postinstall && npm run build` (outputs `/srv/build/prod`).

## Runtime
- App stage: `FROM nginxinc/nginx-unprivileged:stable-alpine AS app`. No USER set (inherits base).
- `COPY --from=build /srv/build/prod /usr/share/nginx/html`.
- Sed edits `/etc/nginx/conf.d/default.conf`: listen port 8080 -> 8000, plus `listen [::]:8000;` (kept port 8000 for backward compatibility).
- `EXPOSE 8000`. No ENTRYPOINT/CMD/VOLUME defined here (inherits base).
- HEALTHCHECK: interval 30s, timeout 5s, start-period 10s, retries 3, `curl -sf -o /dev/null http://localhost:8000 || exit 1`.

## Ports / paths
- Port 8000 (IPv4 and IPv6). Served from `/usr/share/nginx/html`.

## Gotchas
- Upstream serves on 8000, ContainerForge plan uses 8080 from its nginx base. Upstream does its own build from git; ContainerForge uses the release zip.
