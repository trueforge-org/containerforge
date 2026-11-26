# SickHub/arkserver (upstream image source for drpsychick/arkserver)

**Source URL(s) + fetch date**
- https://github.com/SickHub/arkserver/blob/394fd7aa4f6321e5665f9dbc7d1ff4600aa6386f/Dockerfile (fetched as raw)
- https://raw.githubusercontent.com/SickHub/arkserver/394fd7aa4f6321e5665f9dbc7d1ff4600aa6386f/scripts/run.sh
- Fetched 2026-11-26

**What it is**
- ARK: Survival Evolved game server image with arkmanager, description "ARK Survival Evolved linux docker image, for single instances and ARK clusters" (author drpsychick).

**Install/build steps and build deps (Dockerfile)**
- Build args: `STEAMCMD_VERSION` (default latest), `AMG_BUILD` (default latest), `AMG_VERSION` (default `v1.6.69`).
- Stages: `base` from `drpsychick/steamcmd:$STEAMCMD_VERSION`; `arkmanager-latest` and `arkmanager-versioned` extend base; final `FROM arkmanager-$AMG_BUILD`.
- apt (base stage, as root): `curl cron bzip2 perl-modules lsof libc6-i386 rsync sudo` (`libsdl2-2.0.0:i386` commented out). Cleanup of lists, tmp.
- arkmanager install: latest build `curl -sL "https://git.io/arkmanager" | bash -s steam`; versioned build downloads `netinstall.sh` from raw.githubusercontent for `$AMG_VERSION` and runs `bash -s steam -- --unstable`. Symlinks `/usr/local/bin/arkmanager` to `/usr/bin/arkmanager`.
- COPY: `arkmanager/arkmanager.cfg` -> `/etc/arkmanager/arkmanager.cfg`; `arkmanager/instance.cfg` -> `/etc/arkmanager/instances/main.cfg`; `scripts/run.sh` -> `/home/steam/run.sh`; `scripts/log.sh`; `scripts/health-server.py`.
- User: writes `%sudo ALL=(ALL) NOPASSWD:ALL` to `/etc/sudoers`; adds `steam` to sudo; creates `/ark` and `/arkserver` owned by `steam`.
- `WORKDIR /home/steam`; `USER steam`; `VOLUME /ark` and `/arkserver`; `EXPOSE 8080`; no ENTRYPOINT; `CMD ["./run.sh"]`.
- HEALTHCHECK: interval 30s, timeout 15s, start period 120s, 3 retries; `arkmanager rconcmd "ListPlayers" || exit 1`.

**Env vars (Dockerfile ENV)**
- arkmanager: `am_ark_SessionName="Ark Server"`, `am_serverMap=TheIsland`, `am_ark_ServerAdminPassword=k3yb04rdc4t` (a default password; do not copy), `am_ark_MaxPlayers=70`, `am_ark_QueryPort=27015`, `am_ark_Port=7778`, `am_ark_RCONPort=32330`, `am_ark_AltSaveDirectoryName=SavedArks`, `am_arkwarnminutes=15`, `am_arkAutoUpdateOnStart=false`.
- Runtime flags: `VALIDATE_SAVE_EXISTS=false`, `BACKUP_ONSTART=false`, `LOG_RCONCHAT=0`, `ARKCLUSTER=false`, `HEALTH_SERVER=false`, `HEALTH_SERVER_PORT=8080`.
- run.sh reads: `ARKSERVER_SHARED` (default `/ark/server`), `AM_INSTALL_ARGS`, `AM_UPDATE_ARGS`, `ARKCLUSTER`, `LIST_MOUNTS`, `VALIDATE_SAVE_EXISTS`, `BACKUP_ONSTART`, `LOG_RCONCHAT`, `HEALTH_SERVER`, `HEALTH_SERVER_PORT`; `am_*` vars read by name: `am_ark_AltSaveDirectoryName`, `am_serverMap`, `am_arkAutoUpdateOnStart`, `am_ark_GameModIds`.

**Binaries/entrypoint (scripts/run.sh summary)**
- `set -eo pipefail`. Banner, permissions, directory creation, arkmanager.cfg generation, optional cron, optional save validation/backup, install or update, then start in the foreground.
- Dirs: `/ark/config`, `/ark/log`, `/ark/backup`, `/ark/staging`; creates `ShooterGame` tree if `Binaries` missing.
- Config: overwrites `/ark/config/arkmanager.cfg` with a 2-line header, appends `/ark/config/arkmanager_base.cfg` if present, appends `arkserverroot="$ARKSERVER"`, then appends `printenv | sed -n -r 's/am_(.*)=(.*)/\1=\"\2\"/ip'` (each `am_NAME=value` becomes `NAME="value"`).
- Install: `arkmanager install ${AM_INSTALL_ARGS}` if `appmanifest_376030.acf` is missing. Update: `arkmanager update --force --no-autostart ${AM_UPDATE_ARGS}` if `am_arkAutoUpdateOnStart=true`. Loops `checkupdate` every 10 s until success; `checkmodupdate --skip-workshop-dir` if mods set.
- Start: `arkmanager start --no-background --verbose` in a subshell, then `wait`.
- Stop trap: `trap stop INT QUIT TERM`; `stop` runs `broadcast`, `notify`, `stop`, `exit 0`. `set -m` enabled.
- Sudo: `sudo -n true` sets `HAS_PRIVILEGES`; with it, chowns `/ark`, `/home/steam` and `ShooterGame` and cluster Saved dirs, starts cron via `sudo service cron start`. Without privileges, the permission fix is skipped and cron runs `cron && tail -f /dev/null`.
- Default crontab (if `/ark/config/crontab` missing): `*/30 * * * * arkmanager update --update-mods --warn --saveworld`; `10 */8 * * * arkmanager saveworld && arkmanager backup`; `15 10 * * * arkmanager restart --warn --saveworld`.
- Cluster mode: requires a mount at `$ARKSERVER/ShooterGame/Saved/clusters`, else exit 1. Shared mode requires a mount at `$ARKSERVER_SHARED/ShooterGame/Saved`.
- Lock cleanup under `Saved`: `.ark-*.lock`, `.ark-update.time`, `.arkmanager-main.pid`, `.arkserver-main.pid`, `.autorestart`, `.autorestart-main`.
- Save check: `$am_serverMap.ark` must exist, else notify, sleep 5 min, exit 1.
- Health server: `python3 /home/steam/health-server.py` in the background when `HEALTH_SERVER=true`.

**Gotchas**
- Default admin password in the ENV (`k3yb04rdc4t`) and in the chart secret samples: do not carry over.
- The sudo/cron/chown behaviour is what plan.md drops (no sudo, no cron).
