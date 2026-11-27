# AFFiNE docs: Environment variables reference

Source URL(s) + date: https://docs.affine.pro/self-host-affine/references/environment-variables (fetched 2026-11-27)

## Vars named in the page
| Var | Facts from page |
| --- | --- |
| AFFINE_SERVER_PORT | default 3010; port inside application container |
| PORT | host-side mapping is edited in Compose, not this var |
| DATABASE_URL | supported bootstrap var; format `postgresql://user:password@postgres:5432/affine` |
| DB_USERNAME, DB_PASSWORD, DB_DATABASE, DB_DATA_LOCATION | Postgres (compose); DB_DATA_LOCATION is host path for PG data |
| REDIS_SERVER_HOST, REDIS_SERVER_PORT, REDIS_SERVER_PASSWORD, REDIS_SERVER_USERNAME, REDIS_SERVER_DATABASE | Redis |
| AFFINE_SERVER_HOST, AFFINE_SERVER_HTTPS, AFFINE_SERVER_EXTERNAL_URL, AFFINE_SERVER_SUB_PATH | external URL / host / sub-path |
| AFFINE_INDEXER_ENABLED, AFFINE_INDEXER_SEARCH_PROVIDER, _ENDPOINT, _USERNAME, _PASSWORD, _API_KEY | indexer |
| AFFINE_PRIVATE_KEY | private key |
| AFFINE_REVISION | release tag; compose file sets image tag directly |
| UPLOAD_LOCATION, CONFIG_LOCATION | host paths for blobs and config |

## Gotchas
- Page is structured as "Configuration sources", "Database connection", "Redis connection", "Process networking", "Compatibility aliases", "Removed legacy Compose variables", "Legacy .env deployments".
