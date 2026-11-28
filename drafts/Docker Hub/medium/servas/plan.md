# servas — implementation plan
> Source: ./draft.md · Target: apps/servas/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest release `v1.2.0` (published 2026-11-20). The TrueCharts chart pins `beromir/servas:1.2.0@sha256:662b0d8f...` (chart `appVersion` 1.2.0; <https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/servas/values.yaml>). `v1.1.3` was published 2026-10-28. This plan uses `1.2.0`, which matches the chart. |
| Renovate | `datasource=github-releases depName=beromir/Servas versioning=semver` (convention; repo renovate config not fetched) |
| License | GPL-3.0 (GitHub API SPDX `GPL-3.0`; https://api.github.com/repos/beromir/Servas/license). |
| Source URL | https://github.com/beromir/Servas |
| Download | No release assets. Source archive `https://github.com/beromir/Servas/archive/refs/tags/v1.2.0.tar.gz` (built with composer and node). |
| Checksum source | None published by upstream. Pin the sha256 of the archive after computing it once (UNVERIFIED: not computed in this run). |
| Upstream Dockerfile reviewed | `v1.1.3`: https://api.github.com/repos/beromir/Servas/contents/Dockerfile?ref=088eaa3232f5d266e1e002c663797cdd2d8c77bb. `v1.2.0`: https://api.github.com/repos/beromir/Servas/contents/Dockerfile?ref=v1.2.0. Stages: `dunglas/frankenphp:1.13.4-php8.4.27-alpine` (composer install `--no-dev`, `dump-autoload`); `node:24.22-alpine` (vite build); final `dunglas/frankenphp` with `pdo_mysql mysqli opcache bcmath`, `mariadb-client`, `sqlite`. `v1.2.0` uses `dunglas/frankenphp:1.13.6-php8.5.13-alpine` and `node:24.22-alpine`. |
| Upstream runtime | FrankenPHP with Caddy (`/etc/caddy/Caddyfile`, `frankenphp run --config`). `ENV SERVER_NAME=:80`. `ENTRYPOINT ["/docker-entrypoint.sh"]`. No `USER`, runs as root. |
| Upstream entrypoint | `/docker-entrypoint.sh` (https://api.github.com/repos/beromir/Servas/contents/docker-entrypoint.sh?ref=088eaa3232f5d266e1e002c663797cdd2d8c77bb): touches `/app/database/sqlite/database.sqlite` if missing; `php artisan migrate --force`; `php artisan config:cache`; `php artisan view:cache`; `frankenphp run --config /etc/caddy/Caddyfile`. |
| Port | `80/tcp` (Caddyfile `:80`, `SERVER_NAME=:80`). The draft's `8080` is wrong per upstream config. Non-root cannot bind 80, so the ContainerForge build must change the listen port (see section 4). |
| Env vars (real, upstream `.env.example`) | `APP_NAME`, `APP_ENV`, `APP_KEY` (empty, must be generated), `APP_DEBUG`, `APP_URL`, `SERVAS_ENABLE_REGISTRATION`, `SERVAS_SHOW_APP_VERSION`, `LOG_CHANNEL`, `LOG_LEVEL`, `DB_CONNECTION` (`mysql` or `sqlite`), `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `SESSION_DRIVER`, `CACHE_DRIVER`, `QUEUE_CONNECTION`, `FILESYSTEM_DISK`, `MAIL_*`, `REDIS_*`, `AWS_*`, `PUSHER_*` (https://api.github.com/repos/beromir/Servas/contents/.env.example?ref=088eaa3232f5d266e1e002c663797cdd2d8c77bb). Full production list UNVERIFIED. |
| Write paths (upstream) | `/app/database/sqlite` (SQLite file), `/app/bootstrap/cache` (written by `config:cache`/`view:cache`), `storage/` (Laravel sessions, logs, cache), `/var/cache/php/opcache`. |
| Arch | Docker Hub `1.1.3` has amd64 and arm64 digests. The FrankenPHP base is multi-arch. copy-from amd64 / arm64: no (upstream image is alpine/musl). |
| Dependencies | MariaDB or MySQL (external), or SQLite embedded. `apps/mariadb` exists (✅). |

## 2. Target layout

- `apps/servas/Dockerfile`
- `apps/servas/docker-bake.hcl`
- `apps/servas/settings.yaml`
- `apps/servas/container-test.yaml`
- `apps/servas/start.sh`
- `apps/servas/etc/` only if a Caddy or nginx config is shipped (see section 3).
- No `defaults/` unless a default `.env` is shipped (decide in the build round).
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

The draft plans apt PHP on `ghcr.io/trueforge-org/ubuntu`, but the upstream runtime is FrankenPHP, not PHP-FPM with nginx. The runtime choice must be decided before the Dockerfile is written. Options:

1. **Recommended: ubuntu base + pinned apt PHP-FPM + nginx.** Ubuntu 26.04 `php8.x-fpm`, `php8.x-mysql`, `php8.x-xml`, `php8.x-mbstring`, `php8.x-curl`, `php8.x-zip`, `php8.x-intl`, `php8.x-bcmath`, `php8.x-opcache`, `php8.x-sqlite3` (versions UNVERIFIED: check `apt-cache policy` in a build round, and pin). Serve with the nginx setup from `apps/nginx` or a bundled `etc/nginx` config. Closest sibling: `apps/bookstack` (PHP stack) and `apps/nginx` (nginx).
2. FrankenPHP static binary from its GitHub release (UNVERIFIED: release asset names and checksums not fetched). Would keep upstream's runtime model, but adds a new dependency pattern.

The final stage is `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for option 1. Node is needed only in the build stage (vite assets), so use the `node:24.22-alpine` upstream build only as a reference: build the assets in a build stage on the ContainerForge `python-node` base (`ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`), or check the Node major in the image (UNVERIFIED that it is 24).

## 4. Dockerfile

1. `ARG VERSION=1.2.0`, `ARG TARGETARCH`.
2. Build stage A (composer): fetch the source archive (sha256 pinned), `composer install --no-dev --optimize-autoloader --no-plugins --no-scripts`, then `composer dump-autoload --no-dev --classmap-authoritative`. Use a PHP CLI with composer; check what the ContainerForge build base provides (UNVERIFIED).
3. Build stage B (assets): `npm install` and `npm run build` from `package.json`, `.npmrc`, `vite.config.js`, `resources/` (upstream's copy list).
4. Final stage: `apt-get install --no-install-recommends` the pinned PHP packages from section 3 and `mariadb-client`, `sqlite3`, `nginx` (or the nginx base `ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` if its layout fits; check `apps/nginx`). Remove apt lists.
5. Copy the app from build stage A and the build output from B into `/app`, with `public/build`. Remove `docker/` as upstream does.
6. Listen on a non-root port: set nginx `listen 8080` (or the chosen high port) and `EXPOSE 8080`. Port 80 needs root. This is a deliberate change from upstream `:80`; record it in the PR.
7. License: copy `LICENSE` to `/usr/share/licenses/servas/LICENSE`. GPL-3.0.
8. Writable-path remaps at build time (the `/app` tree is read-only at runtime):
   - `ln -s /config/database/sqlite /app/database/sqlite`, plus the SQLite file path used by `DB_DATABASE`.
   - `ln -s /config/storage /app/storage`.
   - `ln -s /tmp/bootstrap-cache /app/bootstrap/cache` is NOT safe at build time; instead set Laravel cache env vars (`APP_CONFIG_CACHE`, `APP_SERVICES_CACHE`, `APP_PACKAGES_CACHE`, `APP_ROUTES_CACHE`, `APP_EVENTS_CACHE`) to `/tmp/...` paths, and confirm the Laravel version supports them (UNVERIFIED).
9. `ENV HOME=/config` only if needed; PHP session and opcache dirs under `/tmp` (`/var/cache/php/opcache` replaced by `/tmp/opcache`, UNVERIFIED path ini key).
10. `EXPOSE 8080`, `VOLUME /config`, `COPY --chmod=0755 . /`, final `USER apps`.

## 5. docker-bake.hcl

- `variable "APP" { default = "servas" }`
- `variable "VERSION" { // renovate: datasource=github-releases depName=beromir/Servas versioning=semver` then `default = "1.2.0"`. Must equal Dockerfile `ARG VERSION`.
- `variable "LICENSE" { default = "GPL-3.0-only" }` (GitHub reports `GPL-3.0`; use the SPDX id the upstream LICENSE file states, UNVERIFIED which variant).
- `variable "SOURCE" { default = "https://github.com/beromir/Servas" }`
- Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (linux/amd64, linux/arm64), `group "default"` with `image-local`.
- Validate with `cd apps/servas && docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/beromir/Servas"`.
- `ports`: `port: 8080`, `protocol: tcp`, `required: false` (matches section 4).
- `env` (only the variables the app and start.sh read):
  - `APP_KEY`, `required: false`, no default (start.sh generates and stores in `/config` if absent).
  - `APP_URL`, default `http://localhost:8080`, `required: false`.
  - `APP_ENV`, default `production`, `required: false`.
  - `APP_DEBUG`, default `false`, `required: false`.
  - `DB_CONNECTION`, default `sqlite`, `required: false`.
  - `DB_DATABASE`, default `/config/database/sqlite/database.sqlite`, `required: false`.
  - `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `required: false`, no default (for mysql mode).
  - `SERVAS_ENABLE_REGISTRATION`, default `false`, `required: false`.
  - `TZ`, default `Etc/UTC`, `required: false`.
- `volumes`: `/config`, `required: true`.
- `dependencies`: `mariadb` (optional, `apps/mariadb` ✅). Not a hard dependency: sqlite mode works without it.

## 7. start.sh

1. `set -eu`.
2. Create `/config/database/sqlite` and `/config/storage` when missing (`mkdir -p`). Create `database.sqlite` with `touch` only when missing.
3. If `APP_KEY` is unset, generate `base64:` key once with `php artisan key:generate --show` writing to `/config/app.key` (create only when missing; read on later starts). Never write to `/app/.env`.
4. Export the Laravel cache env vars pointing at `/tmp`.
5. `cd /app && php artisan migrate --force` (idempotent).
6. `php artisan config:cache` and `php artisan view:cache` with the `/tmp` cache paths.
7. Start the web stack: `php-fpm -F` cannot be `exec`ed together with nginx. Start php-fpm in the background (`php-fpm -D`, pid and socket under `/tmp`), then `exec nginx -g 'daemon off;'` so nginx is the final `exec`. Decide with section 3 (UNVERIFIED which form is clean).
8. Bind on `0.0.0.0` only.

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
- /app/artisan
- /app/vendor/autoload.php
- /app/public/build
- /usr/share/licenses/servas/LICENSE
```

- Port 8080 has a tcp and an http probe (rule: every port in `settings.yaml`). `/` may redirect to the install or login page; check the status on the first run and record it (UNVERIFIED).
- Startup needs no env vars: sqlite mode plus generated `APP_KEY` makes the start path testable without a DB. If mysql is required for start, apply the database-dependent exception narrowly and add the required comment.
- `timeoutSeconds: 180` because `migrate` and `config:cache` run at start. Check sibling PHP apps (`apps/bookstack`) for the family value and align it.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/database/sqlite/database.sqlite` | symlink `/app/database/sqlite -> /config/database/sqlite` at build time; start.sh creates the file |
| `/app/storage` (sessions, logs, cache) | symlink to `/config/storage`; start.sh creates subfolders with `mkdir -p` |
| `/app/bootstrap/cache` (config and view cache) | Laravel cache env vars pointing to `/tmp` (section 4 step 8) |
| `/var/cache/php/opcache` | `/tmp/opcache` (PHP ini) |
| PHP session files | `/tmp` (PHP ini `session.save_path`) |
| nginx temp and pid (`/var/run/nginx`, the chart's emptyDir) | `/tmp/nginx` for pid and temp paths in the nginx config |

- UID: upstream runs as root (chart `runAsUser 0`). ContainerForge runs as `apps` (568). Keep `USER apps`. Chart sets `readOnlyRootFilesystem: false`; the image must not depend on root.
- Port 8080 instead of 80 (section 4 step 6).
- `privileged`: no.

## 10. Risks, caveats and open questions

- Runtime choice (section 3) is open. The draft's apt PHP plan does not match upstream FrankenPHP.
- Version: the chart is on `1.2.0` (values.yaml tag); `1.2.0` is the target. Its base images moved to PHP 8.5 and FrankenPHP 1.13.6 relative to `1.1.3`.
- Port: `80` upstream, `8080` in this plan. Chart service port must match, and downstream chart work is outside this PR.
- Arm64: the draft's `yes*` is unconfirmed as a ContainerForge build (the Docker Hub image is multi-arch, but the ContainerForge build path is not). Recheck with an arm64 build if the amd64 build succeeds.
- DB: external MariaDB or SQLite. Without a DB the sqlite path must work; test it.
- Laravel cache env var names (`APP_*_CACHE`) must be checked against the installed Laravel version (UNVERIFIED).
- Blockers: none confirmed; no GPU, no privileged. Licence is GPL-3.0.

## 11. Build and test steps

```sh
cd apps/servas
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name servas-probe --read-only --tmpfs /tmp \
  -v servas-probe-config:/config servas:1.2.0
docker logs -f servas-probe
forgetool containers test --image servas:1.2.0 --config ./apps/servas/container-test.yaml
docker rm -f servas-probe; docker volume rm servas-probe-config
```

- Readiness signal: nginx/php-fpm ready line (UNVERIFIED exact text; record from the first run) and the migration finishing with no error.
- Check that `/config` gets `app.key`, `database/sqlite/database.sqlite` and `storage/` after start, and that a restart keeps the same data.
- Check `/` status and the login page.

## 12. PR checklist

- Branch `feat/add-servas`, commit `feat(servas): add new container`, PR title `feat(servas): add new container`, target `main`.
- Notes section: `🤖 This PR is AI generated.`
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; check only what applies.
- CLA: signed Contributor License Agreement required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what is untested: arm64 build, the PHP version pin, the mysql mode, the Laravel cache env vars, and the port change from 80 to 8080.
