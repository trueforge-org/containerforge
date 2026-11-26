# AList docs (alistgo.com)

**Source URL(s) + fetch date:** https://alistgo.com/guide/ and https://alistgo.com/guide/install/docker.html · fetched 2026-11-26. Also https://alistgo.com/ (linked website; not separately summarised beyond the guide's intro).

## What it is
Official docs site for AList. Intro says it is a file list tool with multiple storage backends, WebDAV, built on gin and Solidjs. V3 and later are not compatible with V2; upgrading from V2 needs a full reinstall.

## Install/build steps (Docker, from /guide/install/docker.html)
`docker run -d --restart=unless-stopped -v /etc/alist:/opt/alist/data -p 5244:5244 -e PUID=0 -e PGID=0 -e UMASK=022 --name="alist" xhofe/alist:latest`

- Image tags: `xhofe/alist:latest`, pinned versions (e.g. `xhofe/alist:v3.41.0`), `beta` for dev, suffixes `aio`, `ffmpeg`, `aria2` (e.g. `xhofe/alist:latest-aio`).
- Update: `docker pull xhofe/alist:latest`, stop/remove, re-run. Compose: `docker-compose pull && docker-compose up -d`.

## Env vars
| Name | Default | Note |
| --- | --- | --- |
| `PUID` | `0` | user UID |
| `PGID` | `0` | group GID |
| `UMASK` | `022` | file permission mask |
| `RUN_ARIA2` | not stated | true if aria2 is pre-installed, otherwise false |
| `TZ` | UTC | e.g. `Asia/Shanghai` |

No `ALIST_`-prefixed env vars are mentioned on the docs pages fetched.

## Ports
Host `5244` -> container `5244`.

## Volumes/paths
Host `/etc/alist` -> container `/opt/alist/data`. Data persists across container removal unless deleted manually.

## Healthcheck/readiness
Not documented.

## Admin password behavior (important for plan.md)
- The docs do NOT describe a generated password logged on first start.
- Versions before v3.25.0: `docker exec -it alist ./alist admin` shows admin info.
- Versions after v3.25.0: password stored as a hash; cannot be recovered. Reset with `docker exec -it alist ./alist admin random` or `docker exec -it alist ./alist admin set NEW_PASSWORD`.

## License
AGPL-3.0 (stated on the guide pages).

## Gotchas
- Sidebar Install / Config / Storage groups are collapsed; their sub-pages were not expanded. Config page (https://alistgo.com/config/) was not fetched.
- Docker Hub is referenced as `xhofe/alist`.

## Contradictions with plan.md
- plan.md section 1 "First-run admin" says alist logs a generated admin password on first start. Docs describe password reset via `./alist admin` / `admin random`, not a logged first-run password. Recorded; plan.md left as "UNVERIFIED".
