# sftpgo upstream Dockerfile (main branch)

## Source URL(s) + date
- https://raw.githubusercontent.com/drakkan/sftpgo/main/Dockerfile
- Fetched 2026-11-27

## Build stages
- Builder: `FROM golang:1.27-trixie AS builder`, WORKDIR `/workspace`
  - ENV `GOFLAGS=-mod=readonly`
  - ARGs: `GOPROXY` (none), `COMMIT_SHA` (fallback `git describe`), `FEATURES` (e.g. `nos3,nogcs`), `DOWNLOAD_PLUGINS=false`
  - `go mod download && go mod verify`; `go build -trimpath` with `-s -w` and version `-X` ldflags; adds `-tags ${FEATURES}` if set
  - if DOWNLOAD_PLUGINS=true: runs `./docker/scripts/download-plugins.sh`
- Final: `FROM debian:trixie-slim`
  - ARG `INSTALL_OPTIONAL_PACKAGES=false` (true installs jq)
  - installs `ca-certificates`, `media-types` (no-recommends)
  - `mkdir -p /etc/sftpgo /var/lib/sftpgo /usr/share/sftpgo /srv/sftpgo/data /srv/sftpgo/backups`
  - `groupadd --system -g 1000 sftpgo`; `useradd --system --uid 1000 --gid sftpgo --home-dir /var/lib/sftpgo --shell /usr/sbin/nologin sftpgo`
  - sed on `/etc/sftpgo/sftpgo.json`: `users_base_dir` → `/srv/sftpgo/data`; `"backups"` → `/srv/sftpgo/backups`
  - `chown -R sftpgo:sftpgo /etc/sftpgo /srv/sftpgo`; `chown sftpgo:sftpgo /var/lib/sftpgo`; `chmod 700 /srv/sftpgo/backups`
  - COPY from builder: `sftpgo.json` → `/etc/sftpgo/`; `templates` → `/usr/share/sftpgo/templates`; `static` → `/usr/share/sftpgo/static`; `openapi` → `/usr/share/sftpgo/openapi`; `sftpgo` and `sftpgo-plugin-*` → `/usr/local/bin/`
  - ENV `SFTPGO_LOG_FILE_PATH=""`
  - WORKDIR `/var/lib/sftpgo`; USER `1000:1000`; CMD `["sftpgo", "serve"]`

## Not present
- ENTRYPOINT, EXPOSE, VOLUME, HEALTHCHECK, ADD

## Gotchas
- Builder is golang 1.27 on main; the pinned commit (see sftpgo-dockerfile-62ae9ba.md) uses 1.26.
- Templates/static/openapi live under `/usr/share/sftpgo`, not `/usr/local/share`.
