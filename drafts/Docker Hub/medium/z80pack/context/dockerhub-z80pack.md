# Docker Hub: dlandon/z80pack

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/dlandon/z80pack/ (2026-11-27)
- https://hub.docker.com/v2/repositories/dlandon/z80pack/tags?page_size=10 (2026-11-27)

## What it is
- Community image (not official), publisher `dlandon`. CP/M 1/2/3 and MP/M emulation (Z80pack) in Docker.
- 6 stars, 126,019 pulls, is_automated true. last_updated 2026-10-23.

## Tags
| Tag | Digest | Arch | Pushed |
| --- | --- | --- | --- |
| latest | sha256:c1287d3b1258a21c1049a8d353834b9d0f40f4a87f13b9b1f8383b79436da831 | amd64 only | 2026-10-23 |
- Only one tag exists (count 1). Size ~322 MB (amd64).
- Digest matches the TrueCharts chart pin.

## Entrypoint / runtime (from Docker Hub full_description and upstream Dockerfile)
- Web terminal: shellinabox on 4200. Image `CMD ["/sbin/my_init"]` (phusion/baseimage).
- Docker Hub text says the image updates system packages on restart.

## Ports
- 4200/tcp (`EXPOSE 4200`).

## Volumes / paths
- `VOLUME ["/config"]`.
- Emulator tree: `/root/z80pack/cpmsim` (cd target on login).

## User / UID
- Root (no USER). Fixed login user `vintage` (sudo group) with a hard-coded password in the upstream Dockerfile. Do not copy the password.

## Env (unRAID example)
- `PUID=99`, `PGID=100`, `TZ=America/New_York` (unRAID template; image itself uses `TZ=Etc/UTC` default).

## Gotchas
- Docker Hub page says login is `vintage` / `computer` (published default credential).
- Not an official image; single amd64 build.
