# sftpgo upstream Dockerfile (pinned commit 62ae9ba)

## Source URL(s) + date
- https://raw.githubusercontent.com/drakkan/sftpgo/62ae9ba3957e9ed52b44a4f885e805e2d7b35972/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27

## Differences from main
- Builder: `FROM golang:1.26-trixie AS builder` (main uses 1.27)
- Final: `FROM debian:trixie-slim`

## Facts (same as main unless noted)
- Group `sftpgo` GID 1000; user `sftpgo` UID 1000, home `/var/lib/sftpgo`, shell `/usr/sbin/nologin`
- USER `1000:1000`; WORKDIR builder `/workspace`, final `/var/lib/sftpgo`
- CMD `["sftpgo", "serve"]`
- No ENTRYPOINT, EXPOSE, VOLUME, HEALTHCHECK
- sed on `/etc/sftpgo/sftpgo.json`: `"users_base_dir": "",` → `/srv/sftpgo/data`; `"backups"` → `/srv/sftpgo/backups`
- `ENV SFTPGO_LOG_FILE_PATH=""`
