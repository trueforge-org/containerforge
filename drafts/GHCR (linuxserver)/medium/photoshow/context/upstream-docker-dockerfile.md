# Upstream: thibaud-rohmer/PhotoShow docker/Dockerfile (not used by linuxserver)

Source URL (fetched 2026-11-27, GitHub contents API, base64 decoded):
- https://api.github.com/repos/thibaud-rohmer/PhotoShow/contents/docker/Dockerfile

## Summary
- Upstream's own image: `FROM alpine:3.10.1`, maintainer CYOSP.
- Packages: ca-certificates, git, zip, nginx, php7-session, php7-fpm, php7-gd, php7-xml, php7-simplexml, php7-exif, gd-dev, supervisor, fbida-exiftran.
- Clones `thibaud-rohmer/PhotoShow.git` into `/var/www/PhotoShow`.
- Creates `www-data` (UID 33). `daemon off;` in nginx.conf. php-fpm `daemonize = no`.
- Paths: `/opt/PhotoShow/Photos` (photos_dir), `/opt/PhotoShow/generated` (ps_generated), chown www-data.
- ADD: nginx.conf -> `/etc/nginx/conf.d/photoshow.conf`, fpm.conf -> `/etc/php7/php-fpm.d/photoshow.conf`, supervisor.conf -> `/etc/supervisor.d/photoshow.ini`.
- VOLUME `/opt/PhotoShow`, `/var/log`. EXPOSE 80. CMD `/usr/bin/supervisord`.

## Gotchas
- Different layout from linuxserver (`/config`, `/Pictures`, `/Thumbs`, s6). Do not copy its paths.
