# Docker Hub: linuxserver/orcaslicer

Source URL(s):
- https://hub.docker.com/v2/repositories/linuxserver/orcaslicer/ (repo JSON)
- https://hub.docker.com/v2/repositories/linuxserver/orcaslicer/tags?page_size=10 (tags JSON)
- Fetched 2026-11-27. Pull count 188,088; last_updated 2026-11-21.

## What it is
- Image `linuxserver/orcaslicer`, pulled as `lscr.io/linuxserver/orcaslicer`. Active, public.
- Upstream repo: https://github.com/linuxserver/docker-orcaslicer

## Architectures
- amd64 and arm64 (manifest on `latest`, `2.5.2`, `version-v2.5.2`, `v2.5.2-ls53`).
- Arch-prefixed tags exist: `amd64-2.5.2`, `arm64v8-2.5.2`, `amd64-version-v2.5.2`, `arm64v8-latest`.

## Tags seen (page_size=10, count 304)
- `latest`, `2.5.2`, `version-v2.5.2`, `v2.5.2-ls53` (all 2026-11-21, multi-arch).
- Pattern: `v<ver>-ls<build>`; bare `<ver>` and `version-v<ver>` aliases.

## Run notes (from Docker Hub description)
- Minimal run: `docker run --shm-size=1gb -p 3001:3001 lscr.io/linuxserver/orcaslicer:latest`
- Open `https://<host>:3001`; self-signed cert by default, so https.
- `--shm-size=1gb` recommended.
- Base: Docker Baseimage Selkies.
