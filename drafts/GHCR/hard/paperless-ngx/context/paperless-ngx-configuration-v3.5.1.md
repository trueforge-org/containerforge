# Source: paperless-ngx docs/configuration.md (tag v3.5.1)

Source URL(s) + date: https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/v3.5.1/docs/configuration.md (fetched 2026-11-27, 100 KB; key settings extracted)

## Defaults
| Setting | Default (per doc) |
| --- | --- |
| PAPERLESS_DATA_DIR | ../data/ relative to src/ (=/usr/src/paperless/data in image) |
| PAPERLESS_MEDIA_ROOT | ../media/ relative to src/ |
| PAPERLESS_DBENGINE | SQLite (db at data/db.sqlite3) unless set to postgresql or mariadb |
| PAPERLESS_DBNAME | paperless |
| PAPERLESS_URL | "" (empty) |
| PAPERLESS_TIME_ZONE | UTC |
| PAPERLESS_WEBSERVER_WORKERS | 1 |
| PAPERLESS_BIND_ADDR | :: (all interfaces, IPv4 + IPv6) |
| PAPERLESS_TIKA_ENABLED | false |
| PAPERLESS_TIKA_ENDPOINT | http://localhost:9998 |
| PAPERLESS_TIKA_GOTENBERG_ENDPOINT | http://localhost:3000 |
| PAPERLESS_PORT | webserver port inside container (doc: do not change with Docker; use port mapping) |
| PAPERLESS_ADMIN_USER / _PASSWORD / _MAIL | only used when PAPERLESS_ADMIN_USER set; password required |

## Settings documented (names)
- Broker: PAPERLESS_REDIS=<url> (supports credentials, db index).
- Database: PAPERLESS_DBENGINE, PAPERLESS_DBHOST, PAPERLESS_DBPORT, PAPERLESS_DBNAME, PAPERLESS_DBUSER, PAPERLESS_DBPASS.
- Paths: PAPERLESS_CONSUMPTION_DIR, PAPERLESS_DATA_DIR, PAPERLESS_MEDIA_ROOT; log dir defaults to DATA_DIR/log/; classifier defaults DATA_DIR/classification_model.pickle.
- PAPERLESS_SECRET_KEY, PAPERLESS_URL (also used for allowed hosts), PAPERLESS_OCR_LANGUAGE (ISO 639-2, e.g. eng, eng+deu), PAPERLESS_TIME_ZONE, PAPERLESS_WEBSERVER_WORKERS, PAPERLESS_BIND_ADDR, PAPERLESS_PORT.
- Tika: PAPERLESS_TIKA_ENABLED, PAPERLESS_TIKA_ENDPOINT, PAPERLESS_TIKA_GOTENBERG_ENDPOINT.

## Gotchas
- Doc says PAPERLESS_PORT should not be changed when using Docker.
- Doc says PAPERLESS_OCR_LANGUAGE uses ISO 639-2 codes; PAPERLESS_OCR_LANGUAGE is documented (plan.md said it is not in fetched config page; it is in this doc).
