# wallos — implementation plan
> Source: ./draft.md · Target: apps/wallos/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v5.11.3, latest release published 2026-11-20 (GitHub API `repos/ellite/Wallos/releases/latest`, prerelease false). Draft pins 5.11.2 (older); this plan uses the newer 5.11.3. The Dockerfile/startup.sh review below was done at tag v5.11.2 and must be re-checked at v5.11.3. |
| Renovate | `// renovate: datasource=github-releases depName=ellite/Wallos versioning=semver` |
| License | GPL-3.0 (GitHub API `repos/ellite/Wallos` `license.spdx_id`). |
| Source URL | https://github.com/ellite/Wallos ; release https://github.com/ellite/Wallos/releases/tag/v5.11.3 |
| Download | Source only, no binary assets on the release (`assets: []`). Use the tag source archive (`https://github.com/ellite/Wallos/archive/refs/tags/v5.11.3.tar.gz`, UNVERIFIED URL shape, not fetched) or `git clone --branch v5.11.3`. |
| Per-arch | PHP (interpreted): amd64 and arm64 both possible. |
| Checksum source | None published on the release. Record the tarball sha256 at build time. |
| Upstream Dockerfile reviewed | https://github.com/ellite/Wallos/blob/v5.11.2/Dockerfile: `FROM php:8.3-fpm-alpine`, `WORKDIR /var/www/html`, `apk add` of dumb-init, shadow, sqlite-dev, nginx, dcron, tzdata, libzip-dev, icu-dev; `docker-php-ext-install` pdo, pdo_sqlite, calendar, gd, intl, zip; PHP-FPM pool `pm.max_children = 15`, `pm.max_requests = 500`; upload limit 256M; `COPY . .`; `COPY nginx.conf /etc/nginx/nginx.conf`; `COPY nginx.default.conf /etc/nginx/http.d/default.conf`; `COPY cronjobs /etc/cron.d/cronjobs`; `EXPOSE 80`; `ENTRYPOINT ["dumb-init", "--"]`; `CMD ["/var/www/html/startup.sh"]`; no USER (runs as root), no VOLUME, no ARG, no ENV. |
| Upstream startup script reviewed | `startup.sh` at tag v5.11.2 (gh api): env `PUID` (default 82) and `PGID` (default 82) remap www-data; `chown -R www-data:www-data /var/www/html /tmp`; IPv4-only fallback via sed when IPv6 absent; starts `php-fpm -F`, `crond -f`, `nginx -g 'daemon off;'`; runs `/usr/local/bin/php .../createdatabase.php` and `.../db/migrate.php`; chowns `db/` and `images/uploads/logos`; runs `updatenextpayment.php`, `updateexchange.php`, `checkforupdates.php` once (timeout 300). |
| Cron jobs reviewed | `cronjobs` at tag v5.11.2 (gh api): 12 entries under `endpoints/cronjobs/*.php`, logs to `/var/log/cron/`. |
| Env vars (real) | `PUID`, `PGID` (startup.sh). No other env read by the Dockerfile. |
| Ports | 80/tcp (HTTP, `EXPOSE 80`). Healthcheck `curl http://127.0.0.1/health.php`. |
| Data paths | SQLite DB in `/var/www/html/db/`; logo/avatar uploads in `/var/www/html/images/uploads/logos`; logs `/var/log/cron`, `/var/log/startup.log`; `/tmp` (chowned by startup). |
| PHP on Ubuntu 26.04 (resolute) | `php-fpm` 2:8.5+99ubuntu1 (PHP 8.5), https://packages.ubuntu.com/resolute/php-fpm. `php8.3-fpm` is NOT in resolute ("Package not available in this suite", https://packages.ubuntu.com/resolute/php8.3-fpm). Upstream is PHP 8.3: version gap. |
| Dependencies | None (embedded SQLite). |

## 2. Target layout

- `apps/wallos/Dockerfile`
- `apps/wallos/docker-bake.hcl`
- `apps/wallos/settings.yaml`
- `apps/wallos/container-test.yaml`
- `apps/wallos/start.sh` (replaces upstream `startup.sh`; seeds and runs nginx, php-fpm and cron)
- `apps/wallos/etc/` for nginx and php-fpm config (`etc/` is allow-listed; needed because the upstream nginx.conf and php-fpm pool must be shipped); `apps/wallos/etc/nginx/...` and `apps/wallos/etc/php/.../pool.d/www.conf` with the reason: the upstream config writes to `/var/log` and listens on privileged port 80.

No `root/` (never used). No `DOWNSTREAM_CHANGES.md` (not a FROM base). Upstream app code is pulled into the image from the tag, under `/app/wallos` (read-only), with `/var/www/html` symlinked to it or the app configured to use `/app/wallos` directly.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. No PHP runtime sibling exists, so PHP is installed from the 26.04 archive. Closest sibling for a PHP app: `apps/bookstack` (PHP stack) and `apps/nextcloud-fpm` (php-fpm). The `apps/nginx` runtime image (`ghcr.io/trueforge-org/nginx:1.28.3`) is an alternative (draft) but the PHP install would still be needed; choose one base in the PR.

## 4. Dockerfile

1. `FROM <ubuntu> AS build`: `ARG VERSION=5.11.3`; fetch `https://github.com/ellite/Wallos/archive/refs/tags/v${VERSION}.tar.gz` into `/tmp/src` with `curl -fL`, verify sha256 recorded at build time (no upstream checksum). Extract with `tar -xz --strip-components=1`.
2. Final stage `FROM <ubuntu>` (separate from the build stage, which only fetches the source): `USER root`, then `apt-get install -y --no-install-recommends php8.5-fpm php8.5-cli php8.5-sqlite3 php8.5-curl php8.5-gd php8.5-xml php8.5-mbstring php8.5-zip php8.5-intl nginx cron` (PHP 8.5 is the 26.04 version; 8.3 is not available, see section 10). Pin versions and check against the Wallos release notes (UNVERIFIED: whether Wallos 5.11.3 supports PHP 8.5).
3. Copy the app to `/app/wallos` (read-only at runtime): `COPY --from=build /tmp/src /app/wallos`, then `chmod -R a=rX /app/wallos` (no runtime writes).
4. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/wallos/LICENSE`.
5. `ENV HOME=/tmp` (cron and PHP sessions use `/tmp`).
6. `COPY --chmod=0755 . /` then `USER apps`.
7. `EXPOSE 8080` (non-root cannot bind port 80; see section 9) and `VOLUME /config`.

Key note: upstream writes to `/var/www/html/db` and `images/uploads/logos`. Those paths must be redirected to `/config` (symlinks or `DB_PATH`-style config, whichever the app supports; the app's own path config is UNVERIFIED: read `includes/` in the tag before choosing).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "wallos"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ellite/Wallos versioning=semver
  default = "5.11.3"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/ellite/Wallos"
}

group "default" {
  targets = ["image-local"]
}
```

Then the four standard targets from `apps/adguardhome-sync`, with `image-all` platforms `linux/amd64` and `linux/arm64`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ellite/Wallos"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 8080 follows the section 9 recommendation (a non-root user cannot bind 80): `EXPOSE`, the nginx `listen`, `settings.yaml` and `container-test.yaml` must all say 8080. `PUID`/`PGID` (upstream, defaults 82) are dropped: the image user `apps` is fixed and `start.sh` runs unprivileged, so they cannot remap users.

## 7. start.sh

- `set -euo pipefail`; `DATA=/config`; `mkdir -p "$DATA/db" "$DATA/uploads/logos/avatars" /tmp/nginx /tmp/php`.
- Seed nothing into `/config` except missing directories; do not overwrite an existing `db/wallos.db` (the upstream `createdatabase.php` creates it only if absent, keep that behavior).
- Point the app's DB and uploads at `/config` (through symlink or config, chosen in section 4).
- Start, as the `apps` user, in this order: `php-fpm -F -y /etc/php/.../php-fpm.conf` in background; `crond -f` (only if the cron jobs must run; cron needs root and writes `/var/log`, so decide whether to drop cron, since the cron jobs are also reachable as `endpoints/cronjobs` on demand; UNVERIFIED which is supported non-root); `nginx -g 'daemon off;'` in background.
- Run the one-time migrations (`createdatabase.php`, `db/migrate.php`) before starting nginx to avoid serving an empty DB.
- Trap SIGTERM and stop nginx (`nginx -s quit`), php-fpm (`kill -QUIT`) and cron, then `wait`. Use `exec` only if a single process is the main one; for multi-process use the trap and `wait` (the process model is the documented exception).
- No writes to `/app`. Logs to `/tmp` or stdout.

## 8. container-test.yaml

Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json`

- `http` probe on port 8080, path `/` or `/health.php` (health.php exists upstream; verify it is served without login).
- `tcp` probe on 8080.
- `filePaths`: `/start.sh`, `/app/wallos/index.php` (confirm the entry file name in the tag).
- `timeoutSeconds`: from a PHP sibling (`apps/bookstack` or `apps/nextcloud-fpm`; value UNVERIFIED).
- Test runs with no env vars: the default path (no PUID/PGID) is the one tested.

## 9. Rootless and read-only-rootfs adaptations

- Upstream: runs as root (no USER), `runAsNonRoot: false`, `readOnlyRootFilesystem: false`, privileged unset (false), extra persistence `/var/www/html/db` and `/var/www/html/images/uploads/logos` (chart paths). Expectations to verify, not guarantees.
- Port 80 under `USER apps` needs `CAP_NET_BIND_SERVICE` or a port above 1024. Decision for the PR: (a) keep port 80 and grant the capability (not allowed by default in ContainerForge: check siblings such as `apps/nginx` for how they handle it), or (b) use port 8080 (`EXPOSE 8080`, nginx `listen 8080`, `settings.yaml` port 8080, probe 8080). This plan uses (b) 8080 (a sibling precedent for (a) is UNVERIFIED).
- Writable paths: `/config` (DB, uploads, logs) and `/tmp` (nginx temp, php sessions, cron scratch). Nothing else.
- Read-only rootfs: `nginx` and `php-fpm` need `/tmp` for temp files; `/var/log` writes must go to stdout or `/tmp`.
- PUID/PGID: the upstream remaps www-data. In ContainerForge the user is `apps`; the vars are dropped (section 6).

## 10. Risks, caveats and open questions

- PHP version gap: upstream uses PHP 8.3; 26.04 ships PHP 8.5 and has no `php8.3-fpm` in its archive. Running 8.5 is untested with Wallos 5.11.3. Either test PHP 8.5, or add an external PHP 8.3 source (UNVERIFIED availability and supply chain). This is the main open question.
- Multiple services in one container (nginx, php-fpm, cron): a crash in one can go unnoticed (the trap and `wait` must surface failures, and the healthcheck must test the app, not only the port).
- SQLite and uploads must be writable by the web user; the first account is created through the UI.
- Port 80 under non-root (section 9).
- Blockers: PHP version (above) and port 80 (above). No musl base.

## 11. Build and test steps

```sh
cd apps/wallos
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name wallos-probe --read-only --tmpfs /tmp \
  -v wallos-probe-config:/config wallos:5.11.3
docker logs -f wallos-probe
docker rm -f wallos-probe; docker volume rm wallos-probe-config
forgetool containers test --image wallos:5.11.3 --config ./apps/wallos/container-test.yaml
```

Expected readiness signal: nginx and php-fpm both report started, the migrations finish without error, and the HTTP probe returns a 200 or 302 (wording UNVERIFIED until a real run). Empty `/config` must be tested each round.

## 12. PR checklist

- Branch `feat/add-wallos`; commit `feat(wallos): add new container`; target `main`.
- PR title matches the commit; PR template kept with its sections and checkboxes.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what is untested: PHP 8.5 with Wallos, the port decision, arm64 (not built), and the cron behaviour non-root.
