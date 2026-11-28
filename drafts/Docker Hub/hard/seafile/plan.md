# seafile — implementation plan
> Source: ./draft.md · Target: apps/seafile/ · Difficulty: hard (multi-process, MariaDB and cache dependencies, x86_64-only tarball) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 14.0.11 (git tag `v14.0.11-server`; matches the digest-pinned seafile-mc:14.0.11 image used by TrueCharts). Newer tags exist only on the 13.0 line (`v13.0.30-server`, 2026-11-20). |
| Draft tag | `docker.io/seafileltd/seafile-mc:14.0.11` (same version). |
| Renovate | `datasource=github-tags depName=haiwen/seafile-server versioning=loose extractVersion=^v(?<version>\d+\.\d+\.\d+)-server$`, and restrict to the 14.x line with a packageRule (`allowedVersions: "/^14\\./"`) so it does not jump to or from 13.x. UNVERIFIED: that this regex is accepted as written. |
| License | AGPL-3.0 for the repository ("released under Affero GPLv3", with an OpenSSL linking exception; code under `python/` is Apache-2.0). SPDX `AGPL-3.0-only` (UNVERIFIED: `-only` or `-or-later`). |
| Source | https://github.com/haiwen/seafile-server (manual https://manual.seafile.com/) |
| Download URLs | None found. The latest GitHub release is `v7.1.1-server` from 2019 with no assets, and web search found no 14.0 tarball link. The official generic-Linux tarball (x86_64 only per the draft) lives on the Seafile download page. UNVERIFIED: the exact URL and any checksum. Fallback route: `COPY --from=docker.io/seafileltd/seafile-mc:14.0.9` (the draft lists it for both architectures). |
| Checksum | UNVERIFIED. Pin the source image by digest (`docker buildx imagetools inspect seafileltd/seafile-mc:14.0.11`). |
| Upstream Dockerfile reviewed | https://github.com/haiwen/seafile-docker/blob/7880bf3/image/seafile_14.0/Dockerfile (summary): `ubuntu:24.04` with phusion baseimage `/sbin/my_init`; copies the local `seafile-server-${SEAFILE_VERSION}` into `/opt/seafile/` with chmod 777; installs nginx (nginx.org repo), fuse, poppler-utils, exiftool, libmysqlclient-dev, libmemcached, LDAP libs, python3 and a long pip list (click, termcolor, colorlog, pytz, sqlalchemy, pymysql, jinja2, django-pylibmc, pylibmc, psd-tools, lxml, django, cffi, future, mysqlclient, captcha, django_simple_captcha, pyjwt, djangosaml2, pysaml2, pycryptodome, python-ldap, pillow, pillow-heif, cairosvg, cryptography); `EXPOSE 80`; `CMD ["/sbin/my_init","--","/scripts/enterpoint.sh"]`. |
| Ports | 80 (nginx in the upstream image), Seahub 8000 and fileserver 8082 (manual), draft adds 443 (inferred). |
| Env vars (manual, Docker setup) | `SEAFILE_MYSQL_DB_HOST` (default `db`), `SEAFILE_MYSQL_DB_PORT` 3306, `SEAFILE_MYSQL_DB_USER` `seafile`, `SEAFILE_MYSQL_DB_PASSWORD` (required), `INIT_SEAFILE_MYSQL_ROOT_PASSWORD` (first deploy only), `SEAFILE_MYSQL_DB_CCNET_DB_NAME`, `SEAFILE_MYSQL_DB_SEAFILE_DB_NAME`, `SEAFILE_MYSQL_DB_SEAHUB_DB_NAME`, `INIT_SEAFILE_ADMIN_EMAIL` (`me@example.com`), `INIT_SEAFILE_ADMIN_PASSWORD` (`asecret`), `SEAFILE_SERVER_HOSTNAME` (required), `SEAFILE_SERVER_PROTOCOL` (`http`), `JWT_PRIVATE_KEY` (required, at least 32 characters), `CACHE_PROVIDER` (`redis` default, or `memcached`), `REDIS_HOST` (`redis`), `REDIS_PORT` 6379, `REDIS_PASSWORD`, `MEMCACHED_HOST`/`MEMCACHED_PORT` 11211, `TIME_ZONE` (`UTC`), `NON_ROOT` (default `false`). UNVERIFIED: default database names. |
| Data path | `/shared` inside the container (logs under `/shared/logs/seafile`); the draft's `/shared/seafile` pvc. |

## 2. Target layout

- `apps/seafile/Dockerfile`
- `apps/seafile/docker-bake.hcl`
- `apps/seafile/settings.yaml`
- `apps/seafile/container-test.yaml`
- `apps/seafile/start.sh`
- `apps/seafile/defaults/nginx.conf.tpl` (template for the front proxy, rendered into `/tmp` at start)
- `apps/seafile/etc/` only if the configuration templates from the upstream image are needed (UNVERIFIED).

No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Seahub is a Django app with a long pip list, so the ubuntu base with a venv in `/app/venv` follows the `apps/changedetection` venv pattern (note: that app uses the `python-node` base, not ubuntu; the draft's alternative `ghcr.io/trueforge-org/python` base is worth considering) and `apps/bookstack` for the multi-process layout on ubuntu. UNVERIFIED: that Python of Ubuntu 26.04 works with the seahub requirements (upstream uses 24.04). Closest sibling: `apps/bookstack` (several processes, MariaDB) and `apps/changedetection` (venv).

## 4. Dockerfile

1. Source stage: `FROM docker.io/seafileltd/seafile-mc:14.0.11@sha256:<digest> AS source` with a `# renovate: datasource=docker depName=seafileltd/seafile-mc versioning=semver` comment above it (UNVERIFIED digest). Use the official tarball instead if its URL and a checksum are confirmed.
2. Final stage: `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
3. apt (not in the ubuntu base, UNVERIFIED which are already present): `nginx`, `python3`, `python3-venv`, `python3-dev`, `pkg-config`, `libmariadb-dev`, `libmemcached11t64`, `libldap2-dev`, `libsasl2-dev`, `poppler-utils`, `libimage-exiftool-perl`, `fuse3`, `libssl3t64`, `ca-certificates`, `curl`, `build-essential` (removed after the pip step; purge it in the same `RUN`). Pin `nginx` to a version that exists on resolute (UNVERIFIED) only if it ends up being the shipped product; it is not, so no pin.
4. Venv: `python3 -m venv /app/venv`, then `pip install --no-cache-dir` the list from the upstream Dockerfile (section 1) with `PIP_CACHE_DIR=/tmp/pip`; pin versions as the upstream `requirements` files at tag `v14.0.9-server`/seahub (UNVERIFIED, read them before writing).
5. `COPY --from=source /opt/seafile/seafile-server-14.0.11 /app/seafile-server`, then `chown -R apps:apps /app && chmod -R 755 /app`. Verify the binaries run on 26.04 glibc with `ldd` (UNVERIFIED).
6. Licenses: copy `/app/seafile-server/LICENSE*` to `/usr/share/licenses/seafile/` (paths UNVERIFIED).
7. `ENV HOME=/config PYTHONPATH=... (from upstream setup scripts, UNVERIFIED) TIME_ZONE=UTC NON_ROOT=true`. UNVERIFIED: what `NON_ROOT` changes upstream; the name appears in the manual's env table and is the hook for rootless support.
8. `USER apps`, then `COPY --chmod=0755 . /`.
9. `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "seafile" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=haiwen/seafile-server versioning=loose extractVersion=^v(?<version>\d+\.\d+\.\d+)-server$
  default = "14.0.11"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/haiwen/seafile-server" }
```
Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 and arm64; arm64 depends on the `seafile-mc` image having an arm64 manifest, which the draft claims, UNVERIFIED), `group "default"`. Validate with `docker buildx bake --print`. The source-image tag in the Dockerfile must equal `VERSION`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/haiwen/seafile-server"`.
- `ports`: `8080` tcp, required false (our nginx front, replaces upstream 80/443; TLS is left to an ingress; Seahub 8000 and the fileserver 8082 stay on localhost inside the container).
- `env` (names from the manual): `SEAFILE_MYSQL_DB_HOST` default `mariadb`; `SEAFILE_MYSQL_DB_PORT` `3306`; `SEAFILE_MYSQL_DB_USER` `seafile`; `SEAFILE_MYSQL_DB_PASSWORD` default `""` (required true, but the image must still start without it, see section 7); `SEAFILE_MYSQL_DB_CCNET_DB_NAME`, `SEAFILE_MYSQL_DB_SEAFILE_DB_NAME`, `SEAFILE_MYSQL_DB_SEAHUB_DB_NAME` (defaults UNVERIFIED, use `ccnet_db`, `seafile_db`, `seahub_db` only after confirming); `INIT_SEAFILE_MYSQL_ROOT_PASSWORD` `""`; `INIT_SEAFILE_ADMIN_EMAIL` `me@example.com`; `INIT_SEAFILE_ADMIN_PASSWORD` `""` (do not default to the upstream `asecret`); `SEAFILE_SERVER_HOSTNAME` `localhost`; `SEAFILE_SERVER_PROTOCOL` `http`; `JWT_PRIVATE_KEY` `""` (generated into `/config` when empty); `CACHE_PROVIDER` `redis`; `REDIS_HOST` `valkey`; `REDIS_PORT` `6379`; `REDIS_PASSWORD` `""`; `TIME_ZONE` `UTC`.
- `volumes`: `/config` required true (the draft's `/shared/seafile`).
- `dependencies`: `mariadb` ✅, `valkey` ✅ (both exist in apps/).

## 7. start.sh

- `set -eu`; the script must start with no env vars (the test runs that way).
- Seed `/config` only when missing: `/config/seafile/{conf,ccnet,seafile-data,seahub-data,logs}`; create `/config/seafile/seafile-server-latest -> /app/seafile-server` (symlink inside the writable volume, because the upstream scripts derive their top directory from the install path and write `pids`, `conf`, `logs` next to it; link `pids` to `/tmp/seafile-pids`). UNVERIFIED which scripts hard-code `../`.
- Secrets: if `JWT_PRIVATE_KEY` is empty, generate `openssl rand -hex 32` once into `/config/seafile/jwt.key` and reuse it. Do not echo secrets and do not put them on the command line.
- Render `/tmp/nginx.conf` from `defaults/nginx.conf.tpl` (listen 8080, proxy `/` to 127.0.0.1:8000 and `/seafhttp` to 127.0.0.1:8082 and serve `/media`; pid, temp and log paths in `/tmp`), then start `nginx -c /tmp/nginx.conf` in the background FIRST so the port 8080 is open while the rest waits.
- Wait for MariaDB (`mariadb-admin ping` or a bash `/dev/tcp` loop with retry and a log line `waiting for database`), then on first run create the databases and run the upstream setup script with the env values, passing the DB password through the environment, not argv. Admin creation only when `INIT_SEAFILE_ADMIN_PASSWORD` is set. DB-side passwords are applied on every start by the database container, not here.
- Run Seahub and the seafile fileserver under a tiny supervisor loop in the script (start both, `wait -n`, exit if one dies); the last foreground process is Seahub via `exec` only if the fileserver is started in the background and monitored by a trap. Final command: `exec /app/seafile-server/seahub.sh start-fastcgi`-style invocation is UNVERIFIED; read `seahub.sh` and prefer `gunicorn` bound to `127.0.0.1:8000` run directly with `exec`.
- Never write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
# narrowed: requires external mariadb and valkey; full functional test not feasible in single-container suite
tcp:
- port: '8080'
filePaths:
- /app/seafile-server
- /app/venv/bin/python
```
The tcp probe on 8080 works without a database only because `start.sh` launches nginx before waiting for MariaDB (502 from the proxy is acceptable for the probe). This narrowing meets the protocol's three criteria (hard DB dependency, no start without it, no sidecar primitive in the test file). Step 3 of the protocol (run and log parse) is still mandatory, with a real MariaDB container on a shared network for the by-hand check.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects root, writable rootfs and `/shared/seafile` persistence. Reconciled: user `apps` 568, read-only rootfs, persistent state in `/config/seafile` (conf, ccnet, seafile-data, seahub-data, logs, JWT key), ephemeral state in `/tmp` (pids, nginx temp, sockets, python caches).
- Upstream writes: `conf/`, `ccnet/`, `seafile-data/` (user libraries), `seahub-data/` (avatars, thumbnails), `pids/`, `logs/`, `seahub.db` (only for the SQLite option, not used), `/var/log/nginx` (remapped to `/tmp`), `/etc/nginx` (rendered to `/tmp`), `seahub/media` collected static assets (UNVERIFIED; if Seahub writes to its own tree, symlink the writable subdirectories into `/config`).
- Ports 80/443 need root; our nginx listens on 8080.
- The upstream `my_init` (runit-style init, runs as root) is dropped.

## 10. Risks, caveats and open questions

- Largest unknowns: the exact upstream setup scripts for a first run without root and `my_init`, hard-coded paths in `seahub.sh`/`seafile.sh`, Python 3.14-ish compatibility of seahub on Ubuntu 26.04, and arm64 through the `seafile-mc` image. Treat this as a likely multi-round build (protocol limit is 10).
- The tarball is x86_64 only per the draft: arm64 depends on the `COPY --from` route (UNVERIFIED manifest) or a source compile of ccnet/seafile/seahub (out of scope).
- Default admin credentials upstream are weak (`asecret`): the plan creates no admin unless the password is set.
- Draft's `/shared/seafile` data path changes to `/config`; users migrating from TrueCharts need a data move.
- Seafile 14 uses Redis by default (valkey ✅ works with the Redis protocol, not mentioned by the manual; UNVERIFIED).
- File preview and office integrations (separate services) are out of scope.
- No GPU or privileged requirement. FUSE mounting (`fuse3` in upstream) needs privileges and is not supported.

## 11. Build and test steps

Follow `.github/instructions/build-test-protocol.instructions.md` for `apps/seafile`, one app at a time, 10 rounds at most.

```sh
cd apps/seafile
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create seafile-probe-config
docker run --rm -d --name seafile-probe --read-only --tmpfs /tmp \
  -v seafile-probe-config:/config seafile:14.0.11
docker logs -f seafile-probe
forgetool containers test --image seafile:14.0.11 --config ./apps/seafile/container-test.yaml
docker rm -f seafile-probe; docker volume rm seafile-probe-config
```

- Expected readiness signal: log line "waiting for database" while no MariaDB exists (allowed by the protocol exception), nginx up on 8080, no fatal exit; with MariaDB and valkey on a shared network, Seahub answers on 8080 and the login page loads.
- Always start with an empty `/config` volume (fresh volume each round).
- By-hand checks outside the test: start mariadb and valkey containers on one network, set the DB, JWT and admin variables, log in, upload and download a file (checks the fileserver on 8082 through nginx).
- Only try arm64 if an amd64 build is green and a failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-seafile` from a freshly pulled `main`; commit and PR title `feat(seafile): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` keeping its sections; check only the boxes that apply. Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows the status). Only the user can sign it.
- Confirm: changes only in `apps/seafile/`; `ARG VERSION` matches `docker-bake.hcl`; `docker buildx bake --print` passes; final `USER apps`; `COPY --chmod=0755 . /` present; runs read-only with empty `/config`; no assertion weakened.
- Not tested, to state honestly in the PR unless done: the whole first-run setup path, arm64, upload/download, admin creation, LDAP/SSO.
