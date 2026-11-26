# Forceu/barcodebuddy-docker (upstream Docker build)

**Source URL(s) + fetch date:** https://github.com/Forceu/barcodebuddy-docker/blob/527c3c637a39298fb0b5ab57cf532bbdc2aa54b5/Dockerfile (fetched raw at that SHA) · fetched 2026-11-26

## What it is
Docker build for Barcode Buddy: two stages. Go-built `supervisor` binary, then alpine:3.24 with nginx, PHP 8.5 FPM, redis, and the BarcodeBuddy app.

## Install/build steps and build deps
- Stage `build_base`: `FROM golang:1.27-alpine`; `CGO_ENABLED=0 go build -o /compile/supervisor` from `supervisor/`.
- Final: `FROM alpine:3.24`; `apk add ca-certificates curl`; `mkdir /app`, `touch /app/.isdocker`; `mkdir /app /config /defaults`; `COPY root/ /`.
- apk (no-cache): apache2-utils, bash, ca-certificates, coreutils, curl, evtest, nano, nginx, openssl, php85, php85-curl, php85-fileinfo, php85-fpm, php85-gettext, php85-json, php85-mbstring, php85-openssl, php85-pdo, php85-pdo_sqlite, php85-redis, php85-session, php85-simplexml, php85-sockets, php85-sqlite3, php85-xml, php85-xmlwriter, php85-zlib, procps, redis, screen, shadow, sudo, tzdata.
- nginx: appends `fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;` to `/etc/nginx/fastcgi_params`; removes `/etc/nginx/conf.d/default.conf`.
- `useradd -d /config -s /bin/false barcodebuddy`; chown `/var/log/php85`, `/app` to barcodebuddy; `ln -s /usr/bin/php85 /usr/bin/php8`; `ln -s /config /data`.
- App install: build args `BBUDDY_REF` (default empty = latest tag via `git ls-remote --tags --sort=-v:refname`); git shallow fetch of the ref into `/app/bbuddy`; `.git` removed; `build-deps` git removed after.
- Sed edits: `config-dist.php` `IS_DOCKER = true`; `example/grabInput.sh` `SCRIPT_LOCATION="/app/bbuddy/index.php"`, `WWW_USER="barcodebuddy"`, `IS_DOCKER=true`; `/etc/php85/php-fpm.d/www.conf` `pm.max_children = 20` (upstream comment: needed for websockets/SSE); `incl/db.inc.php` `DEFAULT_USE_REDIS = "1"`; `/etc/sudo.conf` `Set disable_coredump false` (sudo bug workaround).
- Labels: `build_version="BarcodeBuddy ${VERSION} Build ${BUILD_DATE}"`, maintainer Marc Ole Bulling.
- `COPY --from=build_base /compile/supervisor /app/supervisor`.

## Runtime deps
PHP 8.5 (php85 packages), nginx, redis, sqlite (php85-sqlite3 / pdo_sqlite), sudo, evtest (input grabber), screen, shadow.

## Binaries/entrypoint/CLI flags
- `CMD ["/app/supervisor"]`. No ENTRYPOINT, no USER.
- Supervisor manages services (per plan.md, `root/` not fetched): redis-server, php-fpm, nginx, wsserver, optional input grabber.

## Env vars
None declared. Build args only: `BUILD_DATE`, `VERSION`, `BBUDDY_REF`.

## Ports
`EXPOSE 80 443`.

## Volumes/paths and persistent data
`VOLUME /config`. `/data` is a symlink to `/config`. App in `/app/bbuddy`, supervisor at `/app/supervisor`.

## User/UID & permissions
Runtime services use the `barcodebuddy` user for app files; redis uses its own user. No USER directive in the image: supervisor runs as root (inferred from absent USER; not stated by sources).

## Config files and formats
`config-dist.php` (copied to config at runtime by root/ scripts, not fetched), `incl/db.inc.php`, `/etc/redis.conf`, `/etc/nginx/nginx.conf`, `/etc/php85/php-fpm.d/www.conf`.

## Healthcheck/readiness endpoints
None in Dockerfile.

## Version/release info and asset naming
- Latest tag used when `BBUDDY_REF` empty: `git ls-remote --tags --refs --sort=-v:refname`.
- Source tag `v${VERSION}`; release v1.9.0.1 (see github-forceu-barcodebuddy.md).

## Arch support
Not stated in Dockerfile.

## Gotchas
- Dockerfile pins the app ref at build time from git, not from a tarball; plan.md chooses the tarball.
- `pm.max_children` must stay high for websockets/SSE (upstream comment).
- Upstream sudo workaround (coredump) is in the Dockerfile.

## Contradictions with plan.md
- plan.md section 1: "alpine 3.24 + php85, golang:1.27-alpine supervisor stage": confirmed.
- plan.md section 1: ports 80 and 443 exposed, `/config` volume with `/data` symlink: confirmed.
