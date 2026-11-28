# friendica — implementation plan
> Source: ./draft.md · Target: apps/friendica/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 2026.05 (GitHub release tag `2026.05-1` "Latest", published 21 May; `-1` only fixed CI, not the app). Tarball version is `2026.05`. |
| Renovate | `datasource=github-tags depName=friendica/friendica versioning=loose extractVersion=^(?<version>\d{4}\.\d{2})(?:-\d+)?$` (UNVERIFIED regex against tag list; check that `2026.05` and `2026.05-1` both resolve to `2026.05`) |
| License | AGPL-3.0 (repo sidebar) -> SPDX `AGPL-3.0-or-later` (UNVERIFIED whether "or later"; check the file headers) |
| Source URL | https://github.com/friendica/friendica |
| Download (arch independent PHP) | `https://files.friendi.ca/friendica-all-in-one-${VERSION}.tar.gz` plus `.asc` signature (from upstream docker Dockerfile, which downloads exactly these). The GitHub release also lists `friendica-full-2026.05.tar.gz` and `friendica-addons-2026.05.tar.gz` with `.sum256` files. |
| Checksum | sha256 for 2026.05 all-in-one: `b0a1e218c4a5a30d25b8be5a66cb97a4f4f802b98e7cf3d0d34ce045b2714ab2`; GPG key `08656443618E6567A39524083EE197EF3F9E4287` (keyserver.ubuntu.com). Since the sha changes per version, verify with GPG against the `.asc`, not a hardcoded sha. |
| Upstream Dockerfile reviewed | https://github.com/friendica/docker/blob/91cb08d73a60af3dc355b0e6ebeaa898389cea5b/2026.05/apache/Dockerfile: `php:8.4-apache-trixie`; PHP ext `pdo_mysql gd exif zip opcache ctype pcntl ldap gmp intl` + PECL `apcu memcached redis imagick`; apt `rsync bzip2 msmtp tini mariadb-client ... gettext`; env `PHP_MEMORY_LIMIT=512M PHP_UPLOAD_LIMIT=512M FRIENDICA_SYSLOG_FLAGS=39`; unpack to `/usr/src/friendica`; volumes `/var/www/html`, `/var/www/data`; entrypoint `/entrypoint.sh` + `apache2-foreground`; Apache modules headers rewrite remoteip |
| PHP requirement | UNVERIFIED (upstream uses 8.4; Ubuntu 26.04 ships 8.5, as `apps/bookstack` uses `php8.5-*`). Confirm Friendica 2026.05 supports 8.5 in `composer.json` `require.php`. |
| Env vars (app) | The container reads `FRIENDICA_*` env in its entrypoint (UNVERIFIED names, the entrypoint was not fetched): upstream docker documents `MYSQL_HOST/MYSQL_USER/MYSQL_PASSWORD/MYSQL_DATABASE`, `FRIENDICA_ADMIN_MAIL`, `FRIENDICA_URL`, `FRIENDICA_TZ`, `FRIENDICA_LANG`. Verify against https://github.com/friendica/docker README before writing `settings.yaml`. |

## 2. Target layout

```
apps/friendica/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/nginx.conf        # nginx -> php-fpm, root /app/www, listen 8080
  defaults/php-fpm.conf      # pool on unix socket in /tmp, runs as apps
  defaults/local.config.php  # optional seed from env (only if env vars given)
```
No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: the draft says ubuntu + PHP from apt (no PHP base here). The draft's "php8.4 needs a PPA" is moot: Ubuntu 26.04 ships php8.5 (as bookstack and phpmyadmin use). Use nginx + php-fpm, not Apache, to match `apps/bookstack` and `apps/phpmyadmin` (closest siblings).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (unused).
2. `USER root`.
3. apt (`--no-install-recommends`): `nginx php8.5-fpm php8.5-cli php8.5-mysql php8.5-gd php8.5-curl php8.5-intl php8.5-mbstring php8.5-xml php8.5-zip php8.5-gmp php8.5-ldap php8.5-imagick php8.5-apcu php8.5-redis php8.5-bcmath gnupg mariadb-client rsync bzip2 msmtp-mta`. Check each name with `apt-cache policy` (UNVERIFIED which exist on 26.04). Do not re-install `curl`/`ca-certificates` (base has them). Pinning: the app is a tarball, not apt, so apt packages are unpinned; version label comes from `VERSION`.
4. Same php-fpm tweaks as `apps/phpmyadmin/Dockerfile` (`clear_env = no`).
5. Download tarball and `.asc`, `gpg --keyserver keyserver.ubuntu.com --recv-keys 08656443618E6567A39524083EE197EF3F9E4287`, `gpg --verify`, extract to `/app/www`.
6. Move the shipped `config/` to `/app/config-dist`, then symlink writable dirs: `/app/www/config -> /config/config`, `/app/www/view/smarty3 -> /tmp/smarty3` (compiled templates, ephemeral), `/app/www/proxy -> /tmp/proxy`, `/app/www/.htaccess` unused. Data dir `/config/data` (draft's `/data`). Addons: the `all-in-one` tarball bundles addons.
7. License: `cp /app/www/LICENSE* /usr/share/licenses/friendica/`.
8. `ENV PHP_MEMORY_LIMIT=512M PHP_UPLOAD_LIMIT=512M HOME=/config`.
9. Cleanup (`/tmp/*`, apt lists, purge gnupg if not needed at runtime).
10. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- Renovate comment placed directly above the `VERSION` variable (regex UNVERIFIED, see section 1):
  `// renovate: datasource=github-tags depName=friendica/friendica versioning=loose extractVersion=^(?<version>\d{4}\.\d{2})(?:-\d+)?$`
- `APP` `friendica`; `VERSION` default `2026.05` with the renovate comment above; `LICENSE` `AGPL-3.0-or-later`; `SOURCE` `https://github.com/friendica/friendica`.
- 4 standard targets and `default` group, `image-all` amd64+arm64. `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/friendica/friendica"`.
- ports: `8080/tcp` (draft says 80, impossible for non-root without capabilities).
- env (only those start.sh really applies): `TZ`, `MYSQL_HOST`, `MYSQL_PORT` (3306), `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `FRIENDICA_URL`, `FRIENDICA_ADMIN_MAIL`, `PHP_MEMORY_LIMIT` (512M), `PHP_UPLOAD_LIMIT` (512M). These are the upstream image's names (see `context/dockerhub-friendica.md`); start.sh renders them into `local.config.php`.
- volumes: `/config` (required true).
- dependencies: `mariadb` ✅ (apps/mariadb exists; hard). opt_dependencies: `valkey` ✅ (apps/valkey exists; optional, for Redis cache/locks).

## 7. start.sh

1. `mkdir -p /config/config /config/data /tmp/smarty3 /tmp/proxy /tmp/nginx-temp`.
2. If `/config/config` is empty, `cp -a /app/config-dist/. /config/config/` (seed only when missing).
3. If env DB vars are set and `/config/config/local.config.php` is missing, write it (values via `php -r` with `var_export`, to survive quotes; password never put on a command line). If not set, leave empty so the web installer can create it (draft says manual setup).
4. Wait for MariaDB (`nc -w1 host port`, up to 30 s, like `apps/bookstack/start.sh`); optional `php bin/console.php dbstructure update` when `local.config.php` exists.
5. Start php-fpm (socket in `/tmp`) in background; start worker loop in background: `while true; do php /app/www/bin/worker.php; sleep 60; done` (Friendica's documented cron entry point is `bin/worker.php`; UNVERIFIED path in 2026.05).
6. `exec nginx -c /defaults/nginx.conf -g 'daemon off;'` listening `0.0.0.0:8080`, temp paths in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 240
# narrowed: requires external mariadb; full functional test not feasible in single-container suite
tcp:
- port: '8080'
```
Use the DB narrowing only if all three criteria hold: hard mariadb dependency, web UI cannot respond without DB (the installer page might respond without DB; if so prefer `http: port 8080 path /`), and no sidecar primitive. Also assert files (`/app/www/index.php`, `/app/www/bin/worker.php`).

## 9. Rootless and read-only-rootfs adaptations

- Draft: root, writable rootfs, `/data` and `/config`. Target: `USER apps`, all writes to `/config` (config, data/storage) or `/tmp` (smarty3, proxy cache, sessions, php-fpm, nginx).
- Upstream writes to its docroot (`config/`, `view/smarty3`, `proxy/`), so symlinks (above) are essential; UNVERIFIED whether Friendica follows symlinks for smarty3 (it supports `system.smarty3_folder`; prefer config over symlink if so).
- No `gosu` (upstream needs it, we do not).

## 10. Risks, caveats and open questions

- MariaDB hard dependency; Valkey optional.
- Web installer or env seeding required; federation needs public HTTPS reverse proxy.
- Background jobs: the draft's "supervisor" is replaced by a start.sh loop; worker path UNVERIFIED.
- PHP 8.5 support and extension package names UNVERIFIED.
- Trusted proxy handling (upstream enables Apache `remoteip`): configure nginx `real_ip` or set `X-Forwarded-*` handling.
- Multi-process (nginx, php-fpm, worker) with only one `exec`; ensure signal forwarding (trap TERM).

## 11. Build and test steps

```sh
cd apps/friendica
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create friendica-probe-config
docker run --rm -d --name friendica-probe --read-only --tmpfs /tmp -v friendica-probe-config:/config friendica:2026.05
docker logs -f friendica-probe    # expect "Waiting for DB" tolerated, nginx and php-fpm ready, process stays alive
forgetool containers test --image friendica:2026.05 --config ./apps/friendica/container-test.yaml
docker rm -f friendica-probe; docker volume rm friendica-probe-config
```
Then repeat with a `mariadb` sidecar and the DB env vars to exercise the `local.config.php` path (the test runs without env, so this path is manual).

## 12. PR checklist

- Branch `feat/add-friendica`, commit `feat(friendica): add new container`.
- Template filled, `🤖 This PR is AI generated.` in Notes.
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: build, PHP 8.5 compatibility, symlinked config, worker loop, DB path, arm64, env var names.
