# factoriotools/factorio-docker (GitHub)

**Source URL(s) + fetch date**
- https://github.com/factoriotools/factorio-docker (linked from draft as source repository)
- https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/docker/Dockerfile (pinned commit from draft's Dockerfile link)
- https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/docker/docker-entrypoint.sh (404; the Dockerfile `COPY files/*.sh` puts it under `docker/files/`)
- https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/docker/files/docker-entrypoint.sh (fetched on retry)
- https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/README.md
- https://raw.githubusercontent.com/factoriotools/factorio-docker/446f2553eedb142eb6a25c670af7def2647ba24c/LICENSE
- Fetched 2026-11-26

**What it is**
Community Docker packaging of the Factorio headless server. Downloads the vendor headless tarball at build time, verifies its sha256, and runs it with an entrypoint script that generates config and saves.

**Install/build steps and build deps (Dockerfile)**
- Two stages. Stage 1 `debian:stable-slim` builds `rcon` (`build-essential`, `make`) and copies `/src/rcon` to `/bin/rcon`.
- Stage 2 `debian:stable-slim`. Packages: `ca-certificates curl jq pwgen xz-utils procps gettext-base file util-linux` (no recommends). On aarch64 with empty `SHA256_ARM64` it also installs `unzip` and fetches box64 (`v0.2.4`) (not used on native arm64 builds).
- Build args: `USER=factorio`, `GROUP=factorio`, `PUID=845`, `PGID=845`, `BOX64_VERSION=v0.2.4`, `SHA256_ARM64` (empty), `PRESET`, `CURL_RETRIES=8`, `VERSION` (required), `SHA256` (required).
- User: `groupadd --system --gid $PGID`, `useradd --system --uid $PUID --gid $PGID --no-create-home --shell /bin/sh`.
- Download: platform `linux64` (x64) or `linux-arm64` (when aarch64 and `SHA256_ARM64` set). URL `https://www.factorio.com/get-download/$VERSION/headless/$platform`, `curl -sSL --retry $CURL_RETRIES`, archive `/tmp/factorio_headless_${platform}_$VERSION.tar.xz`.
- Checksum: `echo "$sha256  $archive" | sha256sum -c`; exits 1 on mismatch.
- Extract: `tar xf` into `/opt`, `chmod ugo=rwx /opt/factorio`. If `bin/arm64` exists and `bin/x64` does not, symlinks `x64` to `arm64`.
- Symlinks `$SCENARIOS` and `$SAVES` into `/opt/factorio`, creates `/opt/factorio/config/`, `chown -R factorio:factorio /opt/factorio /factorio`.
- COPY `files/*.sh` to `/`; `files/config.ini` to `/opt/factorio/config/config.ini`; rcon binary to `/bin/rcon`.

**Runtime deps**
Debian packages above (curl, jq, pwgen, xz-utils, procps, gettext-base, file, util-linux). The entrypoint uses them.

**Binaries/entrypoint/CLI flags**
- ENTRYPOINT `["/docker-entrypoint.sh"]`, no CMD.
- Entrypoint behaviour (from docker/files/docker-entrypoint.sh):
  - Shell `set -eoux pipefail`. Volume fixed at `/factorio`; `$CONFIG/rconpw` generated with `pwgen 15 1` if missing, kept if present.
  - Deletes incomplete `*.tmp.zip` in `$SAVES`. If no `.zip` exists or `GENERATE_NEW_SAVE=true`, creates `$SAVE_FILE` with `/opt/factorio/bin/x64/factorio --create`, `--preset` if set, `--map-gen-settings "$CONFIG/map-gen-settings.json"`, `--map-settings "$CONFIG/map-settings.json"`. Skips creation if the file already exists.
  - Copies missing `server-settings.json`, `map-gen-settings.json`, `map-settings.json` from `/opt/factorio/data/*.example.json`.
  - `sed -i '/write-data=/c\write-data=\/factorio/' /opt/factorio/config/config.ini`.
  - Server flags: `--server-settings`, `--server-banlist`, `--rcon-port`, `--server-whitelist`, `--rcon-password "$(cat rconpw)"`, `--server-id`, `--mod-directory`; `--use-server-whitelist` (bare flag) and `--server-adminlist` unless VERSION is 0.15.* or 0.16.*; `--console-log` if set; `--bind` if set; `--port` unless BIND already has a port; `--start-server-load-latest` when `LOAD_LATEST_SAVE=true`, else `--start-server "$SAVE_FILE"`. Ends with `exec ... factorio "${FLAGS[@]}" "$@"`.
  - `docker-update-mods.sh` runs when enabled; `docker-dlc.sh` always runs.
- HEALTHCHECK: `--interval=30s --timeout=10s --start-period=5m --retries=3 CMD ["/docker-healthcheck.sh"]`.
- Server binary path: `/opt/factorio/bin/x64/factorio` (arm64 build at `bin/arm64`, symlinked to `x64`).
- Entrypoint launches the server with the flags documented on the wiki (see docs-wiki-factorio-com.md), including `--config`, `--server-settings`, `--server-banlist`, `--server-whitelist`, `--use-server-whitelist`, `--server-adminlist`, `--server-id`, `--start-server-load-latest` or `--start-server`, `--port`, `--rcon-port`, `--rcon-password`, `--bind`, `--preset`, `--create`.
- `rcon` helper binary at `/bin/rcon`.

**Env vars (table, image defaults)**

| Name | Default | Notes |
| --- | --- | --- |
| `PORT` | `34197` | Game port, UDP. |
| `RCON_PORT` | `27015` | RCON, TCP. |
| `BIND` | unset | `IP[:PORT]`; explicit port overrides `PORT`. |
| `SAVES` | `/factorio/saves` | ENV in image. |
| `CONFIG` | `/factorio/config` | ENV in image. |
| `MODS` | `/factorio/mods` | ENV in image. |
| `SCENARIOS` | `/factorio/scenarios` | ENV in image. |
| `SCRIPTOUTPUT` | `/factorio/script-output` | ENV in image. |
| `SAVE_NAME` | `_autosave1` | |
| `LOAD_LATEST_SAVE` | `true` | |
| `GENERATE_NEW_SAVE` | `false` | |
| `PRESET` | unset | Examples: default, rich-resources, marathon, death-world, death-world-marathon, rail-world, ribbon-world. |
| `PUID` / `PGID` | `845` / `845` | Regular images only. |
| `DLC_SPACE_AGE` | `true` | ENV in image. |
| `TOKEN` / `USERNAME` | unset | factorio.com credentials for mod updates. |
| `UPDATE_MODS_ON_START` | unset | |
| `UPDATE_IGNORE` | unset | Comma-separated mod names. |
| `CONSOLE_LOG_LOCATION` | unset | |
| `SERVER_SETTINGS_FILE` | `$CONFIG/server-settings.json` | |
| `SERVER_ID_FILE` | `$CONFIG/server-id.json` | |
| `SERVER_ADMINLIST_FILE` | `$CONFIG/server-adminlist.json` | |
| `SERVER_BANLIST_FILE` | `$CONFIG/server-banlist.json` | |
| `SERVER_WHITELIST_FILE` | `$CONFIG/server-whitelist.json` | |

**Ports**
- `34197/udp` game (EXPOSE `$PORT/udp`)
- `27015/tcp` RCON (EXPOSE `$RCON_PORT/tcp`); only opened when rcon is passed.

**Volumes/paths and persistent data**
- VOLUME `/factorio`, holding `config/` (map-gen-settings, map-settings, rconpw, server-settings, admin, ban and whitelist files), `mods/`, `saves/`.
- The README's quick start mounts a host folder at `/factorio`.

**User/UID & permissions**
- Regular image runs as `factorio` UID/GID 845 via ENTRYPOINT logic (PUID/PGID). Files should be owned by 845 in regular images.
- Dockerfile has no `USER` instruction. The entrypoint runs as root only if `id -u` is 0: it remaps `factorio` with `usermod -o -u $PUID` / `groupmod -o -g $PGID`, runs `chown -R factorio:factorio /factorio`, then execs the server through `setpriv --reuid=factorio --regid=factorio --init-groups --`. If not root, it runs the binary as the current user with no `setpriv`.
- Rootless variants (`-rootless` tag suffix, e.g. `stable-rootless`) run as UID 1000 and ignore PUID/PGID; labelled experimental.

**Config files and formats**
- `files/config.ini` seeded to `/opt/factorio/config/config.ini`.
- `server-settings.json`, `map-gen-settings.json`, `map-settings.json` generated under `$CONFIG` by the entrypoint from example files (per README: settings generated at `/opt/factorio/config/server-settings.json`).

**Healthcheck/readiness endpoints**
`/docker-healthcheck.sh` (script not fetched). Start period 5 minutes.

**Version/release info and asset naming**
- Image build args `VERSION` and `SHA256` are required; version is supplied externally.
- Vendor archive naming: `factorio-headless_linux_<version>.tar.xz` (x64) and `factorio-headless_linux-arm64_<version>.tar.xz` (arm64). Download page pattern: `https://www.factorio.com/get-download/<version>/headless/<linux64|linux-arm64>`.
- Factorio 2.1+ has a native `linux-arm64` headless build; older versions run x64 under box64 (experimental).

**Arch support**
x64 (`linux64`) and arm64 (`linux-arm64`, 2.1+ only, native). Older arm64 uses box64 emulation (experimental).

**Gotchas**
- Dockerfile uses `www.factorio.com`; plan.md uses `factorio.com` (redirect target).
- Rootless and regular images differ in UID handling.
- TrueCharts probes use the RCON TCP port, so RCON must be enabled for the chart's health checks to pass.
- Container stop should use long timeout (`docker stop --timeout 120`) so large saves finish writing.

**License**
LICENSE is the MIT License, "Copyright (c) 2016" (no holder named). This is the packaging repo; the game is proprietary and not covered by this license.

**Contradictions with plan.md**
- plan.md says the Docker Hub image has `2.1.25` and the factoriotools git tags have no 2.x. Git tags not checked here; Docker Hub listing fetched shows `latest` and `2.1.24` only (see dockerhub summary).
- plan.md section 1 says this repo is MIT. Confirmed by LICENSE.
- plan.md section 4 uses `https://factorio.com/get-download/...`; upstream uses `https://www.factorio.com/...`. Both are the same site, so not a correction.
