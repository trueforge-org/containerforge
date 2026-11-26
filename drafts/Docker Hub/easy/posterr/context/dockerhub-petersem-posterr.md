# petersem/posterr (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/petersem/posterr (fetched 2026-11-26)

## What it is
Digital poster app for Plex, Sonarr, Radarr and Readarr. Built on Node.js, image about 95.4 MB. Page shows 500K+ pulls.

## Tags
- Only `latest` shown (updated ~3 months before fetch, digest prefix sha256:8d2dec29e...).
- Pull: `docker pull petersem/posterr`.
- Note: TrueCharts values reference `docker.io/petersem/posterr` with a different digest (see truecharts-posterr.md).

## Arch support
- X86 and ARM64 listed in compose and CLI sections.

## Ports, env, volumes (from page run examples)
- Container port 3000, example host 9876:3000.
- Env: `TZ` (timezone name), `BASEPATH` (optional, reverse proxy path, may be empty).
- Volumes: `/usr/src/app/config` (settings, required), `/usr/src/app/public/custom` (custom pictures, required).

## Healthcheck/readiness
- Page says image includes a healthcheck. Setup URL: http://hostIP:9876/settings.

## Gotchas
- Default setup password documented as "raidisnotabackup".
- Plex is mandatory, the other integrations optional.
