# Upstream image: sameersbn/docker-apt-cacher-ng (Dockerfile + entrypoint.sh)

**Source URL(s):** https://raw.githubusercontent.com/sameersbn/docker-apt-cacher-ng/6d0816a/Dockerfile (blob URL in urls.txt is the same file); https://raw.githubusercontent.com/sameersbn/docker-apt-cacher-ng/6d0816a/entrypoint.sh (fetched 2026-11-27)

## Dockerfile
- `FROM ubuntu:jammy-20230816`, maintainer label.
- ENV: `APT_CACHER_NG_VERSION=3.7.4`, `APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng`, `APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng`, `APT_CACHER_NG_USER=apt-cacher-ng`.
- RUN: `apt-get install --no-install-recommends apt-cacher-ng=${APT_CACHER_NG_VERSION}* ca-certificates wget`.
- sed in `/etc/apt-cacher-ng/acng.conf`: `ForeGround: 0` -> `ForeGround: 1`; `PassThroughPattern` set to `.* #` (allows passthrough of all targets).
- `COPY entrypoint.sh /sbin/entrypoint.sh`, chmod 755.
- `EXPOSE 3142/tcp`.
- `HEALTHCHECK --interval=10s --timeout=2s --retries=3 CMD wget -q -t1 -O /dev/null http://localhost:3142/acng-report.html || exit 1`
- `ENTRYPOINT ["/sbin/entrypoint.sh"]`, `CMD ["/usr/sbin/apt-cacher-ng"]`.
- No USER directive.

## entrypoint.sh
- Creates and chowns: `/run/apt-cacher-ng` (root-owned dir, mode 0755, chown apt-cacher-ng user), `$APT_CACHER_NG_CACHE_DIR` (chown apt-cacher-ng:root), `$APT_CACHER_NG_LOG_DIR` (chown apt-cacher-ng).
- If first arg starts with `-`, passes args to apt-cacher-ng.
- Default launch: `exec start-stop-daemon --start --chuid apt-cacher-ng:apt-cacher-ng --exec "$(command -v apt-cacher-ng)" -- -c /etc/apt-cacher-ng ${EXTRA_ARGS}`
- Otherwise `exec "$@"`.

## Env vars
| Var | Value |
| --- | --- |
| APT_CACHER_NG_VERSION | 3.7.4 |
| APT_CACHER_NG_CACHE_DIR | /var/cache/apt-cacher-ng |
| APT_CACHER_NG_LOG_DIR | /var/log/apt-cacher-ng |
| APT_CACHER_NG_USER | apt-cacher-ng |

## Ports
- 3142/tcp

## Volumes/paths
- `/var/cache/apt-cacher-ng` (cache), `/var/log/apt-cacher-ng` (logs), `/run/apt-cacher-ng` (pid dir).

## User/UID
- Daemon runs as `apt-cacher-ng` via start-stop-daemon (`--chuid`). Image itself has no USER.

## Healthcheck
- `wget http://localhost:3142/acng-report.html`

## Gotchas
- Pinned to Ubuntu jammy base and apt-cacher-ng 3.7.4 (upstream image is stale: apt 3.7.4 on jammy).
