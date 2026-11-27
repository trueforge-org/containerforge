# PhotoPrism docs: config options

## Source URL(s) + date
- https://docs.photoprism.app (features overview; no config details)
- https://docs.photoprism.app/getting-started/config-options/
- Fetched 2026-11-27

## Ports
- `PHOTOPRISM_HTTP_PORT` (`--http-port`), default 2342.

## Admin
- `PHOTOPRISM_ADMIN_PASSWORD` (`--admin-password`): no default; 8-72 characters.
- `PHOTOPRISM_ADMIN_USER` / `PHOTOPRISM_ADMIN_USERNAME`: default `admin`.

## Paths
| Variable | Default |
| --- | --- |
| PHOTOPRISM_STORAGE_PATH | none; writable location for sidecar, cache, database files |
| PHOTOPRISM_ORIGINALS_PATH | none; original photos and videos |
| PHOTOPRISM_IMPORT_PATH | none; optional import base |
| PHOTOPRISM_CACHE_PATH | none; optional custom cache |
| PHOTOPRISM_CONFIG_PATH | none; config dir or options.yml |
| PHOTOPRISM_DEFAULTS_YAML | /etc/photoprism/defaults.yml |

## Database
| Variable | Default |
| --- | --- |
| PHOTOPRISM_DATABASE_DRIVER | sqlite (also mysql, postgres) |
| PHOTOPRISM_DATABASE_DSN | none |
| PHOTOPRISM_DATABASE_NAME | photoprism |
| PHOTOPRISM_DATABASE_SERVER | none; host:port, e.g. mariadb:3306 |
| PHOTOPRISM_DATABASE_USER | photoprism |
| PHOTOPRISM_DATABASE_PASSWORD | none |

## Docker image
| Variable | Default |
| --- | --- |
| PHOTOPRISM_UID | 0 |
| PHOTOPRISM_GID | 0 |
| PHOTOPRISM_UMASK | 0002 |

## Gotchas
- All config changes require a restart.
- Features overview page has no install/config detail (only nav links).
