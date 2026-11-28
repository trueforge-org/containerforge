# shlink — implementation plan
> Source: ./draft.md · Target: apps/shlink/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `5.1.9` (tag `v5.1.9`, published 2026-11-21, PHP images bumped to 8.5.13). The draft's `5.1.8` is stale. Source: https://api.github.com/repos/shlinkio/shlink/releases/latest. TrueCharts pins `ghcr.io/shlinkio/shlink:5.1.9@sha256:248d38c8d7fdba90d9e0c3c7ea9e73ef73ec9f54f7f46faf8f369153cc889aab` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shlink/values.yaml). |
| Renovate | `datasource=github-releases depName=shlinkio/shlink versioning=semver`. |
| License | MIT (https://raw.githubusercontent.com/shlinkio/shlink/v5.1.9/LICENSE). Bake `LICENSE` = `MIT`. |
| Source URL | https://github.com/shlinkio/shlink |
| Binary | PHP dist zip per PHP minor: `shlink5.1.9_php8.5_dist.zip`, https://github.com/shlinkio/shlink/releases/download/v5.1.9/shlink5.1.9_php8.5_dist.zip (also `php8.4`). Arch-neutral PHP code, so the same zip serves amd64 and arm64. |
| Checksum source | None published in the release (asset list has only zips). UNVERIFIED. Plan: pin sha256 on first download as `ARG SHLINK_SHA256`. |
| Zip contents | UNVERIFIED whether the dist zip ships `vendor/` and `bin/rr`. The build must check for `vendor/autoload.php` and `bin/rr` (or run `vendor/bin/rr get`, as upstream does). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/shlinkio/shlink/v5.1.9/Dockerfile (byte-identical to v5.1.8). Base `php:8.5-alpine3.24` (musl, so no copy-from). Installs PHP extensions pdo_mysql, pdo_pgsql, intl, calendar, sockets, bcmath, zip, pdo_sqlite, plus sqlsrv on x86_64. Final stage copies `/etc/shlink`, symlinks `/usr/local/bin/shlink`, downloads RoadRunner (`rr`) when `SHLINK_RUNTIME=rr`. `EXPOSE 8080`, `USER 1001`, `ENTRYPOINT ["/bin/sh", "./docker-entrypoint.sh"]`. |
| Upstream entrypoint | https://raw.githubusercontent.com/shlinkio/shlink/v5.1.9/docker/docker-entrypoint.sh: `cd /etc/shlink`; `mkdir -p data/cache data/locks data/log data/proxies data/temp-geolite`; reads `GEOLITE_LICENSE_KEY`, `SKIP_INITIAL_GEOLITE_DOWNLOAD`, `INITIAL_API_KEY` via `bin/cli env-var:read`; runs `php vendor/bin/shlink-installer init --no-interaction --clear-db-cache` (plus `--skip-download-geolite` when the key is empty or skip is `true`, and `--initial-api-key=` when set); then `exec ./bin/rr serve -c config/roadrunner/.rr.yml` when `SHLINK_RUNTIME=rr`. |
| RoadRunner config | https://raw.githubusercontent.com/shlinkio/shlink/v5.1.9/config/roadrunner/.rr.yml: `http.address: ${ADDRESS:-0.0.0.0}:${PORT:-8080}`, RPC `tcp://127.0.0.1:6001`, `WEB_WORKER_NUM` and `TASK_WORKER_NUM` default 0 (auto), `LOGS_FORMAT` default console. |
| Env vars (real, from entrypoint and RR config) | `GEOLITE_LICENSE_KEY`, `SKIP_INITIAL_GEOLITE_DOWNLOAD`, `INITIAL_API_KEY`, `ADDRESS`, `PORT`, `WEB_WORKER_NUM`, `TASK_WORKER_NUM`, `LOGS_FORMAT`, `SHLINK_RUNTIME` (build arg, default `rr`). Chart additionally sets `DB_DRIVER`, `DB_HOST`, `DB_PORT` (unset, default), `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `REDIS_SERVERS`, `DEFAULT_DOMAIN`, `IS_HTTPS_ENABLED`, `ANONYMIZE_REMOTE_ADDR`, `ENABLE_PERIODIC_VISIT_LOCATE` (chart values). The DB and Redis names are not confirmed against Shlink docs (UNVERIFIED). |
| Port | 8080/tcp (container default, `EXPOSE 8080`, RR default). Chart maps service 10153 by setting `PORT`. |
| Health endpoint | `/rest/health` (chart probes). |
| Data write paths | `data/` under the app root (cache, locks, log, proxies, temp-geolite, per entrypoint). |
| Upstream user | UID 1001 (`USER ${USER_ID}`). Chart runs as root (`runAsUser 0`, `runAsNonRoot false`). |
| Arm64 | Yes for the image. GHCR manifest for `ghcr.io/shlinkio/shlink:5.1.9` lists linux/amd64 and linux/arm64 (https://ghcr.io/v2/shlinkio/shlink/manifests/5.1.9). The application zip is arch-neutral. |
| Dependencies | Chart: PostgreSQL (`shlink` user and database) and Valkey, both enabled. ContainerForge has `apps/postgresql` and `apps/valkey` (checked in repo). Shlink's default DB driver is sqlite (UNVERIFIED against Shlink docs; the Dockerfile installs `pdo_sqlite`). |

## 2. Target layout

- `apps/shlink/Dockerfile`: one ubuntu stage that fetches and verifies the zip, installs PHP 8.5 from apt, and lays the app out under `/app/shlink`.
- `apps/shlink/docker-bake.hcl`
- `apps/shlink/settings.yaml`
- `apps/shlink/container-test.yaml`
- `apps/shlink/start.sh`: creates `/config/data` subdirectories, runs `shlink-installer init`, then `exec` RoadRunner.
- `apps/shlink/defaults/php/php.ini`: copy of upstream `docker/config/php.ini` (fetched in the facts run) into `/etc/php/8.5/cli/conf.d/` if needed. Only if the apt default ini lacks a setting the app needs (decide during build; omit otherwise).

No `root/`, no `etc/` beyond what the defaults need, no `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.

Why: PHP 8.5 is installed from apt on this base in `apps/bookstack` and `apps/phpmyadmin`, so no runtime image is needed. Closest sibling: `apps/bookstack` (PHP 8.5 from apt, `/app/www`, `/config` symlinks, `apps` user, `php-fpm` env handling). RoadRunner replaces php-fpm here, so `apps/bookstack`'s nginx/fpm wiring is not copied.

## 4. Dockerfile

1. `FROM <ubuntu> AS app`, `ARG VERSION`, `ARG SHLINK_SHA256`, `ARG SHLINK_RUNTIME=rr`, `USER root`.
2. `apt-get install -y --no-install-recommends php8.5-cli php8.5-pgsql php8.5-sqlite3 php8.5-intl php8.5-bcmath php8.5-zip php8.5-mbstring php8.5-xml php8.5-curl unzip ca-certificates`. Extension list follows the upstream `docker-php-ext-install` list and the draft. Whether php8.5 is in the 26.04 archive and whether `php8.5-sqlite3` and `php8.5-calendar` exist is UNVERIFIED; the build confirms it. `calendar` is built into PHP on Ubuntu (UNVERIFIED). `pdo_mysql`, `sockets` are dropped unless the build proves they are needed (not used by the chart).
3. `curl -fL -o /tmp/shlink.zip https://github.com/shlinkio/shlink/releases/download/v${VERSION}/shlink${VERSION}_php8.5_dist.zip`, then `echo "${SHLINK_SHA256}  /tmp/shlink.zip" | sha256sum -c -`.
4. `mkdir -p /app/shlink && unzip -q /tmp/shlink.zip -d /app/shlink`. Check that `/app/shlink/vendor/autoload.php` exists and that `bin/rr` exists or fetch it with `php vendor/bin/rr get --no-interaction --no-config --location bin/ && chmod +x bin/rr` when `SHLINK_RUNTIME=rr` (same as upstream).
5. `ln -s /etc/shlink ...` is not needed. The app is used from `/app/shlink`. Symlink data: `ln -s /config/data /app/shlink/data`. Dangling until `start.sh` creates `/config/data`.
6. Install the upstream `php.ini` only if needed (section 2).
7. License: `install -D /app/shlink/LICENSE /usr/share/licenses/shlink/LICENSE` if the zip ships it; otherwise copy the MIT text from the fetched LICENSE (UNVERIFIED whether the zip ships LICENSE).
8. `ENV SHLINK_RUNTIME=${SHLINK_RUNTIME} PORT=8080 TZ=Etc/UTC`.
9. Cleanup: `rm -rf /tmp/* /var/lib/apt/lists/*`.
10. `chown -R apps:apps /app/shlink`, `chmod -R 755 /app/shlink`.
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/shlink
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "shlink"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=shlinkio/shlink versioning=semver
  default = "5.1.9"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/shlinkio/shlink"
}
```

Then `image`, `image-local`, `image-all` and `group "default"` as in `apps/bookstack/docker-bake.hcl`. `image` passes `VERSION` and `SHLINK_SHA256` as build args. Validate with `docker buildx bake --print` from `apps/shlink/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/shlinkio/shlink"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: PORT
    default: "8080"
    required: false
  - name: GEOLITE_LICENSE_KEY
    default: ""
    required: false
  - name: SKIP_INITIAL_GEOLITE_DOWNLOAD
    default: "false"
    required: false
  - name: INITIAL_API_KEY
    default: ""
    required: false
  - name: DB_DRIVER
    default: "sqlite"
    required: false
  - name: DB_HOST
    default: ""
    required: false
  - name: DB_PORT
    default: ""
    required: false
  - name: DB_NAME
    default: ""
    required: false
  - name: DB_USER
    default: ""
    required: false
  - name: DB_PASSWORD
    default: ""
    required: false
  - name: REDIS_SERVERS
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
opt_dependencies:
  - name: postgresql
  - name: valkey
```

`dependencies: []` because the image starts with sqlite. `postgresql` and `valkey` are optional, matching the draft's "Optional dependency containers: yes". The DB and Redis names are UNVERIFIED beyond the chart and must be confirmed against Shlink's config (section 10). Defaults for DB_* stay empty so a sqlite start is the default.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -e

cd /app/shlink

mkdir -p /config/data/cache /config/data/locks /config/data/log /config/data/proxies /config/data/temp-geolite

flags="--no-interaction --clear-db-cache"

geolite_license_key="${GEOLITE_LICENSE_KEY:-}"
if [ -z "${geolite_license_key}" ] || [ "${SKIP_INITIAL_GEOLITE_DOWNLOAD:-false}" = "true" ]; then
  flags="${flags} --skip-download-geolite"
fi

if [ -n "${INITIAL_API_KEY:-}" ]; then
  flags="${flags} --initial-api-key=${INITIAL_API_KEY}"
fi

# shellcheck disable=SC2086
php vendor/bin/shlink-installer init ${flags}

exec ./bin/rr serve -c config/roadrunner/.rr.yml
```

Notes:
- Idempotent: `mkdir -p` and the installer are safe on restart. `--clear-db-cache` is upstream behaviour.
- Empty `/config` works: the database (sqlite by default) and data are created in `/config/data`.
- Secrets (`INITIAL_API_KEY`, `GEOLITE_LICENSE_KEY`) are read from env and not written to files. The flag is passed on the command line, so it is visible in the process list during `init`; upstream does the same, so this is accepted, but noted in section 10.
- Upstream `docker-entrypoint.sh` reads env via `bin/cli env-var:read` to support `_FILE` fallback. This plan uses plain env reads, so `*_FILE` variants are not supported. Adopt `bin/cli env-var:read` if `_FILE` support is wanted (open question).
- `exec` hands PID 1 to RoadRunner.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '8080'
http:
- port: '8080'
  path: /rest/health
filePaths:
- /app/shlink/vendor/autoload.php
- /app/shlink/bin/rr
- /app/shlink/bin/cli
```

The tcp and http probes cover the one settings.yaml port. `/rest/health` is the chart's probe path and is expected to answer without a database. The test runs with no env vars, so it starts on sqlite (default). No DB-dependency narrowing is needed if the sqlite start is confirmed (section 10). If sqlite is not the default, the narrowed exception applies: add `# narrowed: requires external postgresql; full functional test not feasible in single-container suite` next to the probes and keep the port and process checks as real assertions.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `data/` (cache, locks, log, proxies, temp-geolite, sqlite file) under app root | `/app/shlink/data` symlink to `/config/data` |
| `public/`, `vendor/`, `config/`, `bin/` (read-only at runtime) | unchanged, owned by `apps` for reading |
| RoadRunner RPC `127.0.0.1:6001` | localhost only, no file |
| PHP temp and session paths | `/tmp` (`TMPDIR=/tmp`) |
| Upstream UID 1001 | `USER apps` (568 in ContainerForge) |
| Chart `runAsUser 0`, `readOnlyRootFilesystem false` | not carried over; image must run as `apps` on read-only rootfs |

RoadRunner must not write under `/app`. Confirm with `--read-only --tmpfs /tmp` in section 11.

## 10. Risks, caveats and open questions

- Draft caveats confirmed: first API key is created by the installer on start (`INITIAL_API_KEY`) or via the shlink CLI inside the container, and GeoLite2 needs a user-supplied license key (entrypoint confirms the env path).
- Sqlite as default DB is UNVERIFIED against Shlink docs. If false, the image cannot start in the single-container test without postgresql, and the narrowed test exception applies (and the protocol criteria must all hold: hard DB dependency, cannot start without it, not feasible as a sidecar test). Confirm first.
- Chart dependencies are PostgreSQL and Valkey. Draft says "Hard dependency containers: no", which fits sqlite-by-default; `opt_dependencies` lists them.
- Checksum: no upstream checksum. Trust-on-first-use pin.
- Whether the dist zip includes `bin/rr` and `vendor/` is UNVERIFIED until downloaded. If `rr` is missing, `vendor/bin/rr get` needs network at build time (allowed, same as upstream).
- PHP 8.5 extension availability on ubuntu 26.04 apt (pgsql, sqlite3, calendar) is UNVERIFIED.
- Command-line secrets (`INITIAL_API_KEY`) are visible in the process list during `init` (same as upstream).
- arm64: image exists upstream; this plan builds the same zip for both arches (UNVERIFIED until built).
- Not a blocker: no musl-only dependency (sqlsrv driver is upstream-only and not needed; dropped), no GPU, no privileged mode.

## 11. Build and test steps

From `apps/shlink/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe with an empty config volume:
   ```sh
   docker volume create shlink-probe-config
   docker run --rm -d --name shlink-probe --read-only --tmpfs /tmp \
     -v shlink-probe-config:/config shlink:5.1.9
   docker logs -f shlink-probe
   ```
   Expected readiness signal: RoadRunner log line about the HTTP server listening on `0.0.0.0:8080` (or the `serve` banner), with no fatal lines from the installer, and `curl -s http://localhost:8080/rest/health` returns JSON. Clean up with `docker rm -f shlink-probe; docker volume rm shlink-probe-config`.
4. `forgetool containers test --image shlink:5.1.9 --config ./apps/shlink/container-test.yaml`
5. Repeat step 3 with the volume kept to confirm the second start does not fail on an existing database.

## 12. PR checklist

- Branch `feat/add-shlink`, commit `feat(shlink): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what was done.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what was not tested: arm64 build and run if not run locally; the checksum trust-on-first-use; the PHP extension list; the postgresql and valkey paths if not exercised.
- Do not check "Built container locally" unless the build and the probe in section 11 actually ran.
- `DOWNSTREAM_CHANGES.md`: not needed (no downstream FROM use).
