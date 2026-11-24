# blog — implementation plan
> Source: ./draft.md · Target: apps/blog/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **1.5.0** (tag `v1.5.0`, latest GitHub release; `config.ini` also says `version = 1.5.0`). The draft's image tag `latest` is replaced by this pinned version. |
| Renovate | `datasource=github-releases`, `depName=m1k1o/blog`, `versioning=semver` |
| License | GPL-3.0 (GitHub API; `LICENSE` at repo root). SPDX `GPL-3.0-only`. |
| Source | https://github.com/m1k1o/blog |
| Download | https://github.com/m1k1o/blog/archive/refs/tags/v1.5.0.tar.gz (PHP source, no build step; amd64 and arm64 identical) |
| Checksum | None published. UNVERIFIED: no checksum source exists. |
| Upstream Dockerfile | reviewed at tag v1.5.0: `php:8.5-apache-trixie`, apt libs for gd, `docker-php-ext-install gd pdo_mysql pdo_pgsql exif`, `a2enmod rewrite`, `COPY --chown=33:33 . /var/www/html`, `VOLUME /var/www/html/data` |
| PHP extensions | curl, PDO, gd, exif (debug mode check lists `curl PDO pdo_mysql gd exif`), plus `pdo_pgsql`/`pdo_mysql`; the default DB is **SQLite** (`config.ini`: `db_connection = sqlite`, `sqlite_db = data/sqlite.db`), so `pdo_sqlite` is also needed |
| Database | **Not required.** Zero-config SQLite is the default (README "Zero configuration setup"). MySQL/MariaDB or PostgreSQL are optional. The draft's "needs an external PostgreSQL" caveat is wrong. |
| Port | 80 in the Apache image. This plan serves on **8080** (rootless). |
| Env vars | Every `BLOG_`-prefixed variable is mapped to a config key (lowercased) in `app/config.class.php`; `true`/`false` strings become booleans. Documented keys: `BLOG_TITLE`, `BLOG_NAME`, `BLOG_NICK`, `BLOG_PASS`, `BLOG_LANG`, `BLOG_DB_CONNECTION` (sqlite|mysql|postgres), `BLOG_DB_NAME`, `BLOG_MYSQL_{HOST,PORT,USER,PASS,SOCKET}`, `BLOG_POSTGRES_{HOST,PORT,USER,PASS,SOCKET}`. Also `TZ` (used in `common.php`). |
| Defaults to flag | `config.ini` ships `[admin] force_login = true, nick = demo, pass = demo`. |
| Write paths | everything under `data/`: `sqlite.db`, `i/` (images), `t/` (thumbnails), `logs/`, optional `data/config.ini` override. PHP sessions use the default save path. |

## 2. Target layout

```
apps/blog/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/nginx.conf       # nginx template rendered to /tmp
  defaults/php-fpm.conf     # php-fpm pool config rendered to /tmp
```
`defaults/` is on the `.dockerignore` allow-list. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: no PHP base exists in the repo; apps such as `apps/bookstack` and `apps/piwigo` install `php8.5-*` from apt on the ubuntu base. This plan uses nginx plus php-fpm (not Apache, which needs root to start cleanly and relies on `.htaccess`). Closest sibling: `apps/bookstack` (PHP on ubuntu), `apps/piwigo`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends nginx php8.5-fpm php8.5-cli php8.5-gd php8.5-curl php8.5-sqlite3 php8.5-pgsql php8.5-mysql php8.5-mbstring php8.5-xml` (php8.5 naming confirmed by sibling Dockerfiles; whether `exif` is bundled in `php8.5-common` and `php8.5-mbstring`/`xml` are needed by blog is UNVERIFIED, so verify with `php -m` at build and fail the build if `gd pdo_sqlite pdo_mysql pdo_pgsql exif curl` are missing). Not pinned: these are runtime dependencies, not the blog version itself; do not use `apt-get install nginx=...`.
3. Download and extract: `mkdir -p /app/www && curl -fsSL "https://github.com/m1k1o/blog/archive/refs/tags/v${VERSION#v}.tar.gz" | tar xz -C /app/www --strip-components=1`.
4. Redirect writable data: `rm -rf /app/www/data && ln -s /config/data /app/www/data`.
5. License: `mkdir -p /usr/share/licenses/blog && cp /app/www/LICENSE /usr/share/licenses/blog/`.
6. Cleanup: `rm -rf /var/lib/apt/lists/* /tmp/*`; `chown -R apps:apps /app`.
7. No ENV changes: `TZ` is passed at runtime; nginx and php-fpm run entirely from `/tmp` configs (see section 7).
8. `USER apps`
9. `COPY --chmod=0755 . /`
10. `EXPOSE 8080`, `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP"     { default = "blog" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=m1k1o/blog versioning=semver
  default = "1.5.0"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/m1k1o/blog" }
```
Standard 4 targets + default group, copied from `apps/adguardhome-sync/docker-bake.hcl`; `image-all` uses linux/amd64 and linux/arm64. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/m1k1o/blog"`.
- ports: `8080/tcp required: false`.
- env (names are the ones the app reads; defaults from `config.ini`): `TZ` `"Etc/UTC"`; `BLOG_TITLE` `"Blog"`; `BLOG_NAME` `"Max Musermann"`; `BLOG_NICK` `"demo"`; `BLOG_PASS` `"demo"` (change in production); `BLOG_LANG` `"en"`; `BLOG_DB_CONNECTION` `"sqlite"`; `BLOG_DB_NAME` `"blog"`; optional external DB: `BLOG_MYSQL_HOST/PORT/USER/PASS` and `BLOG_POSTGRES_HOST/PORT/USER/PASS` default `""` required false. All `required: false`.
- volumes: `/config` required true (uploads, thumbnails, SQLite DB).
- dependencies: none required. Optional `opt_dependencies`: `postgresql` ✅ (`apps/postgresql` exists) and `mariadb` ✅ (`apps/mariadb` exists).

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config/data/{i,t,logs} /tmp/{nginx,sessions,php}
# render configs into /tmp (no writes to /app)
cp /defaults/nginx.conf /tmp/nginx.conf
cp /defaults/php-fpm.conf /tmp/php-fpm.conf
php-fpm8.5 -y /tmp/php-fpm.conf -D
exec nginx -c /tmp/nginx.conf -g 'daemon off;'
```
- `defaults/php-fpm.conf`: no `user`/`group` (already UID 568), `listen = /tmp/php-fpm.sock`, `clear_env = no` (needed so `BLOG_*` and `TZ` reach PHP), `php_admin_value[session.save_path] = /tmp/sessions`, `upload_max_filesize = 32M`, `post_max_size = 32M` (upstream `.htaccess` values), `error_log = /dev/stderr`, `pid = /tmp/php-fpm.pid`.
- `defaults/nginx.conf`: `pid /tmp/nginx.pid;`, all `*_temp_path` and logs in `/tmp` or `/dev/stdout`/`/dev/stderr`, `listen 0.0.0.0:8080;`, `root /app/www;`, `client_max_body_size 32M;`, `fastcgi_pass unix:/tmp/php-fpm.sock` for `.php`, `index index.php`, and the `.htaccess` rules reproduced: `autoindex off`, `location ~ \.(db|ini|sql|log)$ { deny all; }` and `location ~ /\.(?!well-known) { deny all; }`, plus denial of `Dockerfile`, `docker-compose.yml`, `README.md`. Images and thumbnails are served statically from `data/i` and `data/t`.
- Defaults match `settings.yaml`: the app reads `BLOG_*` directly, so start.sh passes nothing through.
- Idempotent: only `mkdir -p` and rendering to `/tmp`. SQLite DB is created by the app in `/config/data/sqlite.db` on first request (UNVERIFIED that the app creates the schema itself; upstream "zero configuration" claim says yes).
- Optional warning at start if `BLOG_PASS` is still `demo`.
- php-fpm runs as a daemon and nginx in the foreground via `exec`; if php-fpm dies the container keeps running (see section 10).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180

http:
- port: '8080'
  path: /

filePaths:
- /app/www/index.php
- /defaults/nginx.conf
```
Probe for the single port in section 6 (8080). The test runs with no env vars, so it exercises the zero-config SQLite path with the demo login. UNVERIFIED: the status code for `/` with `force_login = true` (login page or redirect); if the run step shows a 302, set `statusCode` accordingly rather than weakening the check.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/var/www/html/data` (SQLite, images, thumbnails, logs) | `/app/www/data` symlink to `/config/data` |
| Apache pid/logs/lock, `/var/run/apache2` | not used; nginx pid and temp paths in `/tmp` |
| PHP sessions (`/var/lib/php/sessions`) | `/tmp/sessions` |
| php-fpm socket and pid | `/tmp/php-fpm.sock`, `/tmp/php-fpm.pid` |
| Apache `.htaccess` PHP limits | `upload_max_filesize`/`post_max_size` in the php-fpm pool config |

Draft expectations: chart ran UID 0, `readOnlyRootFilesystem: false`, persistence `/var/www/html/data`. Plan: UID 568, read-only rootfs, persistence `/config/data`. Not privileged.

## 10. Risks, caveats and open questions

- The draft says an external PostgreSQL is required and must exist first; verified false: SQLite is the default, Postgres/MySQL are optional.
- Default login is `demo` / `demo`; users must set `BLOG_NICK` and `BLOG_PASS`.
- Running php-fpm and nginx in one container without a supervisor: if php-fpm exits, requests fail while the container stays up. Optionally add a small loop in start.sh or use `php -S` as piwigo does (rejected here because it ignores the deny rules for `.ini`/`.db`).
- `BLOG_PASS` and DB passwords live in the environment, as upstream expects.
- Upstream moved to PHP 8.5 (trixie); ubuntu 26.04 packages should match, but extension package names are UNVERIFIED until the build runs `php -m`.
- No checksum for the source tarball.

## 11. Build and test steps

```sh
cd apps/blog
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name blog-probe --read-only --tmpfs /tmp \
  -v blog-probe-config:/config blog:1.5.0
docker logs -f blog-probe
forgetool containers test --image blog:1.5.0 --config ./apps/blog/container-test.yaml
docker rm -f blog-probe; docker volume rm blog-probe-config
```
Expected readiness: nginx running with no errors, port 8080 answering, and `/config/data/sqlite.db` present after the first request. Also check from outside the container (e.g. `curl` from a sidecar) that 8080 is reachable and that `/config.ini` and `/data/sqlite.db` return 403/404.

## 12. PR checklist

- Branch `feat/add-blog`; commit and PR title `feat(blog): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; Notes contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested: external MySQL/PostgreSQL modes, file uploads under read-only rootfs, arm64, PHP extension names.
- Check "Built container locally" only if it was built.
