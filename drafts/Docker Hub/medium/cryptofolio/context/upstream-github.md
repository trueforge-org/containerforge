# Xtrendence/Cryptofolio (upstream)

## Source URL(s) + date
- https://raw.githubusercontent.com/Xtrendence/cryptofolio/master/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/Xtrendence/cryptofolio/master/apache/000-default.conf
- https://raw.githubusercontent.com/Xtrendence/cryptofolio/master/apache/start-apache
- https://api.github.com/repos/Xtrendence/cryptofolio/releases/latest

## What it is
PHP web app (portfolio tracker) with JSON-file storage: `api/` backend + `website/` frontend. Android APK also shipped as a release asset (not relevant to container).

## Install/build steps (upstream Dockerfile)
- No build step. `FROM php:7.4-apache`.
- `COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf`
- `COPY apache/start-apache /usr/local/bin`
- `COPY api/ /var/www/html/api/`
- `COPY website/ /var/www/html/website/`

## Runtime deps
- PHP 7.4 + Apache (upstream image). No database.

## Entrypoint/flags
- `CMD ["start-apache"]`
- `start-apache` (bash):
  ```
  sed -i "s/Listen 80/Listen ${PORT:-80}/g" /etc/apache2/ports.conf
  sed -i "s/:80/:${PORT:-80}/g" /etc/apache2/sites-enabled/*
  chown -R www-data:www-data /var/www/html/
  apache2-foreground
  ```

## Env vars
| Var | Default | Read by |
| --- | --- | --- |
| PORT | 80 | start-apache (rewrites Apache Listen and vhost port) |

No `ENV` in upstream Dockerfile.

## Ports
- 80 (`EXPOSE 80`), configurable via `PORT`.

## Volumes/paths
- Web root: `/var/www/html/website/` (DocumentRoot).
- API alias: `/api/` -> `/var/www/html/api/`.
- No `VOLUME` declared upstream. Data is JSON under `api/data` (per plan; not verified here).

## Apache vhost (000-default.conf)
- `<VirtualHost *:80>`, DocumentRoot `/var/www/html/website/`, `Options Indexes FollowSymLinks`, `AllowOverride All`, `Require all granted`.
- `Alias /api/ "/var/www/html/api/"` with same options.

## User/UID
- Upstream: root (no USER). `start-apache` chowns `/var/www/html/` to `www-data`.

## Config files
- `/etc/apache2/ports.conf`, `/etc/apache2/sites-enabled/*` (edited at start for PORT).

## Healthcheck
- None upstream.

## Version/asset naming
- Latest release (API): tag `V.2.2`, published 2021-09-07, target `main`.
- Assets: `API-And-Website.zip` (1546680 bytes, holds `api/` and `website/`), `Cryptofolio-Android-Play-Store-V.2.2.1.apk` (binary, not used).
- Source zip: `https://github.com/Xtrendence/Cryptofolio/archive/refs/tags/V.2.2.zip` (per plan).

## Arch
- PHP source; no arch-specific code stated.

## Gotchas
- Upstream image is PHP 7.4 (EOL).
- Tag `V.2.2` has `V.` prefix (not semver).
- `start-apache` uses `apache2-foreground` and writes `/etc/apache2`, so it needs root at start unless Apache config paths are adapted for a non-root runtime.
- `start-apache` `sed` on `Listen 80` only matches the literal string.
