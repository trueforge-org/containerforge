# TrueCharts chart: shaarli

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shaarli/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shaarli/values.yaml (fetched 2026-11-27)

## What it is
- Chart v11.0.1, appVersion 0.16.11. Category Productivity.
- "The personal, minimalist, super-fast, database free, bookmarking service."
- Sources: ghcr.io/shaarli/shaarli, github shaarli/Shaarli.
- Deps: common 32.8.5 (oci://oci.trueforge.org/truecharts)

## Image (values.yaml)
- `ghcr.io/shaarli/shaarli`, tag `v0.16.11@sha256:cbc8595e29a065754e2010c36e7126b1a2f634ec83be3c786602c0783d758e1f`, pullPolicy IfNotPresent

## Ports
| name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 8000 | 80 | tcp |

## Persistence
| name | mountPath |
| --- | --- |
| cache | /var/www/shaarli/cache |
| data | /var/www/shaarli/data |

## Security context (chart)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Upstream Dockerfile (Shaarli v0.16.11 tag)
Source URL: https://raw.githubusercontent.com/shaarli/Shaarli/v0.16.11/Dockerfile (fetched 2026-11-27)
- Multi-stage: `docs` (python:3-alpine, `make htmldoc`) -> `composer` (composer:latest, `composer install --no-dev`) -> `node` (node:22-alpine, corepack yarn@4.1.0, `yarnpkg install && yarnpkg run build`) -> final `alpine:3.24.3`.
- Final packages: ca-certificates, icu-data-full, nginx, php84 + ctype curl fpm gd gettext iconv intl json ldap mbstring openssl session xml simplexml zlib, s6.
- Copies: .docker/nginx.conf -> /etc/nginx/nginx.conf; .docker/php-fpm.conf -> /etc/php84/php-fpm.conf; .docker/services.d -> /etc/services.d; www.conf removed; php.ini post_max_size and upload_max_filesize set to 10M.
- WORKDIR /var/www; app at /var/www/shaarli; chown nginx:nginx.
- Logs symlinked to stdout/stderr (nginx access/error).
- VOLUME /var/www/shaarli/cache, /var/www/shaarli/data
- EXPOSE 80
- ENTRYPOINT `/usr/bin/s6-svscan /etc/services.d`; CMD []
- LABEL maintainer "Shaarli Community"

## Services (upstream .docker/services.d, v0.16.11)
- nginx service run: `nginx` (execline)
- php-fpm service run: `php-fpm84 -F`
- nginx.conf: user nginx nginx; listen 80 (IPv4 and IPv6); root /var/www/shaarli; fastcgi_pass unix:/var/run/php-fpm.sock

## Version/asset naming
- Git tags `vX.Y.Z`; chart pins v0.16.11.
- Latest release (GitHub redirect): v0.16.11. api releases/latest returned 403 (rate limit).

## License
- Upstream COPYING (raw v0.16.11): `Files: *`, License zlib/libpng.

## Gotchas
- No USER directive; nginx and php-fpm run as root/nginx under s6 (chart runs container as root).
- Nginx and php-fpm sockets under /var/run (needs writable /var/run in read-only rootfs).
- Upstream Dockerfile is at tag v0.16.11 (raw); the plan's blob link pins v0.16.10 (see README).
