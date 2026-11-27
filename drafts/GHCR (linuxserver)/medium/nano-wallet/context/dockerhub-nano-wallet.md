# Docker Hub: linuxserver/nano-wallet

Source URL (fetched 2026-11-27):
- https://hub.docker.com/v2/repositories/linuxserver/nano-wallet/

## Repository
- linuxserver/nano-wallet, image, active, not private, not automated.
- Last image push 2022-05-19 (last_modified 2024-10-16). Registered 2020-05-23.
- Stars 7, pulls ~273k. No license field, source null.
- Description empty on Hub.
- Categories: Security; Integration & delivery; Operating systems.
- No deprecation notice stated. Changelog has no entries after 2020.

## Usage (from full description)
- LSIO image wrapping the Nano light wallet in nginx. Needs a Nano RPC endpoint (public or self-hosted; see linuxserver/nano).
- Access: `http://localhost/#/<RPC_HOST>`.
- Port 80 (web server).
- No app env vars. Generic: `FILE__<VAR>` secrets, `UMASK`. Docker Mods supported.
- Volumes: none.
- CLI example: `docker run -d --name=nano-wallet -p 80:80 --restart unless-stopped lscr.io/linuxserver/nano-wallet:latest`.
- Local build: `docker build --no-cache --pull`; ARM via `Dockerfile.aarch64`.

## Architectures
- amd64, arm64 (arm64v8), armhf (arm32v7). Multi-arch manifest.

## Changelog
- 23.05.20 initial release. 01.06.20 rebased to Alpine 3.12.

## Gotchas
- Last push 2022; image base is old (Alpine 3.12 per changelog and Dockerfile).
