# navidrome upstream docs (configuration + Docker install)

Source URL(s) + date: https://www.navidrome.org/docs (landing, no facts); https://www.navidrome.org/docs/usage/configuration/options/ ; https://www.navidrome.org/docs/installation/docker/ (fetched 2026-11-27)

## Configuration options (key | env | default)
| Setting | Config key | Env var | Default |
| --- | --- | --- | --- |
| HTTP port | Port | ND_PORT | 4533 |
| Music folder | MusicFolder | ND_MUSICFOLDER | "./music" |
| Data folder | DataFolder | ND_DATAFOLDER | "./data" |
| Cache folder | CacheFolder | ND_CACHEFOLDER | "<DataFolder>/cache" |
| Config file | (use -c/--configfile) | ND_CONFIGFILE | "./navidrome.toml" |
| Log level | LogLevel | ND_LOGLEVEL | info |
| Log file | LogFile | ND_LOGFILE | empty (stderr) |
| Session timeout | SessionTimeout | ND_SESSIONTIMEOUT | 48h |
| Scanner enabled | Scanner.Enabled | ND_SCANNER_ENABLED | true |
| Scan schedule | Scanner.Schedule | ND_SCANNER_SCHEDULE | 0 (disabled) |
| Watcher wait | Scanner.WatcherWait | ND_SCANNER_WATCHERWAIT | 5s |
| Scan on startup | Scanner.ScanOnStartup | ND_SCANNER_SCANONSTARTUP | true |
| Artist joiner | Scanner.ArtistJoiner | ND_SCANNER_ARTISTJOINER | " • " |
| Follow symlinks | Scanner.FollowSymlinks | ND_SCANNER_FOLLOWSYMLINKS | true |
| Ignore dot folders | Scanner.IgnoreDotFolders | ND_SCANNER_IGNOREDOTFOLDERS | true |
| Purge missing | Scanner.PurgeMissing | ND_SCANNER_PURGEMISSING | never |

- Config file: navidrome.toml in CWD by default; formats toml/json/yml/ini. Docker: place in host folder mapped to /data.
- Precedence: env vars > CLI args > config file. Env vars = ND_ + UPPERCASE key.

## Docker install
- Image: navidrome/navidrome (Docker Hub) and upstream GHCR; platforms linux/amd64, linux/arm/v6, linux/arm/v7, linux/arm64.
- Volumes: /data (DB + cache, read/write); /music (read-only is enough). Extra volume per extra library.
- Port: 4533:4533.
- User: example `user: 1000:1000` (compose) or `--user $(id -u):$(id -g)`; user must own /data and read /music. Dropping user runs as root (docs advise against).
- PUID/PGID: documented as having NO effect (linuxserver.io convention ignored by this image).
- Permission failures: unwritable /data -> container stops ("unable to open database file"); unreadable /music -> empty library ("open /music: permission denied").
- Fix: chown -R data folder to container uid; chmod -R a+rX music folder.
- No healthcheck documented.

## Gotchas
- Upstream image does not read PUID/PGID; run-as uid is controlled by the runtime user setting.
- Chart default ND_SESSIONTIMEOUT 24h and scan schedule differ from upstream defaults (48h, disabled); chart overrides.
