# mickael-kerjean/filestash (docker/Dockerfile + repo)

Source URL(s): https://github.com/mickael-kerjean/filestash ; https://github.com/mickael-kerjean/filestash/blob/master/docker/Dockerfile (raw variant fetched: https://raw.githubusercontent.com/mickael-kerjean/filestash/master/docker/Dockerfile) ; https://hub.docker.com/r/machines/filestash (not fetched)
Date: fetched 2026-11-26

## What it is
- Self-hosted web file manager (FTP/SFTP/S3/WebDAV/SMB/LDAP frontends). AGPL. Go backend + web UI.

## Build (docker/Dockerfile, master)
- Stage builder_prepare: `FROM alpine/git`; ARG GIT_REPO (filestash repo URL), GIT_BRANCH (default `master`); shallow single-branch clone to `/home/`.
- Stage builder_backend: `FROM golang:1.27.0-trixie`; WORKDIR `/home/filestash/`; RUN `apt-get update`, install curl, make, image libs (libjpeg-dev libtiff-dev libpng-dev libwebp-dev libraw-dev libheif-dev libgif-dev libvips-dev), FFmpeg dev libs (libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libswresample-dev libswscale-dev libavutil-dev); then `make init && make build`.
- Final: `FROM debian:stable-slim`; WORKDIR `/app/`; COPY `/home/filestash/dist/` -> `.`; RUN apt upgrade; install ca-certificates curl ffmpeg libbrotli1 poppler-utils (no-recommends); create user `filestash`; mkdir `/app/data/state/`; chown -R filestash:filestash /app/; `chmod 730 /app/filestash`; clean apt and /tmp.
- `USER filestash`; `CMD ["/app/filestash"]`; `EXPOSE 8334`. No ENV, VOLUME, ENTRYPOINT, HEALTHCHECK.

## Runtime deps
- debian:stable-slim; ffmpeg, poppler-utils, libbrotli1, ca-certificates, curl.

## Entrypoint/flags
- `/app/filestash` (no flags in Dockerfile).

## Env vars
| Var | Default | Meaning |
| --- | --- | --- |
| CONFIG_JSON | none | base64 of config.json; used only by `plg_config_env` plugin (read-only config). Generate: `CONFIG_JSON=$(cat config.json \| base64 -w0)` |
| ADMIN_PASSWORD | none | bcrypt hash; skips admin password setup screen (from install docs) |

## Ports
- 8334/tcp (HTTP listener; EXPOSE). Base build's `plg_starter_http` expects reverse proxy for TLS. ACME/Let's Encrypt and cert loading available (`/ssl-setup.html`).

## Volumes/paths
| Path | Use |
| --- | --- |
| `/app/data/state/` | state dir; config default at `state/config/config.json` |
| `/app/` | app root (owned by filestash) |
- Compose file creates named volume `filestash_filestash` (mount path not stated).

## User/UID
- `filestash` user (UID not stated in docs; created by useradd in Dockerfile). Runs non-root.

## Config files
- `config.json` in `state/config` (default). Keys: `connections` (list, each has unique `label`) and `middleware` (`identity_provider`, `attribute_mapping`) = Storage section; all other keys = Settings section (plugins may add keys).

## Healthcheck
- None in image; no healthcheck endpoint documented.

## Version/asset naming
- Binary download: `https://downloads.filestash.app/latest/filestash_linux_$(uname -m).bin` (~13 MB, static, no libc needed).
- Compose: `https://downloads.filestash.app/latest/docker-compose.yml`; image `machines/filestash:latest`.
- GitHub releases: none listed on repo ("There aren't any releases here"); tags exist (not enumerated). API releases/latest returned 404.

## Arch
- Binary via `uname -m`. Docker image build: golang base, arch not stated in fetched content.

## Gotchas
- Docker build pulls `golang:1.27.0-trixie` and `alpine/git` with unpinned tags in the Dockerfile.
- Build is heavy (C deps for thumbnailing, video, compression); binary is the lighter option.
- Plugins require restart; plugin folder path not documented.
