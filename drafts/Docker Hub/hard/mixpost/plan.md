# mixpost — implementation plan
> Source: ./draft.md · Target: apps/mixpost/ · Difficulty: hard (Laravel app assembled from a skeleton plus a package, several processes) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2.6.0` of the `inovector/mixpost` Laravel package (GitHub release `2.6.0`, published 2026-03-16; Packagist `2.6.0`, requires PHP `^8.2`). The Docker Hub image the chart runs is `v2.6.0`. |
| Important finding | `inovector/mixpost` is a Laravel package, not a runnable app. The runnable skeleton is a separate repo, https://github.com/inovector/MixpostApp (Packagist `inovector/mixpostapp`, latest tag `v2.1.1`, requires `inovector/mixpost ^2.2`, `inovector/mixpost-auth ^2.1`, `laravel/framework ^12`, `laravel/horizon`). The official manual install is `composer create-project inovector/MixpostApp`. The draft's "source from the v2.6.0 tag" is therefore not enough alone. |
| Renovate | Package: `datasource=github-releases depName=inovector/mixpost versioning=semver`. Skeleton (second variable): `datasource=github-tags depName=inovector/MixpostApp versioning=semver extractVersion=^v(?<version>.+)$`. UNVERIFIED: that the release tag has no `v` while older tags do (the API returned `2.6.0` for the release and `v2.3.0` for tags). Check at implementation time and fix the URL or regex. |
| License | Package: MIT (`LICENSE.md`, Packagist `MIT`). Skeleton: no license reported by GitHub. UNVERIFIED, so ask upstream or treat the app as MIT in practice, and record this in the PR. `LICENSE` in bake: `MIT`. Mixpost Pro and Enterprise are paid and are not part of this image. |
| Source | https://github.com/inovector/mixpost |
| Download | No tarball: `composer create-project inovector/mixpostapp:${APP_VERSION}` then `composer require inovector/mixpost:${VERSION}`. Works on amd64 and arm64 (pure PHP). The draft's "binary" link is only the release page. |
| Checksum | Composer verifies package dists against the lock file. UNVERIFIED: the skeleton ships `composer.lock`. If it does, commit nothing, and use `composer install` on the created project. Otherwise note that resolution happens at build time. |
| Upstream Dockerfile | None public (`inovector/mixpost` Docker Hub image, no linked source). The documented Docker run is `inovector/mixpost:latest` with `.env`, port 80, volumes `/var/www/html/storage/app` and `/var/www/html/storage/logs`, MySQL 8 and Redis. |
| Ports | Image listens on 80 (docs map `9000:80`). In a rootless image use 8080. 9000 (php-fpm) stays internal and is not exposed. |
| Env vars (docs `Environment variables`) | `APP_NAME`, `APP_KEY`, `APP_DEBUG`, `APP_DOMAIN` (Docker only), `APP_URL`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`, `MIXPOST_DISK` (`public` or `s3`), `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`, `AWS_BUCKET`, `LOG_CHANNEL`, `MIXPOST_LOG_CHANNEL`, `MIXPOST_CACHE_PREFIX`, `FFMPEG_PATH` (`/usr/bin/ffmpeg`). Skeleton `.env.example` also has `MAIL_*`. Defaults: `DB_HOST 127.0.0.1`, `DB_DATABASE mixpost_db`, `DB_USERNAME mixpost_user`. |
| Processes (docs) | Web app, `php artisan horizon` (queue, needs Redis), and `php artisan schedule:run` every minute. Setup commands: `php artisan optimize`, `php artisan migrate`, first user via `php artisan mixpost-auth:create`. |
| Database | MySQL or MariaDB (docs use MySQL 8). UNVERIFIED: MariaDB compatibility with this Laravel version (Laravel 12 supports MariaDB). |

## 2. Target layout

```
apps/mixpost/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/nginx/mixpost.conf.template   # nginx server block (copied to /tmp at start)
  etc/php/mixpost-fpm.conf          # php-fpm pool, listens on 127.0.0.1:9000, clear_env = no
```
No `root/`. No `DOWNSTREAM_CHANGES.md`. `etc/` is on the `include/.dockerignore` allow-list, and nothing else outside the listed paths would reach the image.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Closest sibling: `apps/bookstack` (Laravel on ubuntu with `php8.5-*` apt packages, composer, symlinks into `/config`). Bookstack here only runs the queue worker, so the nginx and php-fpm wiring is new work. `apps/grocy` and `apps/snipe-it` are other PHP siblings to read before implementing.

## 4. Dockerfile

1. `ARG VERSION`, `ARG APP_VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends php8.5-cli php8.5-fpm php8.5-mysql php8.5-redis php8.5-curl php8.5-mbstring php8.5-xml php8.5-zip php8.5-gd php8.5-bcmath php8.5-intl ffmpeg nginx composer unzip git ca-certificates` and skip anything the base or bookstack-style setup already has (check first). `php8.5-*` follows bookstack, but UNVERIFIED: that the `php8.5-redis` and `php8.5-bcmath` names exist on 26.04 and that Laravel 12 and Mixpost run on PHP 8.5 (the package needs `^8.2`). `ext-fileinfo` is in the core packages. The draft's `supervisor` is not used: `start.sh` supervises the processes itself, which avoids root-owned supervisor state.
3. Create the app in `/app/www`: `composer create-project --no-dev --no-interaction inovector/mixpostapp:${APP_VERSION} /app/www && cd /app/www && composer require --no-interaction -W inovector/mixpost:${VERSION}`. Publish assets as the docs do (`php artisan vendor:publish --tag=mixpost-assets --force`; UNVERIFIED tag name, confirm with `php artisan vendor:publish --help` in the build). Do not run `php artisan optimize` at build time, because the cached config would bake in build-time env.
4. Make writable paths symlinks to `/config`: `storage/app` to `/config/storage/app`, `storage/logs` to `/config/storage/logs`, `storage/framework` to `/tmp/storage-framework` (cache, sessions and views are ephemeral), `bootstrap/cache` to `/tmp/bootstrap-cache`. Remove the originals first.
5. `chown -R apps:apps /app`, license files to `/usr/share/licenses/mixpost/` (package `LICENSE.md`, fetched from the vendor directory).
6. `ENV HOME=/config COMPOSER_HOME=/tmp/composer COMPOSER_CACHE_DIR=/tmp/composer-cache`, clean `/tmp/*` and apt lists.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`.

## 5. docker-bake.hcl

- `APP=mixpost`, `LICENSE=MIT`, `SOURCE=https://github.com/inovector/mixpost`.
- `VERSION` `2.6.0` with `// renovate: datasource=github-releases depName=inovector/mixpost versioning=semver`.
- `APP_VERSION` `2.1.1` (skeleton) with its own renovate comment (section 1). Both are passed as `args` and must match the `ARG`s in the Dockerfile.
- Standard four targets plus `group "default"`. Check with `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/inovector/mixpost"`.
- `ports`: 8080 tcp, required false.
- `env` (names from the docs; defaults must equal `start.sh`): `TZ` (`Etc/UTC`), `APP_URL` (empty, required true), `APP_KEY` (empty, required false: generated and kept in `/config/.app_key` when unset), `APP_DEBUG` (`false`), `APP_NAME` (`Mixpost`), `DB_HOST` (`mariadb`), `DB_PORT` (`3306`), `DB_DATABASE` (`mixpost`), `DB_USERNAME` (`mixpost`), `DB_PASSWORD` (empty, required true), `REDIS_HOST` (`valkey`), `REDIS_PORT` (`6379`), `REDIS_PASSWORD` (empty), `MIXPOST_DISK` (`public`), `LOG_CHANNEL` (`stderr`, so logs reach the container output; UNVERIFIED that Laravel's `stderr` channel exists in this skeleton, the docs list `single` and `daily`, so fall back to `single` if not).
- `volumes`: `/config` required. The chart's `/var/www/html/storage/app` and `/storage/logs` PVCs map to `/config/storage/app` and `/config/storage/logs`.
- `dependencies`: `mariadb` ✅, `valkey` ✅.

## 7. start.sh

1. `mkdir -p /config/storage/app/public /config/storage/logs /tmp/storage-framework/{cache,sessions,views} /tmp/bootstrap-cache /tmp/nginx /tmp/php`.
2. `APP_KEY`: if unset, read `/config/.app_key`, and if missing generate with `php artisan key:generate --show` (writes nothing to `.env`), store it with mode 600, and export it. The key must persist, or stored OAuth tokens become unreadable. Log only that a key was generated, never its value.
3. Required env check: if `APP_URL` or `DB_PASSWORD` is empty, log a clear message and run a stub `php -S 0.0.0.0:8080` page so the test with no env can still probe the port (same trade-off as `apps/mastodon`).
4. Wait for the database with a bounded retry (`nc -w1 $DB_HOST $DB_PORT`, as bookstack does), then `php artisan migrate --force` on every start (idempotent) and `php artisan storage:link` (the link lives in `public/`, so create it at build time if it must be in `/app`; UNVERIFIED).
5. Render `/tmp/nginx/nginx.conf` from `etc/nginx/mixpost.conf.template` (pid, temp paths and logs in `/tmp`, `listen 8080`, root `/app/www/public`, `fastcgi_pass 127.0.0.1:9000`). Write the php-fpm config to `/tmp/php/` with the pool user unset (it runs as `apps`) and `clear_env = no`.
6. Start `php-fpm8.5 -F -y /tmp/php/fpm.conf &`, `php artisan horizon &`, and a scheduler loop `while true; do php artisan schedule:run; sleep 60; done &`.
7. Optional first admin from env (`MIXPOST_ADMIN_*`) is not supported upstream as far as verified. UNVERIFIED whether `mixpost-auth:create` accepts non-interactive options. Until verified, document `docker exec ... php artisan mixpost-auth:create`.
8. `exec nginx -c /tmp/nginx/nginx.conf -g 'daemon off;'` as the final process, with a `trap` to stop the background jobs. If one background process dies, exit so the orchestrator restarts the container.

## 8. container-test.yaml

MariaDB and Valkey are hard dependencies, so the protocol's narrowing applies when all three criteria hold. They do, so use a narrow test with the required comment:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
# narrowed: requires external mariadb and valkey; full functional test not feasible in single-container suite
tcp:
- port: '8080'
filePaths:
- /app/www/artisan
- /app/www/vendor/inovector/mixpost/composer.json
- /app/www/public/index.php
- /usr/share/licenses/mixpost/LICENSE.md
runners:
- entrypoint: php --version
- entrypoint: test -x /usr/bin/ffmpeg
- entrypoint: test -x /usr/sbin/nginx
```
The tcp probe is served by the stub in section 7 step 3 when no env is set. Real behaviour is run by hand in section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/var/www/html/storage/app` (uploads, media) | `/config/storage/app` (symlink) |
| `/var/www/html/storage/logs` | `/config/storage/logs` (symlink) |
| `storage/framework/{cache,sessions,views}`, `bootstrap/cache` | `/tmp/...` (symlinks) |
| `.env` | not used: config comes from the process env |
| nginx pid, temp, logs, php-fpm pid and socket | `/tmp/nginx`, `/tmp/php` |
| Composer cache and home | `/tmp/composer*` |
| Port 80 | 8080 (non-root cannot bind below 1024 without extra capability) |

Draft expects root (UID 0, readOnlyRootFilesystem false). Reject: run as `apps` (568) with a read-only rootfs. Nginx and php-fpm both run as that user. Not privileged.

## 10. Risks, caveats and open questions

- No public upstream Dockerfile, so the layout above is our own. The first build is the real test of the skeleton plus package combination (UNVERIFIED).
- The version scheme is split: the skeleton is `2.1.1` while the package is `2.6.0`. Renovate bumps them separately and a bump of one can break the other (`^2.2` constraint is fine for 2.6.0).
- PHP 8.5 and Laravel 12 compatibility is UNVERIFIED. If it fails, use a distro PHP the package supports, or pin PHP 8.4 from a PPA (not preferred).
- Skeleton license is not declared upstream.
- APP_KEY, first-user creation and social platform API keys are manual steps. Pro features need a paid license and are not in Lite.
- Multi-process container (nginx, php-fpm, horizon, scheduler). A crash of Horizon must stop the container, as in step 8.
- A public HTTPS domain is needed for social network callbacks.

## 11. Build and test steps

```sh
cd apps/mixpost
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create mixpost-probe-config
docker run --rm -d --name mixpost-probe --read-only --tmpfs /tmp -v mixpost-probe-config:/config mixpost:2.6.0
docker logs -f mixpost-probe    # no env: stub page on 8080 and the missing-env message
docker rm -f mixpost-probe; docker volume rm mixpost-probe-config
```
Then run with `mariadb` and `valkey` on one network and `APP_URL`, `DB_*` set. Expect "migrate" output, nginx listening on 8080, Horizon started, and `curl -I http://localhost:8080/` returning 200 or a redirect to the login page. Then run `forgetool containers test --image mixpost:2.6.0 --config ./apps/mixpost/container-test.yaml`. Create a user with `php artisan mixpost-auth:create` and check a restart keeps the same `APP_KEY`.

## 12. PR checklist

- Branch `feat/add-mixpost`, commit and PR title `feat(mixpost): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`. Put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- List what is untested: arm64, the full run against MariaDB and Valkey, Horizon jobs, social account connection, S3 storage, PHP 8.5 compatibility.
- Confirm `bake --print`, `VERSION` and `APP_VERSION` aligned between bake and Dockerfile, the license file shipped, `USER apps`, an empty `/config` start, and the narrowing comment in `container-test.yaml`.
