# linuxserver/docker-pixapop Dockerfile (pinned 932504b80918)

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-pixapop/932504b80918/Dockerfile (fetched 2026-11-27). Blob URL is the same file.

## What it is
PHP 7 + Composer + Yarn build of bierdok/pixapop, on the linuxserver nginx Alpine base.

## Base
- `FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.12`
- Labels: build_version (ARG VERSION, BUILD_DATE), maintainer "bierdok".

## Build args / env
- ARG: BUILD_DATE, VERSION, PIXAPOP_RELEASE (optional; if unset, taken from GitHub API `repos/bierdok/pixapop/releases/latest` tag_name).
- ENV: COMPOSER_ALLOW_SUPERUSER=1, COMPOSER_HOME=/tmp, APP_ENV=prod.

## Install steps
1. `apk add --virtual build-dependencies curl yarn`
2. `apk add imagemagick php7-curl php7-ctype php7-dom php7-exif php7-iconv php7-imagick php7-intl php7-phar`
3. Composer installer -> `/usr/local/bin/composer`; `composer global require hirak/prestissimo`.
4. Download `https://github.com/bierdok/pixapop/archive/${PIXAPOP_RELEASE}.tar.gz` -> `/var/www/html` (strip 1).
5. In /var/www/html: `composer install`, `yarn install`, `yarn build`.
6. `apk del build-dependencies`; rm `/root/.composer`, `/tmp/*`.
7. `COPY root/ /`.

## Entrypoint/flags
- No ENTRYPOINT/CMD in the Dockerfile (inherits from base s6 init).

## Ports
- `EXPOSE 80`

## Volumes/paths
- `VOLUME /config /photos`
- Web root: `/var/www/html`.

## Config files
- `root/` overlay (not fetched).

## Version/asset naming
- Source tarball: `bierdok/pixapop` archive by tag (`PIXAPOP_RELEASE`).
- Image tag scheme: `v1.2-lsNN` (ls15 pinned by chart; Hub lists ls61).

## Arch
- Image published for amd64, arm (v7), arm64 (v8). PHP/ImageMagick availability per arch is from the base image, not verified here.

## Gotchas
- Composer installer invoked with `--1`, which installs Composer 1.x (legacy, for PHP 7).
- Upstream repo bierdok/pixapop returned 404 (see github-bierdok-pixapop.md), so the tarball URL cannot be confirmed to resolve.
