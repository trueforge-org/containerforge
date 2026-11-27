# Docker Hub: linuxserver/quassel-web

Source URL (fetched 2026-11-27):
- https://hub.docker.com/v2/repositories/linuxserver/quassel-web/

## Repository
- linuxserver/quassel-web, image, active, not private. No license field, source null.
- **DEPRECATED** (changelog 26.12.24): no support, no further updates.
- last_updated 2024-12-26. Registered 2019-04-29.
- Stars 11, pulls ~709k. Categories: Networking, Web servers.

## Usage (from README)
- Web client for Quassel (upstream magne4000/quassel-webserver). Needs a separate Quassel Core (linuxserver/quassel-core).
- Ports: 64080 (http, optional), 64443 (https, optional, self-signed cert).
- Env: `PUID=1000`, `PGID=1000`, `TZ=Etc/UTC`, `QUASSEL_CORE`, `QUASSEL_PORT`, `QUASSEL_HTTPS` (true = https on 64443), `URL_BASE` (reverse proxy path prefix), `UMASK`, FILE__ secrets.
- Volume `/config`. Advanced config: `/config/settings-user.js`.
- Arch: amd64, arm64. No armhf.

## Changelog
- 26.12.24 deprecated. 25.05.24 Alpine 3.20 rebase. 10.11.23 Alpine 3.18, settings file renamed to `.cjs`. 06.07.23 armhf dropped.

## Gotchas
- No updates after 2024-12-26.
- Settings file is `settings.cjs` in upstream since the 2023 change (`settings-user.js` in /config for user overrides, per README).
