# Docker Hub: vstavrinov/acestream-service

**Source URL(s) + fetch date:** https://hub.docker.com/r/vstavrinov/acestream-service · fetched 2026-11-26

## What it is
IPTV service image: Ace Stream engine plus search, m3u playlists, EPG. About 10 stars, 50K+ pulls (as shown on the page at fetch time).

## Install/build steps
- `docker pull vstavrinov/acestream-service`
- Build: clone `vstavrinov/acestream-service` and `docker build -t acestream-service .`

## Env vars (as described on the overview)
- `PORT`: service port inside the container.
- `port`: host-facing port (default 80).
- Example: `docker run -d -e PORT=7000 -e port=8000 -p 8000:7000 vstavrinov/acestream-service`.

## Ports
Playlist example: `http://localhost:8000/search.m3u`, `?query=CNN` filter, `?help` options.

## Version/release info
- Tags: only `latest` visible in the fetched summary; `2.1.1.1` (used by TrueCharts chart and plan.md) was not listed in the fetched text.
- Last updated "about a year ago" (no date). Plan.md states `latest` and `2.1.1.1` were pushed 2025-10-30; not contradicted, not verified here.
- Size 510.6 MB; digest starts `sha256:b7d90643e…`.

## Arch support
Not listed on the page.

## Gotchas / contradictions
- The overview's env var names (`PORT`, lowercase `port`) differ from the GitHub README (`ENTRY`, `PORT`, `SCHEME`). The GitHub README and Dockerfile are treated as authoritative; this conflict is recorded here, not used in the plan.
- License: not mentioned on the page.
