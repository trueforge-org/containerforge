# SFTPGo docs: environment variables page

## Source URL(s) + date
- https://docs.sftpgo.com/latest/env-vars/
- Fetched 2026-11-27

## Naming rule
- Prefix `SFTPGO_` + uppercase config key
- Nested keys joined with `__`; array entries by index, e.g. `SFTPGO_SFTPD__BINDINGS__0__PORT`
- List values comma-separated, e.g. `SFTPGO_COMMON__ACTIONS__EXECUTE_ON=upload,download`

## Named variables
- `SFTPGO_SFTPD__BINDINGS__0__PORT` (first SFTP binding port, no default given)
- `SFTPGO_COMMON__ACTIONS__EXECUTE_ON`
- `SFTPGO_DATA_PROVIDER__PASSWORD`

## Env file locations
- deb/rpm: `/etc/sftpgo/sftpgo.env` (systemd EnvironmentFile)
- `env.d` dir relative to config dir; read after startup, cannot set command-line flags

## Gotchas
- Page gives no names or defaults for config dir, users base dir, backups, log file or FTP/WebDAV ports. Config file page (`config-file/`) not fetched (follow-up budget).
- Escaping in env.d: single quotes are literal; double quotes need `\$`.
