# vstavrinov/acestream-service (wrapper image source)

**Source URL(s) + fetch date:** https://github.com/vstavrinov/acestream-service (README on master; Dockerfile at pinned blob `0fa3ec927b0599c213abcdd75e9a8a72211b5189`, raw URL) · fetched 2026-11-26

## What it is
IPTV wrapper: combines the Ace Stream engine with a search service. Returns an m3u playlist for a search query and serves live streams from the same container. Related to `vstavrinov/acestream_search` (see its own summary), but this repo bundles the engine.

## Install/build steps and build deps
- Build: `git clone https://github.com/vstavrinov/acestream-service.git && docker build -t acestream-service .`
- Dockerfile (pinned SHA) starts `FROM vstavrinov/acestream-engine` (the engine image, which is `FROM python:3.10`, see `github-vstavrinov-acestream-engine.md`).
- `WORKDIR /srv/ace`; `ENV COLUMNS=116`, `ENV PYTHONDONTWRITEBYTECODE=0`, `ENV TMP=/dev/shm/tmp`.
- `ADD search.py setup.cfg .`
- As root: `apt-get install nginx`; `apt-get clean`.
- `pip install --no-cache-dir gunicorn flask git+https://github.com/vstavrinov/acestream_search.git` (git install, not pinned to a commit).
- `COPY default.conf /etc/nginx/sites-available/default`; `COPY nginx.conf /etc/nginx/`.

## Runtime deps
nginx (apt), gunicorn, flask, acestream_search (git), plus the engine image contents.

## Binaries/entrypoint/CLI flags
- No ENTRYPOINT, no EXPOSE, no VOLUME, no ARG.
- `USER ace` for runtime.
- CMD (shell form) runs, in order:
  1. `mkdir /dev/shm/.ACEStream`, `mkdir /dev/shm/tmp`
  2. `cp --archive /etc/nginx /dev/shm`, `mkdir /dev/shm/nginx/lib`
  3. symlink `/dev/shm/nginx/sites-enabled/default` -> `../sites-available/default`
  4. `sed` replaces `PORT`, `ENTRY`, `SCHEME` in `/dev/shm/nginx/sites-available/default` (defaults `PORT=80`, `SCHEME=https`, `ENTRY` empty)
  5. `gunicorn --bind 0.0.0.0:3031 search:app &`
  6. `/usr/sbin/nginx -c /dev/shm/nginx/nginx.conf &`
  7. `./start-engine --client-console --live-cache-type memory`

## Env vars
| Name | Default | Purpose |
| --- | --- | --- |
| `PORT` | `80` (Dockerfile CMD) | service (nginx) port inside the container |
| `ENTRY` | empty | external/host port the client connects to; rewrites engine port 6868 in stream URLs. Must equal container port when requests come from the docker host itself. May be omitted for cloud setups. |
| `SCHEME` | `https` (Dockerfile CMD) | protocol the client uses (`https` or `http`) |
| `COLUMNS` | `116` | ENV in Dockerfile |
| `PYTHONDONTWRITEBYTECODE` | `0` | ENV in Dockerfile |
| `TMP` | `/dev/shm/tmp` | ENV in Dockerfile |

Note: the Docker Hub overview (see `dockerhub-vstavrinov-acestream-service.md`) names a different pair, `PORT` and lowercase `port`; the README and Dockerfile are the authority here.

## Ports
- Container service port = `PORT` (nginx). Example run: `-e SCHEME=http -e ENTRY=8000 -e PORT=80 -p 8000:80`.
- Engine HTTP API is not published in the README; standard stream port `6868` is rewritten by nginx to `ENTRY`.

## Volumes/paths and persistent data
- No volumes. Runtime state under `/dev/shm`: `/dev/shm/.ACEStream`, `/dev/shm/tmp`, `/dev/shm/nginx` (config copy, pid, lib).
- Nginx logs symlinked to `/dev/stderr` (error) and `/dev/stdout` (access).
- `/var/lib/nginx` replaced with a symlink to `/dev/shm/nginx/lib`.
- `.ACEStream` in `/srv/ace` symlinked to `/dev/shm/.ACEStream`.

## User/UID & permissions
Build as root (apt/pip), runtime `USER ace`. Chart runs as uid 1000 (see truecharts summary).

## Config files and formats
`default.conf` (nginx site, copied to `/etc/nginx/sites-available/default`), `nginx.conf` (copied to `/etc/nginx/`), `search.py`, `setup.cfg`. Contents of these were not fetched.

## Healthcheck/readiness endpoints
None documented. Playlist route: `/search.m3u` (`?query=CNN` filter, `?help` options).

## Version/release info and asset naming
- No GitHub releases or tags mentioned in README.
- Docker Hub image `vstavrinov/acestream-service` (see Docker Hub summary).
- Engine tarball is downloaded by the engine image, not this repo (see engine summary for the asset naming pattern `acestream_<ACE_VERSION>.tar.gz`).

## Arch support
Not stated in README. The base engine is x86_64 only (see engine summary).

## Gotchas
- Dockerfile installs `acestream_search` from git HEAD; not pinned.
- Runtime writes to `/dev/shm`; not compatible with plain read-only-rootfs without remapping (see plan.md section 9).
- No license file in repo or README (no license mentioned anywhere in the fetched content).

## Contradictions with plan.md
- plan.md section 4 and 9 describe the Dockerfile as installing `nginx` and `gunicorn flask` plus the git package. Consistent with this Dockerfile.
- plan.md section 1 says the engine base is `python:3.10`. Confirmed via engine summary (not this repo).
