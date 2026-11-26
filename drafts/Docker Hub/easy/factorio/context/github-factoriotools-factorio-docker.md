# factoriotools/factorio-docker

Source URL(s) + fetch date:
- https://github.com/factoriotools/factorio-docker (repo, README via https://raw.githubusercontent.com/factoriotools/factorio-docker/master/README.md)
- https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/docker/Dockerfile (same as https://github.com/factoriotools/factorio-docker/blob/446f2553eedb142eb6a25c670af7def2647ba24c/docker/Dockerfile)
- Fetched 2026-11-26

## What it is
Community Docker packaging of the Factorio headless server. Image `factoriotools/factorio`. Upstream license per plan.md: MIT.

## Install/build steps and build deps
Upstream Dockerfile (two stages, verbatim key lines from the fetch):
- Stage 1 `rcon-builder` on `debian:stable-slim`: `apt-get install build-essential`, copy `rcon/` to `/src`, `make` (builds RCON client).
- Stage 2 on `debian:stable-slim`: installs `ca-certificates curl jq pwgen xz-utils procps gettext-base file util-linux`.
- On aarch64 without `SHA256_ARM64`: also installs `unzip` and fetches box64 `v0.2.4` (`box64-GENERIC_ARM-RelWithDebInfo.zip` from ptitSeb/box64 releases) to `/bin/box64`.
- Creates group/user `factorio` with `PGID`/`PUID` default 845.
- Build args: `VERSION` (required), `SHA256` (required), `SHA256_ARM64` (optional), `PRESET`, `CURL_RETRIES` (default 8), `BOX64_VERSION`.
- Download: `curl -sSL https://www.factorio.com/get-download/$VERSION/headless/$platform` where platform is `linux64` or `linux-arm64` (arm64 chosen when `uname -m` is aarch64 and `SHA256_ARM64` set). Archive `/tmp/factorio_headless_${platform}_$VERSION.tar.xz`, verified with `sha256sum -c`.
- Extract with `tar xf ... --directory /opt`, `chmod ugo=rwx /opt/factorio`, symlink `/opt/factorio/bin/x64` to `arm64` if only arm64 exists, symlink `scenarios` and `saves` into `/opt/factorio`, `mkdir /opt/factorio/config/`, `chown -R factorio:factorio /opt/factorio /factorio`.
- Copies scripts, `config.ini`, and the built `rcon` binary.

## Runtime deps
ca-certificates, curl, jq, pwgen (rconpw generation), xz-utils, procps, gettext-base, file, util-linux. On aarch64 without native arm64 archive: box64 + unzip.

## Binaries/entrypoint/CLI flags
- `ENTRYPOINT ["/docker-entrypoint.sh"]`. No CMD, no USER instruction (the image's final USER is not set in the Dockerfile; the entrypoint handles PUID/PGID).
- Scenario entrypoint: `/scenario.sh` run with `--entrypoint` plus scenario name. `/scenario2map.sh` is deprecated.
- `docker exec factorio rcon <cmd>` (2.0.18+). Image includes `jq`.

## Env vars
| Variable | Default | Meaning |
| --- | --- | --- |
| PORT | 34197 | UDP game port (ENV in Dockerfile) |
| RCON_PORT | 27015 | RCON TCP port |
| SAVES | /factorio/saves | saves dir (ENV) |
| CONFIG | /factorio/config | config dir (ENV) |
| MODS | /factorio/mods | mods dir (ENV) |
| SCENARIOS | /factorio/scenarios | scenarios dir (ENV) |
| SCRIPTOUTPUT | /factorio/script-output | script output dir (ENV) |
| PUID / PGID | 845 | server user/group ID (regular images only) |
| DLC_SPACE_AGE | true | toggles Space Age mods in mod-list.json (2.0.8+) |
| PRESET | unset | map preset for a new map |
| GENERATE_NEW_SAVE | false | generate a new save if none exists |
| LOAD_LATEST_SAVE | true | load newest save; else load SAVE_NAME |
| SAVE_NAME | _autosave1 | save name or absolute path |
| BIND | unset | IP (v4/v6), optionally with port; port in BIND overrides PORT |
| TOKEN / USERNAME | unset | factorio.com credentials, mod updates only |
| UPDATE_MODS_ON_START | unset | update mods at start (needs credentials) |
| UPDATE_IGNORE | unset | comma-separated mods to skip |
| CONSOLE_LOG_LOCATION | unset | console log path |
| SERVER_SETTINGS_FILE | $CONFIG/server-settings.json | settings file |
| SERVER_ID_FILE | $CONFIG/server-id.json | identity file |
| SERVER_ADMINLIST_FILE | $CONFIG/server-adminlist.json | admin list |
| SERVER_BANLIST_FILE | $CONFIG/server-banlist.json | ban list |
| SERVER_WHITELIST_FILE | $CONFIG/server-whitelist.json | whitelist |

All env values are compared as strings; quote YAML values. Factorio does not expand env vars inside its JSON files.

## Ports
- `34197/udp` game (`EXPOSE $PORT/udp`).
- `27015/tcp` RCON (`EXPOSE $RCON_PORT/tcp`). Not publishing it disables outside RCON access; RCON still runs inside the container.

## Volumes/paths and persistent data
- `VOLUME /factorio` (single volume). Contents: `config/` (map-gen-settings.json, map-settings.json, rconpw, server-adminlist.json, server-banlist.json, server-settings.json, server-whitelist.json, server-id.json), `mods/` (mod zips), `saves/` (e.g. `_autosave1.zip`), `scenarios/`, `script-output/`.
- Game install is at `/opt/factorio` (not on the volume). Saves/scenarios are symlinked from /opt/factorio into /factorio.
- Entrypoint examples under `/factorio/entrypoints`.

## User/UID and permissions
- Regular image: starts as root, chowns `/factorio`, runs the server as `PUID:PGID` (845:845). Host dirs need `chown 845:845`.
- Rootless image (`-rootless` tag): UID 1000, no PUID/PGID support, no runtime chown, dirs created with open permissions at build time, flagged experimental.

## Config files and formats
- `server-settings.json` (main settings; `visibility.public` must be set explicitly for listing; `lan: true` for LAN), `map-gen-settings.json`, `map-settings.json`, `server-adminlist.json`, `server-banlist.json`, `server-whitelist.json`, `rconpw` (generated by pwgen if absent).

## Healthcheck/readiness
- Dockerfile HEALTHCHECK: `/docker-healthcheck.sh`, interval 30s, timeout 10s, start period 5m, 3 retries.
- Runs `rcon /players count` with 5-second timeout. Read-only, needs no published RCON port. Does not test external UDP connectivity. Docker reports starting/healthy/unhealthy and does not restart automatically. Disable with `healthcheck.disable: true` or `--no-healthcheck`.

## Version/release info and asset naming
- Docker Hub tags: `latest`, `stable`, `stable-<x.y.z>`, `<x.y.z>`, `0.x`, `0.x.y`, `0.x-z`; rootless variants end `-rootless`.
- Archive naming used by the Dockerfile: `factorio_headless_<platform>_<VERSION>.tar.xz` for the download cache; upstream download URL pattern `https://www.factorio.com/get-download/<VERSION>/headless/<linux64|linux-arm64>`.
- Build script: `python3 build.py --both` (dev only); `--changed-from GIT_REF` triggers rebuilds only for new versions or changed checksums.
- The README lists `2.1.25` as a tag on Docker Hub; the Docker Hub page summary lists `latest` as 2.1.24 (see Gotchas).
- Git tags of the repo: plan.md says none for 2.x (checked 2026-11-25); not re-verified here.

## Arch support
- amd64 (linux64) and arm64 (linux-arm64 native archive for 2.1+, per README and Docker Hub page). Older versions run x64 under box64 on arm64 (experimental, crashes/lag).

## Gotchas
- Plan.md section 1 notes the factorio.com get-download URL and the sha256sums page; both were consistent with this upstream Dockerfile (same URL pattern, same checksum approach).
- Upstream runs the game from `/opt/factorio/bin/x64/factorio`; plan.md section "Archive layout" says the same (arm64 uses `bin/arm64` with `x64` symlink).
- Upstream Dockerfile sets `EXPOSE 34197/udp 27015/tcp`; plan.md says RCON port is only open when `--rcon-port` is passed. These are compatible: EXPOSE is metadata; the plan's wording about the open port is a runtime-flag statement not made by upstream.
- Upstream README says `PUID` and `PGID` apply to regular images only. Plan.md's env list omits PUID/PGID (intentional, per plan).
- Changing PUID/PGID changes ownership of mounted data.
- Allow a long stop timeout (`docker stop --timeout 120`) so the world saves.
