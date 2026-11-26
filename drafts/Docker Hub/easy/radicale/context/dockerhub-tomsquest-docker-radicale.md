# tomsquest/docker-radicale (Docker Hub)

Source URL(s) + fetch date (2026-11-26):
- https://hub.docker.com/r/tomsquest/docker-radicale (fetched)

## What it is
Docker image for the Radicale calendar and contact server, with security hardening, volume handling and init. 10M+ pulls, 73 stars. Latest tag about 42.2 MB.

## Features
- Read-only container, drops extra privileges, runs as non-root. Bundles git and pytz/tzdata.

## Arch support
- amd64, arm, arm64, 386.

## Tags
- `latest` (only tag in recent list). Tag scheme: `<arch>.<radicale version>.<increment>` (examples for 3.0.6: `386.3.0.6.0`, `amd64.3.0.6.0`, `arm.3.0.6.0`, `arm64.3.0.6.0`). Draft uses wrapper tag `3.9.2.0`.

## Run examples
- Basic: `docker run -d --name radicale -p 5232:5232 -v ~/radicale/data:/data tomsquest/docker-radicale`
- Hardened: port bound to 127.0.0.1:5232, `--init`, `--read-only`, `--security-opt="no-new-privileges:true"`, `--cap-drop ALL` then add CHOWN, SETUID, SETGID, KILL, `--pids-limit 50`, `--memory 256M`, data volume.
- Compose file in the repo (not fetched).

## Env vars
- `TAKE_FILE_OWNERSHIP` (default true; false skips chown).
- `UID` and `GID` runtime overrides (incompatible with `--read-only`).
- `BUILD_UID` and `BUILD_GID` build args (also usable as env per page).

## Ports, volumes, config
- 5232. `/data` data (collections `/data/collections`, which is `filesystem_folder`). `/config` custom config mounted read-only, needs `hosts = 0.0.0.0:5232` and `filesystem_folder = /data/collections`.
- Default UID/GID 2999.

## Extending
- FROM tomsquest/docker-radicale, add plugins via pip (RadicaleIMAP, RadicaleInfCloud). radicale-imap is not compatible with Radicale 3.0.
