# Upstream README: debridmediamanager/zurg-public (main)

Source URL(s) + date: https://raw.githubusercontent.com/debridmediamanager/zurg-public/main/README.md (fetched 2026-11-27)

## What it is
- zurg serves a Real-Debrid library over WebDAV; rclone mounts it for Plex (Infuse reads WebDAV directly).
- Public stable release is for Real-Debrid. Sponsor nightlies add TorBox, AllDebrid, Premiumize, Debrid-Link, Offcloud, Usenet.
- README states stable version: v1.0.0 (Public).

## Docker
- Public image: `ghcr.io/debridmediamanager/zurg-public:latest` or pinned `:v1.0.0`. Same build also pushed to old name `zurg-testing`.
- Private sponsor image `ghcr.io/debridmediamanager/zurg` (requires sponsorship; 404 otherwise). Not usable by default.

## Run (Plex, Docker)
1. Clone repo; add token to config.yml; `sudo mkdir -p /mnt/zurg`; `docker compose up -d`; check `ls -1R /mnt/zurg`.
- Web server on localhost:9999; dashboard at localhost:9999/config/.
- After config change: `docker compose restart zurg`.

## Binary / env
- `TOKEN` or `RD_TOKEN` env auto-creates config on first run (Docker can skip config file).
- `PORT` env overrides configured port.
- rclone and ffprobe downloaded on first run to bin/ if not installed.

## CLI
- `zurg [flags]`, flag `-c, --config` (default ./config.yml).
- Commands: download-requirements, clear-downloads, clear-torrents, completion, network-test, version.

## Gotchas
- Account setting: uncheck "Use my Remote Traffic automatically when needed" on real-debrid account when running remote.
- Windows needs WinFsp (see WINDOWS.md, not fetched).
- Wiki exists (https://github.com/debridmediamanager/zurg-public/wiki; raw Home.md returned 200) not summarized (budget).
