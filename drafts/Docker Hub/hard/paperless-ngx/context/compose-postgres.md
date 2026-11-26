# Reference compose (docker/compose/docker-compose.postgres.yml)

Source URL: https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/main/docker/compose/docker-compose.postgres.yml (fetched)

## Services
| Service | Image | Ports | Volumes |
| --- | --- | --- | --- |
| broker | docker.io/valkey/valkey:9-alpine | none | redisdata -> /data |
| db | docker.io/library/postgres:18 | none | pgdata -> /var/lib/postgresql |
| webserver | ghcr.io/paperless-ngx/paperless-ngx:latest | 8000:8000 | data -> /usr/src/paperless/data; media -> /usr/src/paperless/media; ./export -> /usr/src/paperless/export; ./consume -> /usr/src/paperless/consume |

- Named volumes: data, media, pgdata, redisdata
- db ENV: POSTGRES_DB=paperless, POSTGRES_USER=paperless, POSTGRES_PASSWORD=paperless
- webserver ENV: PAPERLESS_REDIS=redis://broker:6379, PAPERLESS_DBHOST=db, PAPERLESS_DBENGINE=postgresql; env_file docker-compose.env (contents not shown)
- Not set here: USERMAP_UID/GID, PAPERLESS_TIKA_*, PAPERLESS_OCR_*; no `user:` directive
- depends_on: webserver -> db, broker; all restart: unless-stopped
