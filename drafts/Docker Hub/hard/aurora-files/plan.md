# aurora-files — implementation plan
> Source: ./draft.md · Target: apps/aurora-files/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `9.8.7` (`VERSION` file on `afterlogic/aurora-files` master reads `9.8.7.build9`). The draft names only `latest`. The vendor zip at https://afterlogic.org/download/aurora-files.zip is unversioned (HTTP 200, 79,848,196 bytes, last-modified 2026-10-26), so the zip's own `VERSION` file must be checked at build time. |
| Renovate | `datasource=github-tags`, `depName=afterlogic/aurora-files`, `versioning=loose`. UNVERIFIED: the repo's Releases page is empty and I could not list its tags (GitHub API rate-limited). If there are no tags, drop Renovate for this app and bump `VERSION` by hand. |
| License | `AGPL-3.0` (repo README: AGPL-3.0, bundled modules carry their own licenses). SPDX for bake: `AGPL-3.0-only`. UNVERIFIED whether "or later". The draft's "licence for the vendor code" worry is answered by the AGPLv3 statement, but the afterlogic.org zip terms were not read. |
| Source URL | https://github.com/afterlogic/aurora-files (docs https://afterlogic.com/docs) |
| Downloads | Interpreted PHP, so one arch-independent artifact: `https://afterlogic.org/download/aurora-files.zip` (prebuilt, no composer or npm needed). Building from GitHub needs git, composer and npm plus several modules, so use the zip. |
| Checksum | None published by the vendor. The URL is a moving "latest", so a pinned sha256 would break on every upstream release. Mitigation: assert the extracted `VERSION` starts with `${VERSION}`, and record the observed sha256 in the PR description. |
| Upstream Dockerfile reviewed | `afterlogic/docker-aurora-files` Dockerfile (Alpine 3.24.3, php83 + php83-fpm, nginx, supervisor, mysql-client; `wget` of the zip into `/var/www/html`; `COPY afterlogic.php`; `EXPOSE 80`; no VOLUME, no ENV; HEALTHCHECK `curl http://127.0.0.1/fpm-ping`). |
| PHP extensions needed | fileinfo, mysqli, pdo, pdo_mysql, pdo_sqlite, iconv, mbstring, curl, dom, xml, gd, exif, zip, xmlwriter, xmlreader, session. |
| Ports | Upstream image: `80` (nginx). Draft says 80. This image uses `8080` instead because it runs as non-root and must not bind below 1024 (deliberate deviation from the draft). |
| Env vars | The upstream image defines none. `afterlogic.php` hardcodes DB host `db:3306`, name `afterlogic`, login `afterlogic`, password `docker_Bundle`. Our env vars below are our own design, applied through the same Aurora settings API. |
| Config and data | `data/` under the web root must be writable. Settings are in `data/settings/config.json`. nginx upstream config denies `/data`. Admin panel at `/adminpanel/`. |
| Distribution note | The draft says Alpine/musl; our image is Ubuntu glibc with apt PHP, so there is no musl issue. |

## 2. Target layout

```
apps/aurora-files/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/nginx/aurora-files.conf.template   # reason: nginx server config rendered into /tmp at start
  etc/php/aurora.ini                     # reason: upload/memory limits, session path in /tmp
  defaults/afterlogic-init.php           # reason: first-run DB settings script, run by start.sh
```
No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Reason: draft says ubuntu alone is enough; PHP, nginx and php-fpm come from apt. Closest sibling: `apps/bookstack` (php8.5 apt packages, nginx + php-fpm, `/config` symlinks). `apps/nginx` exists but is not needed as a base.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends` nginx, php8.5-fpm, php8.5-cli, php8.5-mysql, php8.5-sqlite3, php8.5-mbstring, php8.5-curl, php8.5-xml, php8.5-gd, php8.5-zip, php8.5-intl (if needed), unzip, curl, mariadb-client. Check first which are already in the base (do not re-install). The php8.5 naming copies `apps/bookstack`. Pin the apt PHP version against the image content only where the app needs it. UNVERIFIED: Aurora 9.8.7 supports PHP 8.5; upstream tests on 8.3. If the 26.04 archive lacks php8.3 and 8.5 fails the smoke test, stop and record this as a blocker.
3. Download and verify:
   ```sh
   curl -fL -o /tmp/aurora-files.zip https://afterlogic.org/download/aurora-files.zip
   mkdir -p /app/www && unzip -q /tmp/aurora-files.zip -d /app/www
   grep -q "^${VERSION}" /app/www/VERSION   # fails the build when the vendor zip moved on
   ```
4. Move writable data out of `/app`: `rm -rf /app/www/data && ln -s /config/data /app/www/data`. Any other writable path found in testing gets the same treatment (see section 9).
5. Licenses: copy `/app/www/LICENSE` (and third-party notices if present) to `/usr/share/licenses/aurora-files/`.
6. nginx and php-fpm run unprivileged: config, pid, temp paths and fpm socket all under `/tmp` (set in the templates, not via env).
7. `ENV TZ=Etc/UTC PHP_INI_SCAN_DIR` only if required to load `etc/php/aurora.ini`; otherwise copy it into `/etc/php/8.5/fpm/conf.d/` during the root step.
8. Cleanup: `rm -rf /tmp/* /var/lib/apt/lists/*`.
9. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`. (`COPY . /` places `start.sh`, `etc/`, `defaults/` via the allow-list.) Port 8080 is used because binding port 80 as non-root is not allowed.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP"     { default = "aurora-files" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=afterlogic/aurora-files versioning=loose
  default = "9.8.7"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/afterlogic/aurora-files" }
```
Plus `group "default" { targets = ["image-local"] }`, `image` (args `VERSION`, labels source and licenses), `image-local` (`output=["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), copied from `apps/bookstack/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/afterlogic/aurora-files"
ports:
  - {port: 8080, protocol: tcp, required: true}
env:
  - {name: TZ, default: "Etc/UTC", required: false}
  - {name: DB_HOST, default: "", required: false}     # empty = leave Aurora default
  - {name: DB_PORT, default: "3306", required: false}
  - {name: DB_NAME, default: "afterlogic", required: false}
  - {name: DB_USER, default: "afterlogic", required: false}
  - {name: DB_PASSWORD, default: "", required: false}
volumes:
  - {path: /config, required: true}
opt_dependencies:
  - name: mariadb      # ✅ apps/mariadb exists
```
The DB_* names are our own, mapped onto Aurora's `DBHost/DBName/DBLogin/DBPassword` settings in `start.sh`; they are not upstream env vars. Use the exact list format of `apps/bookstack/settings.yaml`. UNVERIFIED: whether Aurora Files can run on SQLite alone (upstream installs `pdo_sqlite` but the init script only configures MySQL). If MySQL is mandatory, change `dependencies:` to a hard `mariadb`.

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`.
1. `mkdir -p /config/data /tmp/nginx /tmp/php/sessions`.
2. First run only (when `/config/data/settings/config.json` is missing): render `defaults/afterlogic-init.php` and run `php /app/www/afterlogic.php`-style init, which calls `\Aurora\System\Api::Init(true)` then `SetValue('DBHost'...)` from `DB_HOST:DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` read via `getenv()` (never interpolated into shell or PHP source, so special characters are safe), then `Save()` and `SyncModulesConfigs()`. Skip the DB part when `DB_HOST` is empty. Idempotent: do not overwrite an existing `config.json`.
3. Render the nginx config from the template into `/tmp/nginx/nginx.conf` (listen `0.0.0.0:8080`, root `/app/www`, `location ~ /data { deny all; }`, fastcgi to `unix:/tmp/php/fpm.sock`, `client_max_body_size 0`, temp paths under `/tmp`, logs to stdout/stderr).
4. Start `php-fpm8.5 -F -y /tmp/php/php-fpm.conf` in the background (socket and pid in `/tmp`, `clear_env = no`), then `exec nginx -c /tmp/nginx/nginx.conf -g 'daemon off;'`. Because fpm is backgrounded, add a `trap` that kills it and have the script exit if fpm dies (poll with `wait -n` before exec is not possible, so use a small watcher or run nginx in the foreground and fpm under `trap 'kill $FPM_PID' EXIT`). No supervisor or s6.
5. Never write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /      # UNVERIFIED: status the app returns on / without a DB; probe expects 200
filePaths:
- /app/www/afterlogic.php   # check actual file name in the unzipped tree
- /app/www/system/autoload.php
- /usr/share/licenses/aurora-files
```
The test runs without env vars, so the DB seeding path is only checked through a manual run. If the app returns an error page without a DB, keep the TCP probe plus `filePaths` and add the narrowed comment `# narrowed: requires external mariadb; full functional test not feasible in single-container suite` only if the three exception criteria hold (they do not if SQLite works).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/www/html/data` (settings, user files) | symlink `/app/www/data` -> `/config/data` |
| nginx `/var/lib/nginx`, `/run/nginx.pid`, temp dirs | all set to `/tmp/nginx/...` in the rendered config |
| php-fpm socket, pid, sessions, upload tmp | `/tmp/php/...` (`session.save_path`, `upload_tmp_dir`) |
| Aurora caches/logs under `data/` | `/config/data` (persistent; logs also appear under `data/logs`) |
| supervisord `/run/supervisord.pid` | not applicable, supervisor dropped |

Draft expectations: chart runs as UID 0, `readOnlyRootFilesystem: false`, no extra persistence. Our image runs as `apps`, read-only rootfs, all persistence in `/config` (no separate `/data`). Not privileged.

## 10. Risks, caveats and open questions

- Vendor zip is unversioned and unsigned, hosted on afterlogic.org (draft caveat confirmed). Builds are not reproducible, and a vendor release makes the VERSION check fail until `VERSION` is bumped. Renovate cannot see the vendor download.
- PHP 8.5 compatibility is UNVERIFIED (upstream pins php83).
- Draft inferred that the app writes into its own tree. Upstream only chowns `data/`; further writes (cache, compiled templates) must be found in a real run with `--read-only` and remapped.
- Running two processes in one container with a bash trap is less robust than a supervisor; accept for now.
- DB requirement (MySQL vs SQLite) is UNVERIFIED; the upstream compose pairs it with MySQL on host `db`.
- Port 80 is replaced by 8080 (non-root); existing chart users must remap the service port.
- Draft confidence is low; this plan raised it by reading the upstream Dockerfile, but nothing was built.
- No hard blockers: arm64 works (PHP), no GPU, no privileged mode.

## 11. Build and test steps

```sh
cd apps/aurora-files
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create aurora-files-probe-config
docker run --rm -d --name aurora-files-probe --read-only --tmpfs /tmp \
  -v aurora-files-probe-config:/config aurora-files:9.8.7
docker logs -f aurora-files-probe
curl -i http://<container-ip>:8080/            # from another container, not only localhost
forgetool containers test --image aurora-files:9.8.7 --config ./apps/aurora-files/container-test.yaml
docker rm -f aurora-files-probe; docker volume rm aurora-files-probe-config
```
Readiness signal: nginx started with no `[emerg]`, php-fpm `ready to handle connections`, port 8080 open, and `/config/data/settings` populated. Then also run once with `DB_*` pointed at `apps/mariadb` to exercise the seeding path the test cannot cover.

## 12. PR checklist

- Branch `feat/add-aurora-files`, commit `feat(aurora-files): add new container`, title identical, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Confirm: `bake --print` ok, `USER apps`, empty `/config` start, read-only rootfs, license files shipped, versions aligned in Dockerfile and bake.
- Untested at planning time (state honestly in the PR if still so): the image build, PHP 8.5 compatibility, SQLite-only operation, the DB seeding path, arm64, and the sha256 of the vendor zip.
