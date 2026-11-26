# wolveix/satisfactory-server (wrapper; now robtme/satisfactory-server)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/wolveix/satisfactory-server/89015af92e8d2c8c88a2bd07e214d85ca368c161/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/wolveix/satisfactory-server/89015af92e8d2c8c88a2bd07e214d85ca368c161/init.sh (fetched 2026-11-26; content served from the robtme mirror page)
- https://raw.githubusercontent.com/wolveix/satisfactory-server/89015af92e8d2c8c88a2bd07e214d85ca368c161/run.sh (fetched 2026-11-26)
- https://raw.githubusercontent.com/wolveix/satisfactory-server/89015af92e8d2c8c88a2bd07e214d85ca368c161/healthcheck.sh (fetched 2026-11-26; summarized, not verbatim)
- https://raw.githubusercontent.com/wolveix/satisfactory-server/89015af92e8d2c8c88a2bd07e214d85ca368c161/README.md (fetched 2026-11-26)
- https://github.com/wolveix/satisfactory-server/releases (fetched 2026-11-26)

## What it is
Dockerized Satisfactory dedicated server wrapper. It downloads the game with SteamCMD at runtime, then launches `FactoryServer.sh`. The maintainer renamed the account to `robtme`; the README recommends `robtme/satisfactory-server` (and `ghcr.io/robtme/satisfactory-server`), and says the `wolveix` image still gets updates. Repo commit reviewed: 89015af.

## Install/build steps
Dockerfile (commit 89015af):
- `FROM steamcmd/steamcmd:ubuntu-22`
- `ARG GID=1000`, `ARG UID=1000`
- `apt-get install -y gosu xdg-user-dirs curl jq tzdata --no-install-recommends`, then `rm -rf /var/lib/apt/lists/*`
- Creates group `steam` (GID) and user `steam` (UID, bash, home `/home/steam`); copies `/root/.local/share/Steam/steamcmd/` to `/home/steam/.local/share/Steam/steamcmd/`; `chown` to UID:GID.
- `mkdir -p /config && chown steam:steam /config`
- `COPY init.sh /`; `COPY --chown=steam:steam healthcheck.sh run.sh /home/steam/`; `chmod +x` on those.
- `ARG VERSION="DEV"`, `ENV VERSION=$VERSION`, `LABEL version=$VERSION`.
- No game download at build time.

## Runtime deps
gosu, xdg-user-dirs, curl, jq, tzdata (apt); steamcmd (in base image); the game's own libraries come from the Steam download.

## Binaries/entrypoint/CLI flags
- `ENTRYPOINT ["/init.sh"]`; `WORKDIR /config`; no `CMD`, no `USER`, no `VOLUME` (Dockerfile).
- `init.sh` runs as root when UID 0, validates PUID/PGID, adjusts the `steam` user/group, `chown -R PUID:PGID /config /home/steam /tmp/dumps`, then `exec gosu $USER /home/steam/run.sh "$@"`. When not root (rootless), it runs `run.sh` directly and only requires the steam UID/GID to match.
- `run.sh` (game launch): `cd /config/gamefiles`, runs `./FactoryServer.sh -Port=$SERVERGAMEPORT -ReliablePort=$SERVERMESSAGINGPORT -ExternalReliablePort=$SERVERMESSAGINGPORT "${ini_args[@]}" "$@" &`, then traps `SIGINT SIGTERM` and forwards `kill -INT` to the game PID, then `wait`.
- `run.sh` update: `steamcmd +force_install_dir /config/gamefiles +login anonymous +app_update "$STEAMAPPID" -beta "$STEAMBETAFLAG" $STEAMBETAPASSWORD validate +quit`. Beta flag: `STEAMBETAID` if set (with `-betapassword STEAMBETAKEY` if set), else `experimental` when `STEAMBETA=true`, else `public`. Removes `/config/gamefiles/steamapps/appmanifest_1690800.acf` first to force a check. Copies Steam logs to `/config/logs/steam`.
- `run.sh` ini args (verbatim list): `-ini:Engine:[/Script/FactoryGame.FGSaveSession]:mNumRotatingAutosaves=$AUTOSAVENUM`, `-ini:Engine:[/Script/Engine.GarbageCollectionSettings]:gc.MaxObjectsInEditor=$MAXOBJECTS`, `-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:LanServerMaxTickRate=$MAXTICKRATE`, `...:NetServerMaxTickRate=$MAXTICKRATE`, `...:ConnectionTimeout=$TIMEOUT`, `...:InitialConnectTimeout=$TIMEOUT`, `-ini:Engine:[ConsoleVariables]:wp.Runtime.EnableServerStreaming=$SERVERSTREAMING` (true becomes 1, else 0), `-ini:Game:[/Script/Engine.GameSession]:ConnectionTimeout=$TIMEOUT`, `...:InitialConnectTimeout=$TIMEOUT`, `...:MaxPlayers=$MAXPLAYERS`, `-ini:GameUserSettings:[/Script/Engine.GameSession]:MaxPlayers=$MAXPLAYERS`. Added only when set: `-DisableSeasonalEvents` and `-multihome=<addr>` (`::` default; IPv4 or IPv6 validated, invalid becomes `::`).
- Numeric env values that fail validation fall back to defaults: SERVERGAMEPORT 7777, SERVERMESSAGINGPORT 8888, AUTOSAVENUM 5, MAXOBJECTS 2162688, MAXTICKRATE 30, TIMEOUT 30, MAXPLAYERS 4.
- `run.sh` skips the update when `SKIPUPDATE` is true and game files exist; otherwise updates (warns if free space under 8 GB).
- Launch gate: exits 1 with "FactoryServer launch script is missing" if `/config/gamefiles/FactoryServer.sh` is absent after update.
- `run.sh` (per the script) copies `/config/saved/server/.` to `/config/backups/`, copies `${GAMESAVESDIR}/server/.` to `/config/backups`, removes `$GAMESAVESDIR`, then `ln -sf /config/saved $GAMESAVESDIR`.
- Pre-launch (init.sh): if `LOG` is not true, deletes files under `/config/gamefiles/FactoryGame/Saved/Logs`.
- Refuses to start when CPU model is "Common KVM processor" or contains "QEMU", unless `VMOVERRIDE=true`.
- Warns when available RAM is under 8 GB (`MemAvailable`).
- Refuses PUID/PGID of 0.

## Env vars (table, wolveix/robtme at 89015af; README for 1.10.0 is noted below)
| Variable | Default | Use |
| --- | --- | --- |
| `AUTOSAVENUM` | 5 | rotating autosave count |
| `DEBUG` | false | prints env, system info, then exits 1 |
| `DISABLESEASONALEVENTS` | false | adds `-DisableSeasonalEvents` (FICSMAS) |
| `GAMECONFIGDIR` | `/config/gamefiles/FactoryGame/Saved` | dirs created by init.sh |
| `GAMESAVESDIR` | `/home/steam/.config/Epic/FactoryGame/Saved/SaveGames` | symlinked to `/config/saved` |
| `LOG` | false | when not true, Satisfactory logs are pruned at start |
| `MAXOBJECTS` | 2162688 | `gc.MaxObjectsInEditor` |
| `MAXPLAYERS` | 4 | player limit |
| `MAXTICKRATE` | 30 | tick rate |
| `MULTIHOME` | `::` | `-multihome=` address |
| `PGID` / `PUID` | 1000 / 1000 | run-as group/user (root only starts with these) |
| `SERVERGAMEPORT` | 7777 | `-Port` |
| `SERVERMESSAGINGPORT` | 8888 | `-ReliablePort` and `-ExternalReliablePort` |
| `SERVERSTREAMING` | true | `wp.Runtime.EnableServerStreaming` |
| `SKIPUPDATE` | false | skip SteamCMD update when game files exist |
| `STEAMAPPID` | 1690800 | set in Dockerfile env |
| `STEAMBETA` | false | `experimental` branch |
| `STEAMBETAID` | empty | custom beta branch (overrides STEAMBETA) |
| `STEAMBETAKEY` | empty | beta password |
| `TIMEOUT` | 30 | connection timeouts |
| `VMOVERRIDE` | false | skip CPU model check |
| `VERSION` | DEV | build arg, image label |

Also in v1.10.0 (per the release notes and Docker Hub page, not in the 89015af files): `BACKUPLIMIT` (default 10), `SERVERADMINPASSWORD`, `SERVERNAME` (default "Satisfactory Server"), `SERVERPASSWORD`. Docker Hub lists these; the 89015af files do not.

## Ports
- 7777/udp (game, `EXPOSE`)
- 7777/tcp (game, server API HTTPS `/api/v1`)
- 8888/tcp (reliable messaging)
- No other ports (15000/15777 not used by this wrapper).

## Volumes/paths and persistent data
`/config` is the single volume (README: bind a local dir). Subfolders created by init.sh:
- `/config/backups`: save backups made at container start (1.10.0 adds timestamped rotation, `BACKUPLIMIT`).
- `/config/gamefiles`: game files (about 8 GB+ download).
- `/config/logs` (`/config/logs/steam`, `/config/logs/satisfactory-path.txt`).
- `/config/saved` (blueprints, `server/`): saves, server config.
- `/config/gamefiles/FactoryGame/Saved/Config/LinuxServer` and `/Logs`.
- `/home/steam/.steam/root`, `/home/steam/.steam/steam`: Steam dirs.
- `/tmp/dumps`: chowned by init.sh (chart uses an emptyDir here).

## User/UID & permissions
- Image user `steam` created with build args UID/GID (default 1000:1000).
- Starts as root when UID 0: changes steam user/group IDs to PUID/PGID, `chown -R` of `/config`, `/home/steam`, `/tmp/dumps`, then `gosu` to the steam user.
- Rootless: must run with UID/GID equal to the steam user's (README: rebuild image with UID/GID build args for others).

## Config files and formats
Server config is driven by ini command-line overrides (above). Saves under `/config/saved`. Satisfactory ini files live under `GAMECONFIGDIR`.

## Healthcheck/readiness endpoints
Dockerfile: `HEALTHCHECK --timeout=30s --start-period=300s CMD bash /home/steam/healthcheck.sh`.
healthcheck.sh (summary of its content, not verbatim): `set -o pipefail`; silent HTTPS POST to the local server API (port from `SERVERGAMEPORT`, certificate verification off) with body `{"function":"HealthCheck","data":{"clientCustomData":""}}`; piped to `jq` checking that `.data.health` is `"healthy"`; exit 0 when healthy.

## Version/release info and asset naming
- Releases (github.com/wolveix/satisfactory-server, now robtme): v1.10.0 (24 Nov, "Server claiming, backup rotation + IPv6 fix"); v1.9.11 (06 Oct, "Rename + docs"); v1.9.10 (16 Sep, K8s liveness probe + custom Steam beta support); 1.9.9 (10 Jun); 1.9.8 (03 May).
- v1.10.0 notes: optional automatic server claiming via `SERVERADMINPASSWORD`, `SERVERNAME`, `SERVERPASSWORD`; timestamped backup rotation controlled by `BACKUPLIMIT` (default 10); if a Steam update fails the installed version starts; clean shutdown on `docker stop`; IPv6-disabled host fix; numeric setting validation (invalid values fall back to defaults); redaction of secrets in debug output; faster startup on large volumes; Kubernetes startup probe; upgrade notes say old loose backups are not rotated and SaveShare plus the example Helm values.yaml were removed.
- Release assets: "Assets 2" shown per release, names not visible in the fetched text.
- Game build is not tied to the wrapper tag: Steam downloads the latest public (or beta) build at runtime.
- Docker Hub: see dockerhub-wolveix-satisfactory-server.md.

## Arch support
Not stated in the repo or README. The game's depot is fetched via SteamCMD; no arm64 path appears in the Dockerfile (base is steamcmd x86_64 image).

## Gotchas
- First start downloads 8 GB+ via SteamCMD and can take a long time; `SKIPUPDATE` and volume persistence matter.
- Memory: 8 to 16 GB recommended; wrapper warns under 8 GB.
- SIGINT is the shutdown signal (`STOPSIGNAL SIGINT`); run.sh forwards SIGINT to the game on SIGINT or SIGTERM.
- Self-signed TLS on the API; healthcheck disables verification. README mentions optional Certbot.
- Mods: supported but rough; no SFTP in the image.
- License: no license text in the fetched pages. plan.md says the GitHub API reports MIT; not verified here.

## Contradictions with plan.md
- plan.md section 1 says the upstream `init.sh` was not reviewed: now reviewed (above).
- plan.md section 1 "Wrapper version" says what changed in 1.10.0 is UNVERIFIED: release notes above now describe it.
- plan.md section 1 env list (wrapper) predates v1.10.0 and omits `BACKUPLIMIT`, `SERVERADMINPASSWORD`, `SERVERNAME`, `SERVERPASSWORD`.
- plan.md `Env` and ports otherwise match the scripts (`EXPOSE 7777/udp 7777/tcp 8888/tcp`, steam app 1690800, ini args, SIGINT forwarding, `/config/saved` symlink).
