# Devidian/docker-spaceengineers Dockerfile + entrypoint.sh + healthcheck.sh

Source URL(s): https://github.com/Devidian/docker-spaceengineers/blob/26569e3/Dockerfile (raw, fetched 2026-11-26); follow-ups at same commit: entrypoint.sh, healthcheck.sh (raw).

## Dockerfile
- `FROM debian:bookworm-20241016-slim`, `WORKDIR /root`
- ARG: `DEBIAN_FRONTEND=noninteractive`, `WINEBRANCH=stable`, `WINEVERSION=9.0.0.0~bookworm-1`
- ENV: `WINEARCH=win64`, `WINEDEBUG=-all`, `WINEPREFIX=/root/server`, `APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1`
- `dpkg --add-architecture i386`; apt: software-properties-common curl gnupg2 wget; WineHQ key from dl.winehq.org, `winehq-bookworm.sources`; non-free from ftp.us.debian.org
- libfaudio0 (+ i386)
- apt: `winehq-${WINEBRANCH}=${WINEVERSION}`, `wine-${WINEBRANCH}-i386`, `wine-${WINEBRANCH}-amd64`, `wine-${WINEBRANCH}`, `steamcmd`, `xvfb`, `cabextract`
- winetricks script from raw.githubusercontent Winetricks master -> /usr/local/bin/winetricks (unpinned)
- `COPY winetricks.sh /root/` then `/root/winetricks.sh` (build-time bulk); removes gnupg2 and software-properties-common; autoremove; clean; rm /var/lib/{apt,dpkg,cache,log}
- `COPY healthcheck.sh /root/`; HEALTHCHECK `--interval=60s --timeout=60s --start-period=600s --retries=3` CMD `/root/healthcheck.sh`
- `COPY entrypoint.sh /root/`; `ENTRYPOINT /root/entrypoint.sh`
- Runs as root (no USER line).

## entrypoint.sh (summary)
- Vars: `GAME_DIR=/appdata/space-engineers/SpaceEngineersDedicated`, `INSTANCES_DIR=/appdata/space-engineers/instances`, `PLUGIN_DIR=/appdata/space-engineers/plugins`, `CONFIG_PATH=${INSTANCES_DIR}/${INSTANCE_NAME}/SpaceEngineers-Dedicated.cfg`, `INSTANCE_IP=$(hostname -I)`
- Install/update: `/usr/games/steamcmd +force_install_dir ${GAME_DIR} +login anonymous +@sSteamCmdForcePlatformType windows +app_update 298740 +quit` (Steam app 298740, Windows platform)
- Patches CONFIG_PATH: `<IP>` -> INSTANCE_IP; `<LoadWorld>` -> `Z:\appdata\space-engineers\instances\${INSTANCE_NAME}\Saves\<WorldName>`; `<Plugins>` from *.dll in PLUGIN_DIR
- `mkdir -p ${INSTANCES_DIR}/${INSTANCE_NAME}`; `rm ${INSTANCES_DIR}/${INSTANCE_NAME}/*.log`
- Start: `cd ${GAME_DIR}/DedicatedServer64/`; `wine SpaceEngineersDedicated.exe -noconsole -ignorelastsession -path Z:\\appdata\\space-engineers\\instances\\${INSTANCE_NAME}`
- Requires `INSTANCE_NAME` (no default in script), config file must exist already (no creation).

## healthcheck.sh (summary)
- `curl https://api.steampowered.com/ISteamApps/GetServersAtAddress/v1?addr=${PUBLIC_IP}`; exit 0 if output contains "Space", else 1.
- Requires `PUBLIC_IP`.

## Gotchas
- Wine 9.0 stable line; Debian bookworm-era base pinned by date tag.
- Instance config must be created beforehand (SE Dedicated Server tool), per README.
