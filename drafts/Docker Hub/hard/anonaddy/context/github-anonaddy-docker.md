# anonaddy/docker (upstream Docker wrapper: Dockerfile and README)

**Source URL(s) + fetch date:** https://github.com/anonaddy/docker/blob/e3f8bd3d009bab256dba3033f8c5f100198439e6/Dockerfile (fetched raw at that SHA); https://raw.githubusercontent.com/anonaddy/docker/master/README.md · fetched 2026-11-26

## What it is
Alpine + s6 + nginx Docker image for addy.io/anonaddy. Maintained by CrazyMax (plan.md says MIT; licence not confirmed in fetched text). Runs nginx, php-fpm, postfix, rspamd and cron under s6-overlay. Recommended deployment is Docker Compose (`examples/compose/compose.yml`).

## Install/build steps and build deps
- Build args: `ANONADDY_VERSION=1.7.4`, Alpine `3.24`.
- Stage 1: `tianon/gosu` binary copied to `/usr/local/bin/`.
- Main stage: `FROM crazymax/alpine-s6:<alpine>-2.2.0.3`.
- Runtime apk: bash, ca-certificates, curl, gnupg, gpgme, imagemagick, libgd, mysql-client, nginx, openssl, shadow, tar, tzdata; php84 + cli, ctype, curl, dom, fileinfo, fpm, gd, gmp, iconv, intl, json, mbstring, opcache, openssl, pcntl, pdo, pdo_mysql, phar, redis, session, simplexml, sodium, tokenizer, xml, xmlreader, xmlwriter, zip, zlib; postfix, postfix-mysql, rspamd, rspamd-controller, rspamd-proxy, cyrus-sasl, cyrus-sasl-login.
- `/usr/bin/php` -> `php84`. Postfix `master.cf` and `main.cf` backed up as `.orig`.
- Temporary build deps: autoconf, automake, build-base, gpgme-dev, imagemagick-dev, libtool, pcre-dev, php84-dev, php84-pear. PECL: `gnupg`, `mailparse`, `imagick`, enabled via `/etc/php84/conf.d/60_gnupg.ini`, `60_mailparse.ini`, `50_imagick.ini`. Build deps removed after.
- App layer: WORKDIR `/var/www/anonaddy`; temp packages git, nodejs, npm; `anonaddy` user/group (home `/var/www/anonaddy`, shell `/bin/sh`) added to `mail` group; composer installed to `/usr/bin`; `git` shallow fetch of tag `v${ANONADDY_VERSION}` from `github.com/anonaddy/anonaddy`; `composer install` without dev, optimized autoloader; `npm ci` then production build with `APP_URL=https://addy-sh.test`; ownership `nobody:nogroup`; removes build packages, `.git`, `node_modules`, `/tmp` contents.

## Runtime deps
See apk list above. Requires external MySQL/MariaDB (`DB_HOST` mandatory) and optionally Redis (`QUEUE_CONNECTION=redis`).

## Binaries/entrypoint/CLI flags
- `COPY rootfs /` (s6 service definitions come from there; not fetched).
- `ENTRYPOINT ["/init"]` (s6-overlay). No CMD, no USER.

## Env vars
General: `TZ` (UTC), `PUID` (1000), `PGID` (1000), `MEMORY_LIMIT` (256M), `UPLOAD_MAX_SIZE` (16M), `NGINX_WORKER_PROCESSES` (auto), `CLEAR_ENV` (yes), `OPCACHE_MEM_SIZE` (128), `LISTEN_IPV6` (true), `REAL_IP_FROM` (0.0.0.0/32), `REAL_IP_HEADER` (X-Forwarded-For), `LOG_IP_VAR` (remote_addr), `LOG_CROND` (true).

App: `APP_KEY` (**required**; `APP_KEY_FILE` supported), `APP_NAME` (addy.io), `APP_DEBUG` (false), `APP_URL`, `QUEUE_CONNECTION` (sync; sync or redis), `ANONADDY_DOMAIN` (**required**), `ANONADDY_SECRET` (**required**; `_FILE` variant), `ANONADDY_HOSTNAME`, `ANONADDY_RETURN_PATH`, `ANONADDY_ADMIN_USERNAME`, `ANONADDY_ENABLE_REGISTRATION` (true), `ANONADDY_DNS_RESOLVER` (127.0.0.1), `ANONADDY_ALL_DOMAINS` (`$ANONADDY_DOMAIN`), `ANONADDY_NON_ADMIN_SHARED_DOMAINS` (true), `ANONADDY_LIMIT` (200), `ANONADDY_BANDWIDTH_LIMIT` (104857600), `ANONADDY_BANDWIDTH_LIMIT_ENABLED` (true), `ANONADDY_NEW_ALIAS_LIMIT` (10), `ANONADDY_ADDITIONAL_USERNAME_LIMIT` (10), `ANONADDY_SIGNING_KEY_FINGERPRINT` (`_FILE` variant), `ANONADDY_DKIM_SIGNING_KEY`, `ANONADDY_DKIM_SELECTOR` (default).

Database: `DB_HOST` (**required**), `DB_PORT` (3306), `DB_DATABASE` (anonaddy), `DB_USERNAME` (anonaddy), `DB_PASSWORD` (`_FILE` variant), `DB_TIMEOUT` (60).

Redis: `REDIS_HOST`, `REDIS_PORT` (6379), `REDIS_PASSWORD` (`_FILE` variant).

Mail: `MAIL_FROM_NAME` (addy.io), `MAIL_FROM_ADDRESS` (`addy@${ANONADDY_DOMAIN}`), `MAIL_ENCRYPTION` (null).

Postfix: `POSTFIX_DEBUG` (false), `POSTFIX_MYNETWORKS` (`127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128`), `POSTFIX_MESSAGE_SIZE_LIMIT` (26214400), `POSTFIX_REJECT_UNKNOWN_REVERSE_CLIENT_HOSTNAME` (true), `POSTFIX_SMTPD_TLS` (false), `POSTFIX_SMTP_TLS` (false), `POSTFIX_RELAYHOST`, `POSTFIX_RELAYHOST_AUTH_ENABLE` (false), `POSTFIX_SPAMHAUS_DQS_KEY`, plus TLS cert/key file vars.

Rspamd: `RSPAMD_ENABLE` (false), `RSPAMD_WEB_PASSWORD` (`_FILE` variant), `RSPAMD_SECURE_IP` (127.0.0.1/32), `RSPAMD_GREYLIST_ENABLE` (true), `RSPAMD_SMTPD_MILTERS` (`inet:127.0.0.1:11332`), `BLOCKLIST_API_ALLOWED_IPS` (127.0.0.1), `BLOCKLIST_API_SECRET`.

## Ports
`EXPOSE 25 8000 11334`: 25 SMTP (Postfix), 8000 HTTP (addy.io via nginx), 11334 HTTP (Rspamd web dashboard).

## Volumes/paths and persistent data
`VOLUME /data` (storage). Must be owned by `PUID:PGID` or the container may not start. Extra app env vars may go in `/data/.env`. DKIM key expected at `/data/dkim/${ANONADDY_DOMAIN}.private`; rspamd signing disabled without it.

## User/UID & permissions
Default PUID/PGID 1000. Image has no USER instruction; s6 handles privilege drop.

## Healthcheck/readiness endpoints
None documented in fetched text.

## Version/release info and asset naming
- Version via build arg `ANONADDY_VERSION=1.7.4`, git tag `v1.7.4` of anonaddy/anonaddy.
- Docker Hub: see `dockerhub-anonaddy-anonaddy.md`.

## Arch support
Not stated in fetched text.

## Gotchas
- Compose example: `stop_grace_period: 90s` recommended when queues are enabled.
- Do not add Docker bridge or private LAN ranges to `POSTFIX_MYNETWORKS` unless all clients there are trusted; set `POSTFIX_REJECT_UNKNOWN_REVERSE_CLIENT_HOSTNAME=false` instead if a bridge hides public clients.
- Rspamd must be enabled for the reply-anonymously feature.

## Contradictions with plan.md
- plan.md section 1 says upstream `VOLUME /data` and `EXPOSE 25 8000 11334`: confirmed.
- plan.md section 1 says services nginx, php-fpm, cron, postfix, rspamd: consistent with apk list (plus s6 service definitions not fetched).
- plan.md section 4 uses `/config` as the volume (new design); upstream uses `/data`. Design choice, not a source conflict.
