# Upstream Dockerfile: kanboard/kanboard v1.2.57

Source URL(s) + date: https://raw.githubusercontent.com/kanboard/kanboard/v1.2.57/Dockerfile (fetched 2026-11-27)
Failed: https://api.github.com/repos/kanboard/kanboard (403) and https://api.github.com/repos/kanboard/kanboard/releases/tags/v1.2.58 (403). Not retried. v1.2.58 release facts unverified here.

## Install/build steps
- `FROM alpine:3.24` (single stage). Labels: source github.com/kanboard/kanboard, licenses MIT, docs https://docs.kanboard.org.
- `ARG VERSION`. `apk add`: tzdata openssl unzip nginx bash ca-certificates s6 curl ssmtp mailx, php85 php85-phar php85-curl php85-fpm php85-json php85-zlib php85-xml php85-dom php85-ctype php85-zip php85-iconv php85-pdo php85-pdo_mysql php85-pdo_sqlite php85-pdo_pgsql php85-mbstring php85-session php85-bcmath php85-gd php85-openssl php85-sockets php85-posix php85-ldap php85-simplexml php85-xmlwriter.
- `rm -rf /var/www/localhost`, `rm -f /etc/php85/php-fpm.d/www.conf`, `ln -sf /usr/bin/php85 /usr/bin/php`.
- `ADD . /var/www/app` (source tree is the build context), `ADD docker/ /`.
- `rm -rf /var/www/app/docker`; writes `$VERSION` to `/var/www/app/app/version.txt`.

## Runtime deps
- nginx, php85-fpm, s6, curl (healthcheck), openssl, tzdata.

## Entrypoint/flags
- `ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]`, `CMD []`. Script comes from the repo `docker/` tree (not fetched).

## Env vars
- None set in Dockerfile.

## Ports
- `EXPOSE 80 443`.

## Volumes/paths
- `VOLUME ["/var/www/app/data", "/var/www/app/plugins", "/etc/nginx/ssl"]`.
- App root `/var/www/app`. Version file `/var/www/app/app/version.txt`.

## User/UID
- No USER, WORKDIR or ENV (runs as root by default).

## Config files
- Not fetched (`config.default.php` in source tree, not read).

## Healthcheck
- `HEALTHCHECK --start-period=3s --timeout=5s CMD curl -f http://localhost/healthcheck.php || exit 1`

## Version/asset naming
- Build arg `VERSION` (tag, e.g. v1.2.58). Source tarball `https://github.com/kanboard/kanboard/archive/refs/tags/<tag>.tar.gz` (per plan).

## Arch
- Not stated upstream.

## Gotchas
- Upstream serves on port 80 as root, nginx config from `docker/`.
- Dockerfile is at v1.2.57; re-check at v1.2.58 before porting (plan already notes this).
