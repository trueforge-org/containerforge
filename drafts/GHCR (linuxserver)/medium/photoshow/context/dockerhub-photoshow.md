# Docker Hub: linuxserver/photoshow

Source URL (fetched 2026-11-27):
- https://hub.docker.com/v2/repositories/linuxserver/photoshow/

## Repository
- linuxserver/photoshow, image, active, not private, not automated.
- **DEPRECATED** (changelog 14.10.22): no support, no further updates.
- last_updated 2022-10-14. Registered 2015-10-13.
- Stars 75, pulls ~8.46M. No license field, source null.
- Categories: none.

## Usage (from README)
- Port 80 (WebUI).
- Env: `PUID=1000`, `PGID=1000`, `TZ=Europe/London`, optional `UMASK`, `FILE__` secrets. Docker Mods supported.
- Volumes: `/config` (nginx config and logs), `/Pictures` (read-only recommended), `/Thumbs` (thumbnails; settings persist in a subfolder).
- First run: create admin account. Folders under /Pictures become galleries.
- Compose 2.1 example, `restart: unless-stopped`. Image `lscr.io/linuxserver/photoshow:latest`.

## Architectures
- amd64, arm64 (arm64v8), armhf (arm32v7).

## Changelog
- 14.10.22 deprecated. 23.09.19 PHP-Exif added. 23.01.21 Alpine 3.13. Initial release 21.08.15.

## Gotchas
- No updates after 2022-10; base is Alpine 3.13 per changelog.
