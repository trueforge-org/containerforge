# nginx-proxy-manager — implementation plan
> Source: ./draft.md · Target: apps/nginx-proxy-manager/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2.17.1` (git tag `v2.17.1`, published 2026-11-19, latest release; same as draft). |
| Renovate | `datasource=github-releases depName=NginxProxyManager/nginx-proxy-manager extractVersion=^v(?<version>.+)$ versioning=semver`. |
| License | `MIT` (GitHub license API and `backend/package.json`). |
| Source URL | https://github.com/NginxProxyManager/nginx-proxy-manager |
| Binary | None. The release has no prebuilt assets; the app is built from the tag tarball `https://github.com/NginxProxyManager/nginx-proxy-manager/archive/refs/tags/v2.17.1.tar.gz` (backend: Node + `yarn install`; frontend: `tsc && vite build`, output `frontend/dist`). The same source works for amd64 and arm64. |
| Checksum source | None published for the tag archive: UNVERIFIED (GitHub tag archives only; no checksum file). |
| Docker image | `jc21/nginx-proxy-manager:2.17.1` publishes amd64 and arm64 (verified on Docker Hub). |
| Upstream Dockerfile reviewed | `docker/Dockerfile` at v2.17.1: `FROM nginxproxymanager/nginx-full:certbot-node` (OpenResty, certbot, Node, s6-overlay), copies `backend/` to `/app`, `frontend/dist` to `/app/frontend`, `docker/rootfs` to `/`, `EXPOSE 80 81 443`, `VOLUME /data`, `ENTRYPOINT /init`, env `NODE_ENV=production`, `NODE_OPTIONS=--openssl-legacy-provider`, s6 envs. The base image repo `nginxproxymanager/docker-nginx-full` was not reachable (404 on the guessed paths), so how OpenResty and certbot are built there is UNVERIFIED. |
| OpenResty | Latest tarball `openresty-1.31.9.1.tar.gz` (sha256 `71d49935bdc186dafc1f4b0a8ba44dba1bf4abc8ca52d4621f2039ec8fdcc95f`, computed by downloading it). No OpenResty apt repo for Ubuntu 26.04 `resolute` (404), only `noble`, so build from source. Renovate datasource for it: `github-tags depName=openresty/openresty extractVersion=^v(?<version>.+)$` (tags `v1.31.9.1` seen). |
| certbot | PyPI `certbot 5.10.0` (latest). Ubuntu 26.04 has certbot 5.5.0 in its archive. |
| Env vars (docs and `backend/lib/config.js`) | `DB_MYSQL_HOST`, `DB_MYSQL_PORT` (3306), `DB_MYSQL_USER`, `DB_MYSQL_PASSWORD`, `DB_MYSQL_NAME`, `DB_MYSQL_SSL`, `DB_MYSQL_SSL_REJECT_UNAUTHORIZED`, `DB_MYSQL_SSL_VERIFY_IDENTITY`, `DB_POSTGRES_HOST`, `DB_POSTGRES_PORT` (5432), `DB_POSTGRES_USER`, `DB_POSTGRES_PASSWORD`, `DB_POSTGRES_NAME`, `DB_SQLITE_FILE` (default `/data/database.sqlite`), `DISABLE_IPV6`, `TZ`. `/data/keys.json` is the generated key file. |
| Ports | 80 (proxy HTTP), 443 (proxy HTTPS), 81 (admin UI). |
| Paths | `/data` (db, nginx configs under `/data/nginx/*`, logs under `/data/logs`, `/data/letsencrypt-acme-challenge`), `/etc/letsencrypt`, `/run/nginx`, `/tmp/nginx`, `/var/cache/nginx`, `/var/lib/nginx` (s6 ownership script), `user npm;` and `pid /run/nginx/nginx.pid;` in `nginx.conf`. |
| Backend start | s6 `backend/run`: `cd /app; node --abort_on_uncaught_exception --max_old_space_size=250 index.js` in a restart loop, with `HOME=$NPMHOME` and `CERTBOT_VERSION`. |
| Default admin | Created on first start; the credentials are not on the setup page, UNVERIFIED here (the draft says it must be changed at once). |
| Not on setup page | `INITIAL_ADMIN_EMAIL`, `PUID`: do not list them. |

## 2. Target layout

```
apps/nginx-proxy-manager/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/          # only if upstream rootfs files must be patched and shipped; otherwise patched with sed at build time
```

Prefer no `defaults/`: extract `docker/rootfs/etc/nginx` and `letsencrypt.ini` from the source tarball at build and patch with `sed`. If a patched `nginx.conf` is too fragile for `sed`, ship one in `defaults/etc/nginx/nginx.conf`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (Node for the backend, Python for certbot, matching the draft). Build stage for OpenResty: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS openresty`. Frontend and backend dependency build run in a `python-node` build stage (same Node ABI as runtime for `sqlite3`/`better-sqlite3`). Closest siblings: `apps/changedetection` and `apps/budge` (python-node), `apps/nginx` (nginx paths), `apps/kasmvnc` (multi-stage build plus an nginx started at runtime).

## 4. Dockerfile

1. Stage `openresty` (ubuntu): `USER root`; `apt-get install --no-install-recommends build-essential libpcre2-dev libssl-dev zlib1g-dev perl curl ca-certificates`; download `openresty-${OPENRESTY_VERSION}.tar.gz`, verify against the pinned `OPENRESTY_SHA256`; `./configure --prefix=/usr/local/openresty --conf-path=/etc/nginx/nginx.conf --pid-path=/tmp/nginx/nginx.pid --error-log-path=/dev/stderr --http-log-path=/dev/stdout --http-client-body-temp-path=/tmp/nginx/body --http-proxy-temp-path=/tmp/nginx/proxy --http-fastcgi-temp-path=/tmp/nginx/fastcgi --http-uwsgi-temp-path=/tmp/nginx/uwsgi --http-scgi-temp-path=/tmp/nginx/scgi --with-http_v2_module --with-http_ssl_module --with-http_realip_module --with-http_gzip_static_module --with-stream --with-stream_ssl_module --with-pcre-jit`; `make install`. Add any module NPM templates need (`http_sub`, `http_auth_request`, `http_stub_status`) after checking `docker/rootfs/etc/nginx/nginx.conf` and `backend/templates`, UNVERIFIED.
2. Stage `app` (python-node): `ARG VERSION`; `USER root`; download the tag tarball, extract to `/src`; `cd frontend && yarn install && yarn build`; `cd ../backend && yarn install --production` (use `corepack enable` if yarn is absent, UNVERIFIED in python-node); assemble `/out/app` (backend) with `/out/app/frontend` (dist); copy `docker/rootfs/etc/nginx` and `etc/letsencrypt.ini`, `var/www/html` to `/out`; copy `LICENSE` to `/out/licenses/`. Caches (`YARN_CACHE_FOLDER`, `npm_config_cache`) to `/tmp`.
3. Final stage `python-node`: `ARG VERSION`, `ARG TARGETARCH`; `USER root`; `apt-get install --no-install-recommends libpcre2-8-0 libssl3t64 zlib1g jq openssl apache2-utils logrotate` only for packages the base lacks (check with `dpkg -l` first); `COPY --from=openresty /usr/local/openresty /usr/local/openresty`; symlink `/usr/local/openresty/nginx/sbin/nginx` to `/usr/local/bin/nginx` and `openresty`; `COPY --from=app /out/app /app/npm` (read-only app), `/out/etc/nginx` to `/etc/nginx`, `/out/var/www/html` to `/var/www/html`; `mkdir -p /usr/share/licenses/nginx-proxy-manager` and copy `LICENSE`.
4. Patch config with `sed`: delete `user npm;`, set `pid /tmp/nginx/nginx.pid;`, `include /data/...` stays valid because `/data` is a symlink to `/config/data`; `proxy_cache_path` to `/tmp/nginx/cache/...`; mkdir `/tmp` dirs at start, not build (tmpfs). `ln -s /config/data /data`; `ln -s /config/letsencrypt /etc/letsencrypt` (target created by `start.sh`).
5. certbot: add it to the base's `/app/venv` with `/app/venv/bin/pip install --no-cache-dir certbot==${CERTBOT_VERSION}` plus the dnspython-based plugins NPM needs at runtime (see section 10); pip caches in `/tmp`. Per the python rules `start.sh` seeds `/config/venv` from `/app/venv` when missing so DNS plugins can be installed at runtime.
6. `ENV NODE_ENV=production NODE_OPTIONS=--openssl-legacy-provider HOME=/config PATH=/config/venv/bin:$PATH` (keep the `NODE_OPTIONS` value from upstream; revisit if the base Node refuses the flag).
7. `chown -R root:root /app /etc/nginx /usr/local/openresty && chmod -R a+rX`. Writable dirs live under `/config` and `/tmp` only.
8. Final instructions in this order: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 80 81 443`, `VOLUME /config`, `WORKDIR /app/npm`, `CMD ["/start.sh"]`. The image's last `USER` is `USER apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "nginx-proxy-manager" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=NginxProxyManager/nginx-proxy-manager extractVersion=^v(?<version>.+)$ versioning=semver
  default = "2.17.1"
}

variable "OPENRESTY_VERSION" {
  // renovate: datasource=github-tags depName=openresty/openresty extractVersion=^v(?<version>.+)$ versioning=loose
  default = "1.31.9.1"
}

variable "OPENRESTY_SHA256" { default = "71d49935bdc186dafc1f4b0a8ba44dba1bf4abc8ca52d4621f2039ec8fdcc95f" }

variable "CERTBOT_VERSION" {
  // renovate: datasource=pypi depName=certbot
  default = "5.10.0"
}

variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/NginxProxyManager/nginx-proxy-manager" }
```

`image` passes `VERSION`, `OPENRESTY_VERSION`, `OPENRESTY_SHA256`, `CERTBOT_VERSION` as args and sets the two OCI labels. Targets: `docker-metadata-action`, `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64), `group "default"` with `image-local`. A renovate bump of `OPENRESTY_VERSION` also needs a new sha: note this in the PR (a `customManager` or manual update). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/NginxProxyManager/nginx-proxy-manager"
ports:
  - port: 80
    protocol: tcp
    required: false
  - port: 81
    protocol: tcp
    required: false
  - port: 443
    protocol: tcp
    required: false
env:
  - name: DB_MYSQL_HOST
    default: ""
    required: false
  - name: DB_MYSQL_PORT
    default: "3306"
    required: false
  - name: DB_MYSQL_USER
    default: ""
    required: false
  - name: DB_MYSQL_PASSWORD
    default: ""
    required: false
  - name: DB_MYSQL_NAME
    default: ""
    required: false
  - name: DB_SQLITE_FILE
    default: "/data/database.sqlite"
    required: false
  - name: DISABLE_IPV6
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: mariadb
```

`mariadb` exists as `apps/mariadb` (✅). The MariaDB variables are optional because SQLite is the default. Add the `DB_POSTGRES_*` variables only if you also verify Postgres support in the running image (the config code reads them; the setup page does not mention them). `/data` and `/etc/letsencrypt` from the chart are served by the `/config` volume (`/config/data`, `/config/letsencrypt`), so only `/config` is listed.

## 7. start.sh

1. `set -euo pipefail`. Create `/config/data/{nginx,logs,letsencrypt-acme-challenge,access}`, `/config/data/nginx/{default_host,proxy_host,redirection_host,dead_host,stream,temp,custom}`, `/config/letsencrypt`, and `/tmp/nginx/{body,proxy,fastcgi,uwsgi,scgi,cache/public,cache/private}` `/tmp/letsencrypt-lib` `/tmp/letsencrypt-log` (idempotent `mkdir -p`).
2. Seed `/config/venv` from `/app/venv` only if missing or empty (real directory, not a symlink).
3. Seed `/config/data/nginx/...` default and dummy certificate files only when missing (upstream's s6 `prepare` scripts do this; replicate only what the running app needs, UNVERIFIED which files).
4. `DISABLE_IPV6=true`: remove `listen [::]` lines from a copy of the `conf.d` files under `/tmp`; otherwise leave. Never write to `/app` or `/etc/nginx`.
5. Start openresty in the background (`nginx -g 'daemon off;'`), start the backend `node --max_old_space_size=250 /app/npm/index.js` in the foreground-supervised loop, forward `SIGTERM` with a `trap` to both, and `wait -n` so the container exits if either dies. The last long-lived process cannot be a plain `exec` because two processes must run; document it in a comment.
6. Servers bind `0.0.0.0` (nginx default) and the admin UI on 81 (from upstream `conf.d/production.conf`, UNVERIFIED path). Database settings come from the `DB_*` env vars read by the backend itself, and the password stays in the environment, never written to files or the process list.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '80'
- port: '81'
- port: '443'
http:
- port: '81'
  path: /api/
filePaths:
- /app/npm/index.js
- /usr/local/bin/nginx
- /usr/share/licenses/nginx-proxy-manager/LICENSE
```

All three ports (80, 81, 443) have a tcp probe. The test starts with no env vars, so SQLite is used and the app is testable in one container; the MariaDB path is not exercised (it is optional), so run it by hand once with the mariadb image. The `/api/` path returning the status JSON is UNVERIFIED; check `backend/routes/main.js` and adjust the path (never loosen to a no-op).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/data` | symlink to `/config/data` (volume). |
| `/etc/letsencrypt` | symlink to `/config/letsencrypt`. |
| `/run/nginx`, `/tmp/nginx`, `/var/cache/nginx`, `/var/lib/nginx`, `/var/log/nginx` | `/tmp/nginx/...`; logs to stdout/stderr or `/config/data/logs`. |
| `/var/lib/logrotate`, `/etc/logrotate.d` | drop logrotate (or write state to `/tmp`); logs are small in `/config/data/logs`, see section 10. |
| `user npm;` in `nginx.conf`, s6 `PUID`/`PGID`, `chown` scripts | removed; runs as `apps`. |
| `HOME=$NPMHOME` | `HOME=/config`; all caches (`yarn`, `pip`, `npm`) to `/tmp`. |
| `/etc/sysctl.conf` edit (`fs.file-max`) | dropped, not allowed rootless. |
| certbot venv writes (DNS plugin installs) | persistent `/config/venv`. |
| Ports 80/443 | non-root bind needs `net.ipv4.ip_unprivileged_port_start<=80` (Docker's default is 0 for containers; Kubernetes may need `NET_BIND_SERVICE` or the sysctl), UNVERIFIED on the target runtimes. |

Draft reconciliation: the chart runs as uid 0 with a writable rootfs; this image runs as `apps`, read-only rootfs compatible; not privileged; the two extra persistence paths collapse to `/config`, which is a chart migration step (copy `/data` to `<config>/data`, `/etc/letsencrypt` to `<config>/letsencrypt`).

## 10. Risks, caveats and open questions

- Largest unknown: the upstream base `nginx-full:certbot-node` composition (modules compiled into OpenResty, certbot setup) was not verified. A missing nginx module shows up as a config error when NPM renders a host template.
- NPM runs OpenResty and Node as two processes without s6; a small shell supervisor loop is needed and must forward signals (section 7).
- Ports 80/81/443 as non-root (section 9). Moving to 8080/8081/8443 would require patching `backend/templates`, UNVERIFIED how many places; kept as upstream.
- Python venv relocation to `/config/venv` can break script shebangs; if so use `python -m venv` created at first start from `/app/venv`'s interpreter or `--system-site-packages`.
- DNS-challenge plugins: NPM installs them with pip at runtime (UNVERIFIED), hence the writable venv.
- Default admin credentials are created at first start and must be changed (draft caveat). Let's Encrypt needs public DNS and inbound 80/443 (draft caveat). Host ports 80/443/81 must be free.
- No checksum for the NPM source tarball (UNVERIFIED); the tag is the pin.
- OpenResty version has no automatic sha update: a renovate bump needs a matching `OPENRESTY_SHA256`.
- arm64 builds untested; `NODE_OPTIONS=--openssl-legacy-provider` may fail on newer Node and then needs removing.
- The build is heavy (OpenResty compile plus Vite build): expect a long build and a larger image than upstream.

## 11. Build and test steps

```sh
cd apps/nginx-proxy-manager
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name nginx-proxy-manager-probe --read-only --tmpfs /tmp \
  -v nginx-proxy-manager-probe-config:/config nginx-proxy-manager:2.17.1
docker logs -f nginx-proxy-manager-probe
forgetool containers test --image nginx-proxy-manager:2.17.1 --config ./apps/nginx-proxy-manager/container-test.yaml
docker rm -f nginx-proxy-manager-probe; docker volume rm nginx-proxy-manager-probe-config
```

Expected readiness: the backend logs its listening line (the upstream backend prints `Backend PID ... listening on port 3000`, UNVERIFIED), openresty starts without `[emerg]`, ports 80, 81 and 443 are open, and `curl http://localhost:81/` returns the admin UI. Repeat on the same volume for the second-start check. Run once more with a MariaDB container and the `DB_MYSQL_*` variables. Round limit 10.

## 12. PR checklist

- Branch `feat/add-nginx-proxy-manager`, commit and PR title `feat(nginx-proxy-manager): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only those that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Honest list of what is untested: arm64, MariaDB path, DNS challenge plugin install, Let's Encrypt issuance, non-root bind of ports 80/443 on Kubernetes, config migration from the chart's `/data` layout.
- Document the `/data` and `/etc/letsencrypt` to `/config` change and that `apps/mariadb` is the optional database.
