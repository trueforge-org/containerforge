# anonaddy — implementation plan
> Source: ./draft.md · Target: apps/anonaddy/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `1.7.4` (tag `v1.7.4` on `anonaddy/anonaddy`, latest release; wrapper `anonaddy/docker` latest tag `1.7.4-r0`; its Dockerfile has `ARG ANONADDY_VERSION=1.7.4`). Matches the draft. |
| Renovate | `datasource=github-releases`, `depName=anonaddy/anonaddy`, `versioning=semver` (tag has `v` prefix; strip it in the Dockerfile URL as `v${VERSION}`). |
| License | `AGPL-3.0-or-later` (`composer.json` in `v1.7.4` has `"license": "AGPL-3.0-or-later"`; `LICENSE` is GNU AGPL v3). The wrapper `anonaddy/docker` is MIT (CrazyMax), not part of our image. |
| Source URL | https://github.com/anonaddy/anonaddy (docs https://addy.io/help/) |
| Downloads | Source only, no prebuilt binary: `https://github.com/anonaddy/anonaddy/archive/refs/tags/v${VERSION}.tar.gz` (arch independent, interpreted PHP). Needs `composer install --no-dev` and a frontend build (`npm ci` + `npm run production`, which runs `vite build`). |
| Checksum | None published for the source archive. Pin by the git tag; the tag object is `90398246...` and peels to commit `0315a78015ae8a0f0f5fbeccf1d53bae7b3d27cc` (from `git ls-remote`), which can be verified after `git fetch --depth 1`. |
| Requirements | `composer.json`: `php ^8.3`. Upstream image uses PHP 8.4 (Alpine `php84`) with extensions ctype curl dom fileinfo fpm gd gmp iconv intl json mbstring opcache openssl pcntl pdo pdo_mysql phar redis session simplexml sodium tokenizer xml xmlreader xmlwriter zip zlib, plus PECL `gnupg`, `mailparse`, `imagick`. |
| Upstream Dockerfile reviewed | `anonaddy/docker/Dockerfile` at the draft commit (`crazymax/alpine-s6`, `EXPOSE 25 8000 11334`, `VOLUME /data`). Services are s6-managed: nginx, php-fpm, cron, postfix, rspamd. The draft's mention of dovecot and ports 587/143 is NOT in this image (no dovecot, no IMAP). |
| Ports | `8000` HTTP (nginx), `25` SMTP (postfix), `11334` rspamd web UI. Draft ports 80/587/143 are not what upstream exposes. |
| Real env vars | From the wrapper README: `APP_KEY` (required), `APP_URL`, `APP_NAME`, `APP_DEBUG`, `ANONADDY_DOMAIN` (required), `ANONADDY_HOSTNAME`, `ANONADDY_SECRET` (required), `ANONADDY_ENABLE_REGISTRATION`, `ANONADDY_ADMIN_USERNAME`, `ANONADDY_LIMIT`, `ANONADDY_RETURN_PATH`, `ANONADDY_ALL_DOMAINS`, `ANONADDY_DNS_RESOLVER`, `ANONADDY_SIGNING_KEY_FINGERPRINT`, `ANONADDY_DKIM_SIGNING_KEY`, `ANONADDY_DKIM_SELECTOR`, `DB_HOST` (required), `DB_PORT` (3306), `DB_DATABASE` (anonaddy), `DB_USERNAME` (anonaddy), `DB_PASSWORD`, `DB_TIMEOUT` (60), `REDIS_HOST`, `REDIS_PORT` (6379), `REDIS_PASSWORD`, `QUEUE_CONNECTION` (sync or redis), `MAIL_FROM_NAME`, `MAIL_FROM_ADDRESS`, `MAIL_ENCRYPTION`, `MEMORY_LIMIT` (256M), `UPLOAD_MAX_SIZE` (16M), `OPCACHE_MEM_SIZE`, `TZ`, plus `POSTFIX_*` and `RSPAMD_*` (postfix/rspamd only). |

## 2. Target layout

```
apps/anonaddy/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/nginx/anonaddy.conf.template      # nginx server on 8000, fastcgi to a unix socket in /tmp
  etc/php/php-local.ini                 # memory_limit, upload sizes, opcache (copied into /usr/local/etc? see section 4)
```

- `etc/` is on the `.dockerignore` allow-list. No `root/`. No `DOWNSTREAM_CHANGES.md`.
- Scope decision (see section 10): this plan covers the web app, the scheduler and the queue worker. Postfix and rspamd are NOT in this image.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

PHP comes from apt (as in `apps/bookstack`, which uses `php8.5-*` packages on this base). Closest sibling: `apps/bookstack` (Laravel, composer, MariaDB, queue worker). There is no `node` app, so the frontend build uses an ubuntu build stage with apt `nodejs npm`.

## 4. Dockerfile

Two stages.

1. Stage `build` (same ubuntu base, `USER root`): `apt-get install -y --no-install-recommends git composer nodejs npm php8.5-cli php8.5-xml php8.5-mbstring php8.5-curl php8.5-gd php8.5-zip php8.5-intl php8.5-gmp php8.5-mysql php8.5-redis php8.5-imagick php8.5-gnupg php8.5-mailparse` (names of the last four are UNVERIFIED on ubuntu 26.04; if absent, build via `pecl`). Fetch `https://github.com/anonaddy/anonaddy/archive/refs/tags/v${VERSION}.tar.gz` into `/build`, run `composer install --no-dev --optimize-autoloader --no-interaction`, then `npm ci --ignore-scripts --no-audit --no-fund && npm run production` (upstream sets `APP_URL=https://addy-sh.test` for the build). Set `COMPOSER_HOME=/tmp/composer`, `npm_config_cache=/tmp/npm`. Check that Node on 26.04 satisfies `package.json` (UNVERIFIED) and that the composer lock accepts PHP 8.5 (upstream tests on 8.4; fall back to `--ignore-platform-req=php` only if a smoke test passes).
2. Final stage: `ARG VERSION`, `USER root`, install runtime packages not already in the base: `nginx`, `php8.5-fpm`, `php8.5-cli` and the same extensions (no composer/node/git), `mariadb-client` is optional (only for a DB wait; `nc` from the base can do it, as in bookstack). Pin per `dockerfile.instructions.md`: PHP and nginx are not the tagged software, so only the app version needs alignment; `ARG VERSION` must equal the bake default.
3. `COPY --from=build /build /app/www`, remove `.git`, `tests`, `node_modules`. Ship `LICENSE` to `/usr/share/licenses/anonaddy/` (the full tree is copied, so also keep `/app/www/LICENSE`).
4. Make runtime writes point elsewhere: replace `/app/www/storage` and `/app/www/bootstrap/cache` with symlinks to `/config/storage` and `/tmp/bootstrap-cache`, and `/app/www/.env` to `/config/.env` (same approach as `apps/bookstack`).
5. PHP-FPM: `clear_env = no` and the pool as the `apps` user on a unix socket `/tmp/php-fpm.sock`, `pid = /tmp/php-fpm.pid`, `error_log = /proc/self/fd/2` via a pool/ini file copied from `etc/`.
6. `ENV HOME=/tmp COMPOSER_HOME=/tmp/composer`, `chown -R apps:apps /app`, clean apt lists and `/tmp/*`, `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8000`, `VOLUME /config`, `WORKDIR /app/www`.

## 5. docker-bake.hcl

- `APP = "anonaddy"`, `LICENSE = "AGPL-3.0-or-later"`, `SOURCE = "https://github.com/anonaddy/anonaddy/"`.
- `VERSION` default `"1.7.4"` preceded by `// renovate: datasource=github-releases depName=anonaddy/anonaddy versioning=semver`.
- `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 + arm64: pure PHP and Debian packages, no vendor binary), group `default`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/anonaddy/anonaddy/"
ports:
  - {port: 8000, protocol: tcp, required: false}
env:        # all names verified in anonaddy/docker README; defaults match start.sh
  - {name: TZ, default: "Etc/UTC", required: false}
  - {name: APP_KEY, default: "", required: true}
  - {name: APP_URL, default: "http://localhost:8000", required: false}
  - {name: ANONADDY_DOMAIN, default: "", required: true}
  - {name: ANONADDY_SECRET, default: "", required: true}
  - {name: ANONADDY_ENABLE_REGISTRATION, default: "true", required: false}
  - {name: DB_HOST, default: "", required: true}
  - {name: DB_PORT, default: "3306", required: false}
  - {name: DB_DATABASE, default: "anonaddy", required: false}
  - {name: DB_USERNAME, default: "anonaddy", required: false}
  - {name: DB_PASSWORD, default: "", required: false}
  - {name: QUEUE_CONNECTION, default: "sync", required: false}
  - {name: REDIS_HOST, default: "", required: false}
  - {name: REDIS_PORT, default: "6379", required: false}
volumes:
  - {path: /config, required: true}
dependencies:
  - name: mariadb      # ✅ apps/mariadb exists
opt_dependencies:
  - name: valkey       # ✅ apps/valkey exists
```

Write it in the same list style as `apps/bookstack/settings.yaml`. Rule: `required: true` vars need a non-empty default or generation in `start.sh`; `APP_KEY` and `ANONADDY_SECRET` are therefore generated into `/config/.env` when missing (see section 7), so the empty default is acceptable. `DB_HOST` has no safe default, so `start.sh` must not crash on it (section 7, no-DB path). Port 25 is not listed: this image does not run postfix.

## 7. start.sh

1. `mkdir -p /config/storage/{app,framework/{cache,sessions,views},logs} /tmp/bootstrap-cache /tmp/nginx /tmp/php`.
2. Seed `/config/.env` only if missing: copy `/app/www/.env.example`. Then apply env vars into it every start without printing them (use a `sed`/`php` helper that escapes values; keep `DB_PASSWORD` and keys out of the process list by never passing them as arguments). Generate `APP_KEY` (`php artisan key:generate --show` equivalent: `base64:$(openssl rand -base64 32)`) and `ANONADDY_SECRET` (random) once, only when empty, and persist them in `/config/.env` so restarts keep them.
3. Wait for the database like `bookstack`: loop up to `DB_TIMEOUT` (default 60) on `nc -w1 $DB_HOST $DB_PORT` when `DB_HOST` is set. If `DB_HOST` is empty, log a warning and still start nginx/php-fpm (so the container stays alive and tests pass), skipping migrations.
4. When the DB is reachable: `php artisan migrate --force` (idempotent). Do not run `config:cache`, because `.env` is rewritten on each start.
5. Render the nginx config from `/etc/nginx/anonaddy.conf.template` into `/tmp/nginx/nginx.conf`: `listen 0.0.0.0:8000`, `pid /tmp/nginx/nginx.pid`, every `*_temp_path` under `/tmp/nginx`, fastcgi to `unix:/tmp/php-fpm.sock`, `error_log /dev/stderr`, `access_log /dev/stdout`, root `/app/www/public`.
6. Start in the background: `php-fpm8.5 -F -y /tmp/php/php-fpm.conf`, `nginx -c /tmp/nginx/nginx.conf -g 'daemon off;'`, a scheduler loop (`while sleep 60; do php artisan schedule:run; done`, replacing upstream's crond) and, when `QUEUE_CONNECTION=redis`, `php artisan queue:work --sleep=3 --tries=3`. 
7. nginx binds `0.0.0.0:8000` and php-fpm uses the unix socket. Make nginx the `exec`'d foreground process (`exec nginx -c /tmp/nginx/nginx.conf -g 'daemon off;'`) so signals reach it, and keep php-fpm, the scheduler and the queue worker as background children started earlier. Because a dead php-fpm would otherwise go unnoticed, add a small background watcher that kills PID 1 when php-fpm exits.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires external mariadb; full functional test not feasible in single-container suite
timeoutSeconds: 240
tcp:
- port: '8000'
filePaths:
- /app/www/artisan
- /app/www/public/index.php
- /usr/share/licenses/anonaddy/LICENSE
```

- `timeoutSeconds: 240` copies the PHP sibling `apps/bookstack`.
- Narrowing is justified only if all three exception criteria hold: hard `dependencies: mariadb` (yes), will not serve properly without it (the app 500s without a DB, though nginx stays up), and a sidecar DB cannot be wired in `container-test.yaml` (UNVERIFIED; check the forgetool schema for a services/sidecar field before accepting the exception). If a sidecar is possible, write a functional HTTP probe instead.
- The test runs with no env, so `APP_KEY`-dependent paths are only covered by the `filePaths` entries; the generation logic in section 7 must be run by hand (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (wrapper volume: `.env`, storage, DKIM, GPG keyring, mail spool) | `/config` (`.env`, `storage/`, `dkim/`, `gnupg/`); the chart used `/data`, so volumes need remounting. Set `GNUPGHOME=/config/gnupg`. |
| `/var/www/anonaddy/storage`, `bootstrap/cache` | symlinks to `/config/storage` and `/tmp/bootstrap-cache`. |
| nginx pid/logs/temp (`/var/lib/nginx`, `/var/log/nginx`, `/run`) | `/tmp/nginx`, stdout/stderr. |
| php-fpm socket/pid/log | `/tmp`. |
| postfix queue/spool under `/var/spool/postfix`, rspamd state | Not applicable: postfix and rspamd are out of this image. |
| Ports 25/587/143, `runAsUser: 0`, s6 init | Port 8000 is unprivileged. Mail ports are not bound here. No s6, no root. |

Draft security expectations reconciled: UID 1000 non-root and read-only rootfs both hold for the web tier. The "extra persistence: mail spool" expectation belongs to the postfix tier.

## 10. Risks, caveats and open questions

- Blocker for a single all-in-one image: postfix's master process must run as root and bind port 25, which conflicts with `USER apps` and rootless. Proposal: a separate follow-up app (`anonaddy-postfix` or reuse a generic postfix image) that pipes mail to this image's `artisan anonaddy:receive-email` (UNVERIFIED how the wrapper wires this; read the postfix config under `rootfs/` of `anonaddy/docker` first). Without it the app is a working UI with no mail delivery. Get maintainer agreement on this split before building.
- The draft's dovecot/IMAP/587 expectations are wrong for this upstream.
- Email services need public DNS (MX, SPF, DKIM, DMARC) and port 25 reachable (draft caveat).
- PHP 8.5 vs upstream-tested 8.4: composer dependencies may not support 8.5 (UNVERIFIED).
- `gnupg`, `mailparse`, `imagick` PHP extensions availability from apt on 26.04 is UNVERIFIED.
- The frontend build needs Node; Node version compatibility UNVERIFIED.
- First-run: registering a user, admin username and DKIM keys are manual steps; document in the PR.
- Hard dependency on `mariadb` ✅ and optional `valkey` ✅ (both exist in `apps/`).

## 11. Build and test steps

Run from the repo root, one app only, in this order (per `build-test-protocol.instructions.md`):

```sh
cd apps/anonaddy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name anonaddy-probe --read-only --tmpfs /tmp \
  -v anonaddy-probe-config:/config anonaddy:1.7.4
docker logs -f anonaddy-probe       # expect nginx "start worker process", php-fpm "ready to handle connections", a "DB_HOST not set, skipping migrations" warning; no fatal errors, container still running
cd ../.. && forgetool containers test --image anonaddy:1.7.4 --config ./apps/anonaddy/container-test.yaml
docker rm -f anonaddy-probe; docker volume rm anonaddy-probe-config
```

- Because the DB path is not covered by the tests, also run once on a user network with `apps/mariadb` (and `apps/valkey` with `QUEUE_CONNECTION=redis`), set `DB_HOST`, `DB_PASSWORD`, `ANONADDY_DOMAIN`, and confirm migrations run and `curl http://<ip>:8000/` returns the login page from another container.
- Restart the container with the same `/config` volume and confirm `APP_KEY` is unchanged.
- Fresh volume per round; round limit 10.

## 12. PR checklist

- [ ] Branch `feat/add-anonaddy`, commit and PR title `feat(anonaddy): add new container`, target `main`.
- [ ] PR body uses `.github/PULL_REQUEST_TEMPLATE.md`; only tick boxes that apply.
- [ ] Notes section contains `🤖 This PR is AI generated.` and states that postfix/rspamd are intentionally out of scope.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- [ ] `docker buildx bake --print` passes; `ARG VERSION` equals the bake default; final `USER apps`; `COPY --chmod=0755 . /` kept.
- [ ] Untested at plan time: build, PHP 8.5 compatibility, PHP extension package names, the Node build, migrations against mariadb, queue with valkey, arm64, mail delivery.
- [ ] No files outside `apps/anonaddy/`; no `root/`; no secrets.
