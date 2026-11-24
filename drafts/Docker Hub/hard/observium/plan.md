# observium — implementation plan
> Source: ./draft.md · Target: apps/observium/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Observium Community Edition `26.1` (read from `VERSION` inside the current `observium-community-latest.tar.gz`). The draft's `pvrmza/docker-observium:20250519` is a date tag of a third-party wrapper, not the app version. Use `26.1`. |
| Renovate | UNVERIFIED: no renovate datasource tracks CE (unversioned "latest" tarball, about two releases a year). Use `// renovate: datasource=custom.observium depName=observium-community versioning=loose`, which needs a maintainer-added customDatasource; otherwise bumps are manual (read `VERSION` in the tarball). |
| License | Observium License Version 1.0 (`LICENSE.COMMUNITY` in the tarball; not an OSI license, permits redistribution only of the unmodified package). SPDX: `LicenseRef-Observium-1.0`. Redistribution of a container that adds files around the unmodified tree is UNVERIFIED legally; flagged in section 10. |
| Source URL | https://www.observium.org/ (docs https://docs.observium.org/) |
| Download | `https://www.observium.org/observium-community-latest.tar.gz` (HTTP 200, 133,581,629 bytes, Last-Modified 2026-05-05). One arch-independent PHP tarball for amd64 and arm64. |
| Checksum | Upstream publishes none. sha256 of the tarball inspected on 2026-11-24: `01f4bec0bb01c49afe07e26f2b3f79d4eeeabf412ce5f15193df4ed7fc77d715`. Pin it as `ARG OBSERVIUM_SHA256` so the build fails when upstream moves "latest" (also enforces "image contains the tagged version"). |
| Install steps (docs.observium.org/install_debian) | PHP modules cli, mysql, gd, bcmath, mbstring, curl, opcache, apcu, pear, Apache mod_php; Ubuntu 26.04 ships PHP 8.5. Copy `config.php.default` to `config.php` with `db_host/db_name/db_user/db_pass`; create `logs/` and `rrd/` (rrd owned by web user); schema via `./discovery.php -u`; admin via `./adduser.php <user> <pass> 10`. Cron: discovery every 6 h, `discovery --host new` every 5 min, `observium-wrapper poller` every 5 min, housekeeping daily (`housekeeping.php -ysel` 05:13, `-yrptb` 04:47). |
| Upstream Dockerfile reviewed | https://github.com/pvrmza/docker-observium/blob/312a90f0a42394f024cc78b0997375f580649f64/Dockerfile : ubuntu 22.04, apache2 prefork + mod_php 8.1, supervisord, cron, `EXPOSE 80`, `VOLUME /config`, entrypoint script (contents not retrieved, UNVERIFIED). |
| Wrapper env vars (README of pvrmza/docker-observium) | `OBSERVIUM_db_host` (default `db`), `OBSERVIUM_db_name` (`observium`), `OBSERVIUM_db_user` (`observium`), `OBSERVIUM_db_pass` (`observiumpwd`), `OBSERVIUM_ADMIN_USER` (`admin`), `OBSERVIUM_ADMIN_PASS` (`admin`); any `OBSERVIUM_*` is written to `config.php`, `__` marks array keys. `/config/hosts` and `/config/devices` for auto-import. Ports 80/443 (443 not backed by a TLS config in the Dockerfile; UNVERIFIED). |
| Tool checks done | Tarball downloaded and inspected: contains `observium-wrapper`, `poller-wrapper.py`, `discovery.php`, `adduser.php`, `add_device.php`, `housekeeping.php`, `config.php.default`, `LICENSE.COMMUNITY`, `VERSION`. |

## 2. Target layout

```
apps/observium/
  Dockerfile            # ubuntu 26.04, apache2 + php8.5, tarball in /app/observium
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh              # config, DB wait, schema, admin, poller loop, exec apache2
  etc/observium/apache2.conf   # rootless Apache config (allow-listed path etc/)
  defaults/config.php   # reads DB settings from env; copied to /config/config.php only when missing
```
No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base). `etc/` and `defaults/` are in the `include/.dockerignore` allow-list.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: PHP source app; Apache and PHP come from ubuntu apt (26.04 = PHP 8.5 per Observium docs). No language base needed. Closest sibling: `apps/bookstack` (PHP stack on ubuntu, php8.5 packages, `/config` symlinks, DB wait loop). `apps/mariadb` exists and is the hard dependency.

## 4. Dockerfile

1. `FROM` line above; `ARG VERSION`, `ARG TARGETARCH`, `ARG OBSERVIUM_SHA256=01f4bec0bb01c49afe07e26f2b3f79d4eeeabf412ce5f15193df4ed7fc77d715`; `USER root`.
2. `RUN apt-get update && apt-get install -y --no-install-recommends` apache2 libapache2-mod-php8.5 php8.5-cli php8.5-mysql php8.5-gd php8.5-bcmath php8.5-mbstring php8.5-curl php8.5-opcache php-apcu php-pear snmp fping rrdtool whois mtr-tiny ipmitool graphviz imagemagick python3 python3-pymysql mariadb-client netcat-openbsd (check what ubuntu base already ships first; package names come from the Observium install doc and the pvrmza Dockerfile list). Apt packages are not the application, so they are not version-pinned; the app version is pinned by checksum (document this in a comment). Remove `/var/lib/apt/lists`.
3. Download and verify: `curl -fsSL -o /tmp/observium.tgz https://www.observium.org/observium-community-latest.tar.gz && echo "${OBSERVIUM_SHA256}  /tmp/observium.tgz" | sha256sum -c -`; `mkdir -p /app/observium && tar xzf /tmp/observium.tgz -C /app --strip-components=1`... (tarball top dir is `observium/`, extract to `/app` so it lands at `/app/observium`). Then assert `grep -qx "Observium CE ${VERSION}" /app/observium/VERSION` so the image really contains the tagged version.
4. License files: `mkdir -p /usr/share/licenses/observium && cp /app/observium/LICENSE.COMMUNITY /usr/share/licenses/observium/`.
5. Make the tree read-only-friendly: `ln -s /config/config.php /app/observium/config.php`; `rm -rf /app/observium/rrd /app/observium/logs && ln -s /config/rrd /app/observium/rrd && ln -s /config/logs /app/observium/logs`; `chown -R root:root /app && chmod -R a+rX /app`. Disable default apache site/modules by shipping own config (step 6). Remove `/etc/cron.d` use (no cron daemon).
6. ENV: `HOME=/config`, `APACHE_RUN_DIR=/tmp/apache/run`, `APACHE_LOCK_DIR=/tmp/apache/lock`, `APACHE_LOG_DIR=/tmp/apache/log`, `PHP_INI_SCAN_DIR=` default (php.ini edits go through `php_admin_value` in the Apache config, not /etc).
7. Cleanup `/tmp/*`.
8. `USER apps`
9. `COPY --chmod=0755 . /`
10. `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP"     { default = "observium" }
variable "VERSION" {
  // renovate: datasource=custom.observium depName=observium-community versioning=loose
  default = "26.1"
}
variable "LICENSE" { default = "LicenseRef-Observium-1.0" }
variable "SOURCE"  { default = "https://www.observium.org/" }
group "default" { targets = ["image-local"] }
target "image"       { inherits = ["docker-metadata-action"] args = { VERSION = "${VERSION}" }
  labels = { "org.opencontainers.image.source" = "${SOURCE}", "org.opencontainers.image.licenses" = "${LICENSE}" } }
target "image-local" { inherits = ["image"] output = ["type=docker"] tags = ["${APP}:${VERSION}"] }
target "image-all"   { inherits = ["image"] platforms = ["linux/amd64", "linux/arm64"] }
```
(Write it in the multi-line layout of `apps/adguardhome-sync/docker-bake.hcl`; compact form above is only for the plan.) Validate with `cd apps/observium && docker buildx bake --print`. `OBSERVIUM_SHA256` stays a Dockerfile ARG default; update it together with `VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.observium.org/"
ports:
  - port: 8080        # Apache; draft's 80/443 replaced because rootless cannot bind <1024
    protocol: tcp
    required: false
env:
  - {name: OBSERVIUM_db_host,    default: "mariadb",        required: false}
  - {name: OBSERVIUM_db_name,    default: "observium",      required: false}
  - {name: OBSERVIUM_db_user,    default: "observium",      required: false}
  - {name: OBSERVIUM_db_pass,    default: "observiumpwd",   required: true}
  - {name: OBSERVIUM_ADMIN_USER, default: "admin",          required: false}
  - {name: OBSERVIUM_ADMIN_PASS, default: "admin",          required: false}
  - {name: TZ,                   default: "Etc/UTC",        required: false}
volumes:
  - path: /config
    required: true
dependencies:
  - mariadb   # ✅ apps/mariadb exists
```
Write the env items in the block style used by sibling settings.yaml files (not flow style). Defaults must equal `start.sh` and the pvrmza names (`OBSERVIUM_db_*` are the names actually read by the wrapper; here `defaults/config.php` reads them with `getenv`). The 443 port is dropped: no TLS config exists (UNVERIFIED upstream).

## 7. start.sh

Idempotent, bash, `set` nothing fatal around DB wait.
1. `mkdir -p /config/{rrd,logs} /tmp/apache/{run,lock,log} /tmp/php-sessions`.
2. Seed `/config/config.php` from `/defaults/config.php` only when missing (`cp -n`). That file contains `$config['db_host']=getenv('OBSERVIUM_db_host')?:'mariadb';` etc., so the DB password is never written to a file or shown in the process list. Optional `OBSERVIUM_*` extras beyond the db/admin set: appended by a small PHP snippet in `defaults/config.php` that loops `getenv()` for keys starting `OBSERVIUM_` (double underscore = nested key), matching upstream wrapper behaviour (UNVERIFIED exact semantics, test in section 11).
3. Wait up to 60 s for `${OBSERVIUM_db_host}:3306` with `nc -z`; log "waiting for database" and continue (Apache starts regardless so the container stays alive).
4. When the DB is reachable: `cd /app/observium && php discovery.php -u` (idempotent schema create/migrate on every start); create the admin with `php adduser.php "$OBSERVIUM_ADMIN_USER" "$OBSERVIUM_ADMIN_PASS" 10` only when the user does not exist (check via `mysql` client `SELECT COUNT(*)` using `MYSQL_PWD` env, not argv). Existing users are not overwritten.
5. Background scheduler loop (no cron daemon): subshell with timers: every 300 s `php observium-wrapper poller` and `php discovery.php -h new`; every 6 h `php discovery.php -h all`; daily housekeeping (`php housekeeping.php -ysel`, `-yrptb`). Output to `/config/logs`. Skip while DB is unreachable.
6. Optional import of `/config/hosts` and `/config/devices` is out of scope (not reproduced; mention in section 10).
7. Final: `exec apache2 -f /etc/observium/apache2.conf -DFOREGROUND` (config binds `Listen 0.0.0.0:8080`, `PidFile /tmp/apache/run/apache2.pid`, `ErrorLog /dev/stderr`, `CustomLog /dev/stdout combined`, prefork MPM, `LoadModule php_module`, `DocumentRoot /app/observium/html`, `php_admin_value session.save_path /tmp/php-sessions`, `php_admin_value sys_temp_dir /tmp`, `User`/`Group` directives omitted).

Never write to `/app`; all caches/sessions in `/tmp`; persistent state in `/config` (rrd, logs, config.php).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
filePaths:
- /app/observium/discovery.php
- /app/observium/html/index.php
- /usr/share/licenses/observium/LICENSE.COMMUNITY
- /start.sh
```
Probe for port 8080 is `tcp`. No `http` probe: without a database `index.php` returns an error page, and the test runs with no env vars. No DB-narrowing exception is claimed because Apache starts without the DB (criterion 2 of the protocol exception does not hold); the DB-gated code path (schema init, admin creation) is run manually in section 11 with a `mariadb` sidecar.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
|---|---|
| Draft/TrueCharts: root (UID 0), rootfs writable | Run as `apps` (568), read-only rootfs. |
| Apache on 80/443 as root, writes `/var/run/apache2`, `/var/lock` | Own `etc/observium/apache2.conf`, port 8080, run/lock/pid in `/tmp/apache`. |
| Observium writes `rrd/`, `logs/`, `config.php`, `html/` caches under install dir | `rrd`, `logs`, `config.php` symlinked to `/config`; other caches are in PHP temp (`/tmp`). `/app` stays read-only (UNVERIFIED that no other path under `html/` is written; run with `--read-only` and check the logs). |
| cron + supervisord | Replaced by the background loop in `start.sh`; supervisord and cron are not installed. |
| fping/snmp raw sockets | fping needs `cap_net_raw`/setuid; rootless may need the `NET_RAW` capability (UNVERIFIED, section 10). |
| Extra persistence in the draft: only `/config` | Matches: `/config` holds rrd (large), logs, config.php. |

## 10. Risks, caveats and open questions

- Licence: Observium License 1.0 is non-OSI and allows redistribution only of the unmodified package. A public container image redistributes it with added files outside the tree (symlinks inside the tree are modifications). UNVERIFIED whether this is acceptable; needs maintainer sign-off before merge. This may be a blocker.
- Version pinning: upstream only offers "latest"; the pinned sha256 will break the build when Observium publishes a new CE release (intended, noisy). No renovate datasource: bumps are manual (UNVERIFIED that a custom datasource is acceptable).
- Tarball is 133 MB (includes MIBs); image will be large.
- Needs a reachable MariaDB with the `observium` DB/user already created (`apps/mariadb` supports `MARIADB_DATABASE`, `MARIADB_USER`, `MARIADB_PASSWORD`).
- SNMP polling needs network reach to devices; ICMP via fping may need `NET_RAW` (UNVERIFIED).
- Draft expects 80 and 443; plan serves HTTP only on 8080. TLS belongs on a reverse proxy.
- UNVERIFIED: PHP 8.5 compatibility of CE 26.1 (docs list 8.5 for Ubuntu 26.04, so expected fine); exact entrypoint behaviour of the pvrmza image (script not retrieved).
- UNVERIFIED count in this plan: 7 (renovate datasource, SPDX id/redistribution, pvrmza entrypoint, TLS 443, read-only paths under html, fping capability, PHP 8.5 runtime).

## 11. Build and test steps

```sh
cd apps/observium
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create observium-probe-config
docker run --rm -d --name observium-probe --read-only --tmpfs /tmp -v observium-probe-config:/config observium:26.1
docker logs -f observium-probe     # expect Apache "resuming normal operations" / "waiting for database" and no PHP fatal
forgetool containers test --image observium:26.1 --config ./apps/observium/container-test.yaml
docker rm -f observium-probe; docker volume rm observium-probe-config
```
Functional run (manual, DB path): start `mariadb` (same Docker network, `MARIADB_DATABASE=observium`, `MARIADB_USER=observium`, `MARIADB_PASSWORD=...`), start observium with `OBSERVIUM_db_host=mariadb OBSERVIUM_db_pass=...`, check log shows schema update done, `curl -s http://localhost:8080/` returns the login page, log in with the admin account, restart and confirm the admin password is unchanged and the DB password change is picked up. Also repeat with `--read-only`. Readiness signal: Apache `AH00094: Command line: ... resuming normal operations` plus port 8080 open. Round limit: 10.

## 12. PR checklist

- Branch `feat/add-observium`; commit and PR title `feat(observium): add new container`; target `main`.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md` (keep sections and checkboxes; tick only what applies), contains upstream source, version `26.1`, base image, ports/volumes, and `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- Untested until implemented: bake print, amd64 and arm64 builds, read-only run, full DB-backed run, poller loop, fping capability, redistribution licence question. Do not tick "Built container locally" unless done.
