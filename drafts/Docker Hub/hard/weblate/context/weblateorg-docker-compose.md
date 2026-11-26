# WeblateOrg/docker-compose docker-compose.yml

Source URL: https://raw.githubusercontent.com/WeblateOrg/docker-compose/master/docker-compose.yml (fetched 2026-11-26)
Also covers: https://github.com/WeblateOrg/docker-compose (repo root, not fetched separately)

## Services
| Service | Image | Ports | Volumes | Env | Other |
| --- | --- | --- | --- | --- | --- |
| cache | `valkey/valkey:9.2.1` | none | `redis-data:/data` | none | cmd `valkey-server --save 60 1 --loglevel warning`; `read_only: true`; restart always |
| database | `postgres:19-alpine` | none | `postgres-data:/var/lib/postgresql` | from `./environment` (contents not shown) | restart always |
| weblate | `weblate/weblate` (no tag) | none | `weblate-data:/app/data`, `weblate-cache:/app/cache` | from `./environment` | depends_on cache, database; `read_only: true`; tmpfs `/run`, `/tmp`; restart always |

- Named volumes: weblate-cache, weblate-data, postgres-data, redis-data.
- No `user`, `cap_drop`, `security_opt`, `privileged` set. No inline env vars. No networks (compose default).
