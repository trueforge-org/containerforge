# OpenFactorioServerManager/factorio-server-manager (repo, docker/, wiki, flags, release zip)

Source URL(s) + fetch date:
- https://github.com/OpenFactorioServerManager/factorio-server-manager (repo page)
- https://raw.githubusercontent.com/OpenFactorioServerManager/factorio-server-manager/master/docker/Dockerfile
- https://raw.githubusercontent.com/OpenFactorioServerManager/factorio-server-manager/master/docker/entrypoint.sh
- https://github.com/OpenFactorioServerManager/factorio-server-manager/wiki/Installation-and-Usage
- https://raw.githubusercontent.com/OpenFactorioServerManager/factorio-server-manager/master/LICENSE returned HTTP 404 (repo ships `LICENSE.md`)
- Release zip `https://github.com/OpenFactorioServerManager/factorio-server-manager/releases/download/0.10.1/factorio-server-manager-linux-0.10.1.zip`: direct binary download, not fetched (recorded only).
- Fetched 2026-11-26

## What it is
- "A tool to help manage Factorio multiplayer servers including mods and save games." Starts/stops the Factorio binary, saves (upload/download/delete), mods, modpacks, logs, config, authentication, Docker availability.
- License: MIT (`LICENSE.md`, per README).
- Release version not shown on repo page. Plan's 0.10.1 comes from the draft's release URL.

## Upstream docker/Dockerfile (master)
- `FROM ubuntu` (no tag). Comment: glibc needed for Factorio server binaries.
- ENV `FACTORIO_VERSION=stable`, `MANAGER_VERSION=0.10.1`, `RCON_PASS=""`.
- RUN 1: `apt-get update && apt-get install -y curl tar xz unzip jq && rm -rf /var/lib/apt/lists/*`.
- WORKDIR `/opt`.
- RUN 2: `curl --location https://github.com/OpenFactorioServerManager/factorio-server-manager/releases/download/$MANAGER_VERSION/factorio-server-manager-linux-$MANAGER_VERSION.zip` to `/tmp/...zip`; `unzip`; `rm`; `mv factorio-server-manager fsm`.
- COPY `./entrypoint.sh /opt/entrypoint.sh`. No USER (runs as root). ENTRYPOINT `["/opt/entrypoint.sh"]`, no CMD.
- VOLUME `/opt/fsm-data`, `/opt/factorio/saves`, `/opt/factorio/mods`, `/opt/factorio/config`.
- EXPOSE `80/tcp`, `34197/udp`.

## Upstream docker/entrypoint.sh
- Reads only RCON_PASS (conditional) and FACTORIO_VERSION (no default; must be set). MANAGER_VERSION unused.
- `init_config` (only when `/opt/fsm-data/conf.json` missing): starts from `.`, adds `.rcon_pass = "$RCON_PASS"` if set and echoes the password to the log; always sets `.sq_lite_database_file = "/opt/fsm-data/sqlite.db"` and `.log_file = "/opt/fsm-data/factorio-server-manager.log"`; `jq ... /opt/fsm/conf.json > /opt/fsm-data/conf.json`.
- `install_game` (every start): `curl --location "https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64" --output /tmp/factorio_${FACTORIO_VERSION}.tar.xz`; `tar -xf` (no -C; unpacks into cwd); removes the tarball.
- Final: `cd /opt/fsm && ./factorio-server-manager --conf /opt/fsm-data/conf.json --dir /opt/factorio --port 80` (no exec).

## Wiki: Installation and Usage
- Docker: `docker pull ofsm/ofsm:latest`; `docker run --name ofsm -d -p 80:80 -p 34197:34197/udp ofsm/ofsm:latest`.
- Linux/Windows binary: get release, install Factorio standalone, run `./factorio-server-manager --dir /home/user/.factorio`; open localhost:8080.
- Flags (usage section):
  - `--bin` Factorio binary (default `bin/x64/factorio`)
  - `--conf` manager config (default `./conf.json`)
  - `--config` Factorio config.ini (default `config/config.ini`)
  - `--dir` Factorio directory (default `./`)
  - `--host` IP the web server listens on (default `0.0.0.0`)
  - `--max-upload` (default 20971520 = 20 MB)
  - `--port` web server port (default "8080" in the usage text; the newer config table lists `80`)
  - `--glibc-custom`, `--glibc-loc`, `--glibc-lib-loc` (custom glibc, defaults false, `/opt/glibc-2.18/lib/ld-2.18.so`, `/opt/glibc-2.18/lib`)
  - `--autostart` (default false)
- No `--bind` flag appears.
- Env precedence (since 0.11): defaults < env vars (prefixed `FSM_`) < conf.json < flags. `FSM_DIR` mentioned.
- Paths relative to Factorio root: `saves`, `mods`, `config`, `data/base`, `factorio-current.log`. Mod packs in `./mod_packs`. Mod portal login in `./factorio.auth`. SQLite default `sqlite.db`.
- `secure` option defaults to true (set false without TLS).
- RCON password `rcon_pass` randomly generated at startup by default (wiki).
- No default username/password documented on the wiki.
- No Factorio version compatibility statement.

## Factorio download (from entrypoint and plan)
- `https://www.factorio.com/get-download/<stable|version>/headless/linux64` (see factorio-api-latest-releases.md for the current version).

## Ports
- 80/tcp (upstream EXPOSE; wiki docker run). Wiki Linux examples use 8080. 34197/udp game.

## Gotchas
- Upstream Dockerfile has no ARG; version pins come from ENV and the zip URL.
- The upstream entrypoint prints the RCON password to the log.
