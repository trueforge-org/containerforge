# vexorian/dizquetv (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/vexorian/dizquetv
- Fetched 2026-11-26

## What it is
- Docker Hub listing: "allows you to create your own IPTV channels and spoof HDHR tuners from your media library." Fork of pseudotv-plex. 1M+ pulls, 32 stars.
- Description labelled "1.5.0-development" (stale).

## Install/build steps
- Only `docker pull vexorian/dizquetv` is shown. Points to the GitHub wiki for setup.

## Env vars, volumes, ports
- None documented on this page. Guide data written to `.dizquetv/xmltv.xml`.

## Arch support
- Not listed on the page.

## Version/release info
- Only `latest` shown under recent tags: digest begins `sha256:f5af99506...`, size 131.6 MB, updated about 2 months before fetch.

## Gotchas
- Plex Pass required for the spoofed HDHR in Plex.
- Media/server changes in Plex not auto-detected.
- Licensing: MIT for original pseudotv-Plex code, zlib for dizqueTV improvements.
