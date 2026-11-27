# Actual Budget docs site (actualbudget.org)

**Source URL(s):** https://actualbudget.org, https://actualbudget.org/docs, https://actualbudget.org/docs/install/docker, https://actualbudget.org/docs/config/ (fetched 2026-11-27; 3 follow-ups)

## Homepage
- "Actual Budget is a super fast and privacy-focused app for managing your finances." Envelope budgeting, multi-device sync, optional end-to-end encryption.

## Docker install (docs/install/docker)
- Image published to Docker Hub `actualbudget/actual-server` and GHCR `ghcr.io/actualbudget/actual` (same behaviour).
- Tags: `latest` (recommended, latest release), `latest-alpine`, `nightly` (master), `nightly-alpine`.
- Run example: `docker run --pull=always --restart=unless-stopped -d -p 5006:5006 -v YOUR/PATH/TO/DATA:/data --name my_actual_budget actualbudget/actual-server:latest`
- Data dir: server creates `server-files` and `user-files` subfolders under the mounted path.
- Compose: uses docker-compose.yml from the actual repo; configure via env vars.
- Connect at `http://serverIP:chosenPort`.

## Config (docs/config)
- Reads optional `config.json` in sync-server package dir; env vars override config.json (not 1:1 names).
- Secret-from-file: `ACTUAL_OPENID_CLIENT_SECRET_FILE`, `ACTUAL_GITHUB_TOKEN_FILE` (`_FILE` suffix takes priority).

| Env var | config.json key | Default / note |
| --- | --- | --- |
| ACTUAL_DATA_DIR | dataDir | `/data` if exists, else `/` |
| ACTUAL_CONFIG_PATH | (none) | config.json in /data if present, else package root |
| ACTUAL_SERVER_FILES | serverFiles | `/data/server-files` if /data exists |
| ACTUAL_USER_FILES | userFiles | `/data/user-files` if /data exists |
| ACTUAL_PORT | port | 5006 |
| ACTUAL_HOSTNAME | hostname | `::` |
| ACTUAL_WEB_ROOT | webRoot | bundled @actual-app/web |
| ACTUAL_UPLOAD_FILE_SYNC_SIZE_LIMIT_MB | - | 20 |
| ACTUAL_UPLOAD_SYNC_ENCRYPTED_FILE_SYNC_SIZE_LIMIT_MB | - | 50 |
| ACTUAL_UPLOAD_FILE_SIZE_LIMIT_MB | - | 20 |
| ACTUAL_HTTPS_KEY / ACTUAL_HTTPS_CERT | https.key / https.cert | optional TLS |
| ACTUAL_LOGIN_METHOD | loginMethod | password (also header, openid) |
| ACTUAL_ALLOWED_LOGIN_METHODS | allowedLoginMethods | password,header,openid |
| ACTUAL_TRUSTED_PROXIES | trustedProxies | RFC1918 + ULA + ::1 |
| ACTUAL_TRUSTED_AUTH_PROXIES | trustedAuthProxies | defaults to trustedProxies |

## Gotchas
- Docs list `/data` as the data mount; server uses `/data` automatically when it exists.
