# lancachenet/monolithic Dockerfile (commit 3f43cc7)

Source URL(s): https://raw.githubusercontent.com/lancachenet/monolithic/3f43cc7/Dockerfile (blob: https://github.com/lancachenet/monolithic/blob/3f43cc7/Dockerfile). Fetched 2026-11-26.

## Base / labels
- `FROM lancachenet/ubuntu-nginx:latest` (tag only, no digest)
- LABEL version=3, description (LAN party game content cache), maintainer LanCache.Net Team

## ENV defaults
- GENERICCACHE_VERSION=2, CACHE_MODE=monolithic, WEBUSER=www-data
- CACHE_INDEX_SIZE=500m, CACHE_DISK_SIZE=1000g, MIN_FREE_DISK=10g, CACHE_MAX_AGE=3560d, CACHE_SLICE_SIZE=1m
- UPSTREAM_DNS="8.8.8.8 8.8.4.4", BEAT_TIME=1h, LOGFILE_RETENTION=3560
- CACHE_DOMAINS_REPO=https://github.com/uklans/cache-domains.git, CACHE_DOMAINS_BRANCH=master
- NGINX_WORKER_PROCESSES=auto, NGINX_LOG_FORMAT=cachelog

## RUN
- apt: update + upgrade; install `jq git ca-certificates` (--no-install-recommends); clean; rm lists
- `git clone --depth=1 --no-single-branch https://github.com/uklans/cache-domains/` -> `/data/cachedomains` (HARDCODED, ignores CACHE_DOMAINS_* env)
- rm `/etc/nginx/sites-enabled/*`, `/etc/nginx/stream-enabled/*`, `/etc/nginx/conf.d/gzip.conf`
- chmod 754 `/var/log/tallylog`; create WEBUSER system user (no home, /bin/false, login disabled) if missing
- chmod 755 `/scripts/*`; mkdir 755 `/data/cache`, `/data/info`, `/data/logs`, `/data/cachedomains`, `/tmp/nginx`
- `chown -R WEBUSER:WEBUSER /data/`
- Recreate `/etc/nginx/sites-enabled`; symlinks: `10_cache.conf` -> `sites-enabled/10_generic.conf`, `20_upstream.conf`, `30_metrics.conf`; `stream-available/10_sni.conf` -> `stream-enabled/10_sni.conf`

## Files / entry
- `COPY overlay/ /`
- WORKDIR `/scripts`; no USER (base default), no CMD/ENTRYPOINT (inherited)
- VOLUME `/data/logs`, `/data/cache`, `/data/cachedomains`, `/var/www`
- EXPOSE 80, 443, 8080

## HEALTHCHECK
- interval 1m, timeout 1s, start-period 120s, retries 3
- `curl --fail http://127.0.0.1/lancache-heartbeat`

## Gotchas
- No pinned cache-domains commit. `/bin/sh` `id -u ... &>` bashism noted. 1s healthcheck timeout tight.
