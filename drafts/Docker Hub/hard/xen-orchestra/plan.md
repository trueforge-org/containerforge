# xen-orchestra — implementation plan
> Source: ./draft.md · Target: apps/xen-orchestra/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `5.213.0` = newest numbered Docker Hub tag of `ronivay/xen-orchestra` (xo-server package version on `master` is `5.214.0`). Draft tag `5.213.0`; image `latest` is a weekly build of `master`. |
| Version caveat | `vatesfr/xen-orchestra` has component tags (`xo-web-v5.51.0`, `xo-server-v5.51.1`, ...) with different numbering than the `xo-server` package version, and no tag for `5.213.0`. The commit for `5.213.0` is UNVERIFIED; pin `XO_REF` to a `master` commit sha (current HEAD seen: `e9760747f90b96c56e3d5fc1534ff3cd5a6d3ee6`). |
| Renovate | `datasource=docker depName=ronivay/xen-orchestra versioning=loose` (tracks the version signal only; `XO_REF` is bumped manually together with it) |
| License | `AGPL-3.0-or-later` (xo-server `package.json`; GitHub shows NOASSERTION because there is no root LICENSE file, root README says AGPL3) |
| Source | https://github.com/vatesfr/xen-orchestra (docs https://docs.xen-orchestra.com/) |
| Downloads | Source tarball `https://github.com/vatesfr/xen-orchestra/archive/<XO_REF>.tar.gz`. No release binaries. Built with `yarn` + `turbo`. |
| Checksum | None published; integrity from the pinned commit sha and `yarn.lock`. |
| Upstream Dockerfile | Reviewed `ronivay/xen-orchestra-docker` `Dockerfile`, `run.sh`, `healthcheck.sh`, `conf/xo-server.toml.j2`, `conf/monit-services`. Build stage `node:24-trixie`: `apt install build-essential python3-minimal libpng-dev ca-certificates git fuse`, `yarn config set network-timeout 200000 && yarn && yarn build`, then symlinks all `packages/*` (except xo-server, xo-web, xo-server-cloud, xo-server-test, xo-server-test-plugin) into `packages/xo-server/node_modules` as plugins. Runtime `node:24-trixie-slim`: `redis-server libvhdi-utils libxml2 python3-minimal python3-jinja2 lvm2 libfuse2t64 nfs-common netbase cifs-utils ca-certificates monit procps curl ntfs-3g`, global `forever`, plus libnbd v1.23.4 and nbdkit v1.44.3 built from source. |
| Root build script | `turbo run build --filter xo-server --filter 'xo-server-*' --filter xo-web --filter @xen-orchestra/web --filter @xen-orchestra/backup-archive && yarn build:doc`; `packageManager` is `yarn@1.22.22`. Upstream image has the v6 web UI build commented out (issue 54). |
| Ports | `80/tcp` HTTP (`HTTP_PORT`), optional HTTPS `HTTPS_PORT` (`443`) with `CERT_PATH`/`KEY_PATH` (self-signed via `autoCert = true` when empty). Redis `6379` is internal to the container; monit web `2812` localhost only. |
| Env vars (upstream image) | `HTTP_PORT` (default 80), `HTTPS_PORT`, `REDIRECT_TO_HTTPS`, `CERT_PATH`, `KEY_PATH`; the config template is rendered once when `/etc/xo-server/config.toml` is missing. xo-server itself reads `config.toml` from `$HOME/.config/xo-server/config.toml` or `/etc/xo-server/config.toml`; `[redis] uri = 'redis://127.0.0.1:6379/0'`; `datadir` default `/var/lib/xo-server/data`. |
| Data paths | `/var/lib/xo-server` (data), `/var/lib/redis`, `/usr/local/lib/vddk` (optional VMware VDDK). |
| Defaults | First login `admin@admin.net` / `admin` (README). |

## 2. Target layout

```
apps/xen-orchestra/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.toml.tmpl   # xo-server config template rendered by envsubst
```

`defaults/` is allow-listed. No `root/`, no `DOWNSTREAM_CHANGES.md`. No Python/jinja2 and no monit/forever: `start.sh` uses `envsubst` (in base `gettext-base`) and supervises two processes itself.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the runtime and the build stage (Node runtime from the draft). Node major in the base is UNVERIFIED; upstream uses Node 24, so confirm `node --version` and that it satisfies xo-server (`>=14` in package.json). Closest siblings: `apps/budge`, `apps/changedetection` (python-node + npm build). `yarn` 1.22.22 must be installed globally (`npm i -g yarn@1.22.22` into `/usr/local`) if the base lacks it.

## 4. Dockerfile

1. Stage `build` (`FROM` the python-node line): `USER root`; `apt-get install -y --no-install-recommends build-essential python3 libpng-dev libfuse-dev pkg-config` (git, ca-certificates, curl already in ubuntu base; `libfuse-dev` is a guess for native modules, UNVERIFIED). `ARG XO_REF`, `ENV YARN_CACHE_FOLDER=/tmp/yarn npm_config_cache=/tmp/npm TURBO_TELEMETRY_DISABLED=1`.
   - `curl -fsSL https://github.com/vatesfr/xen-orchestra/archive/${XO_REF}.tar.gz | tar xz -C /build --strip-components=1`
   - `yarn config set network-timeout 200000 && yarn install --frozen-lockfile && yarn build`
   - plugin symlinks as upstream (`find packages -maxdepth 1 -mindepth 1 -not -name xo-server -not -name xo-web ... -exec ln -s ...`), converted to real links relative to `/app/xen-orchestra`.
2. Final stage (python-node line), `ARG VERSION`, `ARG TARGETARCH`, `USER root`:
   - `apt-get install -y --no-install-recommends valkey-server libvhdi-utils libxml2 lvm2 libfuse2t64 nfs-common cifs-utils ntfs-3g netbase procps` (package names from the upstream image; `redis-server` replaced by `valkey-server`, and Ubuntu 26.04 availability of each package is UNVERIFIED). Pin `valkey-server=${VALKEY_PACKAGE_VERSION}` the way `apps/valkey/Dockerfile` pins `PACKAGE_VERSION` (current valkey pin there is `9.0.4-0ubuntu0.2`, re-check for 26.04 at implementation).
   - `COPY --from=build /build /app/xen-orchestra`; `chown -R root:root /app && chmod -R a+rX /app`.
   - License notices: copy xo-server `package.json` license field and the repo `README.md` to `/usr/share/licenses/xen-orchestra/` (no LICENSE file exists upstream; AGPL-3.0 text from `/usr/share/common-licenses/AGPL-3` if present, otherwise fetch from gnu.org).
   - libnbd/nbdkit (NBD backups) are skipped in the first version, see section 10.
3. `ENV HOME=/config HTTP_PORT=8080 XO_REDIS_URI=""`.
4. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /app/xen-orchestra/packages/xo-server`, `EXPOSE 8080`, `VOLUME /config`, `CMD ["/start.sh"]`. Image ends with `USER apps`.

## 5. docker-bake.hcl

- `APP` = `xen-orchestra`
- `VERSION`:
  ```hcl
  // renovate: datasource=docker depName=ronivay/xen-orchestra versioning=loose
  default = "5.213.0"
  ```
- Extra variable `XO_REF` (commit sha), passed as arg with `VERSION`; `VALKEY_PACKAGE_VERSION` if pinned.
- `LICENSE` = `AGPL-3.0-or-later`, `SOURCE` = `https://github.com/vatesfr/xen-orchestra/`
- Targets `docker-metadata-action`, `image`, `image-local`, `image-all`, group `default`, per `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`. The Dockerfile should assert the built xo-server version equals `VERSION` (`node -p "require('./package.json').version"` in `packages/xo-server` and `test` it) so the tag matches the contents. Caveat: the HEAD sha in section 1 reports xo-server `5.214.0`, not `5.213.0`, so the assertion would fail; either pick the commit whose xo-server version is `5.213.0` (UNVERIFIED which) or set `VERSION` to the version of the pinned commit.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/vatesfr/xen-orchestra/"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: HTTP_PORT
    default: "8080"
    required: false
  - name: XO_REDIS_URI
    default: ""
    required: false      # empty = embedded valkey on 127.0.0.1, data in /config/redis
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: valkey         # ✅ apps/valkey exists
```

HTTPS (`HTTPS_PORT`, `CERT_PATH`, `KEY_PATH`, `REDIRECT_TO_HTTPS`) is left out of v1; terminate TLS in a reverse proxy. Add them only if implemented in `start.sh`.

## 7. start.sh

- `set -euo pipefail`, `mkdir -p /config/data /config/redis /config/.config/xo-server /tmp/xo`.
- Render `/config/.config/xo-server/config.toml` from `/defaults/config.toml.tmpl` with `envsubst '${HTTP_PORT} ${REDIS_URI}'` (start.sh must `export REDIS_URI` first) only when the file is missing (never overwrite user edits). Template: `datadir = '/config/data'`, `[[http.listen]] port = ${HTTP_PORT}` (no `hostname` key, so it listens on all addresses), `[redis] uri = '${REDIS_URI}'`.
- Redis: if `XO_REDIS_URI` is empty, start `valkey-server --bind 127.0.0.1 --port 6379 --dir /config/redis --appendonly yes --daemonize no &` and wait with `valkey-cli ping`; set `REDIS_URI=redis://127.0.0.1:6379/0`. Otherwise `REDIS_URI=$XO_REDIS_URI` (no password is written to files unless the user supplies it in that URI).
- Because `exec` replaces the shell, a trap cannot stop valkey. Instead run valkey with `--appendonly yes` so an abrupt stop loses at most one second of data, and use `tini` (in base) as PID 1 so the orphaned valkey receives the termination signal.
- Final command: `cd /app/xen-orchestra/packages/xo-server && exec node dist/cli.mjs` (upstream monit starts `forever ... dist/cli.mjs`; `forever` dropped). Embedded valkey runs in the background; use `wait -n` only if xo-server is not exec'd, otherwise accept that a valkey crash is detected by xo-server connection errors.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
tcp:
- port: '8080'
filePaths:
- /app/xen-orchestra/packages/xo-server/dist/cli.mjs
- /app/xen-orchestra/packages/xo-web/dist
- /defaults/config.toml.tmpl
- /usr/share/licenses/xen-orchestra
```

`timeoutSeconds`: xo-server startup (plugin loading) is slow; take the larger value from `apps/budge` or `apps/changedetection` and add margin. No env needed (embedded valkey). The xo-web `dist` path is UNVERIFIED; confirm after the first build.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/etc/xo-server/config.toml` | `/config/.config/xo-server/config.toml` (via `HOME=/config`) |
| `/var/lib/xo-server` | `datadir = '/config/data'` |
| `/var/lib/redis`, `/var/run/redis.pid` | `/config/redis`, no pid file |
| `/var/log/xo-server.log`, monit logs | stdout/stderr |
| yarn/npm/turbo caches | `/tmp` |
| HTTP port 80 | 8080 (draft expected 80/443 and `runAsUser 0`) |
| NFS/SMB remotes mount, `SYS_ADMIN`/`DAC_READ_SEARCH` | NOT supported rootless; see section 10. Draft expected SYS_ADMIN; we do not request it. |

## 10. Risks, caveats and open questions

- Mounting NFS/SMB backup remotes needs `SYS_ADMIN` (+ AppArmor unconfined) and root, which conflicts with `USER apps`. Document the feature as unavailable; S3/local-path remotes still work. Decide if a privileged variant is wanted (blocker for full feature parity, not for startup).
- The version-to-commit mapping is UNVERIFIED; building `master` unpinned (as in the draft) is rejected, so `XO_REF` is pinned.
- Build is heavy (turbo + yarn 1 on a large monorepo, long arm64 QEMU builds). Native modules compile with `build-essential`.
- libnbd/nbdkit (NBD-based delta backups) and VMware VDDK omitted; add later via a build stage mirroring upstream if needed.
- Ubuntu 26.04 package availability for `libvhdi-utils`, `libfuse2t64`, `ntfs-3g`, `valkey-server` UNVERIFIED (launchpad lookups for several were empty).
- Default credentials `admin@admin.net`/`admin` must be flagged in docs.
- xo-server must reach XCP-ng/XenServer hosts over the network; no extra container permission needed.
- Redis: draft kept Redis in the same container; here it is embedded by default but can be replaced by the existing `valkey` image through `XO_REDIS_URI`.

## 11. Build and test steps

```sh
cd apps/xen-orchestra
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create xen-orchestra-probe-config
docker run --rm -d --name xen-orchestra-probe --read-only --tmpfs /tmp \
  -v xen-orchestra-probe-config:/config xen-orchestra:5.213.0
docker logs -f xen-orchestra-probe
forgetool containers test --image xen-orchestra:5.213.0 --config ./apps/xen-orchestra/container-test.yaml
docker rm -f xen-orchestra-probe; docker volume rm xen-orchestra-probe-config
```

Readiness signal: xo-server logs `Web server listening on http://[::]:8080` (exact wording UNVERIFIED) and valkey `Ready to accept connections`. Also verify login with `admin@admin.net`/`admin`, and a restart on the same volume keeps data.

## 12. PR checklist

- Branch `feat/add-xen-orchestra`, commit `feat(xen-orchestra): add new container`, PR title the same, target `main`.
- PR template filled in; Notes contains `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: whole build (yarn/turbo), arm64, valkey embedding, package availability on 26.04, pinned `XO_REF` to version match, NFS/SMB remote limitation.
