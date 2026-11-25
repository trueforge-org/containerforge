# chevereto — implementation plan
> Source: ./draft.md · Target: apps/chevereto/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **1.6.2** (draft tag matches). Latest and only stable release, published 2022-01-07. The upstream repo is stale (no release since 2022). Source: `gh api repos/rodber/chevereto-free/releases/latest`. |
| Renovate | `datasource=github-releases depName=rodber/chevereto-free versioning=semver` |
| License | **AGPL-3.0-only** (`composer.json` `"license": "AGPL-3.0-only"`; LICENSE file is AGPLv3). Sources: https://raw.githubusercontent.com/rodber/chevereto-free/1171863/composer.json and https://raw.githubusercontent.com/rodber/chevereto-free/1171863/LICENSE |
| Source URL | https://github.com/rodber/chevereto-free |
| Download (both arches, same file) | https://github.com/rodber/chevereto-free/releases/download/1.6.2/1.6.2.zip (also `1.6.2-lite.zip`, not used). PHP source, no compile. |
| Checksum source | **UNVERIFIED**: GitHub returns `digest: null` for both zip assets and no checksum file is published. We must compute the sha256 of `1.6.2.zip` ourselves and pin it in the Dockerfile (trust on first use). |
| PHP requirement | `composer.json` `"php": "~7.4"` (PHP 7.4 only). Source: https://raw.githubusercontent.com/rodber/chevereto-free/1171863/composer.json |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/rodber/chevereto-free/1171863/httpd-php.Dockerfile: `FROM php:7.4-apache`, composer copied from `composer:latest`, PHP extensions gd/opcache/exif/pdo_mysql/zip/imagick, apt `imagemagick libmagickwand-dev rsync inotify-tools`, `a2enmod rewrite`, `VOLUME /var/www/html/content` and `VOLUME /var/www/html/images`, `COPY . /var/www/html`, `composer install --classmap-authoritative --ignore-platform-reqs`, `chown www-data: /var/www/html -R`, `CMD ["/bin/bash", "apache2-foreground"]` (the path of `apache2-foreground` is not a PATH binary, so do not copy the CMD). |
| Env vars (real, from the upstream Dockerfile) | `CHEVERETO_DB_HOST` (default `mariadb`), `CHEVERETO_DB_USER`, `CHEVERETO_DB_PASS`, `CHEVERETO_DB_NAME`, `CHEVERETO_DB_TABLE_PREFIX` (`chv_`), `CHEVERETO_DB_PORT` (`3306`), `CHEVERETO_DB_DRIVER` (`mysql`), `CHEVERETO_DB_PDO_ATTRS` (`[]`), `CHEVERETO_DEBUG_LEVEL` (`1`), `CHEVERETO_DISABLE_PHP_PAGES` (`1`), `CHEVERETO_DISABLE_UPDATE_HTTP` (`1`), `CHEVERETO_DISABLE_UPDATE_CLI` (`1`), `CHEVERETO_ERROR_LOG` (`/dev/stderr`), `CHEVERETO_IMAGE_FORMATS_AVAILABLE` (`JPG,PNG,BMP,GIF,WEBP`), `CHEVERETO_IMAGE_LIBRARY` (`gd`), `CHEVERETO_HTTPS` (`1`), `CHEVERETO_HOSTNAME` (`localhost`), `CHEVERETO_HOSTNAME_PATH` (`/`), `CHEVERETO_SESSION_SAVE_HANDLER` (`files`), `CHEVERETO_SESSION_SAVE_PATH` (`/tmp`), `CHEVERETO_UPLOAD_MAX_FILESIZE` (`64M`), `CHEVERETO_POST_MAX_SIZE` (`64M`), `CHEVERETO_MAX_EXECUTION_TIME` (`30`), `CHEVERETO_MEMORY_LIMIT` (`512M`). Only the upstream Dockerfile was read; the app code that consumes them is **UNVERIFIED**. |
| Ports | Apache on **80** (the `php:apache` default). The upstream Dockerfile has no `EXPOSE`. Port 80 is inferred, not read from the app. |
| Data and write paths | `/var/www/html/content` and `/var/www/html/images` (both `VOLUME`s in upstream). Sessions to `/tmp`. Other write paths: **UNVERIFIED** (not read from the app source). |
| Draft chart values | Chart runs as root, `readOnlyRootFilesystem: false`, `fsGroup: 33`, persistence on the two image paths (draft, from TrueCharts values.yaml). |

## 2. Target layout

- `apps/chevereto/Dockerfile`
- `apps/chevereto/docker-bake.hcl`
- `apps/chevereto/settings.yaml`
- `apps/chevereto/container-test.yaml`
- `apps/chevereto/start.sh`
- `apps/chevereto/DOWNSTREAM_CHANGES.md`: **not applicable**, chevereto is not a `FROM` base.
- No `defaults/` (the upstream config is env-driven). No `etc/` unless the Apache `ports.conf` change is copied from there (preferred: write it in the Dockerfile with `sed` against the packaged file). No `root/`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Reason: the upstream runtime is PHP plus Apache, with no ContainerForge PHP base. The PHP-stack sibling is `apps/bookstack` (apt PHP on ubuntu 26.04, with `php8.5-*` packages and `USER apps`).

**Blocker to resolve before writing the Dockerfile.** `composer.json` requires PHP `~7.4`. Ubuntu 26.04 does not ship PHP 7.4 (bookstack uses `php8.5`). Options, in order of preference:

1. Ask the user whether PHP 7.4 may be built from source on ubuntu (large build, EOL runtime, a source download with checksum), or whether the app may run on PHP 8.x. Running on PHP 8.x is not verified against chevereto 1.6.2 and would be a port, not the upstream build.
2. Stop and mark `unfixable` with the reason "PHP ~7.4 required, not available on ubuntu 26.04" if neither option is accepted.

The rest of this plan assumes option 1 is accepted, with PHP 7.4 built from source. Do not guess a PHP 8 package set.

## 4. Dockerfile

1. Build stage on the base, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download `https://github.com/rodber/chevereto-free/releases/download/${VERSION}/${VERSION}.zip` to `/tmp`, and check the pinned sha256 with `echo "<sha256>  /tmp/chevereto.zip" | sha256sum -c -`. The sha256 is computed by us (see section 1).
3. Install the apt packages for the Apache and PHP build (pinned against what the chosen PHP source provides). Use `apt-get install -y --no-install-recommends` and clean `/var/lib/apt/lists/*`.
4. Unzip to `/app/chevereto/`. Remove `sync.sh` as upstream does.
5. Install composer (`composer install --working-dir=/app/chevereto --no-dev --classmap-authoritative --ignore-platform-reqs`), with `COMPOSER_HOME=/tmp/composer` and `COMPOSER_CACHE_DIR=/tmp/composer-cache`.
6. Remap the writable paths to `/config` with build-time symlinks, as bookstack does: `/app/chevereto/content -> /config/content` and `/app/chevereto/images -> /config/images`. Keep the symlink targets under `/config`, and remove the real directories first.
7. Apache: set `Listen 8080` in `ports.conf` and the vhost to `*:8080`, run as `apps`, and move `PidFile`, `ErrorLog` and the lock files to `/tmp` (`APACHE_RUN_DIR=/tmp/apache`, `APACHE_PID_FILE=/tmp/apache/apache2.pid`). Enable `rewrite`.
8. Licence: `COPY`/`cp` `LICENSE` to `/usr/share/licenses/chevereto/LICENSE`.
9. Cleanup: `rm -rf /tmp/* $HOME/.cache $HOME/.composer /var/lib/apt/lists/*`. `chown -R apps:apps /app/chevereto && chmod -R 755 /app/chevereto`.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "chevereto"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=rodber/chevereto-free versioning=semver
  default = "1.6.2"
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/rodber/chevereto-free"
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
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Validate with `docker buildx bake --print` from `apps/chevereto/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/rodber/chevereto-free"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: CHEVERETO_DB_HOST
    default: "mariadb"
    required: true
  - name: CHEVERETO_DB_PORT
    default: "3306"
    required: false
  - name: CHEVERETO_DB_USER
    default: "MYMARIADBUSER"
    required: true
  - name: CHEVERETO_DB_PASS
    default: "MYMARIADBPASSWORD"
    required: true
  - name: CHEVERETO_DB_NAME
    default: "chevereto"
    required: false
  - name: CHEVERETO_HOSTNAME
    default: "localhost"
    required: false
  - name: CHEVERETO_HTTPS
    default: "1"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: mariadb
```

Only env vars the upstream Dockerfile sets are listed. Defaults match upstream except the DB password, which must be a placeholder to show it is required. `CHEVERETO_HTTPS=1` is upstream's default and may not fit a plain-HTTP test; keep it, and confirm in section 8. `mariadb` is a hard dependency (draft), and `apps/mariadb` exists (✅).

## 7. start.sh

Startup behaviour to implement:

- `mkdir -p /config/content /config/images`, and create `/config/content` and `/config/images` only when missing. Never overwrite existing files.
- Export the `CHEVERETO_*` env vars as the upstream image does (they are read by the app; names must match what the app reads, which is **UNVERIFIED** until the app source is read).
- Apply `CHEVERETO_DB_PASS` and the other DB values on every start, so a changed password still works on existing data.
- Set `upload_max_filesize`, `post_max_size`, `max_execution_time` and `memory_limit` from the env, as upstream's `php.ini` does, into a file under `/tmp`, not `/app`.
- Do not write to `/app/chevereto` at runtime. Sessions go to `/tmp`.
- Launch Apache in the foreground: `exec apache2 -D FOREGROUND -f /app/apache/apache2.conf` (or the packaged config path, confirmed at build). Use `exec` so signals reach Apache.
- Bind `0.0.0.0:8080` (Listen directive from section 4).

Empty `/config` start must work: the install wizard runs in the browser, so no database write happens at start (UNVERIFIED; confirm with the app source).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/chevereto/index.php
- /app/chevereto/app
- /usr/share/licenses/chevereto/LICENSE
```

- Every port in `settings.yaml` has a `tcp` probe (8080).
- The HTTP probe `/` may redirect to the install page; accept only a status the app really returns (UNVERIFIED, check after the first run).
- If the app cannot start without MariaDB, apply the database-dependent exception from the protocol: narrow the assertions, add `# narrowed: requires external mariadb; full functional test not feasible in single-container suite`, and keep real checks (tcp, http, filePaths). Confirm the three criteria in the protocol first.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/www/html/content` (VOLUME) | symlink `/app/chevereto/content -> /config/content` |
| `/var/www/html/images` (VOLUME) | symlink `/app/chevereto/images -> /config/images` |
| Apache PID and lock files, default `/var/run/apache2` | `/tmp/apache` via `APACHE_RUN_DIR` and `APACHE_PID_FILE` |
| PHP sessions, `CHEVERETO_SESSION_SAVE_PATH=/tmp` | already `/tmp` |
| `/var/www/html` owner `www-data` (upstream `chown`) | ContainerForge runs as `apps`; do not chown to `www-data` |
| Port 80 | 8080 (non-root cannot bind < 1024) |
| `CHEVERETO_ERROR_LOG=/dev/stderr` | keep; stderr is readable by Docker logs |

Reconcile the draft's security expectations: the TrueCharts chart forces root, `readOnlyRootFilesystem: false` and `fsGroup: 33`. The ContainerForge plan runs as `apps` with a read-only root, so the chart's root requirement is not carried over. Persistence at `/config` replaces the two `/var/www/html` PVCs.

## 10. Risks, caveats and open questions

- **PHP 7.4 (blocker)**: see section 3. EOL runtime; no ubuntu 26.04 package.
- **Upstream staleness**: last release 2022-01-07, PHP 7.4, no security updates expected (draft and upstream status).
- **Checksum is trust on first use**: the sha256 of `1.6.2.zip` is computed by us, not published upstream.
- **App code unverified**: the `CHEVERETO_*` env names are taken from the Dockerfile. The app's own reads and any config file it writes must be checked in the source before start.sh is final.
- **Mount size**: uploads grow without limit (draft caveat). The `/config` volume needs room and a backup plan.
- **Database dependency**: MariaDB must be reachable on first use. The install wizard creates the admin account in the browser (draft, inferred).

## 11. Build and test steps

From `apps/chevereto/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name chevereto-probe --read-only --tmpfs /tmp -v chevereto-probe-config:/config chevereto:1.6.2`, then `docker logs -f chevereto-probe`. Expected readiness signal: an Apache line such as `resuming normal operations` on stderr, with the process still running and no PHP fatal errors. The first run has no database, so a "waiting for database" line is allowed only if the process stays alive (protocol exception).
4. Clean up: `docker rm -f chevereto-probe; docker volume rm chevereto-probe-config`.
5. `forgetool containers test --image chevereto:1.6.2 --config ./apps/chevereto/container-test.yaml`. If forgetool is unavailable, run the container as in step 3 and check the same assertions by hand.
6. Run arm64 only if an amd64 failure is arm64-specific.

## 12. PR checklist

- Branch: `feat/add-chevereto`
- Commit: `feat(chevereto): add new container`
- PR title: `feat(chevereto): add new container`
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`. Do not tick "Built container locally" unless the build and run in section 11 were done.
- Say what is not tested: arm64, the browser install wizard, and any path that needs the database if the narrowed exception is used.
- Blocker: resolve the PHP 7.4 question (section 3) before opening the PR.
