# Docker Hub: linuxserver/headphones

Source URL (fetched 2026-11-27):
- https://hub.docker.com/v2/repositories/linuxserver/headphones/

## Repository
- linuxserver/headphones, image, active, not private, not automated.
- **DEPRECATED**: README banner says no support and no further updates. Changelog entry 17.10.23 marks deprecation.
- last_updated 2023-10-17 (last_modified 2024-10-16). Registered 2015-08-05.
- Stars 224, pulls ~89M. No license field. Source field null.
- Description: "A Headphones container, brought to you by LinuxServer.io."
- Image reference: `lscr.io/linuxserver/headphones:latest`.

## Architectures
- amd64 (x86-64) and arm64 (arm64v8). armhf dropped 06.07.23.

## Usage (from README)
- Ports: 8181 (web UI).
- Volumes: `/config`, `/downloads`, `/music`.
- Env: `PUID=1000`, `PGID=1000`, `TZ=Etc/UTC`, optional `UMASK`, FILE__ prefix for secrets.
- Docker Mods supported. Compose version 2.1 example, restart `unless-stopped`.
- Local build: `docker build --no-cache --pull`; arm builds via `Dockerfile.aarch64`.

## Changelog
- 17.10.23 deprecated. 06.07.23 armhf dropped. 23.02.23 Alpine 3.17 and s6v3 migration. 02.02.22 Python 3, Alpine 3.15.

## Gotchas
- No updates since 2023; any new build is downstream of an unmaintained upstream.
