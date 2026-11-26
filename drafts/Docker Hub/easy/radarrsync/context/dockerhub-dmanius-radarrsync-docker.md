# dmanius/radarrsync-docker (Docker Hub)

Source URL(s) + fetch date (2026-11-26):
- https://hub.docker.com/r/dmanius/radarrsync-docker (fetched)

## What it is
"Custom radarrsync for docker": a modified RadarrSync build for containers that links two Radarr servers through their web API. Supports two servers. Page shows 500K+ pulls, image about 19.7 MB. Repo last updated almost six years before fetch.

## Tags and arch
- Only `latest`. Pull: `docker pull dmanius/radarrsync-docker`.
- No architectures listed.

## Env vars (page)
- RADARR_URL, RADARR_KEY, RADARR4K_URL, RADARR4K_KEY, PROFILE_ID (same names as the fork).

## Compose example (page)
```yaml
radarsync:
  image: dmanius/radarrsync-docker
  container_name: radarrsync
  environment:
    - RADARR_URL=https://radarr-url.com
    - RADARR4K_URL=https://radarr4k-url.com
    - RADARR_KEY=<key>
    - RADARR4K_KEY=<key>
    - PROFILE_ID=5
  restart: always
```
- Page note: both servers need the same root path (example `/movie`).
- No ports, no volumes, no docker run example on the page.
