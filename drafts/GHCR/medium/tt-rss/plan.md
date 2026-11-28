# tt-rss — implementation plan
> Source: ./draft.md · Target: apps/tt-rss/ · Difficulty: medium · Role: main (row 1), sidecar (row 2, nginx) · Verified on 2026-11-25

Two rows: row 1 is the php-fpm app (main), row 2 is the nginx web tier. Plan both as separate apps only if the chart needs both; the draft names `apps/tt-rss` for the app. The nginx sidecar is covered by `apps/nginx` (exists) with tt-rss config, so no separate `tt-rss-web-nginx` app is planned unless the chart requires it (see section 10).

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No releases and no tags (https://api.github.com/repos/tt-rss/tt-rss/releases/latest returns 404). Default branch `main`, last push 2026-11-22. Pin a commit: app `03628f0aa3c4a86e960ddd61b5ba372cd3a27b50`, web-nginx `d62bcf96d01a7a2e750f6c9581ca462556e57281` (the commits the chart's images were built from). Draft's `master.zip` is not confirmed: UNVERIFIED. |
| Renovate | UNVERIFIED: no tags, so `github-releases` does not apply. Use `datasource=git-refs depName=https://github.com/tt-rss/tt-rss currentValue=main` (precedent `apps/tvheadend`). |
| License | GPL-3.0 (GitHub SPDX `GPL-3.0`, https://api.github.com/repos/tt-rss/tt-rss) |
| Source URL | https://github.com/tt-rss/tt-rss |
| Download (row 1) | Source archive `https://github.com/tt-rss/tt-rss/archive/<commit>.tar.gz` (UNVERIFIED: not fetched). No binary. The app is PHP: no compile step. |
| Download (row 2) | Nginx config template only: `.docker/web-nginx/nginx.conf` in the same repo at `d62bcf96d01a7a2e750f6c9581ca462556e57281`. Uses `apt:nginx` on Ubuntu (sidecar). |
| Checksum source | None published. Pin the commit SHA (content-addressed) and record the archive sha256. |
| Upstream app Dockerfile reviewed | https://raw.githubusercontent.com/tt-rss/tt-rss/03628f0aa3c4a86e960ddd61b5ba372cd3a27b50/.docker/app/Dockerfile: `FROM alpine:3.24.4`, apk: ca-certificates dcron git postgresql-client rsync sudo tzdata + PHP 8.5 (`php85`, fpm, pdo_pgsql, curl, gd, intl, mbstring, xml, zip, sodium, apcu, xdebug). php-fpm `www.conf`: `listen = 9000`, `clear_env = no`, status 9001, `user/group = app`. `git clone --depth=1` of `tt-rss-plugin-nginx-xaccel` (not pinned). ENV: `SCRIPT_ROOT=/opt/tt-rss`, `SRC_DIR=/src/tt-rss/`, `APP_INSTALL_BASE_DIR=/var/www/html`, `PHP_SUFFIX=85`, `OWNER_UID=1000`, `OWNER_GID=1000`, `PHP_WORKER_MAX_CHILDREN=5`, `PHP_WORKER_MEMORY_LIMIT=256M`, `TTRSS_DB_HOST=db`, `TTRSS_DB_PORT=5432`, `TTRSS_PHP_EXECUTABLE=/usr/bin/php85`, `TTRSS_PLUGINS="auth_internal, note, nginx_xaccel"`, plus `ADMIN_USER_PASS`, `ADMIN_USER_ACCESS_LEVEL`, `AUTO_CREATE_USER`, `AUTO_CREATE_USER_PASS`, `AUTO_CREATE_USER_ACCESS_LEVEL=0`, `AUTO_CREATE_USER_ENABLE_API`, `TTRSS_NO_STARTUP_PLUGIN_UPDATES`, `TTRSS_XDEBUG_ENABLED`, `TTRSS_XDEBUG_HOST`, `TTRSS_XDEBUG_PORT=9000`. EXPOSE `9000/tcp`. No VOLUME, no USER, CMD `/bin/sh -c ${SCRIPT_ROOT}/startup.sh`. |
| Upstream web-nginx Dockerfile reviewed | https://raw.githubusercontent.com/tt-rss/tt-rss/d62bcf96d01a7a2e750f6c9581ca462556e57281/.docker/web-nginx/Dockerfile: `FROM nginx:1.31.8-alpine`, ARG `APP_UPSTREAM=app`, `APP_WEB_ROOT=/var/www/html`, `APP_BASE=/tt-rss`, `RESOLVER=127.0.0.11`, template `nginx.conf.template` rendered to `/etc/nginx` (`NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx`), HEALTHCHECK `curl http://localhost${APP_BASE}/index.php`. No EXPOSE, no USER, CMD inherited. |
| Ports | 9000/tcp (php-fpm, internal). 80/http for nginx (UNVERIFIED: listen port in the template not fetched). |
| Data paths | `/var/www/html` (APP_INSTALL_BASE_DIR, shared with nginx), `/opt/tt-rss/config.d`, `/opt/tt-rss/sql/post-init.d`, `/src/tt-rss/` (SRC_DIR). UNVERIFIED: cache and feed-icon dirs written at runtime. |
| Dependencies | PostgreSQL: `apps/postgresql` exists (draft row 1 marks it ✅). nginx: `apps/nginx` exists; the tt-rss-specific web tier is not an app (row 2 is ❌ for `tt-rss-web-nginx`). |

## 2. Target layout

Row 1 (app, main):
- `apps/tt-rss/Dockerfile`
- `apps/tt-rss/docker-bake.hcl`
- `apps/tt-rss/settings.yaml`
- `apps/tt-rss/container-test.yaml`
- `apps/tt-rss/start.sh` (replaces upstream `startup.sh` flow: DB wait, config, first-run seed, php-fpm start)
- `apps/tt-rss/defaults/` for `config.docker.php` template and the nginx `nginx.conf.template` (reason: the app must write its config into `/config`, not `/app`)

Row 2 (nginx web tier): if a separate app is required, `apps/tt-rss-web-nginx/` mirroring `apps/nginx` (Dockerfile, bake, settings, test, start.sh, defaults/nginx.conf.template). This is a second PR (one app = one PR). Otherwise the chart's nginx sidecar is served by `apps/nginx` with the `defaults/` template from row 1.

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. PHP comes from Ubuntu apt (`php-fpm`, `php-pgsql`, `php-curl`, `php-gd`, `php-mbstring`, `php-xml`, `php-intl`, `php-zip`, `php-apcu`), not from Alpine. Alpine and PHP 8.5 are upstream-only. The Ubuntu PHP version must be checked against tt-rss's requirements (UNVERIFIED: PHP version in 26.04 apt). Closest sibling: `apps/bookstack` (PHP stack on ubuntu) and `apps/nginx` for row 2.

## 4. Dockerfile

1. `ARG VERSION` (commit SHA), `ARG TARGETARCH`, `USER root`.
2. Install PHP and extensions from apt (pinned to the 26.04 PHP version, checked with `apt-cache policy`). Install `git`, `postgresql-client`, `rsync`, `curl`, `dcron` only if the scripts need them (check `startup.sh` usage).
3. Download `https://github.com/tt-rss/tt-rss/archive/${VERSION}.tar.gz` with curl, verify sha256 pinned in the Dockerfile, extract to `/app/tt-rss` (the source, read-only at runtime).
4. Clone the nginx-xaccel plugin into `/app/tt-rss/plugins.local/nginx_xaccel` pinned to a commit (UNVERIFIED: commit to pin; upstream clones HEAD).
5. License: copy upstream `LICENSE` to `/usr/share/licenses/tt-rss/`.
6. `ENV SCRIPT_ROOT=/app/tt-rss/...` (UNVERIFIED: upstream `SCRIPT_ROOT=/opt/tt-rss` path is remapped), `APP_INSTALL_BASE_DIR=/config/html` (writable, shared with nginx), `HOME=/config`, `TMPDIR=/tmp`, `PHP_WORKER_MAX_CHILDREN=5`, `PHP_WORKER_MEMORY_LIMIT=256M`, `TTRSS_DB_PORT=5432`.
7. php-fpm pool: `listen = 9000`, `user = apps`, `group = apps`, `clear_env = no`, error log to `/tmp`. Pool config comes from `defaults/` (not written to `/etc` at runtime).
8. `chown -R apps:apps /app` where needed; `/app` is read-only.
9. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 9000`, `VOLUME /config`.

Row 2 (nginx): `FROM` the ContainerForge nginx base (`apps/nginx`), template copied from `defaults/`, `EXPOSE 80`, `USER apps`.

## 5. docker-bake.hcl

- `APP = "tt-rss"`, `SOURCE = "https://github.com/tt-rss/tt-rss"`, `LICENSE = "GPL-3.0-only"`.
- `VERSION` (commit SHA) with a renovate annotation: `// renovate: datasource=git-refs depName=https://github.com/tt-rss/tt-rss currentValue=main` (UNVERIFIED: annotation style for commits; check `apps/tvheadend`).
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/tt-rss && docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://tt-rss.org/"`.
- `ports`: `9000` tcp (`required: true`, internal php-fpm). Add `80` http only if row 1 serves HTTP itself (it does not: the nginx sidecar does).
- `env`: `TTRSS_DB_HOST` (`postgresql` or user-supplied), `TTRSS_DB_PORT` (`5432`), `TTRSS_DB_NAME`, `TTRSS_DB_USER`, `TTRSS_DB_PASS` (required), `ADMIN_USER_PASS`, `AUTO_CREATE_USER` (optional), `PHP_WORKER_MAX_CHILDREN` (`5`), `PHP_WORKER_MEMORY_LIMIT` (`256M`), `TZ` (`Etc/UTC`). Only vars the app reads: check `config.docker.php` and `startup.sh` before listing (UNVERIFIED: DB name/user var names).
- `volumes`: `/config` (`required: true`) for the web root and `config.d`.
- `dependencies`: `postgresql` (exists in `apps/postgresql`).
- Do not list `TTRSS_XDEBUG_*` (debug only) unless the chart exposes it.

## 7. start.sh

- `set -eu`; no writes to `/app`.
- Seed `/config/html` from the built source only when missing (`rsync` or `cp -n`).
- Render `config.docker.php` into `/config/config.d/` only when missing; re-apply DB settings from env on every start.
- Wait for PostgreSQL (`pg_isready` or a TCP check with a bounded timeout), then run schema init (idempotent, `php update.php --update-schema`) and start the background updater via `dcron` or a loop (UNVERIFIED: which the chart expects).
- Final line: `exec php-fpm -F` (PID 1 handoff; UNVERIFIED: the versioned binary name in the Ubuntu package, check `ls /usr/sbin/php-fpm*`).

## 8. container-test.yaml

- forgetool schema header from sibling apps.
- `tcp` probe on `9000` (php-fpm). `timeoutSeconds` from `apps/bookstack`.
- `filePaths`: `/config/config.d/config.php` (or the chart path) after seed, since the test runs without env vars.
- Expected readiness signal: php-fpm `ready to handle connections` in logs.
- Without PostgreSQL, the schema init fails: narrow with `# narrowed: requires external postgresql; full functional test not feasible in single-container suite` and keep the process + tcp assertions.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/www/html` (web root) | `/config/html` |
| `/opt/tt-rss/config.d` | `/config/config.d` |
| php-fpm `error_log` | `/tmp/error.log` (already upstream) |
| Upstream `USER` | upstream pool runs `app`; ContainerForge runs `apps` (UID check UNVERIFIED) |
| nginx temp dirs (row 2) | `/tmp` (nginx `client_body_temp`, `proxy_temp`, `fastcgi_temp`, `scgi_temp`, `uwsgi_temp`) |
| `dcron` spool | `/tmp` (UNVERIFIED: whether dcron is kept) |

Run `docker run --read-only --tmpfs /tmp` and check that nginx and php-fpm start.

## 10. Risks, caveats and open questions

- Alpine/PHP 8.5 vs Ubuntu PHP version: the Ubuntu apt PHP may not match tt-rss's PHP minimum. UNVERIFIED. Blocker until settled.
- No pinned version: track commits, not tags. Renovate annotation style is UNVERIFIED.
- Plugins git-cloned at build time (not pinned): pin the commit (see section 4).
- Two containers (app and nginx) plus PostgreSQL must be deployed together. Row 2 is a separate app/PR.
- Draft's security expectations: nginx-conf configmap mount, cnpg PostgreSQL, `readOnlyRootFilesystem` false (chart). The app targets read-only with `/config` writes (section 9).
- `TTRSS_DB_HOST=db` upstream default must be replaced with the ContainerForge `postgresql` app name (UNVERIFIED: service name).
- Blockers: Ubuntu PHP version, PHP extension coverage, nginx sidecar layout.

## 11. Build and test steps

From `apps/tt-rss/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create tt-rss-probe-config`, `docker run --rm -d --name tt-rss-probe --read-only --tmpfs /tmp -v tt-rss-probe-config:/config tt-rss:<commit-short>`, `docker logs -f tt-rss-probe` (expect `ready to handle connections` and no fatal error), then `docker rm -f tt-rss-probe; docker volume rm tt-rss-probe-config`.
4. `forgetool containers test --image tt-rss:<commit-short> --config ./apps/tt-rss/container-test.yaml`.

Row 2 (if separate): repeat in `apps/tt-rss-web-nginx/`. Round limit: 10 per app.

## 12. PR checklist

- Branch `feat/add-tt-rss` (and `feat/add-tt-rss-web-nginx` if row 2 is separate), commit `feat(tt-rss): add new container`, PR title the same.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Say what was not tested: the PHP version choice, PostgreSQL wiring, the nginx sidecar, and arm64.
- Check "Built container locally" only if the build actually ran.
