# storj/storagenode-docker (upstream image Dockerfile and entrypoint)

Source URL(s) + fetch date (all 2026-11-26; main branch):
- https://raw.githubusercontent.com/storj/storagenode-docker/main/Dockerfile
- https://raw.githubusercontent.com/storj/storagenode-docker/main/docker/entrypoint

## What it is
Upstream Docker packaging for the Storj storage node. The image does not contain the node binaries; they are downloaded at first start from the version server and kept under `/app/config/bin`. Supervisor runs the node (and optionally the updater).

## Install/build steps
Dockerfile (main):
- `ARG DOCKER_PLATFORM`, `ARG DOCKER_ARCH`; `FROM --platform=${DOCKER_PLATFORM:-linux/amd64} ${DOCKER_ARCH:-amd64}/debian:bookworm-slim`
- `ARG GOARCH`, `ARG VERSION_SERVER_URL`, `ARG SUPERVISOR_SERVER`
- `ENV GOARCH=${GOARCH:-amd64} VERSION_SERVER_URL=${VERSION_SERVER_URL:-https://version.storj.io} SUPERVISOR_SERVER=${SUPERVISOR_SERVER:-unix}`
- `apt-get install -y --no-install-recommends ca-certificates supervisor unzip wget`; `update-ca-certificates`
- `mkdir -p /var/log/supervisor /app`; `COPY docker/ /`
- `chmod -R a+rw /etc/supervisor /var/log/supervisor /app` (non-root access)
- Supervisor config symlink `/etc/supervisord.conf` -> `/etc/supervisor/supervisord.conf`
- `EXPOSE 28967`, `EXPOSE 14002`, `WORKDIR /app`, `ENTRYPOINT ["/entrypoint"]`
- ENV defaults: `ADDRESS=""`, `EMAIL=""`, `WALLET=""`, `STORAGE="2.0TB"`, `SETUP="false"`, `AUTO_UPDATE="true"`, `LOG_LEVEL=""`, `BINARY_STORE_DIR="/app/config/bin"`
- No VOLUME, CMD, USER, STOPSIGNAL or HEALTHCHECK.

Entrypoint (docker/entrypoint, verbatim essentials):
- `BINARY_DIR=/app/bin`; `BINARY_STORE_DIR=${BINARY_STORE_DIR:-/app/config/bin}`
- Binary URL: `wget -O- "${VERSION_SERVER_URL}/processes/${process}/${version}/url?os=linux&arch=${GOARCH}"`; download zip to `/tmp/<binary>.zip`, `unzip -p` into `BINARY_STORE_DIR`.
- For `storagenode-updater` then `storagenode`: download at `minimum` version if missing; then `should-update` loop over `minimum`, `suggested`.
- Run params: `RUN_PARAMS` + `--config-dir config` + `--identity-dir identity`; `--version.server-address=${VERSION_SERVER_URL}` when set.
- `AUTO_UPDATE` normalized to `false` unless exactly `true`.
- `STORJ_CONSOLE_ADDRESS` default `0.0.0.0:14002`, exported.
- Node params added when set: `--storage.allocated-disk-space=${STORAGE}`, `--contact.external-address=${ADDRESS}`, `--operator.email=${EMAIL}`, `--operator.wallet=${WALLET}`, `--log.level=${LOG_LEVEL}`.
- `SETUP=true`: `exec /app/bin/storagenode setup ${SNO_RUN_PARAMS} ${*}`.
- Otherwise: patches `/etc/supervisor/supervisord.conf` with `sed` (updater command, node command `storagenode run ...`), removes `user=root` when not root, sets `SUPERVISOR_SERVER` mode (`unix` default, `public_port` on `*:9001`, `private_port` on `127.0.0.1:9001`), then `exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf`.

## Runtime deps
debian:bookworm-slim, supervisor, unzip, wget, ca-certificates. Network to `VERSION_SERVER_URL` (default https://version.storj.io) and GitHub release downloads.

## Binaries/entrypoint/CLI flags
Entrypoint `/entrypoint`; binaries `/app/bin/storagenode`, `/app/bin/storagenode-updater`. Flags as listed above.

## Env vars (table)
| Variable | Default | Use |
| --- | --- | --- |
| `ADDRESS` | "" | `--contact.external-address` |
| `EMAIL` | "" | `--operator.email` |
| `WALLET` | "" | `--operator.wallet` |
| `STORAGE` | 2.0TB | `--storage.allocated-disk-space` |
| `SETUP` | false | `true` runs `storagenode setup` instead of run |
| `AUTO_UPDATE` | true | runs storagenode-updater under supervisor when `true` |
| `LOG_LEVEL` | "" | `--log.level` |
| `BINARY_STORE_DIR` | /app/config/bin | downloaded binaries |
| `VERSION_SERVER_URL` | https://version.storj.io | version server |
| `GOARCH` | amd64 | arch used for the download URL |
| `SUPERVISOR_SERVER` | unix | `unix`, `public_port` (*:9001) or `private_port` (127.0.0.1:9001) |
| `STORJ_CONSOLE_ADDRESS` | 0.0.0.0:14002 | dashboard listen address |
| `RUN_PARAMS` | "" | extra params for run |

## Ports
28967 (node public port; tcp and udp per TrueCharts), 14002 (dashboard).

## Volumes/paths and persistent data
Upstream: `/app/config` (config, binaries, storage) and `/app/identity` (identity). No VOLUME instruction in the Dockerfile; the chart supplies them.

## User/UID & permissions
Dockerfile makes `/etc/supervisor`, `/var/log/supervisor` and `/app` world-writable for non-root use. Runs as root by default (chart uses root).

## Config files and formats
supervisord config at `/etc/supervisor/supervisord.conf` (patched by sed at start).

## Healthcheck/readiness endpoints
None in the Dockerfile.

## Version/release info and asset naming
Node versions come from the version server, not the image tag. The image itself is `storjlabs/storagenode` (latest only on Docker Hub).

## Arch support
`GOARCH` build arg/env selects arm64/amd64 for downloads.

## Gotchas
- Upstream auto-updates the node binary inside the container; the planned image drops supervisor and the updater (plan.md, consistent with this file).
- `SETUP=true` runs setup on every start (the script does not check for an existing config); plan.md's planned idempotency check is an addition.
- `user=root` removal and public/private supervisor modes are entrypoint details the plan does not use.
