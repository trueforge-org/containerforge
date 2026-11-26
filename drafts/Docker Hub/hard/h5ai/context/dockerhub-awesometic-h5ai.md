# Docker Hub: awesometic/h5ai (DEPRECATED)

**Source URL(s):** https://hub.docker.com/r/awesometic/h5ai
**Fetched:** 2026-11-26

## Status
Deprecated. No further updates or security fixes. Successor: `awesometic/h5ai-ng` (https://hub.docker.com/r/awesometic/h5ai-ng; repo https://github.com/awesometic/h5ai-ng).

## What it is
File indexer for HTTP web servers, with several directory views, breadcrumb and tree overview. Packaged on Alpine with nginx and PHP; supervisor manages services. Image about 100.4 MB; 46 stars; 1M+ pulls. License MIT.

## Bundled versions
Alpine 3.24, nginx 1.30.6, PHP 8.5.12+, h5ai 0.30.0. PHP JIT enabled (tracing, 100 MB buffer). Thumbnails, caching and packaged downloads are active.

## Tags and architectures
- Only `latest` listed (digest begins `sha256:f45fc5a8e…`, updated 28 days before the snapshot).
- Architectures: amd64, arm64, armv7, armv6.

## Port
80 (run example uses `-p 80:80`).

## Volumes
- `/h5ai`: shared files to browse.
- `/config`: h5ai and nginx configuration.
- `/logs`: optional log persistence (`nginx/access.log`, `nginx/error.log`, `php/error.log`, `.state`).

## Env vars
| Var | Purpose |
| --- | --- |
| PUID / PGID | Owner IDs for /config (default 911 if unset) |
| TZ | Timezone; also sets log rotation timing (example Asia/Seoul) |
| HTPASSWD | `true` enables auth |
| HTPASSWD_USER | Permitted username |
| HTPASSWD_PW | Password (alternative to interactive set with `-it`) |
| LOG_ROTATE_INTERVAL_DAYS | default 1 |
| LOG_RETENTION_DAYS | default 30 |
| LOG_READ_GID | default PGID |

## User
Container runs with the PUID/PGID mapping; no other user specified.

## Run example
```
docker run -d --name=h5ai -p 80:80 -v /shared/dir:/h5ai -v /config/dir:/config \
  -e PUID=$UID -e PGID=$GID -e TZ=Asia/Seoul --restart unless-stopped awesometic/h5ai
```
Browse to http://localhost/. No Compose file provided.

## Upgrade notes
- PHP config path changed from `/etc/php82` to `/etc/php85`.
- On start, if an existing `options.json` is older than the new one, a backup is written under `/config`.
- HTTPS not built in; use a reverse proxy.

## Source links
- GitHub: https://github.com/awesometic/docker-h5ai
- h5ai upstream: https://larsjung.de/h5ai/ (redirects to https://github.com/lrsjng/h5ai/)
