# farmOS/farmOS (GitHub) + draft Dockerfile

**Source URL(s) + date:** https://github.com/farmOS/farmOS; raw `docker/Dockerfile` at tag 3.5.11 and at commit `c09e3f403a21e2c3073dd5db686981c99e0314b7` (draft link, 4.x); `docker/build-farmOS.sh`, `docker/docker-entrypoint.sh`, `docker/docker-compose.production.yml`, `CHANGELOG.md`, `README.md` at 3.5.11; release page 3.5.11. Fetched 2026-11-26.

**What it is:** Drupal-based farm management / record keeping web app. GPL-2.0 (README). Image `farmos/farmos` on Docker Hub.

## Install/build (3.5.11 Dockerfile)
- Base: `FROM drupal:10.6-php8.3-apache-bookworm`. Base symlinks `/var/www/html` -> `/opt/drupal`; DocumentRoot `/opt/drupal/web`.
- `ENV BUILD_PATH=/var/farmOS`, `ENV DRUPAL_PATH=/opt/drupal`.
- GEOS PHP ext built from source: `ARG PHP_GEOS_VERSION=e77d5a16abbf89a59d947d1fe49381a944762c9d`, `https://github.com/libgeos/php-geos/archive/${PHP_GEOS_VERSION}.tar.gz`, `apt libgeos-dev`, `./autogen.sh && ./configure && make && make install`.
- `docker-php-ext-install bcmath exif`; `docker-php-ext-enable bcmath exif geos`.
- apt: `git unzip postgresql-client libgeos-c1v5`.
- `ENV COMPOSER_MEMORY_LIMIT=-1`, `ENV COMPOSER_ALLOW_SUPERUSER=1`.
- `RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf`.
- `COPY conf.d/ /usr/local/etc/php/conf.d` (not fetched).
- Production: `mkdir ${BUILD_PATH} && build-farmOS.sh --no-dev && chown -R www-data:www-data ${BUILD_PATH}/web/sites && rm -r ${DRUPAL_PATH} && cp -rp ${BUILD_PATH} ${DRUPAL_PATH}`.
- `ENTRYPOINT ["docker-entrypoint.sh"]`, `CMD ["apache2-foreground"]`. No EXPOSE, VOLUME, WORKDIR.
- Dev stage (not for prod): xdebug, `WWW_DATA_ID` remap (default 1000).

### build-farmOS.sh
- Fails if `${BUILD_PATH}` non-empty.
- `git clone ${PROJECT_REPO} project`, move `.git` into build dir, `git checkout ${PROJECT_VERSION}`, `git reset --hard`.
- `COMPOSER_HOME=$(mktemp -d)`.
- Tagged semver `FARMOS_VERSION`: `composer require farmos/farmos:${FARMOS_VERSION} --no-install`. `3.x`: requires `3.x-dev`. Other: `dev-<branch>`. Repo added only for non-tag builds.
- allow-plugins: composer/installers, cweagans/composer-patches, dealerdirect/phpcodesniffer-composer-installer, drupal/core-composer-scaffold, oomphinc/composer-installers-extender, phpstan/extension-installer, wikimedia/composer-merge-plugin.
- `composer install` (+ args, e.g. `--no-dev`).
- `sed -i "s|version: 3.x|version: ${FARMOS_VERSION}|g" ${BUILD_PATH}/web/profiles/farm/farm.info.yml`.

## Runtime deps
- Apache (`apache2-foreground`), user www-data. PHP ext: bcmath, exif, geos, plus base image set.
- Docs-required PHP ext: BCMath, EXIF, GEOS, SimpleXML. Docs-required DB: PostgreSQL 16+ (recommended), MariaDB 10.6+, MySQL 8.0+, SQLite 3.45+.

## Entrypoint (docker-entrypoint.sh, full logic)
- If `${DRUPAL_PATH}` empty: `cp -rp ${BUILD_PATH}/. ${DRUPAL_PATH}`.
- If `${DRUPAL_PATH}/web/sites` empty: `cp -rp ${BUILD_PATH}/web/sites/. ${DRUPAL_PATH}/web/sites`.
- If `FARMOS_FS_READY_SENTINEL_FILENAME` set: write `ready` to it.
- `exec "$@"`.

## Env vars

| Variable | Default | Used by | Notes |
| --- | --- | --- | --- |
| `BUILD_PATH` | `/var/farmOS` | Dockerfile/scripts | build tree |
| `DRUPAL_PATH` | `/opt/drupal` | Dockerfile/entrypoint | runtime tree |
| `FARMOS_FS_READY_SENTINEL_FILENAME` | unset | entrypoint | optional |
| `FARMOS_VERSION` | `3.x` | build-farmOS.sh | build arg |
| `PROJECT_VERSION` | `3.x` | build-farmOS.sh | composer-project branch |
| `WWW_DATA_ID` | `1000` | dev stage | build arg |
| `COMPOSER_MEMORY_LIMIT`, `COMPOSER_ALLOW_SUPERUSER` | `-1`, `1` | Dockerfile | build only |

No runtime DB env vars; DB is set in the web installer.

## Ports
- Apache 80 (compose maps `80:80`).

## Volumes/paths
- Persistent: `web/sites` = `/opt/drupal/web/sites` (settings.php, files, private).
- Compose: `./sites:/opt/drupal/web/sites`.
- Private files: `$settings['file_private_path'] = '/opt/drupal/web/sites/default/private/files'`; dir mode 770, owner www-data.
- OAuth2 keys: `../keys/` outside webroot (bind mount under compose).

## User/UID
- www-data (UID/GID 33 per docs; `chown 33:33 sites` on host).

## Config files
- Optional `php.ini` mounted to `/usr/local/etc/php/conf.d/farmos.ini` (docs: `upload_max_filesize = 50M`, `post_max_size = 50M`).
- Docs recommended: `memory_limit=256M`, `max_execution_time=240`, `max_input_time=240`, `max_input_vars=5000`, `realpath_cache_size=4096K`, `realpath_cache_ttl=3600`.

## Healthcheck
- None in repo. Installer served at site hostname.

## Version/asset naming
- Latest release 3.5.11 (GitHub "Latest", 19 Nov, year not shown). Assets list failed to load; the draft's `farmOS-3.5.11.tar.gz` name is not confirmed here.
- Draft commit `c09e3f40...` is 4.x: `FROM drupal:11.4-php8.4-apache-trixie`, `ARG FARMOS_VERSION=4.x`, `PROJECT_VERSION=4.x`, `PHP_GEOS_VERSION=dfe1ab17b0f155cc315bc13c75689371676e02e1`.

## Arch
- Not stated. PHP source; arch-independent build (GEOS ext compiled per arch).

## Gotchas
- CHANGELOG 3.5.11: "Update PHP to 8.4.28 ... for the security update" in the Docker image (CVE-2026-129496). Conflicts with the 3.5.11 Dockerfile base `php8.3`. PHP minor for 3.5.11 unresolved.
- Docs requirement page: PHP 8.4. Plan targets PHP 8.5.
- Changelog: 3.5.10 Drupal core 10.6.22; 3.5.8/3.5.9 PHP 8.3.36 (3.5.8 build failed, 3.5.9 fixes it); 3.5.7 Drupal 10.6.19 + Gin 4.1.4; 3.5.6 Drupal 10.6.17.
- `/var/www/html` is a symlink to `/opt/drupal`, so `/var/www/html/sites` is NOT `web/sites`.
- composer-project branch floats unless `PROJECT_VERSION` pinned.
- Entrypoint only seeds empty dirs; upgrades are manual (DB update steps).
