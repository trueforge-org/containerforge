# awesometic/docker-h5ai (upstream Docker wrapper, DEPRECATED)

**Source URL(s):** https://github.com/awesometic/docker-h5ai/blob/master/Dockerfile (fetched via https://raw.githubusercontent.com/awesometic/docker-h5ai/master/Dockerfile)
**Fetched:** 2026-11-26

## Status
Deprecated: the image receives no further updates, security fixes included. The maintainer points users to `awesometic/h5ai-ng` (https://hub.docker.com/r/awesometic/h5ai-ng, source https://github.com/awesometic/h5ai-ng). The plan.md described this repo as archived; the Docker Hub page says deprecated.

## What it is
A lightweight h5ai 0.30.0 container on Alpine 3.24 with nginx 1.30.6 and PHP 8.5.12+, managed by supervisor.

## Base and build
- `FROM` nginx 1.30.6 Alpine 3.24 image.
- ARG: none. Labels: maintainer and description (names omitted).
- Packages (apk, no cache): bash, bash-completion, supervisor, tzdata, shadow, logrotate; PHP 8.5 (8.5.12+): fpm, session, json, xml, mbstring, exif, intl, gd, pecl-imagick, zip; ffmpeg, imagemagick, zip, apache2-utils, patch.

## Config files copied
- `config/h5ai.conf` to `/etc/nginx/conf.d/h5ai.conf`
- PHP ini to `/etc/php85/conf.d/`: `00_timezone.ini`, `00_jit.ini`, `00_memlimit.ini`
- `config/supervisord.conf` to `/etc/supervisor/conf.d/supervisord.conf` (contents not in the Dockerfile)
- `config/logs.sh` to `/usr/local/bin/h5ai-logs` (0755)
- `config/_h5ai` directory to `/usr/share/h5ai/_h5ai`
- `ADD config/init.sh /` and `ADD config/h5ai.conf.htpasswd.patch /`

## Nginx tweaks
- `worker_processes` changed from 1 to `auto` (sed; .bak kept).
- `conf.d/default.conf` renamed to `default.conf.bak`.

## Runtime
- `/init.sh` made executable; `ENTRYPOINT ["/init.sh"]`. No CMD, no USER.
- `EXPOSE 80`
- `VOLUME /config` and `VOLUME /h5ai`.

## Env vars (defaults, from Dockerfile)
| Var | Default |
| --- | --- |
| PUID | 911 |
| PGID | 911 |
| TZ | Asia/Seoul |
| HTPASSWD | false |
| HTPASSWD_USER | guest |
| HTPASSWD_PW | (empty) |

Docker Hub documents also `LOG_ROTATE_INTERVAL_DAYS` (default 1), `LOG_RETENTION_DAYS` (default 30), `LOG_READ_GID` (default PGID). Log day values are 1 to 36500; retention >= rotation interval. These are wrapper features, not h5ai.

## Gotchas for our build
- The PUID/PGID/HTPASSWD wrapper is not needed; plan.md chooses rootless `apps` (568) and no PUID handling.
- Supervisor manages nginx and php-fpm here; plan.md uses a plain shell start with `wait -n`.
- PHP 8.5 path in this image is `/etc/php85` (Alpine). Ubuntu paths differ (`/etc/php/8.5/`).
- The image runs as root (no USER); `init.sh` is not fetched and not summarised.
