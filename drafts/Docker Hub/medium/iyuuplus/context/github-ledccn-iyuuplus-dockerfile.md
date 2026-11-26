# ledccn/iyuuplus-dev: docker/Dockerfile (HEAD)
Source URL(s): https://github.com/ledccn/iyuuplus-dev/blob/HEAD/docker/Dockerfile = raw HEAD (fetched 2026-11-26, 101 lines). Unpinned HEAD; no release tags.

## Base / labels
- FROM alpine:3.21; LABEL Version="8.3.3" Release="20260112" (labels only)
- ARG package_url=mirrors.ustc.edu.cn (sed on /etc/apk/repositories)

## ENV
| Env | Value |
| --- | --- |
| LANG | C.UTF-8 |
| TZ | Asia/Shanghai |
| S6_SERVICES_GRACETIME | 30000 |
| S6_KILL_GRACETIME | 60000 |
| S6_CMD_WAIT_FOR_SERVICES_MAXTIME | 0 |
| S6_SYNC_DISKS | 1 |
| COMPOSER_ALLOW_SUPERUSER | 1 |
| APP_ENV | prod |
| IYUU_REPO_URL | https://gitee.com/ledc/iyuuplus-dev.git |

## Build steps
1. apk add: ca-certificates curl bash openssl wget zip unzip tzdata git libressl tar s6-overlay; PHP 8.3 (php83 + bz2 bcmath curl dom fileinfo mbstring openssl opcache pcntl pdo pdo_sqlite phar posix simplexml sockets session sodium sqlite3 zip gd mysqli pdo_mysql pecl-event xml); nginx nginx-mod-http-headers-more
2. ln -sf /usr/bin/php83 /usr/bin/php; install Composer to /usr/local/bin/composer (getcomposer.org installer)
3. /etc/php83/conf.d/99-overrides.ini: upload_max_filesize=100M, post_max_size=108M, memory_limit=1024M, date.timezone=$TZ; opcache enabled
4. apk add mariadb mariadb-client (removes /etc/my.cnf.d/mariadb-server.cnf)
5. mkdir /iyuu; git config safe.directory /iyuu
6. COPY --chmod=755 ./rootfs / (s6 services, nginx and mysql configs)

## Ports / volumes / entry
- EXPOSE 8780
- VOLUME ["/iyuu"], VOLUME ["/data"]
- ENTRYPOINT ["/init"] (s6-overlay)
- No USER line (runs as root)

## Runtime deps
- Network to gitee.com at first start (init-config clones IYUU_REPO_URL into /iyuu; later runs `git fetch` + `git reset --hard origin/master`). See github-ledccn-iyuuplus-init-config.md.

## Gotchas
- Labels say Version 8.3.3 but no git tag exists upstream.
- Mirror sed is default-on (mirrors.ustc.edu.cn).
