# Upstream Dockerfile: RSS-Bridge/rss-bridge (commit 98e0301)

Source URL: https://raw.githubusercontent.com/RSS-Bridge/rss-bridge/98e03011dbb80ea9cea3ef8c5e29a1778f169cc9/Dockerfile (fetched 2026-11-27)

## Base and packages
- `FROM debian:12-slim AS rssbridge`.
- apt (no-install-recommends): ca-certificates nginx nss-plugin-pem php-curl php-fpm php-intl php-mbstring php-memcached php-sqlite3 php-xml php-zip curl patchelf.
- Default PHP is 8.2 (Debian 12). Comments: json, opcache, openssl, zlib enabled by default.

## curl-impersonate
- Version `1.0.0rc2`.
- Per arch archive (SHA-512 checked with `sha512sum -c`):
  - aarch64: `libcurl-impersonate-v1.0.0rc2.aarch64-linux-gnu.tar.gz`
  - armv7l: `libcurl-impersonate-v1.0.0rc2.arm-linux-gnueabihf.tar.gz`
  - x86_64: `libcurl-impersonate-v1.0.0rc2.x86_64-linux-gnu.tar.gz`
- Download: `https://github.com/lexiforest/curl-impersonate/releases/download/v1.0.0rc2/<archive>` (owner is lexiforest).
- Extract to `/usr/local/lib/curl-impersonate`; `patchelf --set-soname libcurl.so.4 /usr/local/lib/curl-impersonate/libcurl-impersonate.so`.
- Then purge curl and patchelf, remove apt lists.

## Env
| Name | Value |
| --- | --- |
| LD_PRELOAD | /usr/local/lib/curl-impersonate/libcurl-impersonate.so |
| CURL_IMPERSONATE | chrome131 |

## Config and layout
- nginx logs symlinked to /dev/stderr and /dev/stdout.
- `COPY ./config/nginx.conf /etc/nginx/sites-available/default`
- `COPY ./config/php-fpm.conf /etc/php/8.2/fpm/pool.d/rss-bridge.conf`
- `COPY ./config/php.ini /etc/php/8.2/fpm/conf.d/90-rss-bridge.ini`
- `COPY --chown=www-data:www-data ./ /app/`

## Entrypoint / ports
- `EXPOSE 80`; `ENTRYPOINT ["/app/docker-entrypoint.sh"]`. No CMD, USER, VOLUME.
- Labels: description, repository, website (GitHub repo).
