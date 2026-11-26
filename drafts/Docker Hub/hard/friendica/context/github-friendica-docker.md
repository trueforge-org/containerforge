# friendica/docker (official image Dockerfile and README)

Source URL(s) + fetch date:
- https://github.com/friendica/docker/blob/91cb08d73a60af3dc355b0e6ebeaa898389cea5b/2026.05/apache/Dockerfile, fetched via raw.githubusercontent.com/friendica/docker/91cb08d.../2026.05/apache/Dockerfile (2026-11-26, WebFetch summary)
- https://raw.githubusercontent.com/friendica/docker/master/README.md (2026-11-26, WebFetch summary of master README; the image README on master, not pinned to the commit)

## Dockerfile (2026.05, apache variant)

Base: `php:8.4-apache-trixie`. Build ARG: none. Upstream runs as root (no USER instruction); gosu is installed to drop privileges in the entrypoint.

Install/build steps:
- gosu 1.19 fetched from `https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch` + `.asc`, key `B42F6819007F00F88E364FD4036A9C25BF357DD4` from keys.openpgp.org, verified, then `gosu --version` and `gosu nobody true` tested.
- Friendica tarball `https://files.friendi.ca/friendica-all-in-one-${FRIENDICA_VERSION}.tar.gz` + `.asc`, key `08656443618E6567A39524083EE197EF3F9E4287` from keyserver.ubuntu.com. Build verifies gpg AND the SHA256 `FRIENDICA_DOWNLOAD_SHA256`, extracts, renames to `/usr/src/friendica`, `chmod 777` on `view/smarty3`.
- PHP extensions (docker-php-ext-install): pdo_mysql, gd (freetype, jpeg, webp), exif, zip, opcache, ctype, pcntl, ldap, gmp, intl.
- PECL: apcu 5.1.28, memcached 3.4.0, redis 6.3.0 (zstd and lz4 enabled), imagick 3.8.1; enabled with docker-php-ext-enable.
- Config written: opcache-recommended.ini (jit tracing, jit_buffer_size 32M; upstream has the typo `opcache.revalidte_freq`), sendmail.ini (msmtp), apcu `apc.enable_cli=1`, friendica.ini (memory_limit, upload_max_filesize, post_max_size from env), php.ini-production symlinked to php.ini.

Apt packages:
- Runtime: rsync, bzip2, msmtp, tini, mariadb-client, bash, gettext, librsvg2-2, libmagickcore-7.q16-10-extra.
- Build libs: libpng-dev, libjpeg62-turbo-dev, libtool, libmagick++-dev, libmemcached-dev, zlib1g-dev, libssl-dev, libgraphicsmagick1-dev, libfreetype6-dev, libwebp-dev, libzip-dev, libldap2-dev, libgmp-dev.
- Temporary (purged): ca-certificates, wget, gnupg, dirmngr (if needed).

Env defaults: `GOSU_VERSION=1.19`, `PHP_MEMORY_LIMIT=512M`, `PHP_UPLOAD_LIMIT=512M`, `FRIENDICA_SYSLOG_FLAGS=39`, `FRIENDICA_VERSION=2026.05`, `FRIENDICA_DOWNLOAD_SHA256=b0a1e218c4a5a30d25b8be5a66cb97a4f4f802b98e7cf3d0d34ce045b2714ab2`.

Entrypoint/cmd: `ENTRYPOINT ["/entrypoint.sh"]`, `CMD ["apache2-foreground"]`. Copied `*.sh` and `upgrade.exclude` go to `/`, `config/*` to `/usr/src/friendica/config/`.

Apache: modules headers, rewrite, remoteip enabled. remoteip trusts `X-Forwarded-For` from 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16.

Dirs: `/var/www/data` created 775, owner www-data:www-data.

Volumes: `/var/www/html`, `/var/www/data`.

EXPOSE: none; Apache listens on 80 from the base image.

## README (image docs, master)

Tags: `apache` (default for latest), `fpm` (needs a web server proxy, port 9000, not to be published), `fpm-alpine`, `*-dev` and `*-rc` (re-download at each start; need FRIENDICA_UPGRADE=true).

Ports: apache 80. Volumes: `/var/www/html` (install and uploads), `/var/lib/mysql` (database container).

Env variables (exact names):
| Variable | Default / note |
| --- | --- |
| FRIENDICA_URL | full URL with protocol, domain, subpath |
| FRIENDICA_TZ | default localization |
| FRIENDICA_LANG | default language |
| FRIENDICA_SITENAME | site name |
| FRIENDICA_NO_VALIDATION | `true` disables URL and email validation |
| FRIENDICA_DATA | storage provider name (e.g. Filesystem) |
| FRIENDICA_DATA_DIR | `/var/www/data` |
| FRIENDICA_UPGRADE | `false` |
| FRIENDICA_ADMIN_MAIL | admin email for automatic install |
| FRIENDICA_DEBUGGING | `true` enables logging |
| FRIENDICA_LOGFILE | `/var/www/friendica.log` |
| FRIENDICA_LOGLEVEL | `notice` |
| FRIENDICA_LOGGER | stream, syslog or monolog (default stream) |
| FRIENDICA_SYSLOG_FLAGS | `LOG_PID \| LOG_ODELAY \| LOG_CONS \| LOG_PERROR` |
| FRIENDICA_SYSLOG_FACTORY | `LOG_USER` |
| MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE | required for automatic install |
| MYSQL_PORT | `3306` |
| REDIS_HOST, REDIS_PORT, REDIS_PW, REDIS_DB | Redis lock driver (optional) |
| PHP_MEMORY_LIMIT | `512M` |
| PHP_UPLOAD_LIMIT | `512M` (post_max_size and upload_max_filesize) |
| SMTP, SMTP_PORT (587), SMTP_TLS (on), SMTP_STARTTLS (on; off if port 465), SMTP_AUTH_USER, SMTP_AUTH_PASS, SMTP_AUTH (on if user and password set), SMTP_DOMAIN (required), SMTP_FROM (`no-reply`) | msmtp mail relay |

`_FILE` suffix: works for FRIENDICA_ADMIN_MAIL, MYSQL_DATABASE, MYSQL_PASSWORD, MYSQL_USER.

Web installer: without preconfiguration the wizard is used (http://localhost:8080/ with `-p 8080:80`). Automatic install needs FRIENDICA_URL, FRIENDICA_ADMIN_MAIL, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, MYSQL_HOST.

Cron/worker: background tasks are needed. Either set them up manually, or run a second container from the same image with `cron.sh` as its command.

Compose notes: examples use mariadb with `MYSQL_RANDOM_ROOT_PASSWORD=yes`; no SSL in examples (run behind a proxy).

Gotchas:
- Upstream runs as root; not rootless or read-only-rootfs ready by itself. gosu is the privilege-drop mechanism we do not use.
- Contradicts plan.md section 6: plan lists `FRIENDICA_DB_HOST`, `FRIENDICA_DB_PORT`, `FRIENDICA_DB_NAME`, `FRIENDICA_DB_USER`, `FRIENDICA_DB_PASSWORD`, which are NOT upstream names. Upstream uses MYSQL_HOST, MYSQL_PORT, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD. plan.md was corrected accordingly (see README).
- Upstream data dir default is `/var/www/data`; TrueCharts uses `/data` (see truecharts file).

Failed to fetch: none. Entrypoint script (`/entrypoint.sh`) was not fetched; its details are not in this summary.
