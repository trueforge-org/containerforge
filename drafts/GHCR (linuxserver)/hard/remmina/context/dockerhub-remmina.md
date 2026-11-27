# Docker Hub: linuxserver/remmina

Source URL(s):
- https://hub.docker.com/v2/repositories/linuxserver/remmina/ (repo JSON)
- https://hub.docker.com/v2/repositories/linuxserver/remmina/tags?page_size=10 (tags JSON)
- https://hub.docker.com/v2/repositories/linuxserver/remmina/tags/1.4.43 (tag JSON)
- Fetched 2026-11-27. Pull count 2,273,783; last_updated 2026-11-25.

## What it is
- Image `linuxserver/remmina`, pulled as `lscr.io/linuxserver/remmina`. Active, public.
- Upstream repo: https://github.com/linuxserver/docker-remmina

## Architectures
- amd64 and arm64 (`latest`, `1.4.43`, `version-1.4.43dfsg-0ubuntu0.26.04.2`, `1.4.43dfsg-0ubuntu0.26.04.2-ls236`).
- Arch-prefixed tags also exist: `amd64-1.4.43`, `arm64v8-1.4.43`, `arm64v8-latest`.

## Digests for tag 1.4.43 (current, fetched 2026-11-27)
| Arch | Digest | Size |
| --- | --- | --- |
| amd64 | sha256:f087b70014f2589da468c2ecb9ff1cc4a2d5b1af2af07310c8b87aae671e05d2 | 1045536281 |
| arm64 | sha256:53dd603f05a5e656a24500d94a11d897a881d4e4364a29e45f6e53bdc8eff558 | 1008585823 |

## Tags seen (page_size=10, count 1205)
- `latest`, `1.4.43`, `version-1.4.43dfsg-0ubuntu0.26.04.2`, `1.4.43dfsg-0ubuntu0.26.04.2-ls236` (all 2026-11-25).
- Pattern: `<upstream>dfsg-<ubuntu build>-ls<build>`.

## Run notes (from Docker Hub description)
- Minimal run: `docker run --shm-size=1gb -p 3001:3001 lscr.io/linuxserver/remmina:latest`
- Open `https://<host>:3001`; self-signed cert by default, so https.
- `--shm-size=1gb` recommended.
- Base: Docker Baseimage Selkies.
