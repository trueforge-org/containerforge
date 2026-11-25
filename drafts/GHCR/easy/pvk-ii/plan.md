# pvk-ii — implementation plan
> Source: ./draft.md · Target: apps/pvk-ii/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No upstream version: Steam app **17575** (`pvkii`), updated by SteamCMD at start. Chart pins wrapper tag `ghcr.io/ich777/steamcmd:pvkii@sha256:22d30823...`. UNVERIFIED: no server build id fetched. |
| Draft corrections | Draft lists only `27015/udp`. Chart exposes `27015/udp` (main) and `27015/tcp` (tcprcon). Add both. |
| Renovate | None usable for the game (no upstream version). Track the base `apps/steamcmd` line. |
| License | UNVERIFIED: proprietary Steam content. Decide with the maintainer; base steamcmd is `AGPL-3.0-or-later`. |
| Source URL | https://store.steampowered.com/app/ (draft). Steam app id 17575. SteamCMD wiki: https://developer.valvesoftware.com/wiki/SteamCMD |
| Download | SteamCMD `+force_install_dir <dir> +login anonymous +app_update 17575 [validate] +quit`. amd64 only. |
| Checksum source | None published. SteamCMD `validate`. |
| Upstream Dockerfile reviewed | ich777 wrapper (same as postscriptum): https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile. Runs as root, ENTRYPOINT `/opt/scripts/start.sh`, no EXPOSE, no VOLUME. |
| Launch line (verified) | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh: `cd ${SERVER_DIR}` then `${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`. Chart: `GAME_NAME=pvkii`, `GAME_PARAMS=-maxplayers 18 +map bt_island`, `GAME_PORT=27015`. |
| Env vars (chart, real) | `GAME_ID=17575`, `GAME_NAME=pvkii`, `GAME_PARAMS`, `GAME_PORT=27015`, `DATA_PERM=770`, `VALIDATE=false`, `USERNAME=""`, `PASSWRD` (secret `env-secrets`). |
| Data path | Wrapper writes `/serverdata/serverfiles` and `/serverdata/steamcmd`. Map to `/config/serverfiles` and `/config/steamcmd`. |
| Blocker | None found for the launch line. arm64 is not supported (x86 SteamCMD bootstrap). |

## 2. Target layout

- `apps/pvk-ii/Dockerfile`
- `apps/pvk-ii/docker-bake.hcl`
- `apps/pvk-ii/settings.yaml`
- `apps/pvk-ii/container-test.yaml`
- `apps/pvk-ii/start.sh`

No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<VERSION>` (the `apps/steamcmd` image, which provides the 32-bit SteamCMD and the lib32 deps through the i386 package). Closest sibling: `apps/steamcmd`. The steamcmd digest is not in this repo; pin it from the published image before merge (UNVERIFIED digest).

## 4. Dockerfile

1. `ARG VERSION`.
2. `USER root` only if lib32 packages are missing at runtime (pin to the base release if added).
3. `ENV HOME=/config`.
4. `COPY --chmod=0755 start.sh /start.sh`.
5. `USER apps`, `COPY --chmod=0755 . /`.

## 5. docker-bake.hcl

- `APP = "pvk-ii"`, `VERSION` with renovate annotation for the base image (`datasource=docker depName=ghcr.io/trueforge-org/steamcmd`), `LICENSE` per section 1, `SOURCE = "https://store.steampowered.com/app/17575"`.
- Standard targets; `image-all` is amd64 only.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url` = SOURCE.
- `ports`: `27015` udp (required: true, game), `27015` tcp (required: false, RCON).
- `env`: `STEAM_APP_VALIDATE` default `false`, `GAME_PARAMS` default `-maxplayers 18 +map bt_island`, `GAME_PORT` default `27015`, `TZ` default `Etc/UTC`. Only vars this plan's `start.sh` reads (`STEAM_APP_IDS` belongs to the base `/start.sh`, which is replaced; the app id 17575 is hard-coded). The wrapper's `USERNAME`/`PASSWRD` are the Steam login (anonymous is enough for this app, UNVERIFIED), not a game password; do not add them unless a login is needed, and then read the password from env only.
- `volumes`: `/config` (required: true).
- `dependencies`: none.

## 7. start.sh

1. `set -euo pipefail`, `export HOME=/config`.
2. Create `/config/serverfiles` and `/config/steamcmd` (idempotent).
3. Run SteamCMD (bootstrap from `/config/Steam/steamcmd/steamcmd.sh`, as in `apps/steamcmd/start.sh`) with `force_install_dir /config/serverfiles`, `app_update 17575` (+`validate` when enabled). Do not exec the steamcmd image's start.sh with `+` args: it would run steamcmd interactively.
4. `cd /config/serverfiles`, `exec ./srcds_run -game pvkii ${GAME_PARAMS} -console +port ${GAME_PORT}`. Pass env values safely (no shell eval of user input).
5. No writes to `/app`. Temp in `/tmp`.

## 8. container-test.yaml

- Schema header from `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh`, `/usr/local/share/steamcmd/steamcmd.sh`.
- Probes: `tcp` on `27015` (RCON/TCP; UNVERIFIED that the server listens on TCP 27015 in the unprovisioned test run, since the game is downloaded at start; if it does not, state the reason in the test file rather than weakening it). The test runs with no env vars and no game content: the server only listens after the SteamCMD download. Use a long `timeoutSeconds` (sibling family value), and add the start-up path to `filePaths`. The UDP game port has no tcp probe (open question as in postscriptum).
- No DB dependency, so the database-dependent narrowing does not apply.

## 9. Rootless and read-only-rootfs adaptations

- Chart runs as root with `readOnlyRootFilesystem` false. Plan: `USER apps`, read-only rootfs, writes only to `/config` and `/tmp`.
- `/serverdata` becomes `/config/...`.
- No privileged mode (chart default false).

## 10. Risks, caveats and open questions

- First start downloads the server (large, slow) (inferred).
- arm64 unsupported (x86 SteamCMD).
- UDP game port must be reachable; UDP probes unsupported by forgetool tcp (open question).
- Draft missed `27015/tcp` RCON port (fixed in section 6).
- License unverified.
- Blockers: none for the launcher; arm64 and UDP probe are the only open items.

## 11. Build and test steps

From `apps/pvk-ii/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name pvk-ii-probe --read-only --tmpfs /tmp -v pvk-ii-probe-config:/config <image>:<version>`, then `docker logs -f pvk-ii-probe`. Readiness: the srcds server prints its listening/start-up lines after the download (exact string UNVERIFIED until run). Clean up with `docker rm -f pvk-ii-probe; docker volume rm pvk-ii-probe-config`.
4. `forgetool containers test --image <image>:<version> --config ./apps/pvk-ii/container-test.yaml`
5. Round limit 10.

## 12. PR checklist

- Branch `feat/add-pvk-ii`, commit `feat(pvk-ii): add new container`, PR title matches.
- PR template, `🤖 This PR is AI generated.` in Notes.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what is untested: no build or run has been done; arm64 not tested or supported.
- Do not check "Built container locally" unless it was built.
