# Docker Hub: linuxserver/mysql-workbench

Source URL(s):
- https://hub.docker.com/v2/repositories/linuxserver/mysql-workbench/ (repo JSON)
- https://hub.docker.com/v2/repositories/linuxserver/mysql-workbench/tags?page_size=10 (tags JSON)
- Fetched 2026-11-27. Pull count 5,679,084; last_updated 2026-11-21.

## What it is
- Image `linuxserver/mysql-workbench`, pulled as `lscr.io/linuxserver/mysql-workbench`. Active, public.
- Upstream repo: https://github.com/linuxserver/docker-mysql-workbench

## Architectures
- Hub tags list only `amd64` for every tag shown. No arm64 seen in tags JSON.

## Tags seen (page_size=10, count 416)
- `latest`, `8.0.47`, `version-8.0.47` (all 2026-11-21), `8.0.47-ls92` (2026-11-21), `8.0.47-ls91` (2026-11-18), `8.0.47-ls90` (2026-11-14), and older `-lsNN` builds.
- Pattern: `<workbench version>-ls<build>` for rebuilds of the same Workbench version.

## Run notes (from Docker Hub description)
- Minimal run: `docker run --shm-size=1gb -p 3001:3001 lscr.io/linuxserver/mysql-workbench:latest`
- Open `https://<host>:3001`; self-signed cert by default, so scheme is https.
- `--shm-size=1gb` recommended.
- Base: Docker Baseimage Selkies (linuxserver/docker-baseimage-selkies).
- GPU and compose guidance point to docs.linuxserver.io/selkies.

## Gotchas
- Hub tag list is amd64-only, consistent with Oracle shipping amd64 deb only.
