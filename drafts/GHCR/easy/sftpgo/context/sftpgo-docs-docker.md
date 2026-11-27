# SFTPGo docs: Docker page

## Source URL(s) + date
- https://docs.sftpgo.com/latest/docker/
- Fetched 2026-11-27

## Image
- `ghcr.io/drakkan/sftpgo:<tag>` (also Docker Hub `drakkan/sftpgo`)
- Tags: latest, v2, v2.7, v2.7.6, `-plugins`, `-alpine`, `-slim`, `-alpine-slim`, `-distroless-slim`, `edge*`

## Ports (example commands)
- 8080: web admin UI (`/web/admin`, first admin created there)
- 2022: SFTP
- No FTP or WebDAV ports documented on this page

## Volumes/paths
- `/srv/sftpgo`: persistent data; default user home `/srv/sftpgo/data/<username>`; backups `/srv/sftpgo/backups` (can be mounted separately)
- `/var/lib/sftpgo`: system user home and working dir; host keys created here by default
- Custom config file may be mounted at `/var/lib/sftpgo` or `/var/lib/sftpgo/.config/sftpgo`

## User/UID
- Default `1000:1000`; override with `--user` (non-root)

## Config
- Configure via env vars (see sftpgo-docs-env-vars.md)

## Healthcheck
- Not mentioned

## Run notes
- `-e SFTPGO_GRACE_TIME=32` (default 0); Docker stop timeout is 10s by default
- Variant notes: distroless has no shell, SQLite disabled, default provider bolt; slim omits jq, git, rsync
