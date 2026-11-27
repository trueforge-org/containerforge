# GOAN wrapper README (xavier-hernandez, pinned commit)

## Source URL(s) + date

- https://raw.githubusercontent.com/xavier-hernandez/goaccess-for-nginxproxymanager/6044a67020e04752f962a76f95ff99f6cdb00701/README.md
- Fetched 2026-11-27

## What it is

- GoAccess dashboard for Nginx Proxy Manager (NPM) and other proxy logs.

## Docker run (README)

- Port `7880:7880`. Mount `/path/to/host/nginx/logs:/opt/log:ro`. Optional `/path/to/host/custom:/opt/custom:ro` (required for LOG_TYPE=CUSTOM).
- Example env: `TZ=America/New_York`, `SKIP_ARCHIVED_LOGS=False`, `DEBUG=False`, `BASIC_AUTH=False`, `EXCLUDE_IPS=127.0.0.1`, `LOG_TYPE=NPM`, `HTML_REFRESH=5`.

## Env vars (README table)

| Var | Default | Notes |
| --- | --- | --- |
| SKIP_ARCHIVED_LOGS | False | skip `proxy-host*.gz` |
| DEBUG | False | more logs, parsing error checks |
| BASIC_AUTH | False | nginx basic auth; container restart needed on change |
| BASIC_AUTH_USERNAME | - | requires BASIC_AUTH=True |
| BASIC_AUTH_PASSWORD | - | requires BASIC_AUTH=True |
| EXCLUDE_IPS | - | comma list / ranges (goaccess man) |
| INCLUDE_PROXY_HOSTS | - | e.g. `11,21` -> proxy-host-11/21 logs only |
| LOG_TYPE | NPM | CUSTOM, NPM, NPM+R, TRAEFIK, NCSA_COMBINED, CADDY_V1 (NPM+ALL in notes) |
| LOG_TYPE_FILE_PATTERN | *.log | only NCSA_COMBINED / CADDY_V1 |
| LANG / LANGUAGE | - | e.g. zh_CN.UTF-8; de, es, fr, it, ja, ko, pt_BR, ru, sv, uk, zh_CN |
| ENABLE_BROWSERS_LIST | False | use goaccess browsers.list |
| CUSTOM_BROWSERS | - | `Browser:Category,...` |
| HTML_REFRESH | - | seconds between report refresh |
| KEEP_LAST | - | days kept in storage |
| PERSIST | - | persist parsed data to disk |
| RESTORE | - | load stored data |
| DB_PATH | /tmp | on-disk DB path |
| PROCESSING_THREADS | 1 | goaccess threads |

## LOG_TYPE notes

- NPM (default): reads `proxy-host-*_access.log(.gz)`, `proxy*host-*.log`.
- NPM+R: second GoAccess instance at `/redirection`; reads `redirection*host-*.log(.gz)`, `fallback_access.log(.gz)`, `dead-host*.log(.gz)`.
- NPM+ALL: adds `/redirection` instance and `/error` instance (`*_error.log(.gz)`).
- CUSTOM: needs `/opt/custom` mount with `goaccess.conf` (container exits if missing); the README says to leave the port at 7890 in that file. Ignores SKIP_ARCHIVED_LOGS and EXCLUDE_IPS.
- TRAEFIK: reads `access.log` (and LOG_TYPE_FILE_PATTERN `*.log`); ignores SKIP_ARCHIVED_LOGS; TIME_FORMAT, DATE_FORMAT, LOG_FORMAT overridable.
- CADDY_V1: reads `access.log` by default; ignores SKIP_ARCHIVED_LOGS.
- NCSA_COMBINED: reads `*.log` by default; ignores SKIP_ARCHIVED_LOGS.
- NGINX_ACCESS: reads `access.log`.

## Gotchas

- Websockets must be enabled on NPM proxy host for live updates.
- Basic auth requires container restart after toggling BASIC_AUTH.
- Bundled MaxMind GeoLite2 databases (README date noted in plan.md).
