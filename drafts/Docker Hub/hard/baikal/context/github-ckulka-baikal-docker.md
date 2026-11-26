# ckulka/baikal-docker (upstream Docker wrapper, nginx variant)

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/ckulka/baikal-docker/06c53989a648198501cce322bd200221a5e1e136/nginx.dockerfile (pinned SHA from draft/plan) · fetched 2026-11-26

## What it is
Unofficial Docker build of Baikal, nginx variant (`ckulka/baikal:<ver>-nginx`).

## Install/build steps and build deps
- Stage 1 (builder): `FROM alpine`, `ENV VERSION=0.10.1`; downloads the Baikal release zip from `https://github.com/sabre-io/Baikal/releases/download/${VERSION}/...` (note: the wrapper pins VERSION 0.10.1 in its own Dockerfile); `apk add unzip`, extract.
- Stage 2 (final): `FROM nginx:1`.
- One RUN: fetches the Sury PHP signing key into `/etc/apt/trusted.gpg.d/php.gpg`; adds `packages.sury.org/php` repo (via temporary `lsb-release`); installs `php8.1-curl php8.1-fpm php8.1-mbstring php8.1-mysql php8.1-pgsql php8.1-sqlite3 php8.1-xml sqlite3 msmtp msmtp-mta`; removes apt lists; edits `/etc/php/8.1/fpm/pool.d/www.conf` with sed: user `www-data` -> `nginx`, listen -> `/var/run/php-fpm.sock`.
- COPY `files/docker-entrypoint.d/*.sh`, `*.php` and `nginx/` contents to `/docker-entrypoint.d/`; `baikal` directory from builder to `/var/www/baikal` (owner nginx:nginx); `files/nginx.conf` to `/etc/nginx/conf.d/default.conf`.

## Runtime deps
PHP 8.1 (from Sury), php-fpm, nginx, sqlite3, msmtp. Note: Baikal 0.13.0 composer.json requires `php ^8.2` (see github-sabre-io-baikal.md), so the PHP 8.1 wrapper cannot run 0.13.0 as-is.

## Binaries/entrypoint/CLI flags
No ENTRYPOINT/CMD in the file; inherited from `nginx:1` base (which runs `/docker-entrypoint.sh`, running `/docker-entrypoint.d/` scripts).

## Env vars
Not declared in the Dockerfile. Chart sets `BAIKAL_SKIP_CHOWN: false`. Plan.md: the entrypoint.d script chowns files unless `BAIKAL_SKIP_CHOWN` is set (per plan, not fetched script).

## Ports
No EXPOSE. nginx listens on 80 (`files/nginx.conf`, per plan; base image default).

## Volumes/paths and persistent data
`VOLUME`-like declared paths: `/var/www/baikal/config` and `/var/www/baikal/Specific` (per README/plan; the Dockerfile fetched shows them as volumes).

## User/UID & permissions
nginx and php-fpm run as `nginx` user. Pool user changed from `www-data` to `nginx`.

## Config files and formats
`files/nginx.conf` (-> `/etc/nginx/conf.d/default.conf`); PHP pool `www.conf`.

## Healthcheck/readiness endpoints
None in fetched Dockerfile.

## Version/release info
Wrapper variants by tag: `0.10.1-nginx`, `0.10.1`, `0.10.1-apache`, `0.10.1-php8.2`, `0.10.1-nginx-php8.2`, and older. The draft and chart use `0.10.1-nginx`.

## Arch support
Per Docker Hub: amd64, arm32v7, arm64v8, i386 (see dockerhub summary).

## Gotchas
- Wrapper pins Baikal 0.10.1 and PHP 8.1; upstream Baikal 0.13.0 needs PHP ^8.2.
- Sury PHP repo is a third-party apt source.
- The Sury/`php8.1` packages are not in ubuntu 26.04; the port must use the base's PHP packages.

## Contradictions with plan.md
- plan.md section 1 says "nginx base, PHP 8.1 from Sury, pool user nginx, socket /var/run/php-fpm.sock, volumes ..., entrypoint.d script chowns files, no EXPOSE, env BAIKAL_SKIP_CHOWN": all confirmed.
