# postscriptum — implementation plan
> Source: ./draft.md · Target: apps/postscriptum/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No upstream version exists to pin: the PostScriptum dedicated server is a Steam app (app id 746200) updated by SteamCMD at start. Chart pins only the ich777 wrapper tag `postscriptum@sha256:abb80492...`. UNVERIFIED: no release page or build id was fetched. |
| Draft corrections | Draft lists ports 10002/udp and 10001/udp (inferred). Chart `main` port is **10027/udp** and `queryport` is **10037/udp** (TrueCharts values, `GAME_PARAMS: Port=10027 QueryPort=10037 -log`). Use the chart values. |
| Renovate | None usable: no upstream version. Track the base image `ghcr.io/trueforge-org/steamcmd` via the `apps/steamcmd` renovate line instead. |
| License | UNVERIFIED: proprietary Steam content, no SPDX published. Set `LICENSE` to the license of the software in the image per the Dockerfile rule; the steamcmd base is `AGPL-3.0-or-later`. Decide with the maintainer before merge. |
| Source URL | https://www.postscriptum.com/ (draft). Steam store and SteamCMD wiki: https://developer.valvesoftware.com/wiki/SteamCMD |
| Download | SteamCMD `+force_install_dir <dir> +login anonymous +app_update 746200 validate +quit`. No prebuilt file. amd64 only. |
| Checksum source | None published. SteamCMD `validate` is the integrity check. |
| Upstream Dockerfile reviewed | ich777 wrapper, https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, lib32 libs, user `steam`, no `USER` (runs as root), ENTRYPOINT `/opt/scripts/start.sh`, no EXPOSE, no VOLUME. Launch script: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh (`cd ${SERVER_DIR}`, `${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`). |
| Env vars (wrapper, real) | `DATA_DIR`, `SERVER_DIR`, `STEAMCMD_DIR`, `GAME_ID`, `GAME_NAME`, `GAME_PARAMS`, `GAME_PORT`, `VALIDATE`, `UMASK`, `UID`, `GID`, `USERNAME`, `PASSWRD`, `USER`, `DATA_PERM`. Chart sets `GAME_ID=746200`, `GAME_PARAMS=Port=10027 QueryPort=10037 -log`, `VALIDATE=false`, `DATA_PERM=770`. |
| Data path | Wrapper writes `/serverdata/serverfiles` (game) and `/serverdata/steamcmd` (SteamCMD). Map to `/config/serverfiles` and `/config/steamcmd` (SteamCMD bootstrap under `/config` already done by apps/steamcmd). |
| Blocker | **Launcher unverified.** The wrapper launches `srcds_run` (Source engine). PostScriptum is not confirmed to use `srcds_run`. The game's real binary and its arguments must be verified from the server's own files after the first SteamCMD download before `start.sh` can be written. |

## 2. Target layout

- `apps/postscriptum/Dockerfile`
- `apps/postscriptum/docker-bake.hcl`
- `apps/postscriptum/settings.yaml`
- `apps/postscriptum/container-test.yaml`
- `apps/postscriptum/start.sh`

No `defaults/` unless the server needs a seed config (decide after the first download). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<VERSION>` (the `apps/steamcmd` image). The steamcmd image already ships SteamCMD (`/usr/local/share/steamcmd/steamcmd.sh`), 32-bit steamcmd and runs as `apps`. Closest sibling: `apps/steamcmd`. The steamcmd image's own digest is not in this repo; pin it from the published image before merge (UNVERIFIED digest). Its ubuntu base is `ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG VENDOR` (matching the sibling pattern if the base is used).
2. `USER root` only if apt is needed (lib32 libs are already present through the steamcmd i386 package; add `lib32gcc-s1 lib32stdc++6 lib32z1` only if the server fails without them, pinned to the base release).
3. `COPY --chmod=0755 start.sh /start.sh`.
4. `ENV HOME=/config`.
5. `USER apps`, `COPY --chmod=0755 . /`.
6. `EXPOSE` not required (declared in settings.yaml); `VOLUME /config` only through settings.yaml.

## 5. docker-bake.hcl

- `APP = "postscriptum"`.
- `VERSION` with `// renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd` (or the steamcmd renovate line if no docker datasource applies). Use the app's own version string for the build tag (e.g. the date of the wrapper tag, `UNVERIFIED`).
- `LICENSE` per section 1 (decide with maintainer), `SOURCE = "https://www.postscriptum.com/"`.
- Standard targets: `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (linux/amd64 only), `group "default"`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1`, `upstream_env_url: "https://www.postscriptum.com/"`.
- `ports`: `10027` udp (required: true, game), `10037` udp (required: true, query).
- `env`: `GAME_ID` is fixed (746200), `GAME_PARAMS` default `Port=10027 QueryPort=10037 -log`, `STEAM_APP_VALIDATE` default `false` (`STEAM_APP_IDS` is read only by the base `/start.sh`, which this plan's own `start.sh` replaces, so do not list it; the app id 746200 is hard-coded in `start.sh`), `TZ` default `Etc/UTC`. Only vars that start.sh reads.
- `volumes`: `/config` (required: true).
- `dependencies`: none.

## 7. start.sh

1. `set -euo pipefail`, `export HOME=/config`.
2. Ensure `/config/serverfiles` and `/config/steamcmd` exist (idempotent).
3. Run SteamCMD for app 746200 with `force_install_dir /config/serverfiles`, `app_update 746200` (+`validate` when `STEAM_APP_VALIDATE=true`). Do not use the steamcmd image's `start.sh` with `+` args: it execs an interactive steamcmd after the update. Call `/config/Steam/steamcmd/steamcmd.sh +runscript` directly, with the bootstrap copy as the sibling does.
4. `cd /config/serverfiles`, then `exec <server binary> <GAME_PARAMS>`. The binary is **UNVERIFIED** (see section 10).
5. Never write to `/app`. Caches and temp under `/tmp` (`STEAMCMD_TMP_DIR` in `/config` is acceptable only because the sibling uses it; prefer `/tmp` for new work).
6. Bind on all interfaces (game server config, not user-facing); map `GAME_PARAMS` port values from env.

## 8. container-test.yaml

- Schema header copied from `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh`, `/usr/local/share/steamcmd/steamcmd.sh`.
- `runners`: none that start the server (it downloads a large game at first start and CI has no game content).
- Probes: the game port is UDP-only. forgetool `tcp` probes cannot test UDP; **open question**: check forgetool schema for a UDP probe before merge. Do not drop the probe silently.
- `timeoutSeconds`: reuse a large sibling value; the server download is slow.

## 9. Rootless and read-only-rootfs adaptations

- Upstream chart runs as `runAsUser 0` and `readOnlyRootFilesystem false`. Plan: `USER apps` with `readOnlyRootFilesystem` true, because all writes go to `/config` and `/tmp`.
- `/serverdata` (chart mount) becomes `/config/serverfiles` and `/config/steamcmd`.
- Upstream `UID=99` / `GID=100` (`usermod` in the wrapper) is not used: ContainerForge `apps` user is fixed.
- No privileged mode needed (chart default false).
- Extra persistence: none beyond `/config`.

## 10. Risks, caveats and open questions

- **Launcher and binary unverified** (blocker for `start.sh`). The wrapper uses `srcds_run`, Source-specific; PostScriptum is not confirmed to use it.
- Draft ports 10002/10001 are wrong; chart gives 10027/10037 (corrected above).
- Steam app 746200 (chart) is the id to use; the wrapper's `GAME_NAME` for this game is not confirmed.
- Large first-start download (inferred).
- arm64 not supported (SteamCMD bootstrap x86 only).
- UDP-only probes cannot be tested with forgetool `tcp` (section 8).
- License unverified (section 1).
- Blockers: no arm64; launcher unverified; UDP probe support unverified.

## 11. Build and test steps

From `apps/postscriptum/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name postscriptum-probe --read-only --tmpfs /tmp -v postscriptum-probe-config:/config <image>:<version>`, then `docker logs -f postscriptum-probe` until the SteamCMD download finishes and the server starts. Readiness signal: UNVERIFIED (depends on server output). Clean up with `docker rm -f postscriptum-probe; docker volume rm postscriptum-probe-config`.
4. `forgetool containers test --image <image>:<version> --config ./apps/postscriptum/container-test.yaml`
5. Round limit: 10 per the build-test protocol.

## 12. PR checklist

- Branch `feat/add-postscriptum`, commit `feat(postscriptum): add new container`, PR title matches.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`, with `🤖 This PR is AI generated.` in Notes.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what is untested: no build or run has been done yet; the launcher and arm64 are unverified.
- Do not check "Built container locally" unless it was built.
