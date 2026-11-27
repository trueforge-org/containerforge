# Source: ich777/docker-nwnee scripts/start-server.sh (master, follow-up of start.sh)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-nwnee/master/scripts/start-server.sh (fetched 2026-11-27, 6.4 KB)

## Env exported
- NWNX_SQL_TYPE=mysql, NWNX_SQL_HOST=localhost, NWNX_SQL_USERNAME=nwnee, NWNX_SQL_PASSWORD=nwnee, NWNX_SQL_DATABASE=nwnee, NWNX_SQL_QUERY_METRICS=true, NWNX_CORE_LOG_LEVEL=${LOG_LVL}, NWNX_CORE_LOAD_PATH=/nwnx/binaries.

## Version logic
- LAT_V from `https://api.github.com/repos/nwnxee/unified/releases/latest` (.name). Fallback: existing build dir version; else `sleep infinity`.
- If NWNEE_V=latest, NWNEE_V = LAT_V with "build" stripped.
- Server zip: https://nwn.beamdog.net/downloads/nwnee-dedicated-${NWNEE_V}.zip -> unzip into ${SERVER_DIR}; marker file build<ver>.
- NWNX binaries: https://github.com/nwnxee/unified/releases/download/${LAT_V}/NWNX-EE.zip -> ${SERVER_DIR}/binaries; marker binariesbuild<ver>.
- On mismatch: removes old build marker, bin, data, binaries and re-downloads.
- Download failure: `sleep infinity` (container stays up, idle).

## Services started (screen sessions)
- MariaDB: `mysqld` in screen "MariaDB", log ${SERVER_DIR}/MariaDBLog.0.
- Redis: `/usr/bin/redis-server` in screen "RedisServer", log ${SERVER_DIR}/RedisLog.0.
- Redis dir set to ${SERVER_DIR}/redis, dbfilename redis.rdb, BGSAVE.

## Directories created under SERVER_DIR
- redis, user, "Neverwinter Nights"/modules, "Neverwinter Nights"/hak.

## Gotchas
- Needs outbound internet at container start (downloads at runtime, not build time).
- Downloads are unpinned "latest" unless NWNEE_V set.
- Log files under SERVER_DIR; container logs are screen logs.
