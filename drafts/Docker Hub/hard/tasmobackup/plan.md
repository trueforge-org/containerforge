# tasmobackup — implementation plan
> Source: ./draft.md · Target: apps/tasmobackup/ · Difficulty: hard (nginx + php-fpm + cron in one image, rootless rework) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `1.08.01` (GitHub tag `1.08.01`, also the draft's image tag `danmed/tasmobackupv1:1.08.01`; other tags seen: `v1.03.17`, `list`). The Releases page is empty, so only tags exist. Repo pushed 2026-10-21. |
| Renovate | `datasource=github-tags depName=danmed/TasmoBackupV1 versioning=loose` |
| License | MIT (GitHub API and README) |
| Source | https://github.com/danmed/TasmoBackupV1 |
| Download | Source tarball only, same for both arches (pure PHP): `https://github.com/danmed/TasmoBackupV1/archive/refs/tags/${VERSION}.tar.gz`. Draft "binary" link is the tag page. |
| Checksum | None published. Pin by tag; record that in the PR. |
| Upstream Dockerfile reviewed | Root `Dockerfile` (base `docker.patrickdk.com/docker-php-nginx:7.3`): copies the repo to `/var/www/html/` (owner www-data), compiles `.po` to `.mo` with `msgfmt`, gzips `resources/*.js` and `*.css`, writes an nginx vhost, installs a root crontab `8 * * * * wget -O - "http://localhost/backupall.php?docker=true"`, `CMD /usr/bin/install.sh /usr/bin/supervisord ...`. No EXPOSE, no VOLUME. |
| Upstream `install.sh` (entrypoint helper) | If `data/config.inc.php` is missing: creates `/var/www/html/data`, copies `config.inc.php.example` there; chowns to www-data; creates `data/backups`; sets `TZ` in php `custom.ini`; `sed`s `MYSQL_SERVER`, `MYSQL_USERNAME`, `MYSQL_PASSWORD`, `DBTYPE`, `DBNAME` into `data/config.inc.php`; runs `php /var/www/html/upgrade.php` as www-data; starts crond. |
| Env vars (README/docker-compose) | `DBTYPE` (`sqlite` or `mysql`), `DBNAME` (for sqlite `data/tasmobackup`, for mysql no `data/` prefix), `MYSQL_SERVER`, `MYSQL_USERNAME`, `MYSQL_PASSWORD`, optional `TZ`. |
| Paths | `data/` (SQLite DB file `data/tasmobackup`, `data/backups/`, `data/config.inc.php`); compose mounts `./data:/var/www/html/data`. `upgrade.php` creates/updates tables. Backups run via `backupall.php`. |
| Ports | compose maps host 8259 to container 80. Rootless plan: 8080. |
| Root files in repo | `backupall.php edit.php export.php index.php listbackups.php scan.php settings.php upgrade.php config.inc.php.example hooks lib locale resources images favicon*`, `LICENSE` (MIT). |

## 2. Target layout

```
apps/tasmobackup/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/nginx.conf         # nginx server block on 8080 -> php-fpm unix socket in /tmp
  defaults/php-fpm.conf       # pool config, user apps, socket /tmp/php-fpm.sock, pid in /tmp
```
No root/ (reason: reserved). No DOWNSTREAM_CHANGES.md.

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` (nginx already runs rootless with temp dirs in `/tmp`; draft lists it as the alternative to plain ubuntu). Add PHP-FPM from apt. Closest siblings: `apps/bookstack` (PHP 8.5 packages on ubuntu 26.04, apt `php8.5-*` names), `apps/it-tools` / `apps/nginx` (nginx config copy mechanism).

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. apt (no recommends): `php8.5-fpm php8.5-cli php8.5-curl php8.5-sqlite3 php8.5-mysql php8.5-xml php8.5-mbstring gettext curl`. UNVERIFIED which extensions the app needs (README lists "php-curl, php-xml (inferred)"); confirm with `grep -rn "curl_\|SQLite\|mysqli" *.php lib`. Check the nginx base for what is already installed before adding; php package names follow apps/bookstack.
3. Fetch: `curl -fL https://github.com/danmed/TasmoBackupV1/archive/refs/tags/${VERSION}.tar.gz -o /tmp/app.tgz`, `mkdir -p /app/www`, `tar xzf /tmp/app.tgz -C /app/www --strip-components=1`; remove `HA_addon install.sh docker-compose.yml tests .git*`; compile translations: `for po in /app/www/locale/*/LC_MESSAGES/*.po; do msgfmt -o "${po%.po}.mo" "$po"; done`; `gzip -k -9` the `resources/*.js` and `*.css` (as upstream does).
4. Data path: `rm -rf /app/www/data && ln -s /config/data /app/www/data` (relative `DBNAME=data/tasmobackup` and `data/backups` then land in `/config`). `chown -R apps:apps /app && chmod -R 755 /app`.
5. License: `install -D /app/www/LICENSE /usr/share/licenses/tasmobackup/LICENSE`.
6. `ENV HOME=/config TZ=Etc/UTC`, `EXPOSE 8080`, `VOLUME /config`, `COPY --chmod=0755 . /`, final `USER apps` and `COPY --chmod=0755 . /`. Remove apt lists.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "tasmobackup" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=danmed/TasmoBackupV1 versioning=loose
  default = "1.08.01"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/danmed/TasmoBackupV1" }
```
Plus `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64, arm64), `group "default"`. Run `docker buildx bake --print`.

## 6. settings.yaml

Header + `schema_version: 1`, `upstream_env_url: "https://github.com/danmed/TasmoBackupV1"`.
- ports: `8080` tcp `required: false`.
- env: `TZ` `Etc/UTC`; `DBTYPE` `sqlite`; `DBNAME` `data/tasmobackup`; `MYSQL_SERVER` `""`; `MYSQL_USERNAME` `""`; `MYSQL_PASSWORD` `""`; `BACKUP_CRON_MINUTE` is NOT listed (upstream fixes minute 8; keep that, do not invent vars). All required false.
- volumes: `/config` required true (draft's `/var/www/html/data` is remapped to `/config/data`).
- dependencies: none (MySQL optional and external, so not listed; no `opt_dependencies` unless a mariadb sibling should be mentioned: `mariadb` exists in apps/ but upstream marks MySQL optional).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/data/backups /tmp/php /tmp/nginx-temp /tmp/nginx-cache
[ -f /config/nginx.conf ] || cp /defaults/nginx.conf /config/nginx.conf
if [ ! -f /config/data/config.inc.php ]; then cp /app/www/config.inc.php.example /config/data/config.inc.php; fi
# apply env on every start without sed (special characters in passwords)
php -r '...rewrite $DBType, $DBServer, $DBUser, $DBPassword, $DBName assignments in config.inc.php from DBTYPE, MYSQL_SERVER, MYSQL_USERNAME, MYSQL_PASSWORD, DBNAME with var_export...'
php /app/www/upgrade.php >/dev/null || echo "upgrade.php failed" >&2
php-fpm8.5 -F -y /config/php-fpm.conf &
( while true; do sleep $(( (68 - $(date +%M | sed 's/^0//')) % 60 * 60 )); curl -fsS "http://127.0.0.1:8080/backupall.php?docker=true" >/dev/null || true; done ) &
exec nginx -c /config/nginx.conf -g 'daemon off;'
```
The loop must be corrected during implementation to fire at minute 8 of every hour (upstream cron `8 * * * *`); simpler alternative `sleep 3600` after a first aligned wait. Secrets stay out of the process list (set via file, not argv). `php-fpm8.5` binary name is UNVERIFIED on 26.04. nginx binds `listen 8080` and `[::]:8080` (all interfaces), pool socket `/tmp/php-fpm.sock`. Nothing is written to `/app` (the data symlink points to `/config`). `TZ` is passed to php-fpm via `env[TZ]` and `date.timezone` through `php_admin_value` in the pool config (instead of upstream's `sed` on `custom.ini`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
http:
- port: '8080'
  path: /
filePaths:
- /app/www/index.php
- /app/www/backupall.php
```
8080 is the only port. Default env (sqlite) works with no variables; MySQL path is checked by hand.

## 9. Rootless and read-only-rootfs adaptations

- Upstream: root crond + supervisord, www-data chown, `/var/www/html/data` writable, `custom.ini` edited with sed, `install.sh` removed from tree. Here: `USER apps`; data via symlink to `/config/data`; cron replaced by a bash loop in start.sh; php-fpm socket, pid, nginx temp in `/tmp`; no chown at runtime.
- Draft security expectations (root, writable rootfs, `/var/www/html/data` PVC) are replaced by `apps` UID and `/config`. Migration: mount the old data dir at `/config/data`.
- PHP session/upload dirs (`session.save_path`, `upload_tmp_dir`) set to `/tmp` in the pool config.

## 10. Risks, caveats and open questions

- nginx + php-fpm + scheduler in one container: start.sh must exit if php-fpm dies (use `wait -n` or a monitor).
- Required PHP extensions and the real `.po`/`.mo` need verification against the tag.
- The backup timer is a loop, not cron; clock drift and container pause can skip runs.
- Tasmota devices must be reachable on the LAN (scan.php IP scan, host networking may be needed).
- SQLite and backups live together in `/config/data`; back up both.
- Backups run unauthenticated over HTTP on localhost: `backupall.php?docker=true` skips auth. UNVERIFIED how the app treats external callers; do not expose publicly without a reverse proxy.
- No musl/GPU/privileged blockers; arm64 works since the app is pure PHP.

## 11. Build and test steps

```sh
cd apps/tasmobackup
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tasmobackup-probe --read-only --tmpfs /tmp -v tasmobackup-probe-config:/config tasmobackup:1.08.01
docker logs -f tasmobackup-probe
forgetool containers test --image tasmobackup:1.08.01 --config ./apps/tasmobackup/container-test.yaml
docker rm -f tasmobackup-probe; docker volume rm tasmobackup-probe-config
```
Expected: `/config/data/tasmobackup` SQLite file is created, `upgrade.php` runs without error, nginx and php-fpm stay up, `curl -f localhost:8080/` returns the TasmoBackup page. Then restart with the same volume to confirm idempotency.

## 12. PR checklist

- Branch `feat/add-tasmobackup`; commit and PR title `feat(tasmobackup): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested (planning only): the build, PHP extension list, php-fpm binary name, the backup timer, MySQL mode, arm64. Do not tick "Built container locally" unless done.
