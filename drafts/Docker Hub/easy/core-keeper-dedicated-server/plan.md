# core-keeper-dedicated-server — implementation plan
> Source: ./draft.md · Target: apps/core-keeper-dedicated-server/ · Difficulty: easy (largest of the six: two processes, Steam download at runtime) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Software | Core Keeper Dedicated Server, Steam app `1963720` ("Core Keeper Dedicated Server" tool). Closed source, proprietary; downloaded with SteamCMD using an anonymous login. Not redistributable inside the image. |
| Reference wrapper | `escaping/core-keeper-dedicated` (https://github.com/escapingnetwork/core-keeper-dedicated, HEAD `5448b12a...` is the commit the draft links). Reviewed: `Dockerfile`, `README.md`, `scripts/setup.sh`, `scripts/launch.sh`, `scripts/compile-parameters.sh`. |
| Version | Not versioned by upstream in any way renovate can read. The Steam build changes with every game update and is resolved at start (see section 10). Draft has no version. |
| Renovate | UNVERIFIED / not applicable for the game. For `VERSION` use `datasource=docker depName=ghcr.io/trueforge-org/steamcmd` (see section 5). |
| License | The game server is proprietary (Steam subscriber agreement). It is not part of the image, so the bake `LICENSE` is the repo's `AGPL-3.0-or-later`, as in the siblings `apps/steamcmd` and `apps/hytale`. |
| Source (`SOURCE`, `upstream_env_url`) | https://store.steampowered.com/app/1963720/ |
| Download | amd64 only, via SteamCMD: `app_update 1007` (Steamworks SDK Redist, provides `steamclient.so`) and `app_update 1963720` into one install dir, exactly as upstream `setup.sh` does (`+login anonymous`, `+@sSteamCmdForcePlatformType linux`, `+@sSteamCmdForcePlatformBitness 64`). Upstream's arm64 variant runs the x64 server through Box64, which we do not support. |
| Checksum | None published; SteamCMD verifies content itself (`validate`). |
| Server binary / launch | `./CoreKeeperServer` in the install dir, started under a virtual display: `Xvfb :99 -screen 0 1x1x24 -nolisten tcp &` then `DISPLAY=:99 LD_LIBRARY_PATH=<steamclient dir> ./CoreKeeperServer -batchmode -logfile <file> ...`. |
| Server flags / env (upstream compile-parameters.sh) | `WORLD_INDEX`->`-world` (default 0), `WORLD_NAME`->`-worldname` ("Core Keeper Server"), `WORLD_SEED`->`-worldseed`, `WORLD_MODE`->`-worldmode` (0 normal, 1 hard, 2 creative, 4 casual), `HASHED_WORLD_SEED`->`-hashedworldseed`, `GAME_ID`->`-gameid` (15-28 alphanumeric chars), `DATA_PATH`->`-datapath`, `MAX_PLAYERS`->`-maxplayers` (10), `SEASON`->`-season`, `SERVER_IP`->`-ip`, `SERVER_PORT`->`-port`, `PASSWORD`->`-password`, `ACTIVATE_CONTENT`->`-activatecontent`, `ACTIVATE_ALL_CONTENT`=true->`-activateallcontent`, `ALLOW_ONLY_PLATFORM`->`-allowonlyplatform`. Empty values are not passed. |
| Network | Two modes (upstream README). With `SERVER_PORT` empty the server uses Steam Datagram Relay: outbound only, no listening port, the Game ID is written to `GameID.txt` next to the executable. With `SERVER_PORT` set it uses Direct Connect on that UDP port. The draft's `27015/udp` is only "inferred" and is NOT in the upstream docs: UNVERIFIED, do not declare it. |
| Paths upstream | Server files `/home/steam/core-keeper-dedicated`, data `/home/steam/core-keeper-data` (these are the chart's two PVCs). |
| Packages upstream | `xvfb libxi6 tini tzdata gosu jo jq gettext-base unzip wget` (plus Box64 libs on arm64). The ubuntu base already has `tini tzdata jq gettext-base unzip wget`, so only `xvfb` and `libxi6` are new. |
| Upstream extras not planned for v1 | Discord webhooks, mod.io mods (`MODS_ENABLED`, `MODIO_*`, `MODS`), `USE_DEPOT_DOWNLOADER`, `PUID`/`PGID` (we are always UID 568). |

## 2. Target layout

```
apps/core-keeper-dedicated-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- No `defaults/`, `etc/`, `scripts/`, `health/`: the game creates its own config and world files.
- No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses this image as a `FROM` base).
- Dependency container `steamcmd` exists (`apps/steamcmd`) and is used as the base. Closest siblings: `apps/steamcmd` (SteamCMD install and `start.sh` helper), `apps/hytale` (game server with amd64-only `image-all`), `apps/luanti` (UDP-only test with `filePaths`).

## 3. Base image

```
FROM ghcr.io/trueforge-org/steamcmd:20180105.0.0@sha256:8b67db010bcf272055df719d0d6c0d5b4c265374ecf45d1615ef8b396f67933c
```

The tag and digest were read from the GHCR registry on 2026-11-23 (tags `20180105.0.0`, `20180105.0`, `20180105`, `rolling` exist). Re-check the digest at implementation time (`docker buildx imagetools inspect`). The base already contains the pinned `steamcmd` deb (i386 packages enabled), a first-run copy of SteamCMD into `/config/Steam/steamcmd`, and a `start.sh` that downloads Steam apps. It is built on `ghcr.io/trueforge-org/ubuntu:26.4` and is amd64 only. No other `apps/*/Dockerfile` uses it as `FROM` yet, so this is the first consumer: no downstream change in this repo.

## 4. Dockerfile

1. `FROM` as in section 3. `ARG VERSION`.
2. `USER root` for installs only.
3. Keep the base's installer: `RUN cp /start.sh /usr/local/bin/steamcmd-start.sh && chmod 0755 /usr/local/bin/steamcmd-start.sh` before our own `start.sh` replaces `/start.sh` (the base `steamcmd` wrapper also execs `/start.sh`, which is acceptable here).
4. `RUN apt-get update && apt-get install -y --no-install-recommends xvfb libxi6 && rm -rf /var/lib/apt/lists/*`. These are runtime libraries for the Unity server and not the app itself, so they are not version-pinned. Add `xauth` only if `xvfb-run` is chosen instead of plain `Xvfb`. Unity may need further libraries (UNVERIFIED, discovered during the first run; upstream only installs `libxi6`).
5. `ENV HOME=/config STEAM_INSTALL_DIR=/config/server`.
6. `COPY --chmod=0755 . /` (installs `/start.sh`).
7. No `EXPOSE`: no port is open in the default (SDR) mode. In Direct Connect mode the user publishes the UDP port they chose (documented in `settings.yaml` comment). `VOLUME /config`.
8. Final `USER apps`.

The game is NOT downloaded at build time (large, licence-restricted, changes constantly) but on container start into `/config/server`, never into the read-only `/app`.

## 5. docker-bake.hcl

- `APP` = `core-keeper-dedicated-server`
- `VERSION` mirrors the SteamCMD base tag so the image tag and the base stay aligned (the game build is not a renovate-readable version):
  ```hcl
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd
  default = "20180105.0.0"
  ```
  Open question for maintainers (section 10): another scheme (for example the Steam public build id) would need a custom manager.
- `LICENSE` = `AGPL-3.0-or-later`
- `SOURCE` = `https://store.steampowered.com/app/1963720/`
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default"`. As in `apps/steamcmd/docker-bake.hcl`, `image-all` lists only `linux/amd64` (the Steam depot is x86-64 only).
- Validate: `cd apps/core-keeper-dedicated-server && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/1963720/"
ports:
  []   # Default Steam relay mode opens no port. Direct Connect mode listens on the UDP port given in SERVER_PORT.
env:
  - { name: WORLD_INDEX, default: "0", required: false }
  - { name: WORLD_NAME, default: "Core Keeper Server", required: false }
  - { name: WORLD_SEED, default: "", required: false }
  - { name: HASHED_WORLD_SEED, default: "", required: false }
  - { name: WORLD_MODE, default: "0", required: false }
  - { name: GAME_ID, default: "", required: false }
  - { name: MAX_PLAYERS, default: "10", required: false }
  - { name: SEASON, default: "", required: false }
  - { name: SERVER_IP, default: "", required: false }
  - { name: SERVER_PORT, default: "", required: false }
  - { name: PASSWORD, default: "", required: false }
  - { name: ACTIVATE_CONTENT, default: "", required: false }
  - { name: ACTIVATE_ALL_CONTENT, default: "false", required: false }
  - { name: ALLOW_ONLY_PLATFORM, default: "", required: false }
  - { name: SKIP_UPDATE, default: "false", required: false }   # our own start.sh switch: do not contact Steam when the server is already installed
  - { name: TZ, default: "Etc/UTC", required: false }
volumes:
  - path: /config
    required: true
```

Use the repo's one-entry-per-block style (as in the siblings) when writing the real file; the flow style above is just compact. Names match the upstream wrapper so existing TrueCharts values map directly. Dependencies: `steamcmd` is a build-time base (FROM), not a runtime container, so `dependencies:` stays empty (note for reviewers: `steamcmd` exists in `apps/` ✅).

## 7. start.sh

Flow (bash, `set -euo pipefail`):

1. `export HOME=/config`; `SERVER_DIR=/config/server`; `DATA_DIR=/config/data`; `mkdir -p "$SERVER_DIR" "$DATA_DIR"`.
2. Install or update (idempotent, only when needed):
   `if [ "${SKIP_UPDATE:-false}" != "true" ] || [ ! -x "$SERVER_DIR/CoreKeeperServer" ]; then STEAM_APP_IDS=1007,1963720 STEAM_INSTALL_DIR="$SERVER_DIR" STEAMCMD_PRE_UPDATE=false /usr/local/bin/steamcmd-start.sh +quit; fi`
   (uses the base image's `STEAM_APP_IDS`/`STEAM_INSTALL_DIR` logic, which does `force_install_dir`, `app_update <id>` per id, anonymous login. UNVERIFIED: that the extra `+@sSteamCmdForcePlatform*` arguments from upstream are not needed on this base. If the server download complains, run the app update with them through the base's script arguments.) Fail with a clear error if `CoreKeeperServer` is missing afterwards.
3. `chmod +x "$SERVER_DIR/CoreKeeperServer"` only if not executable (the file lives in the writable `/config`).
4. Build the argument array exactly like upstream: always `-batchmode -logfile /tmp/corekeeper.log -datapath /config/data`, then each non-empty variable of section 1 to its flag; `ACTIVATE_ALL_CONTENT=true` adds `-activateallcontent`. Quote every value (array, no `eval`), so spaces in `WORLD_NAME` and special characters in `PASSWORD` are safe. The password never goes into a file.
5. `rm -f "$SERVER_DIR/GameID.txt" "$SERVER_DIR/GameInfo.txt"`; `mkdir -p -m 1777 /tmp/.X11-unix` (the tmpfs `/tmp` is empty at start; UNVERIFIED that Xvfb needs it); `touch /tmp/corekeeper.log`.
6. `Xvfb :99 -screen 0 1x1x24 -nolisten tcp &`, `tail -n +1 -F /tmp/corekeeper.log &` (so logs reach `docker logs`).
7. `export DISPLAY=:99 LD_LIBRARY_PATH="$SERVER_DIR/linux64:${LD_LIBRARY_PATH:-}"` (UNVERIFIED: where `steamclient.so` from app 1007 lands; upstream uses `<steamcmd>/linux64`, so verify with `find /config/server -name 'steamclient*'`).
8. Start `"$SERVER_DIR/CoreKeeperServer" "${params[@]}" &`, record the PID, `trap 'kill -TERM "$pid"; wait "$pid"' TERM INT`, and `wait` for it. This is a documented exception to "SHOULD `exec`": two helper processes (Xvfb, tail) must be reaped, so the script forwards signals itself; tini from the base is PID 1 anyway.
9. On exit stop Xvfb and tail.

Binding: SDR mode needs no listener; Direct Connect uses `-ip ${SERVER_IP}` (empty means `0.0.0.0` per upstream docs). Nothing is written to `/app`; caches and logs go to `/tmp`; saves go to `/config/data`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
# No tcp/http probe: the default Steam relay mode opens no port and Direct Connect is UDP,
# and the game files are downloaded from Steam at first start (not available to an offline smoke test).
runners:
- entrypoint: test -x /usr/bin/Xvfb
filePaths:
- /start.sh
- /usr/local/bin/steamcmd-start.sh
- /usr/local/share/steamcmd/steamcmd.sh
- /usr/bin/Xvfb
```

- `settings.yaml` lists no ports, so no probe is missing. The real server path (Steam download, world creation, `GameID.txt`) is verified manually per section 11; the forgetool run passes no env vars and has no Steam access guarantee.
- If the maintainers want a runtime assertion, a `healthCommands` entry that checks `pgrep -f CoreKeeperServer` could be added after the first successful manual run, but it would need Steam network access in CI (UNVERIFIED), so it is not planned.

## 9. Rootless and read-only-rootfs adaptations

| Upstream path / behaviour | Remap |
|---|---|
| `/home/steam/core-keeper-dedicated` (server files PVC) | `/config/server` |
| `/home/steam/core-keeper-data` (world data PVC, `-datapath`) | `/config/data` |
| `${STEAMCMDDIR}` SteamCMD self-update and `~/.steam` | `HOME=/config`; base `start.sh` copies SteamCMD to `/config/Steam/steamcmd` when missing |
| `logs/<date>.log` inside the server dir | `/tmp/corekeeper.log` (ephemeral), streamed with `tail` |
| `/tmp/.X11-unix` created in image at build | `mkdir -p -m 1777` in `start.sh` (tmpfs at runtime) |
| `PUID`/`PGID` and `gosu` | dropped; the container is always UID 568 (`apps`) |

Draft expectations reconciled: the chart runs as root with a writable rootfs; we run rootless (UID 568), `readOnlyRootFilesystem: true`, not privileged. The draft's Reason says saves are in `/config` while the chart uses two directories: this plan consolidates both under one persistent volume `/config` (`server/` and `data/`). Migration note for the PR: existing chart data in `core-keeper-data` must be moved to `/config/data` (and `core-keeper-dedicated` to `/config/server`, or simply re-downloaded).

## 10. Risks, caveats and open questions

- amd64 only (confirmed: x86-64 Steam depot, `arm64: no` in the draft). `image-all` must list only `linux/amd64`.
- Needs outbound access to Steam at first start; the download is large and the first start is slow. A restart with `SKIP_UPDATE=true` avoids it.
- Version tracking: neither renovate nor the Steam depot gives a version for `VERSION`; tag mirrors the base. Open question: acceptable to maintainers, or use a different scheme?
- The draft's `27015/udp` is unverified and was dropped; Direct Connect port is user-defined.
- UNVERIFIED during this pass (needs the first container run): extra shared libraries for the Unity server, the location of `steamclient.so`, whether `STEAM_APP_IDS` handling in the base script is enough without the platform-force arguments, Xvfb needing `/tmp/.X11-unix`, whether the log line for readiness is `Game ID: ...` (upstream says `GameID.txt` appears).
- `steamcmd` base is an image of our own (`AGPL-3.0-or-later` label); the Valve SteamCMD licence applies to what it downloads.
- Discord notifications and mod.io mod support from upstream are intentionally out of scope for the first version.
- No hard blocker: glibc Ubuntu base, no privileged mode needed.

## 11. Build and test steps

```sh
cd apps/core-keeper-dedicated-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create core-keeper-dedicated-server-probe-config
docker run --rm -d --name core-keeper-dedicated-server-probe --read-only --tmpfs /tmp \
  -v core-keeper-dedicated-server-probe-config:/config core-keeper-dedicated-server:20180105.0.0
docker logs -f core-keeper-dedicated-server-probe
```

- Expected signals: SteamCMD prints `Success! App '1963720' fully installed.`, then the server log shows the world loading and a Game ID; `/config/server/GameID.txt` exists (`docker exec ... cat /config/server/GameID.txt`); the container keeps running with no fatal errors. First start can take several minutes.
- Repeat once to prove idempotency: restart the same container with `-e SKIP_UPDATE=true` and the same volume.
- Also try Direct Connect: `-e SERVER_PORT=27015 -p 27015:27015/udp` (any port) and confirm the process stays up.
- Cleanup: `docker rm -f core-keeper-dedicated-server-probe; docker volume rm core-keeper-dedicated-server-probe-config`.
- Then: `forgetool containers test --image core-keeper-dedicated-server:20180105.0.0 --config ./apps/core-keeper-dedicated-server/container-test.yaml`.

## 12. PR checklist

- Branch `feat/add-core-keeper-dedicated-server`, commit and PR title `feat(core-keeper-dedicated-server): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, only check boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- State honestly what is untested: any real Steam download and server start (if Steam access was unavailable), Direct Connect mode, arm64 (unsupported by design), mods and Discord features (not implemented).
- `docker buildx bake --print` before commit; changes only under `apps/core-keeper-dedicated-server/`.
