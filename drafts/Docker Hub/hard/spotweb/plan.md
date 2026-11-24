# spotweb — implementation plan
> Source: ./draft.md · Target: apps/spotweb/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 1.5.8 (GitHub releases API, published 2024-12-20). Draft tag was 1.5.4. Tags have no `v` prefix |
| Renovate | `datasource=github-releases depName=spotweb/spotweb versioning=loose` (numeric tags; loose as `apps/bookstack`) |
| License | BSD-3-Clause (LICENSE.md, per repo page) |
| Source | https://github.com/spotweb/spotweb (default branch `develop`) |
| Download | Same for amd64/arm64 (PHP): `https://github.com/spotweb/spotweb/archive/refs/tags/1.5.8.tar.gz`. The release has no assets |
| Checksum | None published |
| Requirements (README) | Web server with PHP; extensions curl, dom, gettext, mbstring, xml, zip, zlib, gd, openssl; database MySQL, PostgreSQL or SQLite (SQLite least supported). CI badges cover PHP 8.1 to 8.5. Setup wizard at `install.php` |
| Upstream Dockerfile | `joachimbaten/spotweb-docker` @ 5c930ba: `alpine:latest`, nginx + supervisor + php82-fpm, `git clone --depth=1 --branch develop` (unpinned), `mkdir -m777 /app/cache`, cron via `/etc/periodic/{1min,5min}`, `EXPOSE 80`. Its `entrypoint.sh` reads `TZ` (default `Europe/Amsterdam`) and `SPOTWEB_RETRIEVE` (cron directory name, e.g. hourly/daily), sets `date.timezone`, runs `/root/init_db.sh` (content unseen, UNVERIFIED) and starts supervisord. Alpine/musl: not reusable |
| Ports | Draft says 80/http. We use 8080 (non-root) |
| Config files | `dbsettings.inc.php`, `ownsettings.php` in the Spotweb root (README troubleshooting). Their keys are UNVERIFIED here |
| Dependencies | postgresql ✅ (`apps/postgresql` exists). DB must be created externally |

## 2. Target layout

```
apps/spotweb/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/nginx.conf       # server on 8080 -> php-fpm unix socket in /tmp
  defaults/php-fpm.conf     # pool, pid/log/socket under /tmp, clear_env = no
  defaults/ownsettings.php  # empty seed, only copied when missing
```
`root/` is not used. No DOWNSTREAM_CHANGES.md.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` with php-fpm and nginx from apt (draft main choice; the `nginx` image alternative is rejected because PHP-FPM must be added anyway and the nginx image drives `-c /config/nginx.conf`). Closest sibling: `apps/bookstack` (php8.5 on ubuntu 26.04).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (not needed for the download, keep for parity).
2. `USER root`; `apt-get update && apt-get install -y --no-install-recommends nginx php8.5-fpm php8.5-cli php8.5-curl php8.5-xml php8.5-gd php8.5-zip php8.5-mbstring php8.5-pgsql php8.5-mysql php8.5-sqlite3 php8.5-intl`, then `rm -rf /var/lib/apt/lists/*`. Verify names with `apt-cache` (php8.5 is what `apps/bookstack` uses; gettext/dom/zlib/openssl are part of `php8.5-common`/`-xml`, UNVERIFIED). Do not reinstall curl, tar (base has them).
3. `curl -fsSL -o /tmp/spotweb.tgz https://github.com/spotweb/spotweb/archive/refs/tags/${VERSION}.tar.gz` (fall back to `v${VERSION}` like bookstack if the tag naming changes); no checksum available. `mkdir -p /app/www && tar xzf /tmp/spotweb.tgz -C /app/www --strip-components=1`.
4. Symlinks created at build time (targets live in `/config`, created at runtime): `/app/www/dbsettings.inc.php -> /config/dbsettings.inc.php`, `/app/www/ownsettings.php -> /config/ownsettings.php`, `/app/www/cache -> /tmp/spotweb-cache`.
5. License files: `mkdir -p /usr/share/licenses/spotweb && cp /app/www/LICENSE.md /usr/share/licenses/spotweb/`.
6. `ENV HOME=/config` (php/composer/etc caches under `/tmp`: `ENV XDG_CACHE_HOME=/tmp/.cache`). Configure php-fpm `clear_env = no` as bookstack does.
7. Remove the distro default nginx site and make nginx use `/defaults/nginx.conf` with pid, temp paths, logs under `/tmp`. `rm -f /tmp/spotweb.tgz`.
8. `chown -R apps:apps /app`, then `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /app/www`, final `USER apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "spotweb" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=spotweb/spotweb versioning=loose
  default = "1.5.8"
}
variable "LICENSE" { default = "BSD-3-Clause" }
variable "SOURCE" { default = "https://github.com/spotweb/spotweb" }
```
Targets: `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Header + `schema_version: 1`, `upstream_env_url: "https://github.com/spotweb/spotweb"`.
- ports: `8080` tcp, required true.
- env (the names below are read by our `start.sh`, not by Spotweb itself): `TZ` (`Etc/UTC`, false), `DB_ENGINE` (`pdo_pgsql`, false), `DB_HOST` (""), `DB_PORT` (`5432`), `DB_NAME` (`spotweb`), `DB_USER` (`spotweb`), `DB_PASS` (""), `SPOTWEB_RETRIEVE_INTERVAL` (`3600` seconds, false). `DB_HOST`, `DB_USER`, `DB_PASS` are `required: true` and handled by start.sh (it waits and logs when `DB_HOST` is empty, so the container still starts).
- volumes: `/config` required true.
- dependencies: `postgresql` ✅ (`apps/postgresql`).

## 7. start.sh

1. `set -euo pipefail`; defaults `: "${DB_PORT:=5432}"` etc., `mkdir -p /config /tmp/spotweb-cache /tmp/nginx /tmp/php`; set PHP `date.timezone` from `TZ` through a `-d date.timezone=` php-fpm option, not by editing files in `/etc`.
2. Seed `/config/ownsettings.php` from `/defaults/ownsettings.php` only when missing.
3. Generate `/config/dbsettings.inc.php` on every start from the environment (applies a changed password on existing data), writing PHP strings with `php -r` and `var_export(getenv(...))` so quotes, `$` and backslashes in the password are safe and the password never appears in argv. Keys follow Spotweb's `$dbsettings['engine'|'host'|'dbname'|'user'|'pass'|'port']` (UNVERIFIED here; confirm against the `dbsettings.inc.php` template in the tarball). If `DB_HOST` is empty, skip generation and let the install wizard (`install.php`) be used.
4. Wait up to ~60 s for `DB_HOST:DB_PORT` (as bookstack does), then run the schema upgrade script if the tarball ships one (UNVERIFIED name; otherwise the first-visit wizard creates the schema and admin user, per draft).
5. Background loop: every `SPOTWEB_RETRIEVE_INTERVAL` seconds run `php /app/www/retrieve.php` (file exists in the repo root per the repo page); log output to stdout.
6. Start `php-fpm8.5 -F -y /defaults/php-fpm.conf` in the background; nginx binds `0.0.0.0:8080`.
7. Final: `exec nginx -c /defaults/nginx.conf -g 'daemon off;'`. Helpers are backgrounded; a trap on TERM kills them.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /install.php
filePaths:
- /start.sh
- /app/www/index.php
- /app/www/retrieve.php
- /usr/share/licenses/spotweb/LICENSE.md
runners:
- entrypoint: php --version
```
Probe for the only port 8080 (tcp + http). The http check targets `install.php`, which UNVERIFIED works without a database (it is the setup wizard); if it needs one, fall back to the narrowed smoke tests allowed by the protocol's database exception only if all three criteria hold (hard DB dependency, will not serve without it, no sidecar possible), with the required `# narrowed: requires external postgresql; full functional test not feasible in single-container suite` comment. The DB env path (`dbsettings.inc.php` generation) is not covered by the test (no env), so it is run by hand in section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/app/cache` (mode 777) | symlink to `/tmp/spotweb-cache` |
| `dbsettings.inc.php`, `ownsettings.php` | symlinks to `/config/*` |
| nginx pid, temp, logs; php-fpm pid, socket, log | `/tmp/nginx`, `/tmp/php` |
| supervisor, `/etc/periodic` cron (root) | dropped: start.sh background loop |
| Port 80 | 8080 (non-root cannot bind low ports) |

Draft: root UID 0, writable rootfs, no persistence (DB external). Image runs UID 568, read-only rootfs; only `/config` (two small files) and `/tmp` are written. Spotweb has no data volume of its own: `/config` is kept for settings.

## 10. Risks, caveats and open questions

- Needs an external PostgreSQL (draft); wizard-based first setup.
- Upstream pinned nothing (`develop` cloned at build). We pin the release tag 1.5.8, so behaviour differs from the TrueCharts image (1.5.4 and `develop`).
- Several processes (nginx, php-fpm, retrieval loop) in one container.
- UNVERIFIED: dbsettings key names, upgrade script name, `install.php` without DB, exact PHP package names on ubuntu 26.04, the upstream `init_db.sh` env names (unreadable, 403), supported PHP 8.5 for 1.5.8 (README lists 8.1 to 8.5 for current code).
- Retrieval is mandatory for content: if `DB_HOST` is unset nothing is retrieved.
- No blockers (not musl-only, no GPU, not privileged, arm64 expected fine).

## 11. Build and test steps

```sh
cd apps/spotweb
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name spotweb-probe --read-only --tmpfs /tmp -v spotweb-probe-config:/config spotweb:1.5.8
docker logs -f spotweb-probe
forgetool containers test --image spotweb:1.5.8 --config ./apps/spotweb/container-test.yaml
docker rm -f spotweb-probe; docker volume rm spotweb-probe-config
```
Then repeat with a scratch `postgresql` container on a shared network and `-e DB_HOST=... -e DB_USER=... -e DB_PASS=...` (use a password with `$`, quotes and a backslash) to prove `dbsettings.inc.php` generation and the wizard. Readiness: nginx and php-fpm start without errors and `curl -I http://127.0.0.1:8080/install.php` returns 200.

## 12. PR checklist

- Branch `feat/add-spotweb`, commit `feat(spotweb): add new container`, target `main`.
- Use the PR template; check only the applicable boxes.
- Notes: `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge ; only the user can sign it.
- Untested (state honestly): database-backed flow, retrieval loop, arm64, schema upgrade, PHP 8.5 compatibility.
- Pre-completion: `bake --print`, version alignment, final `USER apps`, empty `/config` start, postgresql listed under `dependencies` (apps/postgresql exists).
