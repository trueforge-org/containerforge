# fireflyiii — implementation plan

> Source: ./draft.md · Target: apps/fireflyiii/ · Difficulty: hard (PHP stack with nginx + php-fpm + scheduler) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 6.7.9 (tag `v6.7.9`, published 2026-10-11, GitHub "Latest"). Draft says 6.2.21, which is stale; use 6.7.9 |
| Renovate | `datasource=github-releases depName=firefly-iii/firefly-iii versioning=semver` |
| License | AGPL-3.0 (GitHub API `AGPL-3.0`); bake value `AGPL-3.0-only` (UNVERIFIED only vs or-later) |
| Source URL | https://github.com/firefly-iii/firefly-iii |
| Binary / archive | `https://github.com/firefly-iii/firefly-iii/releases/download/v${VERSION}/FireflyIII-v${VERSION}.tar.gz` (prebuilt, vendor dir included, arch independent, so the same URL for amd64 and arm64) |
| Checksum source | Release asset `FireflyIII-v${VERSION}.tar.gz.sha256` (also `.asc` signature). GitHub digest of the tar.gz is `sha256:f905729c3be6e66d5333c22992281224ef1dc7e21cea13f4ef09af643d09b825` for v6.7.9. Format of the `.sha256` file content UNVERIFIED, so compare only the hash field |
| PHP | `composer.json` requires `php >= 8.5` and ext: bcmath, curl, fileinfo, iconv, intl, json, mbstring, openssl, pdo, session, simplexml, tokenizer, xml, xmlwriter. Ubuntu 26.04 provides `php8.5-*` (already used by `apps/bookstack`) |
| Env vars (from `.env.example`) | APP_KEY (exactly 32 chars, or `_FILE`), APP_URL, APP_ENV, APP_DEBUG, SITE_OWNER, TZ, DB_CONNECTION (`mysql`/`pgsql`/`sqlite`), DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD, DB_SOCKET, CACHE_STORE (default `file`), SESSION_DRIVER (default `file`), REDIS_HOST, REDIS_PORT, REDIS_PASSWORD, REDIS_DB, REDIS_CACHE_DB, TRUSTED_PROXIES, STATIC_CRON_TOKEN (32 chars), DEFAULT_LANGUAGE, DEFAULT_LOCALE, LOG_CHANNEL, MAIL_*, PGSQL_SSL_MODE, PGSQL_SCHEMA, MYSQL_USE_SSL, AUTHENTICATION_GUARD. Many accept a `_FILE` suffix |
| Writable dirs | `storage/` (app, build, database, debugbar, export, framework, logs, upload) and `bootstrap/cache` |
| Cron | Artisan command `firefly-iii:cron` (`app/Console/Commands/Tools/Cron.php`); recommended cadence from the docs is UNVERIFIED (docs.firefly-iii.org returned 403). Treat as once a day plus on demand |
| Upstream image | Official image is built from an Azure DevOps repo (`MainImage`, Dockerfile linked in draft); could not be fetched. It is based on serversideup php-fpm-nginx with s6 (per draft), so it is only a reference, not a source to copy |
| Port | 8080 inside upstream image (draft: 8080/http); we choose 8080 for nginx |

## 2. Target layout

```
apps/fireflyiii/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                  renders configs to /tmp, seeds /config, migrates, starts php-fpm + scheduler + nginx
  defaults/nginx.conf       Laravel server block on 8080, pid/temp/log paths in /tmp, fastcgi to unix socket
  defaults/php-fpm.conf     pool without user/group, listen = /tmp/php-fpm.sock, clear_env = no
  defaults/php.ini          memory_limit, upload sizes, opcache settings (read via PHP_INI_SCAN_DIR)
```

`defaults/` holds config templates that start.sh copies/renders into `/tmp`; they are required because the stock Ubuntu configs live in read-only `/etc`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. PHP comes from apt (no php base image in the repo). Closest sibling: `apps/bookstack` (Laravel, php8.5 packages, `/app/www`, symlinks into `/config`), plus `apps/nginx` for the nginx-as-`apps` pattern. Note bookstack currently runs only a queue worker and relies on a s6 init hook; do not copy that part, because this plan runs nginx itself.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends nginx php8.5-fpm php8.5-cli php8.5-bcmath php8.5-curl php8.5-gd php8.5-intl php8.5-mbstring php8.5-xml php8.5-zip php8.5-pgsql php8.5-mysql php8.5-sqlite3 php8.5-redis netcat-openbsd`. Not pinned: the image contents are driven by the Firefly archive, not by a distro package, so there is no VERSION alignment problem. Package availability for php8.5-intl/pgsql/redis/sqlite3 on 26.04 is UNVERIFIED (bookstack proves xml/curl/gd/ldap/mysql/zip/memcached). Do not install `cron`; the scheduler is a loop in start.sh.
3. Download and verify:
   ```
   curl -fL -o /tmp/ff.tar.gz "https://github.com/firefly-iii/firefly-iii/releases/download/v${VERSION}/FireflyIII-v${VERSION}.tar.gz"
   curl -fL -o /tmp/ff.sha256 "https://github.com/firefly-iii/firefly-iii/releases/download/v${VERSION}/FireflyIII-v${VERSION}.tar.gz.sha256"
   echo "$(cut -d' ' -f1 /tmp/ff.sha256)  /tmp/ff.tar.gz" | sha256sum -c -
   mkdir -p /app/www && tar xzf /tmp/ff.tar.gz -C /app/www
   ```
   Check whether the archive is flat or has a top-level directory (UNVERIFIED) and add `--strip-components=1` if needed; assert `/app/www/artisan` and `/app/www/public/index.php` exist.
4. Licenses: `mkdir -p /usr/share/licenses/fireflyiii && cp /app/www/LICENSE /usr/share/licenses/fireflyiii/`.
5. Make writable paths point out of `/app`: `rm -rf /app/www/storage && ln -s /config/storage /app/www/storage`; `rm -rf /app/www/bootstrap/cache && ln -s /tmp/bootstrap-cache /app/www/bootstrap/cache`. Alternative to the second symlink: set `APP_SERVICES_CACHE`, `APP_PACKAGES_CACHE`, `APP_CONFIG_CACHE`, `APP_ROUTES_CACHE`, `APP_EVENTS_CACHE` to `/tmp/bootstrap-cache/*.php` (Laravel honors these; UNVERIFIED for this Firefly release), pick one and test.
6. `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/* /var/lib/apt/lists/*`.
7. `ENV HOME=/config PHP_INI_SCAN_DIR=:/tmp/php.d` (so rendered ini lands in `/tmp`).
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /app/www`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "fireflyiii" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=firefly-iii/firefly-iii versioning=semver
  default = "6.7.9"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/firefly-iii/firefly-iii" }
```

Add `group "default"`, `image` (args `VERSION`, labels source/licenses), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64) like `apps/adguardhome-sync`. The Dockerfile's URL uses `v${VERSION}`; the bake `VERSION` has no `v`. Run `docker buildx bake --print`.

## 6. settings.yaml

Header and `schema_version: 1`, `upstream_env_url: "https://github.com/firefly-iii/firefly-iii"`.

- ports: `8080` tcp, `required: false`.
- env (only vars the app reads, all defaults identical to start.sh): `TZ` (`Etc/UTC`), `APP_URL` (`http://localhost:8080`), `APP_KEY` (default `""`, required false: start.sh generates and persists one), `SITE_OWNER` (`mail@example.com`), `DB_CONNECTION` (`sqlite`), `DB_HOST` (`""`), `DB_PORT` (`""`), `DB_DATABASE` (`""`: start.sh sets `/config/database/database.sqlite` for sqlite), `DB_USERNAME` (`""`), `DB_PASSWORD` (`""`), `CACHE_STORE` (`file`), `SESSION_DRIVER` (`file`), `REDIS_HOST` (`""`), `REDIS_PORT` (`6379`), `REDIS_PASSWORD` (`""`), `TRUSTED_PROXIES` (`""`), `STATIC_CRON_TOKEN` (`""`, generated when empty), `APP_ENV` (`production`).
- volumes: `/config` required.
- opt_dependencies: `postgresql` ✅ (apps/postgresql exists), `mariadb` ✅ (apps/mariadb exists), `valkey` ✅ (apps/valkey exists). The draft calls Valkey a hard dependency, but upstream defaults to `CACHE_STORE=file` and `SESSION_DRIVER=file`, so it is optional and belongs under `opt_dependencies`; no hard `dependencies:` entry, which also means the DB-dependent test exception is not used.

## 7. start.sh

Steps (all idempotent, empty `/config` safe):

1. `mkdir -p /config/storage/{app/public,build,database,debugbar,export,framework/{cache/data,sessions,views},logs,upload} /tmp/bootstrap-cache /tmp/nginx /tmp/php.d`.
2. APP_KEY: if unset and `/config/storage/app_key` missing, generate `tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32`, store with `umask 077`; export from the file on every start. Same for `STATIC_CRON_TOKEN` (32 chars) in `/config/storage/cron_token`. Never print them.
3. DB: default `DB_CONNECTION=sqlite`, `DB_DATABASE=/config/storage/database/database.sqlite`, `touch` the file if absent (so the image works with no env and no database container). For pgsql/mysql export the env as given; if `DB_HOST` is set, wait up to 30 s with `nc -z "$DB_HOST" "${DB_PORT:-5432}"` before migrating (log, do not exit). Default port by connection (5432 pgsql, 3306 mysql). Passwords are only exported, never written to files.
4. Render configs: `cp /defaults/php-fpm.conf /tmp/php-fpm.conf`, `cp /defaults/php.ini /tmp/php.d/99-firefly.ini`, `cp /defaults/nginx.conf /tmp/nginx.conf` (port fixed at 8080, no env needed).
5. Upgrade: `php /app/www/artisan migrate --force`, then `php artisan firefly-iii:upgrade-database`, `php artisan firefly-iii:laravel-passport-keys`, `php artisan cache:clear`, `config:clear`, `view:clear` (command names taken from composer scripts in `composer.json`; run `artisan list` in the image to confirm).
6. `php-fpm8.5 -F -y /tmp/php-fpm.conf &` and a loop `while sleep 86400; do php artisan firefly-iii:cron; done &` (cadence UNVERIFIED), then trap `TERM INT` to kill children.
7. `exec nginx -c /tmp/nginx.conf -g 'daemon off;'`.

Network: nginx `listen 8080;` (all interfaces, IPv6 optional) and fastcgi over the unix socket `/tmp/php-fpm.sock`. Draft's s6 supervisor is replaced by this shell supervision; if php-fpm dies the container keeps running, so add `wait -n` style check or a health probe in a follow-up.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/www/artisan
- /app/www/public/index.php
```

Because SQLite is the no-env default, a real HTTP probe is possible (the login/register redirect should return 200 after redirects; confirm the expected status when running). No DB-dependency narrowing is used. Paths that only run when `DB_HOST` is set (pgsql/mysql wait and connect) are not covered by the test; run them by hand against `apps/postgresql`. Verify the `filePaths` key shape against a sibling that uses it. `timeoutSeconds: 240` matches `apps/bookstack` (migration on first start).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `storage/**` (logs, uploads, cache, sqlite, passport keys) | symlink `/app/www/storage` to `/config/storage` |
| `storage/upload` (draft's extra persistence `/var/www/html/storage/upload`) | included in `/config/storage/upload` |
| `bootstrap/cache` | `/tmp/bootstrap-cache` |
| nginx pid, temp, logs, `/var/lib/nginx` | `/tmp/nginx.conf` sets `pid`, `*_temp_path`, `error_log stderr`, `access_log off` or stdout |
| php-fpm pid, socket, error log, session dir | `/tmp/php-fpm.conf`, `session.save_path` in `/tmp` or Laravel `file` sessions in `/config/storage/framework/sessions` |
| `.env` | not used; configuration is via real env vars (Laravel reads them directly) |
| OPcache file cache / composer | `/tmp` |

Draft expectations: chart sets UID 33, `readOnlyRootFilesystem: false`. Image runs UID 568 with read-only rootfs; no privileged mode or capabilities. nginx must listen on 8080 (non-privileged port).

## 10. Risks, caveats and open questions

- Draft version 6.2.21 is old; 6.7.9 needs PHP >= 8.5 (satisfied by Ubuntu 26.04 only if `php8.5-*` packages exist for every extension; verify before building).
- Three processes in one container (nginx, php-fpm, scheduler) via a plain shell; no real supervisor. Acceptable for a first version, document it.
- Cron cadence and `.sha256` file format are UNVERIFIED (docs blocked with HTTP 403).
- Archive layout (flat vs top-level dir) UNVERIFIED.
- Redis/Valkey optional, not hard, contrary to the draft. `CACHE_STORE`/`SESSION_DRIVER` can be switched with env.
- First run needs an account created through the web UI (register page), not through env.
- `APP_URL` mismatches break asset links and redirects behind a proxy; document `TRUSTED_PROXIES`.
- Scheduler loop uses `firefly-iii:cron`; also available is an HTTP cron endpoint via `STATIC_CRON_TOKEN`.

## 11. Build and test steps

```sh
cd apps/fireflyiii
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name fireflyiii-probe --read-only --tmpfs /tmp \
  -v fireflyiii-probe-config:/config fireflyiii:6.7.9
docker logs -f fireflyiii-probe
forgetool containers test --image fireflyiii:6.7.9 --config ./apps/fireflyiii/container-test.yaml
docker rm -f fireflyiii-probe; docker volume rm fireflyiii-probe-config
```

Readiness: migration output ends without errors (`Nothing to migrate` on restart), php-fpm logs `ready to handle connections`, nginx accepts on 8080, `curl -I http://127.0.0.1:8080/` returns 200 or a 302 to `/login`/`/register`. Second pass: restart the same volume (idempotency) and a pass with `DB_CONNECTION=pgsql` against `apps/postgresql`. Cap at 10 rounds.

## 12. PR checklist

- Branch `feat/add-fireflyiii`; commit `feat(fireflyiii): add new container`; same PR title; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check).
- State untested items honestly: arm64, PostgreSQL/MySQL path, Valkey path, cron loop, php8.5 extension package names, checksum file format.
- Pre-completion: bake `--print` ok, Dockerfile/bake aligned, read-only rootfs and empty `/config` verified, no downstream consumers.
