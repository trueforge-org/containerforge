# Docker Hub: library/yourls (official image)

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/library/yourls/ (2026-11-27)
- https://hub.docker.com/v2/repositories/library/yourls/tags?page_size=10 (2026-11-27)

## What it is
- Official Docker library image; YOURLS (PHP URL shortener). 321 stars, ~24.0M pulls.
- last_updated 2026-11-24; description matches upstream.

## Tags (latest 10 page)
| Tag | Digest (index) | Last pushed |
| --- | --- | --- |
| latest, apache, 1.10.6, 1.10, 1, 1.10.6-apache, 1.10-apache | sha256:4e5ec5cdc4be3470bf2a718a1b77c01525498c7b770119bd2a1ed669dd4c529a | 2026-11-24 |
| fpm, 1.10.6-fpm, 1.10-fpm, 1-fpm | sha256:460f477b7244... | 2026-11-24 |
- Tags listed: 92 total. fpm-alpine variants exist (per full_description).
- Chart pins the `latest`/`apache` index digest `4e5ec5cd...` (matches).

## Architectures
amd64, arm64/v8, arm/v7, arm/v5, 386, ppc64le, riscv64, s390x.

## Entrypoint / flags
- Entrypoint `container-entrypoint.sh` (per Dockerfile template, see github-yourls-containers-dockerfile-template.md).
- Admin UI at `/admin/`. First root hit may show an error until install.

## Env vars (from full_description)
| Var | Notes |
| --- | --- |
| YOURLS_SITE | Required. URL, no trailing slash, lowercase |
| YOURLS_USER | Required. Admin username |
| YOURLS_PASS | Required. Admin password |
| YOURLS_DB_HOST | Optional if linked mysql. Supports `_FILE` suffix |
| YOURLS_DB_USER | Default `root`. Supports `_FILE` |
| YOURLS_DB_PASS | Supports `_FILE` (e.g. /run/secrets/...) |
| YOURLS_DB_NAME | Default `yourls`; DB must pre-exist |
| YOURLS_DB_PREFIX | Default `yourls_` |

- Docker secrets: `_FILE` suffix loads value from file (list truncated in fetch; at least DB_HOST/USER/PASS confirmed).

## Ports
- Examples publish `8080:8080`. Container listen port not stated in the fetched text.

## Volumes / paths
- `/var/www/html/` = YOURLS web root.
- User content: `/var/www/html/user/plugins/`, `/var/www/html/user/pages/`, `/var/www/html/user/languages/`.
- Image-baked extras: `/usr/src/yourls/` (copied to `/var/www/html/` on start).
- fpm variant: `/usr/local/etc/php-fpm.d/` (docker.conf; user `.conf` files loaded in glob order).

## User / UID
- Runs as `www-data` by default.

## Gotchas
- Persistent user content requires read/write/execute for `www-data`.
- Compose example uses `8080:8080` port mapping and `YOURLS_USER: example_username`.
