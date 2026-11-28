# twofauth — implementation plan
> Source: ./draft.md · Target: apps/twofauth/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `9.0.3`, latest release, published 2026-11-23 (https://api.github.com/repos/Bubka/2FAuth/releases/latest, tag `v9.0.3`). The chart pins `docker.io/2fauth/2fauth:9.0.1`, so this plan moves one minor step ahead. |
| Renovate | `datasource=github-releases depName=Bubka/2FAuth versioning=semver`. Upstream tags are `vX.Y.Z`; the Dockerfile strips the `v` (see section 4). |
| License | AGPL-3.0 (GitHub API `license.spdx_id`, https://api.github.com/repos/Bubka/2FAuth) |
| Source URL | https://github.com/Bubka/2FAuth |
| Download | Source archive `https://github.com/Bubka/2FAuth/archive/refs/tags/v${VERSION}.tar.gz`. The release has no binary assets (`assets: []`). |
| Per-arch | Source build (PHP), so there is no per-arch binary. Architecture is only the base image's. |
| Checksum source | None published on the release. Verify the tag by its commit SHA at build time (UNVERIFIED: the commit SHA of `v9.0.3` was not fetched). |
| Upstream Dockerfile reviewed | https://api.github.com/repos/Bubka/2FAuth/contents/Dockerfile?ref=v9.0.3: Alpine 3.24 final image, PHP 8.4 via apk (`php84`, `php84-fpm`, `php84-pdo_pgsql`, `php84-pgsql`, `php84-pdo_sqlite`, `php84-pdo_mysql`, `php84-xml`, `php84-gd`, `php84-mbstring`, `php84-tokenizer`, `php84-fileinfo`, `php84-bcmath`, `php84-ctype`, `php84-dom`, `php-redis`, `php84-session`, `php84-openssl`), `nginx`, `supervisord` v0.7.3, composer 2.9 in a build stage, `composer install --no-dev --optimize` in a vendor stage. `USER ${UID}:${GID}` (1000:1000). `EXPOSE 8000/tcp`. `ENTRYPOINT /usr/local/bin/entrypoint.sh`. `WORKDIR /srv`. |
| Entrypoint | https://api.github.com/repos/Bubka/2FAuth/contents/docker/entrypoint.sh?ref=v9.0.3: reads `APP_KEY`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `REDIS_PASSWORD` from `*_FILE` variants too; creates the SQLite file when `DB_CONNECTION=sqlite`; then starts services. |
| Supervisord | https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/docker/supervisord.conf: `php-fpm` `/usr/sbin/php-fpm84 -F`, `nginx` `/usr/sbin/nginx -g 'daemon off;'`. No `user=` set. |
| nginx | https://api.github.com/repos/Bubka/2FAuth/contents/docker/nginx.conf?ref=v9.0.3: `listen 8000;` and `listen [::]:8000;`, `root /srv/public;`, `error_log /dev/stderr`. |
| Port | **8000/tcp.** The draft's `80/http` is wrong for this image (nginx listens on 8000). |
| Env vars (real, from `.env.example`) | `APP_NAME`, `APP_ENV`, `APP_TIMEZONE`, `APP_DEBUG`, `SITE_OWNER`, `APP_KEY`, `APP_URL`, `APP_SUBDIRECTORY`, `LOG_CHANNEL`, `LOG_LEVEL`, `CACHE_DRIVER`, `SESSION_DRIVER`, `DB_CONNECTION`, `DB_DATABASE`, `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `MAIL_*`, `THROTTLE_API`, `LOGIN_THROTTLE`, `AUTHENTICATION_GUARD`, `TRUSTED_PROXIES`, `WEBAUTHN_NAME`, `WEBAUTHN_ID`, `REDIS_HOST`, `REDIS_PASSWORD`, `REDIS_PORT`, `BROADCAST_DRIVER`, `QUEUE_DRIVER` (source: https://api.github.com/repos/Bubka/2FAuth/contents/.env.example?ref=v9.0.3). Upstream image defaults: `LOG_CHANNEL=daily`, `LOG_LEVEL=info`, `DB_CONNECTION=sqlite`, `DB_DATABASE=/srv/database/database.sqlite`, `WEBAUTHN_NAME=2FAuth` (Dockerfile). |
| Data / write paths | `/2fauth` created by upstream (UID-owned, mode 700): the end-user directory (chart config volume). SQLite at `/srv/database/` (upstream default). Laravel `storage/` and `bootstrap/cache` under `/srv` (standard Laravel; the exact write set is UNVERIFIED for 9.0.3). |
| Dependencies | PostgreSQL, optional (`apps/postgresql` exists). Redis optional (`REDIS_HOST`). |
| Laravel APP_KEY | Required for the UI. Upstream does not generate it in the entrypoint; the `.env.example` leaves it empty. Generation method for this image is in section 7. |

## 2. Target layout

- `apps/twofauth/Dockerfile`
- `apps/twofauth/docker-bake.hcl`
- `apps/twofauth/settings.yaml`
- `apps/twofauth/container-test.yaml`
- `apps/twofauth/start.sh` (runs the first-start setup, then starts PHP-FPM and nginx)
- `apps/twofauth/defaults/` (only if a nginx and php-fpm configuration template is shipped, see section 4 step 6)

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
Reason: no language runtime image is needed. PHP and its extensions come from Ubuntu apt, as the draft says. The base has no PHP. Closest sibling: `apps/bookstack` (Laravel app, PHP 8.5 from apt on the same ubuntu base, `clear_env`, symlinks of `.env` and `storage/` into `/config`, `USER apps`, `WORKDIR /config`). Use bookstack as the pattern for the file layout and the symlink approach.

## 4. Dockerfile

1. `FROM <ubuntu> AS build` is not needed for the app source. Fetch and unpack in the final stage, as `apps/bookstack` does, so the build stays a single stage.
2. `ARG VERSION`, `USER root`. Add `ARG VERSION=9.0.3`. Keep the Dockerfile `ARG VERSION` equal to `docker-bake.hcl` `VERSION`.
3. Install PHP and extensions from apt, following `apps/bookstack/Dockerfile` (Ubuntu 26.04 ships PHP 8.5): `php8.5-fpm`, `php8.5-cli`, `php8.5-pgsql`, `php8.5-sqlite3`, `php8.5-mysql`, `php8.5-xml`, `php8.5-mbstring`, `php8.5-curl`, `php8.5-zip`, `php8.5-bcmath`, `php8.5-gd`, `php8.5-intl`, `php8.5-redis`, `php8.5-tokenizer` (if packaged separately), `nginx`, `composer`.
   UNVERIFIED: the package set and whether 2FAuth 9.0.3 supports PHP 8.5. Check `composer.json` `require.php` in the fetched source; if it does not allow 8.5, use the next available PHP on 26.04 (`php8.4-*`) and record it in section 10.
4. Download and unpack the source, with `set -e` in one `RUN`:
   `curl -fsSL -o /tmp/2fauth.tar.gz https://github.com/Bubka/2FAuth/archive/refs/tags/v${VERSION}.tar.gz`, then `mkdir -p /app/2fauth`, `tar xf /tmp/2fauth.tar.gz -C /app/2fauth --strip-components=1`, `rm /tmp/2fauth.tar.gz`.
   Checksum: the writer computes the SHA-256 of the tarball from the tag at build time and pins it in an `ARG` (UNVERIFIED: no upstream checksum is published).
5. Composer install with the composer binary from apt, using `/tmp` for its cache: `COMPOSER_HOME=/tmp/composer COMPOSER_CACHE_DIR=/tmp/composer-cache composer install -d /app/2fauth --no-dev --optimize-autoloader --no-interaction --no-scripts`. Then `rm -rf /tmp/composer*`.
6. Move the upstream runtime paths to ContainerForge paths, using symlinks created at build time (because `/app` is read-only at runtime), as `apps/bookstack` does:
   - `/app/2fauth/storage` must be writable. Symlink `/app/2fauth/storage` to `/config/storage`, and seed `/config/storage` from a pristine copy in `start.sh` (section 7).
   - `/app/2fauth/.env` symlinks to `/config/.env`, seeded by `start.sh`.
   - `/app/2fauth/bootstrap/cache`: point Laravel at `/tmp` with the env vars `APP_CONFIG_CACHE`, `APP_ROUTES_CACHE`, `APP_EVENTS_CACHE`, `APP_SERVICES_CACHE`, `APP_PACKAGES_CACHE` set to `/tmp/bootstrap/...` (UNVERIFIED for the 2FAuth 9.0.3 Laravel version; check `bootstrap/app.php` at build time).
   - `/app/2fauth` is the code tree: it stays read-only at runtime, so the nginx `root` in `docker/nginx.conf` (`/srv/public`) must be changed to `/app/2fauth/public`. Ship the adjusted nginx config in `etc/` or `defaults/` (see section 7).
   - Nginx and PHP-FPM temp, PID and log paths: `client_body_temp_path`, `proxy_temp_path`, `fastcgi_temp_path` and the `pid` line set to `/tmp/nginx/...`. The PHP-FPM socket and pid under `/tmp`.
7. Copy the upstream `docker/nginx.conf` and `docker/php-fpm` pool settings into `defaults/` with those changes, and reference them from `start.sh`.
8. License: `COPY` or `cp` `LICENSE` to `/usr/share/licenses/twofauth/LICENSE` in the same `RUN`.
9. Tail:

```dockerfile
ENV LOG_CHANNEL=daily LOG_LEVEL=info DB_CONNECTION=sqlite DB_DATABASE=/config/database/database.sqlite WEBAUTHN_NAME=2FAuth \
    APP_CONFIG_CACHE=/tmp/bootstrap/config.php APP_ROUTES_CACHE=/tmp/bootstrap/routes.php \
    APP_EVENTS_CACHE=/tmp/bootstrap/events.php APP_SERVICES_CACHE=/tmp/bootstrap/services.php \
    APP_PACKAGES_CACHE=/tmp/bootstrap/packages.php

USER apps
COPY --chmod=0755 . /

EXPOSE 8000
VOLUME /config
WORKDIR /config
CMD ["/start.sh"]
```

`DB_CONNECTION` defaults to the upstream value `sqlite` (database under `/config/database`), so the image starts with no env, as the container test requires. Users set `DB_CONNECTION=pgsql` plus `DB_HOST` etc. for the chart's external PostgreSQL setup.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "twofauth"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Bubka/2FAuth versioning=semver
  default = "9.0.3"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/Bubka/2FAuth"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Copy the layout of `apps/valkey/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/twofauth`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Bubka/2FAuth"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: APP_NAME
    default: "2FAuth"
    required: false
  - name: APP_KEY
    default: ""
    required: false
  - name: APP_URL
    default: ""
    required: false
  - name: APP_DEBUG
    default: "false"
    required: false
  - name: DB_CONNECTION
    default: "sqlite"
    required: false
  - name: DB_HOST
    default: ""
    required: false
  - name: DB_PORT
    default: "5432"
    required: false
  - name: DB_DATABASE
    default: "/config/database/database.sqlite"
    required: false
  - name: DB_USERNAME
    default: ""
    required: false
  - name: DB_PASSWORD
    default: ""
    required: false
  - name: WEBAUTHN_NAME
    default: "2FAuth"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```

- `APP_KEY` is `required: false` because `start.sh` generates it on first start when empty (section 7). The `settings.yaml` schema allows this only with a generating `start.sh`.
- `DB_CONNECTION` is `sqlite` by default (the upstream default), so the container starts with no env. For PostgreSQL the user sets `DB_CONNECTION=pgsql`, `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`; no credentials are baked in. `start.sh` must also accept the `*_FILE` variants (UNVERIFIED which upstream supports beyond those in section 1).
- `postgresql` is listed under `opt_dependencies`, not `dependencies`. It is optional: SQLite remains usable, so the DB-dependency exception in the build protocol does not apply.

## 7. start.sh

```bash
#!/bin/bash
set -euo pipefail

APP_DIR=/app/2fauth
CONFIG_DIR=/config

mkdir -p "$CONFIG_DIR/storage" "$CONFIG_DIR/database" /tmp/bootstrap /tmp/nginx /tmp/php-fpm

# Seed storage from the pristine tree only when missing or empty (never overwrite user state)
if [ -z "$(ls -A "$CONFIG_DIR/storage" 2>/dev/null)" ]; then
  cp -a /usr/share/twofauth/storage.pristine/. "$CONFIG_DIR/storage/"
fi

# .env: create once; generate APP_KEY when no key exists
if [ ! -f "$CONFIG_DIR/.env" ]; then
  cp "$APP_DIR/.env.example" "$CONFIG_DIR/.env"
fi
if ! grep -q '^APP_KEY=base64:' "$CONFIG_DIR/.env" && [ -z "${APP_KEY:-}" ]; then
  APP_KEY="$(php "$APP_DIR/artisan" key:generate --show)"
  export APP_KEY
fi

# SQLite file must exist before migrating
if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then touch "${DB_DATABASE:-/config/database/database.sqlite}"; fi

# Migrations on every start (idempotent)
php "$APP_DIR/artisan" migrate --force

# UNVERIFIED: /tmp/supervisord.conf is never created above; start.sh must first copy it from the template in defaults/ (e.g. cp /defaults/supervisord.conf /tmp/supervisord.conf), and the pristine storage copy must be made in the Dockerfile before the symlink replaces storage/.
# Two processes: run under supervisord (see the note below); a bare "&" plus exec nginx would leave php-fpm unsupervised.
exec supervisord -n -c /tmp/supervisord.conf
```

- Notes:
  - UNVERIFIED that the upstream entrypoint runs migrations (the reviewed entrypoint summary in section 1 does not mention it). Migrations run on every start here, which is idempotent. Verify the exact upstream command at build time (UNVERIFIED).
  - `APP_KEY`: the env value wins over the generated key. A key generated on first start is stored in `/config/.env`. The `APP_KEY` env handling is UNVERIFIED against the upstream entrypoint's `file_env APP_KEY` path, so mirror `file_env` for `APP_KEY_FILE` and the other `*_FILE` variables.
  - `storage.pristine` is a build-time copy of `storage/` made in the Dockerfile before the symlink replaces `storage/`. Put it at `/usr/share/twofauth/storage.pristine` and use that path in `start.sh` instead of `$APP_DIR/storage.pristine`.
  - Supervising two processes needs a supervisor or a `wait` loop. The upstream uses supervisord (v0.7.3). The writer must decide between shipping supervisord (a binary from apt or pinned release, with its checksum) and a small wait loop. Plan default: ship nginx and php-fpm under supervisord from apt, with `/tmp/supervisord.conf` generated from a template in `defaults/` (the `supervisor` apt package must be added in section 4 step 3). Record the choice in the PR.
  - Binds 0.0.0.0: nginx listens on `*:8000` (section 4 step 7 copies the upstream `listen 8000;`, which is all interfaces by default).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/2fauth/artisan
- /app/2fauth/vendor/autoload.php
- /usr/share/licenses/twofauth/LICENSE
```

- Probes: `tcp` and `http` on 8000 (coverage minimum).
- UNVERIFIED: the HTTP status for `/` on a first start with no `APP_KEY`. If the app returns a non-200 without an app key, the writer narrows the `http` check to the status it returns, with a comment. Do not remove the probe.
- Runs with no env: the default is SQLite under `/config/database`, so the test exercises a real start without PostgreSQL. The PostgreSQL path is a manual check (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | ContainerForge adaptation |
| --- | --- |
| Runs as `1000:1000` (`USER ${UID}:${GID}`) | Runs as `apps` (`USER apps`), the ContainerForge rule. The chart's `runAsUser 1000` is compatible in intent. |
| `/srv` owned by UID, `/srv` writable | `/app/2fauth` is read-only; writable state moves to `/config` (`storage/`, `.env`, `database/`) through symlinks made at build time. |
| `/2fauth` end-user directory (chart `/2fauth` config volume) | Mapped to `/config`. Users with existing data mount their old `/2fauth` contents into `/config`; document in the PR. |
| `/srv/database/database.sqlite` (upstream sqlite default) | `/config/database/database.sqlite` when sqlite is used. |
| nginx temp, pid, log under `/var/lib/nginx`, `/run/nginx` | Moved to `/tmp/nginx`, logs to stderr. |
| PHP-FPM socket and pid under `/run/php` | Moved to `/tmp/php-fpm`. |
| Laravel `bootstrap/cache` | Redirected to `/tmp/bootstrap` by env vars (section 4). |
| Chart `readOnlyRootFilesystem: false` | The image is designed for `--read-only --tmpfs /tmp`. |
| Chart `privileged: no`, `runAsGroup 1000` | No change. |

## 10. Risks, caveats and open questions

- **PHP version**: the plan uses PHP 8.5 from Ubuntu 26.04 apt (as `apps/bookstack`). 2FAuth upstream uses 8.4. If `composer.json` does not allow 8.5, the writer switches to `php8.4-*` packages. UNVERIFIED.
- **Version**: the chart pins 9.0.1. This plan targets 9.0.3. The chart must move to the same tag, or the PR must say the chart is one version behind.
- **Checksum**: no release asset or checksum is published. The tarball hash is computed at build time (section 4 step 4).
- **arm64**: UNVERIFIED for the upstream image; the ubuntu base is multi-arch, so `image-all` should build, but it is not tested.
- **Supervision**: two processes (nginx, php-fpm). The choice of supervisord or a wait loop is open (section 7).
- **Secrets**: `APP_KEY` and the two-factor secrets are sensitive. The `/config` volume must be backed up, or stored codes are lost (draft caveat). Use `*_FILE` variables for secrets where supported.
- **Database**: PostgreSQL is optional. The default stays upstream's `sqlite`; the PostgreSQL path is untested until run manually.
- **Laravel cache env vars** (`APP_*_CACHE`) must match the Laravel version in 9.0.3. UNVERIFIED.
- **Blockers**: none confirmed. Not musl-only (the upstream Alpine base is replaced), no GPU, no privileged need.

## 11. Build and test steps

```sh
cd apps/twofauth
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name twofauth-probe --read-only --tmpfs /tmp \
  -v twofauth-probe-config:/config -e DB_CONNECTION=sqlite \
  -e DB_DATABASE=/config/database/database.sqlite -p 8000:8000 twofauth:9.0.3
docker logs -f twofauth-probe
curl -fsS -o /dev/null -w '%{http_code}\n' http://localhost:8000/
forgetool containers test --image twofauth:9.0.3 --config ./apps/twofauth/container-test.yaml
docker rm -f twofauth-probe; docker volume rm twofauth-probe-config
```

- Run once more with `-e DB_CONNECTION=pgsql` against a `postgresql` container (the chart's real setup) to check the external-database path, and record the result in the PR. This is a manual check, outside the narrow exception.
- Readiness signal: nginx and php-fpm started, the app answers on 8000, and no `FATAL` or repeated stack traces appear. The first start creates `/config/.env` and `/config/storage`.
- Restart with the same `/config` volume, and check `/config/.env` is kept and `APP_KEY` is not regenerated.

## 12. PR checklist

- Branch `feat/add-twofauth`, commit and PR title `feat(twofauth): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it, and the `license/cla` check shows the status.
- Say what was not tested: arm64, the PostgreSQL path if it was not run, upgrade from the chart's 9.0.1 data, and the supervisor choice under real load.
- `docker buildx bake --print` passes, and `VERSION` equals the Dockerfile `ARG VERSION`.
