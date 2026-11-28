# farmos — implementation plan
> Source: ./draft.md · Target: apps/farmos/ · Difficulty: hard · Role: main · Verified on 2026-11-24

Corrections to the draft: the `farmOS-3.5.11.tar.gz` release asset is only the farmOS package; the upstream image builds the full Drupal codebase with composer (`composer-project` plus `farmos/farmos`). The Docker Hub `latest` tag and upstream `main` are the 4.x line (Drupal 11), while the latest GitHub release is 3.5.11 (Drupal 10.6). This plan follows the 3.5.11 release, which matches the draft.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `3.5.11` (latest GitHub release, 2026-11-19, matches draft). Tags also include 7.x-1.x legacy ones |
| Renovate | `datasource=github-releases depName=farmOS/farmOS versioning=semver` |
| License | GPL-2.0 (GitHub SPDX `GPL-2.0`; `LICENSE.txt` in repo). Use `GPL-2.0-only` only if headers confirm; otherwise keep `GPL-2.0` as reported (UNVERIFIED -only/-or-later) |
| Source URL | https://github.com/farmOS/farmOS |
| Download | `https://github.com/farmOS/farmOS/releases/download/3.5.11/farmOS-3.5.11.tar.gz` (arch independent, PHP) |
| Checksum | GitHub asset digest `sha256:490f0a6b2bd2222d37bac1e4e283f91e7be943e04e82ba1c8704356eaae4ee3c` (API). The recommended build does not use this tarball (see section 4) |
| Upstream Dockerfile reviewed | `docker/Dockerfile` at tag 3.5.11 (base `drupal:10.6-php8.3-apache-bookworm`; builds `php-geos` from a pinned commit; installs `bcmath exif geos`; `git unzip postgresql-client libgeos-c1v5`; `COMPOSER_MEMORY_LIMIT=-1`; `build-farmOS.sh --no-dev` into `/var/farmOS`, copied to `/opt/drupal`; DocumentRoot `/opt/drupal/web`; `ENTRYPOINT docker-entrypoint.sh`, `CMD apache2-foreground`; `ServerName localhost`). The commit linked in the draft is 4.x (Drupal 11.4, php8.4, trixie) |
| Build script | `build-farmOS.sh`: `git clone https://github.com/farmOS/composer-project.git`, checkout `${PROJECT_VERSION}` (3.x), `composer require farmos/farmos:${FARMOS_COMPOSER_VERSION} --no-install` (`3.x-dev` when FARMOS_VERSION is `3.x`, the bare tag such as `3.5.11` for a tagged release), allow-plugins (`composer/installers`, `cweagans/composer-patches`, `dealerdirect/phpcodesniffer-composer-installer`, `drupal/core-composer-scaffold`, `oomphinc/composer-installers-extender`, `phpstan/extension-installer`, `wikimedia/composer-merge-plugin`), `composer install --no-dev`, then `sed -i "s|version: 3.x|version: ${FARMOS_VERSION}|g" web/profiles/farm/farm.info.yml` |
| PHP ini (upstream `conf.d`) | `memory_limit=256M max_execution_time=240 max_input_time=240 max_input_vars=5000 post_max_size=100M upload_max_filesize=100M expose_php=Off`, `opcache.memory_consumption=256`, `opcache.max_accelerated_files=20000`, `realpath_cache_size=4096K`, `realpath_cache_ttl=3600` |
| Entrypoint | seeds an empty `/opt/drupal` and empty `web/sites` from `/var/farmOS` (bind-mount support), optional `FARMOS_FS_READY_SENTINEL_FILENAME` |
| Persistent path | `web/sites` (settings, `files`, private files). Upstream path is `/opt/drupal/web/sites`; the draft path `/var/www/html/sites` is not that path (base image symlinks `/var/www/html` to `/opt/drupal`, so it resolves to `/opt/drupal/sites`) |
| Ports | 80/tcp (Apache upstream); we serve on 8080 |
| Env vars | Upstream image reads none for the app; the DB is configured in the web installer. UNVERIFIED for 3.5.11 beyond `FARMOS_FS_READY_SENTINEL_FILENAME` |
| Ubuntu 26.04 (resolute) packages | `php8.5` 8.5.4-0ubuntu1.6, `nginx` 1.28.3-2ubuntu1.14, `php-geos` 1.0.0-8ubuntu2, `geos` 3.14.1-2 (Launchpad API) |

## 2. Target layout

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- `etc/farmos/nginx.conf` and `etc/farmos/php-fpm.conf` and `etc/farmos/php/farmOS.ini`: runtime config templates, copied by `COPY . /` (allow-list contains `etc/`). Never `root/`.
- No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, with nginx plus php-fpm from apt (the draft's choice; upstream uses Apache, but rootless Apache is awkward). Closest sibling: `apps/bookstack` (PHP stack, `php8.5-*` packages and the `clear_env = no` php-fpm tweak) and `apps/phpmyadmin`. Both siblings set `/etc/php/8.5`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends` (verify none is already in the base): `nginx php8.5-fpm php8.5-cli php8.5-pgsql php8.5-gd php8.5-xml php8.5-mbstring php8.5-curl php8.5-zip php8.5-intl php8.5-bcmath php8.5-opcache php-geos composer git unzip postgresql-client`. `exif` is in `php8.5-common`. Check `php -m` shows `bcmath exif geos gd pdo_pgsql` during the build (`RUN php -m | grep -E ...`). Pin `nginx=` the way `apps/nginx` does only if the VERSION of the app depended on it; here VERSION is farmOS, so the apt packages do not need pinning, but the image must report 3.5.11 (checked in step 4).
3. Build farmOS (same method as upstream `build-farmOS.sh`), as root in `/app/farmos` with `COMPOSER_HOME=/tmp/composer` and `COMPOSER_MEMORY_LIMIT=-1`:
   ```sh
   git clone --depth 1 --branch 3.x https://github.com/farmOS/composer-project.git /tmp/project
   mv /tmp/project/.git /app/farmos/.git; rm -rf /tmp/project   # then: git -C /app/farmos checkout 3.x && git reset --hard
   cd /app/farmos && composer require farmos/farmos:${VERSION} --no-install
   # composer config --no-plugins allow-plugins.<each of the 7 plugins above> true
   composer install --no-dev --no-interaction
   sed -i "s|version: 3.x|version: ${VERSION}|g" web/profiles/farm/farm.info.yml
   rm -rf /app/farmos/.git /tmp/composer
   ```
   The composer-project branch name `3.x` is taken from the upstream default `PROJECT_VERSION=3.x` at 3.5.11. Composer needs PHP 8.5 compatibility with Drupal 10.6: UNVERIFIED, may need `--ignore-platform-req=php` or PHP 8.4 (see section 10).
4. Writable sites: `mv /app/farmos/web/sites /app/farmos-sites-default && ln -s /config/sites /app/farmos/web/sites` (symlink created at build time; seed in `start.sh`).
5. Licenses: copy `/app/farmos/web/profiles/farm/LICENSE.txt` (path UNVERIFIED, `find` it) and `/app/farmos/vendor/drupal/core/LICENSE.txt` to `/usr/share/licenses/farmos/`.
6. Set `ENV HOME=/config COMPOSER_HOME=/tmp/composer` and `chown -R apps:apps /app && chmod -R 755 /app`.
7. Remove build-only tools if unneeded at runtime: keep `git unzip composer` because Drupal update workflows use composer; purge nothing else. `apt-get clean && rm -rf /var/lib/apt/lists/*`.
8. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 8080`; `VOLUME /config`; `WORKDIR /app/farmos`.

## 5. docker-bake.hcl

`APP="farmos"`, `VERSION` default `3.5.11` preceded by `// renovate: datasource=github-releases depName=farmOS/farmOS versioning=semver`, `LICENSE="GPL-2.0-only"` (or the exact SPDX confirmed in step 1; UNVERIFIED), `SOURCE="https://github.com/farmOS/farmOS"`. Four standard targets (`docker-metadata-action`, `image` with `args.VERSION` and OCI `source`/`licenses` labels, `image-local` with `type=docker` and tag `${APP}:${VERSION}`, `image-all` with amd64 and arm64) plus `group "default" { targets = ["image-local"] }`. Run `docker buildx bake --print`.

## 6. settings.yaml

Header and `schema_version: 1`; `upstream_env_url: "https://github.com/farmOS/farmOS"`.
- ports: `8080/tcp required: false`.
- env: `TZ` default `Etc/UTC` required false; `PHP_MEMORY_LIMIT` default `256M` required false (only if `start.sh` writes it into the generated ini, see section 7). No DB variables: the DB is entered in the web installer.
- volumes: `/config` required true (`/config/sites`).
- dependencies: `postgresql` (hard at install time, ✅ `apps/postgresql` exists). Use `dependencies:` because the installer needs a PostgreSQL (or MariaDB, `opt_dependencies: mariadb` ✅) database.

## 7. start.sh

1. `mkdir -p /config/sites /config/tmp /tmp/nginx /tmp/php`.
2. Seed only when missing: `[ -d /config/sites/default ] || cp -rn /app/farmos-sites-default/. /config/sites/`. Never overwrite `settings.php`. Drupal needs `sites/default/settings.php` writable and `sites/default/files` writable on first install: `chmod u+w /config/sites/default` and create `files/` if absent.
3. Render configs into `/tmp`: `envsubst` (in base) the templates in `/etc/farmos/` to `/tmp/nginx/nginx.conf` (listen `0.0.0.0:8080`, `root /app/farmos/web`, Drupal rewrite `try_files $uri /index.php?$query_string`, `fastcgi_pass unix:/tmp/php/php-fpm.sock`, pid and temp paths under `/tmp/nginx`) and `/tmp/php/php-fpm.conf` (`user` omitted since non-root, `listen` the same socket, `clear_env = no`, `error_log = /proc/self/fd/2`, `catch_workers_output = yes`).
4. PHP ini: write the upstream `conf.d` values (section 1) to `/tmp/php/farmOS.ini` and run fpm with `-d`/`PHP_INI_SCAN_DIR=:/tmp/php`. `memory_limit` comes from `PHP_MEMORY_LIMIT` (default `256M`); upload and post sizes `100M`.
5. Start `php-fpm8.5 -F -y /tmp/php/php-fpm.conf &`, then `exec nginx -c /tmp/nginx/nginx.conf -g 'daemon off;'`. (Two processes: tini in the base handles signals; add a `trap 'kill $FPM_PID' TERM` before exec is NOT possible after exec, so keep fpm child of nginx wrapper or use `wait -n` if a clean shutdown matters. Prefer: run nginx in background and `exec php-fpm`... pick one during the build and document it.)
6. No writes to `/app`. Drupal temp dir must point to `/tmp` (set in the installer or `$settings['file_temp_path']` in `settings.php`; seed a `settings.php` snippet only after install, not by the container).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '8080'
http:
- port: '8080'
  path: /core/install.php
filePaths:
- /app/farmos/web/index.php
- /app/farmos/vendor/autoload.php
```
`/core/install.php` returns 200 on an unconfigured site (the plain `/` redirects). UNVERIFIED which status the probe accepts; adjust path after the first run. The DB narrowing exception does NOT apply: the app starts and serves the installer without a database, so a full probe is used. DB-dependent install is checked by hand against `apps/postgresql`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `web/sites/default/{settings.php,files}` | `/config/sites` via build-time symlink, seeded by `start.sh` |
| Private files (set in installer) | `/config/private` (user enters path; document in README) |
| Drupal temp, php sessions, opcache | `/tmp` (tmpfs); `session.save_path` or fpm `php_admin_value` to `/tmp/php` |
| nginx pid, temp, logs | `/tmp/nginx`, logs to stdout/stderr |
| Composer cache and `~/.composer` | `COMPOSER_HOME=/tmp/composer` |
| `drush`/`update.php` code updates under `/app/farmos` | Not supported at runtime (read-only `/app`); upgrade by bumping the image version |

Draft: TrueCharts runs as root with `/var/www/html/sites` as persistence. We use UID 568, port 8080, `/config/sites`. Not privileged. Existing TrueCharts data must be copied from `/var/www/html/sites` (upstream `/opt/drupal/web/sites`) to `/config/sites`.

## 10. Risks, caveats and open questions

- BIG: PHP 8.5 on Ubuntu 26.04 versus Drupal 10.6 (3.5.11). Drupal 10.6 officially supports PHP 8.1 to 8.4; 8.5 support is UNVERIFIED. Fallbacks: an alternative PHP build (PPA, not allowed by repo conventions without review), or follow siblings that already use 8.5 and test; if it fails, mark the app blocked until farmOS 4.x (Drupal 11.4) is released as a GitHub release and re-plan for it.
- `php-geos` from apt must provide an extension for PHP 8.5 (`php8.5-geos` or the `php-geos` meta): UNVERIFIED. Without it, farmOS geometry features fail. Check `php -m | grep geos`.
- Composer build is large (several minutes, high memory), needs network, and `composer-project` branch `3.x` can drift (floating branch). A lock on a commit is advisable.
- Draft "needs external database" is correct; the database is configured through the web installer (manual setup), so there is no env-based auto-provisioning. Consider a future `start.sh` extension with `drush site:install`.
- 4.x (`latest` on Docker Hub) is not what this plan builds. Renovate will not move to 4.x until a 4.x GitHub release exists; review the major bump manually.
- Two long-running processes (nginx plus php-fpm) in one container: choose a supervision approach in the build step.
- Apache modules in the upstream image (rewrite, etc.) are replaced by nginx rules; clean URLs need the `try_files` rule above.

## 11. Build and test steps

```sh
cd apps/farmos && docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name farmos-probe --read-only --tmpfs /tmp -v farmos-probe-config:/config farmos:3.5.11
docker logs -f farmos-probe
forgetool containers test --image farmos:3.5.11 --config ./apps/farmos/container-test.yaml
docker rm -f farmos-probe; docker volume rm farmos-probe-config
```
Readiness: nginx started with no `emerg`, php-fpm logs `ready to handle connections`, and `curl -fsS http://localhost:8080/core/install.php` returns the Drupal installer. Then run a manual installer pass against `apps/postgresql` on a shared network to confirm `sites/default/settings.php` is written to `/config/sites`. arm64 is only tried if requested.

## 12. PR checklist

- Branch `feat/add-farmos`; commit and PR title `feat(farmos): add new container`.
- PR template filled in; Notes include `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Check: VERSION aligned between Dockerfile and bake, renovate comment, `USER apps`, `COPY --chmod=0755 . /`, empty `/config` start, read-only rootfs.
- Untested: PHP 8.5 compatibility, geos extension, composer build, full installer run with PostgreSQL, arm64, upgrade from an existing TrueCharts sites folder.
