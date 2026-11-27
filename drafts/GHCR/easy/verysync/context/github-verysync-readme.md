# Upstream README: Jonnyan404/verysync (master, Chinese)

Source URL(s) + date: https://raw.githubusercontent.com/Jonnyan404/verysync/master/README.md (fetched 2026-11-27). Written in Chinese; facts translated.

## What it is
- Multi-platform file sync software (VerySync). P2P chunked sync, AES-encrypted transfers.
- Upstream sites: http://verysync.com/, forum http://forum.verysync.com/forum.php.

## Docker usage
- Simple: `docker run --name verysync -d -p 8886:8886 jonnyan404/verysync` -> web UI at http://IP:8886.
- Custom ports: `-p 3000:3000` (public relay, optional), `-p 22027:22027/udp` and `-p 22037:22037/udp` (LAN discovery, optional), `-p xxx:xxx` data transfer port (default 22330, optional), web GUI port `PORT` (default 8886, required).
- Data: mount `/path:/data`; set download dir to `/data` in the web UI.
- Non-root: set `VUID` to a UID that exists on the Linux host (from 2.16.x).
- Offline images per arch (AMD64, ARM64, ARMv7) on GitHub Releases: `gunzip -c verysync-docker-*.tar.gz | docker load`; tag example `v2.20.1`.

## Ports summary
| Port | Use |
| --- | --- |
| 8886 (PORT) | web GUI (default) |
| 3000 | public relay (optional) |
| 22027/udp, 22037/udp | LAN discovery (optional) |
| 22330 | data transfer (default) |

## Gotchas
- Changelog entry 2025-04-11: CI-built images and offline images.
