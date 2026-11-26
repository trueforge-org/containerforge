# photoview.github.io docs

Sources:
- https://photoview.github.io: landing, summarized. Self-hosted gallery; reads filesystem; multi-user; shares; EXIF; darktable RAW; ffmpeg video; ARM. Docker not mentioned on landing. License not on landing.
- https://photoview.github.io/docs/getting-started/ (follow-up): redirect stub only (failed content).
- https://photoview.github.io/en/docs/getting-started/ (follow-up): fetched.
- https://photoview.github.io/en/docs/installation-environment-variables/ (follow-up): fetched; env table in compose-env section below.

## Getting started (en)
1. Create docker-compose.yml from full or minimal example in GitHub repo.
2. Adjust "Change This:" comments; `docker-compose up -d`.
3. Open http://localhost:8000; complete wizard (admin user/pass; photo path default /photos).
4. Settings -> Scan All.
- Full example includes Watchtower; DB options MariaDB, Postgres, SQLite.

## Env vars (en docs)
| Var | Default | Purpose |
| --- | --- | --- |
| PHOTOVIEW_DATABASE_DRIVER | mysql | mysql, postgres, or sqlite |
| PHOTOVIEW_MYSQL_URL | none | required for mysql |
| PHOTOVIEW_POSTGRES_URL | none | required for postgres |
| PHOTOVIEW_SQLITE_PATH | none | required for sqlite, e.g. /app/database/photoview.db |
| PHOTOVIEW_LISTEN_IP | 127.0.0.1 | bind IP |
| PHOTOVIEW_LISTEN_PORT | 4001 | port (image overrides to 80) |
| PHOTOVIEW_SERVE_UI | 0 | 1 = serve built UI |
| PHOTOVIEW_UI_PATH | ./ui | built UI location |
| PHOTOVIEW_API_ENDPOINT | none | public API URL, required if SERVE_UI=0 |
| PHOTOVIEW_UI_ENDPOINT | none | public UI URL, required if SERVE_UI=0 |
| PHOTOVIEW_MEDIA_CACHE | ./photo_cache | thumbnails/optimized media |
| MAPBOX_TOKEN | none | map features |
| PHOTOVIEW_DISABLE_FACE_RECOGNITION | 0 | disable face recognition |
| PHOTOVIEW_DISABLE_VIDEO_ENCODING | 0 | disable ffmpeg encoding |
| PHOTOVIEW_DISABLE_RAW_PROCESSING | 0 | disable RAW processing |

Not covered: image name, UID settings (see /en/docs/installation-docker/, not fetched - budget).
