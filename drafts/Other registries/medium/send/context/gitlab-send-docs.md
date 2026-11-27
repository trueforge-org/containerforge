# timvisee/send: README, docs/docker.md, server/config.js (env reference)

## Source URL(s) + date
- https://gitlab.com/timvisee/send/-/raw/master/README.md (fetched 2026-11-27)
- https://gitlab.com/timvisee/send/-/raw/master/docs/docker.md (fetched 2026-11-27)
- https://gitlab.com/timvisee/send/-/raw/master/server/config.js (fetched 2026-11-27; defaults read from code)

## What it is
- Send: self-hosted file sharing with client-side encryption. Mozilla discontinued upstream; community fork.
- License: MPL-2.0 (README). qrcode.js MIT.
- README requirement line: Node.js 16.x (stale vs Dockerfile Node 26).

## Docker quickstart (docs/docker.md)
- `docker run -v $PWD/uploads:/uploads -p 1443:1443 -e DETECT_BASE_URL=true -e REDIS_HOST=localhost -e FILE_DIR=/uploads registry.gitlab.com/timvisee/send:latest`.
- Needs a running Redis (metadata DB; required for all storage backends).

## Env vars (server)
| Name | Default (config.js) | Note |
| --- | --- | --- |
| PORT | 1443 | listen port (config key listen_port) |
| IP_ADDRESS | 0.0.0.0 | listen address |
| BASE_URL | https://send.example.com | public URL (docs: set to HTTPS URL) |
| DETECT_BASE_URL | false | autodetect URL from browser if BASE_URL unset (docs) |
| NODE_ENV | development (config.js); docs say production is the default | read by config.js; Dockerfile CMD uses prod.js |
| SENTRY_CLIENT / SENTRY_DSN | "" | optional |
| MAX_FILE_SIZE | 2.5 GiB in config.js (1024^3 * 2.5); docs say 2147483648 | bytes |
| MAX_FILES_PER_ARCHIVE | 64 | |
| MAX_EXPIRE_SECONDS | 604800 | 7 days |
| MAX_DOWNLOADS | 100 | |
| DEFAULT_DOWNLOADS | 1 | |
| DEFAULT_EXPIRE_SECONDS | 86400 | |
| DOWNLOAD_COUNTS | [1,2,3,4,5,20,50,100] | CSV |
| EXPIRE_TIMES_SECONDS | [300,3600,86400,604800] | CSV |
| REDIS_HOST / REDIS_PORT / REDIS_USER / REDIS_PASSWORD / REDIS_DB | localhost / 6379 / "" / "" / (db) | Redis metadata |
| FILE_DIR | /uploads (docs) ; config.js default is a tmp path | local storage dir |
| S3_BUCKET, S3_ENDPOINT, S3_USE_PATH_STYLE_ENDPOINT, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY | - | S3 backend |
| GCS_BUCKET | "" | GCS backend |
| SEND_FOOTER_DMCA_URL | "" | footer DMCA contact |
| UI_COLOR_PRIMARY / UI_COLOR_ACCENT | #0a84ff / #003eaa | branding |
| CUSTOM_FOOTER_TEXT / CUSTOM_FOOTER_URL / UI_CUSTOM_CSS | "" | branding |

## Gotchas
- config.js `env` default is `development`; docs claim `production` is default. Code is authoritative: NODE_ENV is read from env (`env: 'NODE_ENV'`).
- Public upload sharing risks noted by docs (advise LAN or auth proxy).
- Docs recommend reverse proxy with SSL termination for HTTPS.
