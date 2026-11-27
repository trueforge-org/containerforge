# Upstream container scripts: docker-tachidesk @ 7a2bdee (startup_script.sh, create_server_conf.sh)

Source URL(s) + date: https://raw.githubusercontent.com/suwayomi/docker-tachidesk/7a2bdee0b5aab381f80a9186ef8c73507771050f/scripts/startup_script.sh and .../scripts/create_server_conf.sh (fetched 2026-11-27)

## create_server_conf.sh
- Exits if `/home/suwayomi/.local/share/Tachidesk/server.conf` exists.
- Else unzips `server-reference.conf` from `/home/suwayomi/startup/tachidesk_latest.jar` into the Tachidesk data dir as `server.conf`.

## startup_script.sh (CMD)
- Calls create_server_conf.sh, then `sed -i` rewrites keys in server.conf from env vars (`${VAR:-default}`). Passwords can come from `*_FILE` env vars (SOCKS_PROXY_PASSWORD_FILE, AUTH_PASSWORD_FILE, BASIC_AUTH_PASSWORD_FILE, DATABASE_PASSWORD_FILE, SYNCYOMI_API_KEY_FILE).
- Forces `server.initialOpenInBrowserEnabled=false` and `server.systemTrayEnabled=false`.
- Starts Xvfb (1280x1024x24, -nolisten tcp) if installed; links /opt/kcef/jcef to data dir `bin/kcef`; sets `LD_PRELOAD=.../bin/kcef/libcef.so`.
- Final: `exec java -Duser.home=/home/suwayomi -jar /home/suwayomi/startup/tachidesk_latest.jar` (exec, so java is tini's child).

## Env var -> server.conf key mapping (selected)
| Env | server.conf key |
| --- | --- |
| BIND_IP | server.ip |
| BIND_PORT | server.port |
| SOCKS_PROXY_ENABLED / _VERSION / _HOST / _PORT / _USERNAME / _PASSWORD | server.socksProxy* |
| TZ | exported, default Etc/UTC |
| WEB_UI_ENABLED / WEB_UI_FLAVOR / WEB_UI_CHANNEL / WEB_UI_UPDATE_INTERVAL | server.webUI* |
| DOWNLOAD_AS_CBZ | server.downloadAsCbz |
| DOWNLOAD_CONVERSIONS, EXTENSION_STORES | server.downloadConversions / server.extensionStores (perl) |
| MAX_SOURCES_IN_PARALLEL | server.maxSourcesInParallel |
| UPDATE_INTERVAL | server.globalUpdateInterval |
| AUTH_MODE, AUTH_USERNAME, AUTH_PASSWORD, JWT_* | server.authMode, authUsername, authPassword, jwt* |
| BASIC_AUTH_ENABLED / _USERNAME / _PASSWORD | server.basicAuth* (AUTH_MODE falls back to basic_auth when BASIC_AUTH_ENABLED=true) |
| DEBUG, MAX_LOG_FILES, MAX_LOG_FILE_SIZE, MAX_LOG_FOLDER_SIZE | server.debugLogsEnabled, maxLogFiles, maxLogFileSize, maxLogFolderSize |
| BACKUP_TIME, BACKUP_INTERVAL, BACKUP_TTL, AUTO_BACKUP_INCLUDE_* | server.backup* / autoBackupInclude* |
| FLARESOLVERR_ENABLED / _URL / _TIMEOUT / _SESSION_NAME / _SESSION_TTL / _RESPONSE_AS_FALLBACK | server.flareSolverr* |
| DATABASE_TYPE / _URL / _USERNAME / _PASSWORD / _SCHEMA, USE_HIKARI_CONNECTION_POOL, HIKARI_MAX_POOL_SIZE | server.database* / useHikariConnectionPool / hikariMaxPoolSize |
| KCEF_ENABLED | server.kcefEnabled |

## Not mapped here (chart sets these; no effect in this script)
- AUTO_DOWNLOAD_*, UPDATE_EXCLUDE_*, UPDATE_MANGA_INFO, EXTENSION_REPOS (script reads EXTENSION_STORES instead), GQL_DEBUG. Verify against the chart's `preview` image before relying on them.

## Gotchas
- Script rewrites server.conf on every start; the file persists in the appdata volume.
- Script uses `sed -i` on server.conf, so the config dir must be writable.
