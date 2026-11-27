# ich777/docker-fivem-server Dockerfile

Source URL(s): https://raw.githubusercontent.com/ich777/docker-fivem-server/master/Dockerfile (fetched 2026-11-27; blob URL is the same content)

## What it is
Debian-based FiveM server image by ich777, built `FROM ich777/debian-baseimage`. Label source: https://github.com/ich777/docker-fivem-server.

## Install/build steps
- `apt-get install --no-install-recommends xz-utils unzip screen` then clean apt lists.
- Downloads gotty v1.0.1 (`https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz`) and extracts to `/usr/bin/`.
- `mkdir /serverdata` and `/serverdata/serverfiles`; `useradd -d $SERVER_DIR -s /bin/bash fivem`; chown data dir.
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`.

## Runtime deps
- xz-utils (extract fx.tar.xz), unzip, screen, gotty (web console).

## Entrypoint/flags
- `ENTRYPOINT ["/opt/scripts/start.sh"]`
- Entrypoint script is in `scripts/start.sh` (see github-ich777-fivem-start.md).

## Env vars (ENV defaults)
| Name | Default |
| --- | --- |
| DATA_DIR | /serverdata |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_CONFIG | "" |
| SRV_ADR | https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/ |
| MANUAL_UPDATES | "" |
| ENABLE_WEBCONSOLE | true |
| GOTTY_PARAMS | -w --title-format FiveM |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| SERVER_KEY | template |
| START_VARS | "" |
| DATA_PERM | 770 |
| USER | fivem |

## Ports
- Not EXPOSEd in the Dockerfile. Chart uses 8080 (gotty web console, inferred from chart targetPort) and 30110/30120 tcp+udp (game).

## Volumes/paths
- `/serverdata`, `/serverdata/serverfiles` (SERVER_DIR).

## User/UID
- Image creates user `fivem` (no fixed UID; start.sh remaps to `UID`/`GID` env, default 99/100). Entrypoint runs as root and drops to `fivem` via `su`.

## Gotchas
- `ulimit -n 2048` is run in its own RUN step, so it has no effect on later steps or the container.
- Entrypoint requires root (usermod/groupmod/chown); not rootless-compatible as shipped.
- Build depends on `ich777/debian-baseimage` base.
