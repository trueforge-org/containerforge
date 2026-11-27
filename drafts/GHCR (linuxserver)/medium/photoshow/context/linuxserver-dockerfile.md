# linuxserver/docker-photoshow Dockerfile

Source URL (fetched 2026-11-27, pinned commit):
- https://raw.githubusercontent.com/linuxserver/docker-photoshow/0cacdcb6c785/Dockerfile

## Base
- `FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.13` (tag only, no digest).

## ARG / ENV / LABEL
- ARG: `BUILD_DATE`, `VERSION`, `PHOTOSHOW_COMMIT` (resolved in RUN if unset).
- ENV: none.
- LABEL: `build_version`, `maintainer="sparklyballs"`.

## RUN (single layer)
1. `apk add --no-cache` curl, fbida-exiftran, ffmpeg, imagemagick, jq, php7-exif, php7-gd, php7-imagick, zip.
2. If `PHOTOSHOW_COMMIT` unset: `curl https://api.github.com/repos/thibaud-rohmer/PhotoShow/commits/master | jq -r .sha` -> `/version.txt`.
3. Appends to `/etc/php7/php-fpm.conf`: `[www]`, `php_admin_value[upload_max_filesize] = 10M`, `post_max_size = 10M`, `memory_limit = 64M`, `max_execution_time = 15`.
- No PhotoShow source is downloaded here; the clone happens at container start (see install script).

## Copy / runtime
- `COPY root/ /`
- `EXPOSE 80`
- `VOLUME /config /Thumbs /Pictures`
- No ENTRYPOINT, CMD, HEALTHCHECK, USER, WORKDIR (inherited from base).

## Gotchas
- Base is `baseimage-alpine-nginx` (not `baseimage-alpine`), PHP 7 via php-fpm.
- Source clone and config happen at runtime in `root/etc/cont-init.d/40-install`.
