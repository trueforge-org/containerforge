# ronivay/xen-orchestra-docker: Dockerfile, run.sh, healthcheck.sh

## Source URL(s) + date
- https://raw.githubusercontent.com/ronivay/xen-orchestra-docker/0be1b1f87e7895d3cc0091c4088fbfc97317687e/Dockerfile (fetched 2026-11-26)
- .../0be1b1f87e7895d3cc0091c4088fbfc97317687e/run.sh (fetched 2026-11-26; used as entrypoint, see Gotchas)
- .../0be1b1f87e7895d3cc0091c4088fbfc97317687e/healthcheck.sh (fetched 2026-11-26)

## What it is
- Community Docker image for Xen Orchestra (XO) server. Multi-stage Dockerfile, monit + forever supervise services.

## Install/build steps + deps
- Stage `xo-build`: `node:24-trixie`
  - `apt install -y build-essential python3-minimal libpng-dev ca-certificates git fuse`
  - `git clone -b master https://github.com/vatesfr/xen-orchestra /etc/xen-orchestra`
  - `yarn config set network-timeout 200000 && yarn && yarn build` (WORKDIR /etc/xen-orchestra)
  - Web UI v6 build commented out (issue #54).
  - Symlinks every `packages/*` except xo-server, xo-web, xo-server-cloud, xo-server-test, xo-server-test-plugin into `packages/xo-server/node_modules` (plugins).
- Stage `nbd-build`: `debian:trixie`; builds libnbd `v1.23.4` and nbdkit `v1.44.3` from gitlab (`--prefix=/usr/local`, DESTDIR staging).
  - ARGs: `LIBNBD_REPO`, `LIBNBD_VERSION`, `NBDKIT_REPO`, `NBDKIT_VERSION`.
- Runtime `node:24-trixie-slim`:
  - `apt install -y redis-server libvhdi-utils libxml2 python3-minimal python3-jinja2 lvm2 libfuse2t64 nfs-common netbase cifs-utils ca-certificates monit procps curl ntfs-3g`
  - `npm install forever -g`
  - `COPY --from=xo-build /etc/xen-orchestra`, `COPY --from=nbd-build` libnbd/nbdkit into `/usr/local`, `ldconfig`
  - Logs: symlinks `/var/log/redis/redis-server.log`, `/var/log/xo-server.log`, `/var/log/monit.log` -> `/proc/1/fd/1`
  - `ADD healthcheck.sh /healthcheck.sh` (chmod +x); `ADD conf/xo-server.toml.j2 /xo-server.toml.j2`; `ADD conf/monit-services /etc/monit/conf.d/services`; `ADD run.sh /run.sh` (chmod +x)
- `WORKDIR /etc/xen-orchestra/packages/xo-server`, `EXPOSE 80`, `CMD ["/run.sh"]`
- Label: `org.opencontainers.image.authors`

## Runtime deps
- redis-server, monit, forever, python3 + jinja2 (template render), libvhdi-utils, lvm2, nfs-common, cifs-utils, ntfs-3g, libfuse2t64, netbase, procps, curl.

## Entrypoint/flags
- `run.sh` (bash):
  - If `/etc/xo-server/config.toml` missing: export `HTTP_PORT` (default 80), `CERT_PATH` (default `'./temp-cert.pem'`), `KEY_PATH` (default `'./temp-key.pem'`); render `/xo-server.toml.j2` with python3 jinja2 using `env=os.environ` into `/etc/xo-server/config.toml`.
  - `trap StopProcesses EXIT TERM` (monit stop all loop)
  - `/usr/bin/monit && /usr/bin/monit start all`; then `sleep 1d` loop; `wait`.

## Env vars
| Var | Default | Use |
| --- | --- | --- |
| HTTP_PORT | 80 | HTTP listen port in container |
| HTTPS_PORT | unset | enables second listener, autoCert |
| REDIRECT_TO_HTTPS | unset (`true` to enable) | needs HTTPS_PORT |
| CERT_PATH | `'./temp-cert.pem'` (run.sh default) | PEM path, single quotes part of value |
| KEY_PATH | `'./temp-key.pem'` (run.sh default) | key path, single quotes part of value |

## Ports
- EXPOSE 80. HTTPS optional via HTTPS_PORT.

## Volumes/paths
- Documented in README: `/var/lib/xo-server` (xo data), `/var/lib/redis`, `/usr/local/lib/vddk` (VMware VDDK), `/etc/xo-server` (config dir, optional mount).
- Config generated to `/etc/xo-server/config.toml`.

## Healthcheck
- Dockerfile: `HEALTHCHECK --start-period=1m --interval=30s --timeout=5s --retries=2 CMD /healthcheck.sh`
- healthcheck.sh: `curl -s -k -L -I -m 3 http://127.0.0.1:${HTTP_PORT}` must succeed; `pgrep redis-server` and `pgrep rpcbind` must succeed; exit 1 otherwise.

## User/UID
- Not set in Dockerfile (runs as root). README: runs with root or reduced privileges; NFS/SMB remotes need `--cap-add sys_admin --cap-add dac_read_search` and `apparmor:unconfined`.

## Gotchas
- `entrypoint.sh` path (guessed, not in urls.txt) returned 404; used `run.sh` which is the actual CMD.
- Dockerfile uses `git clone -b master` (no pinned ref). Ronivay pinned commit is only for the Dockerfile repo; XO source is unpinned.
- Shell `run.sh` installs `StopProcesses` trap; `--stop-timeout` recommended (README: 60s).
