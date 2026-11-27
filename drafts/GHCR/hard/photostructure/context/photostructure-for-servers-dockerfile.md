# photostructure-for-servers Dockerfile

**Source URL(s):** https://raw.githubusercontent.com/photostructure/photostructure-for-servers/42bd6d0e2f7c2a5abaaa1948cb9591c591163467/Dockerfile · fetched 2026-11-27 (pinned commit 42bd6d0)

## What it is
Official PhotoStructure Docker image (Node edition packaged for containers). Two-stage build.

## Build
- Stage `builder`: `FROM photostructure/base-tools-debian@sha256:69e6b13a...` (digest pinned). Copies `package.json package-lock.json .npmrc`, runs `npm ci --omit=dev`.
- Final: `FROM node:24-trixie-slim` (major pinned, not patch).
- apt: ca-certificates, libjpeg-turbo-progs (jpegtran), libreadline8t64, locales-all, passwd, perl (exiftool), procps, ripgrep, tini, tzdata, wget (healthcheck).
- `npm install --force --location=global --min-release-age=3 npm`.
- Renames node user/group to `photostructure` (`groupmod --new-name photostructure node`, `usermod --login photostructure --home /home/photostructure --move-home node`).
- `touch /.running-in-container` (replaces PS_IS_DOCKER).
- `COPY --chown=root:root . ./` then `COPY --from=builder ... ./` (tools dir).
- No sudo. Optional tools (FFmpeg via pixi) are installed at runtime as the runtime user.

## Runtime
- WORKDIR /opt/photostructure
- ENTRYPOINT `["/usr/bin/tini", "--", "/opt/photostructure/docker-entrypoint.sh"]`
- ENV PATH includes /opt/photostructure and /opt/photostructure/tools.
- Entrypoint renumbers the `photostructure` account to PUID/PGID before dropping privileges.

## Ports
- EXPOSE 1787

## Healthcheck
- `--interval=30s --timeout=10s --start-period=60s --retries=3`
- `wget --quiet --output-document - "http://localhost:${PS_HTTP_PORT:-1787}/ping"`

## User/UID
- Image user `photostructure`; PUID/PGID (linuxserver-style) remap it at start.

## Gotchas
- Image needs no extra packages for FFmpeg; it is installed on first run (see docs file).
- Docker Hub image `photostructure/server` (per docs) vs GHCR `ghcr.io/photostructure/server` (TrueCharts).
