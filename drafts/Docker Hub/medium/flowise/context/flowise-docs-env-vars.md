# docs.flowiseai.com environment variables

Source URL(s): https://docs.flowiseai.com (intro only, no config facts) ; https://docs.flowiseai.com/configuration/environment-variables.md (fetched, follow-up)
Date: fetched 2026-11-26

| Var | Default | Meaning |
| --- | --- | --- |
| PORT | 3000 | HTTP listen port |
| DATABASE_TYPE | sqlite | sqlite, mysql or postgres |
| DATABASE_PATH | ~/.flowise | SQLite folder only |
| DATABASE_HOST | none | non-SQLite host |
| DATABASE_PORT | none | non-SQLite port |
| DATABASE_NAME | none | non-SQLite db name |
| DATABASE_USER | none | non-SQLite user |
| DATABASE_PASSWORD | none | non-SQLite password |
| SECRETKEY_PATH | Flowise/packages/server | encryption key file location |
| LOG_PATH | Flowise/packages/server/logs | logs |
| BLOB_STORAGE_PATH | ~/.flowise/storage | uploads when STORAGE_TYPE=local |
| STORAGE_TYPE | local | s3, gcs or local |
| DEBUG | none | true prints component logs |

- Not on the page: APIKEY_PATH, FLOWISE_USERNAME, FLOWISE_PASSWORD (page only says FLOWISE_PASSWORD may be reused for FLOWISE_SECRETKEY_OVERWRITE).
