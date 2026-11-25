# sonsoftheforest — implementation plan
> Source: ./draft.md · Target: apps/sonsoftheforest/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | UNVERIFIED: no game version or release tag fetched. The Steam app ID is not in the fetched files | — |
| Release date | UNVERIFIED | — |
| Upstream image | `ghcr.io/ich777/steamcmd:sonsoftheforest` | draft.md |
| Upstream Dockerfile (sonsoftheforest branch) | `FROM ich777/winehq-baseimage`; `apt-get -y install lib32gcc-s1 winbind xvfb screen`; ENV DATA_DIR=/serverdata, STEAMCMD_DIR=/serverdata/steamcmd, SERVER_DIR=/serverdata/serverfiles, GAME_ID (empty), GAME_PARAMS, GAME_PORT=27015, VALIDATE, UMASK=000, UID=99, GID=100, USERNAME, PASSWRD, USER=steam, DATA_PERM=770; ENTRYPOINT /opt/scripts/start.sh; no USER instruction; no VOLUME; no EXPOSE | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/sonsoftheforest/Dockerfile |
| Upstream Dockerfile (master) | `FROM ich777/debian-baseimage:bullseye_amd64`; apt lib32gcc-s1, lib32stdc++6, lib32z1 | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile |
| Upstream start script | not fetched: UNVERIFIED | — |
| Env vars | the ENV list above; read from the upstream Dockerfile, names only | sonsoftheforest Dockerfile |
| Ports | UNVERIFIED: only GAME_PORT=27015 is confirmed as an env default. The draft's 8766/udp, 9700/udp, 27016/udp are inferred | — |
| Binary amd64 | Wine-hosted Windows server. The download is via SteamCMD; the SteamCMD wiki returned 403, so its Linux URL is UNVERIFIED | https://developer.valvesoftware.com/wiki/SteamCMD (403) |
| arm64 | none: amd64 only (Wine base) | draft.md, upstream base |
| License | UNVERIFIED (no SPDX id for the server or for Wine). The Steam store page is not a license source | — |
| Checksum | UNVERIFIED | — |
| Local sibling | `apps/steamcmd` exists: `FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, `USER root` for install, `USER apps` at end | apps/steamcmd/Dockerfile (local) |

Upstream Dockerfile reviewed: yes (two branches). Checksum source: none.

## 2. Target layout

- `apps/sonsoftheforest/Dockerfile`
- `apps/sonsoftheforest/docker-bake.hcl`
- `apps/sonsoftheforest/settings.yaml`
- `apps/sonsoftheforest/container-test.yaml`
- `apps/sonsoftheforest/start.sh`
- `apps/sonsoftheforest/defaults/` for the `dedicatedserver.cfg` template, only if needed (reason: seed `/config` when missing)

Do not use `root/`. Add `DOWNSTREAM_CHANGES.md` only if this app becomes a FROM base, which is not planned.

## 3. Base image

- Runtime: `FROM ghcr.io/trueforge-org/steamcmd:<tag>` (tag from `apps/steamcmd/docker-bake.hcl` `VERSION`; digest UNVERIFIED, not available in the repo). `apps/steamcmd/Dockerfile` itself is `FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, so the alternative is that ubuntu line plus the same `steamcmd` apt install. Conflict to resolve: `apps/steamcmd` ships its own `/start.sh` and `/usr/local/bin/steamcmd` execs `/start.sh`; a child image that overwrites `/start.sh` breaks that wrapper, so name this app's script differently or call `/usr/games/steamcmd` directly.
- Wine and Xvfb are not in the base and must be added in the Dockerfile.
- Closest sibling: `apps/steamcmd`.

## 4. Dockerfile

1. `ARG VERSION` (SteamCMD/app version placeholder, aligned with docker-bake.hcl), `ARG TARGETARCH`. Fail unless `TARGETARCH=amd64`.
2. `USER root` only for installs, then `USER apps`.
3. apt: `wine64` (or the Wine package available on the base), `xvfb`, `lib32gcc-s1`. Check each against the base image first, and pin versions.
4. Wine prefix: set `WINEPREFIX=/tmp/wine` for runtime. Do not put it in `/config` unless persistence is needed. Note that the prefix is then rebuilt on each start (see section 10).
5. Xvfb: start it from start.sh on a fixed display, for example `:99`.
6. ENV: move HOME, caches and the SteamCMD scratch to `/tmp`. Set `STEAMCMD_DIR=/config/steamcmd` and `SERVER_DIR=/config/serverfiles` so game data persists under `/config`.
7. `COPY --chmod=0755 . /`
8. `EXPOSE` the UDP ports confirmed by the game (UNVERIFIED; see section 10), `VOLUME /config`, `USER apps`, `ENTRYPOINT ["/start.sh"]`.

## 5. docker-bake.hcl

- `APP = "sonsoftheforest"`, `SOURCE = "https://store.steampowered.com/app/1326470/"` (game page) and a link to the upstream repository in the notes, `LICENSE` UNVERIFIED.
- `variable "VERSION"` with a renovate comment. The datasource is UNVERIFIED. Game builds have no GitHub release, so choose the datasource the repo already uses for SteamCMD-served apps, after checking a sibling.
- Four standard targets and `group "default" { targets = ["image-local"] }`. Mark `image-all` amd64 only.
- Validate with `docker buildx bake --print` from `apps/sonsoftheforest`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url` set to the game page (same as SOURCE).
- `ports`: UNVERIFIED. List only confirmed ports, and at least the game port, once confirmed.
- `env`: `GAME_PORT` (default 27015), `VALIDATE` (default empty), `UMASK` (default 000), `USERNAME` and `PASSWRD` (default empty, not required; only if the server reads them, which is UNVERIFIED). Defaults must match start.sh.
- `volumes`: `/config`.
- `dependencies`: `steamcmd` (sibling `apps/steamcmd` exists and is used as the base).

## 7. start.sh

- Idempotent. Create `/config/steamcmd` and `/config/serverfiles` if missing.
- Seed `/config/serverfiles/userdata/dedicatedserver.cfg` only when missing, from `defaults/`. Never overwrite it on restart.
- Run SteamCMD `+force_install_dir /config/serverfiles +login anonymous +app_update <APP_ID> validate` with the app ID UNVERIFIED. Run it on every start only if `VALIDATE` is set, so normal restarts stay fast.
- Start Xvfb on a fixed display, then run the server under Wine with `WINEPREFIX=/tmp/wine` and `GAME_PORT` from env.
- Write no files to `/app`. Keep all state in `/config` and `/tmp`.
- Bind to `0.0.0.0` where the server allows it (UNVERIFIED).
- End with `exec` on the Wine server process so signals reach it. Forward SIGTERM to Wine and Xvfb cleanly.

## 8. container-test.yaml

- forgetool schema header from a sibling app.
- Probes for every port in settings.yaml. With no confirmed ports, use only a `filePaths` check until they are confirmed. Do not invent a probe.
- `filePaths`: `/start.sh`, and `/config/steamcmd` once the first-start code path is confirmed.
- `timeoutSeconds`: generous, because the first start downloads several GB. Copy a sibling's value for a large download, or mark as UNVERIFIED.
- Tests run with no env vars, so the `VALIDATE` and login paths are not tested. Note this in a comment.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/steamcmd` | `/config/steamcmd` |
| `/serverdata/serverfiles` | `/config/serverfiles` |
| Wine prefix (not in upstream Dockerfile, set by start script) | `/tmp/wine` (ephemeral) |
| `/opt/scripts` (upstream start script) | replaced by our `/start.sh` |
| user `steam` (UID 99, GID 100) | `apps`; the upstream UID/GID env is not used |
| no USER in upstream (root) | `apps` |
| `dedicatedserver.cfg` (configmap in TrueCharts) | seeded into `/config/serverfiles/userdata/` only when missing |

Draft security expectations to reconcile: upstream non-root no, read-only rootfs no, no privileged. Target is rootless, read-only, no privileged, and no extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- Blocker: the server is Windows-only and runs under Wine. This is heavy and can break on a glibc Ubuntu base. Test the Wine step first.
- Blocker: no arm64. Wine does not run there in this setup.
- UNVERIFIED: the Steam app ID, the Linux SteamCMD download URL, the game version, the ports, the license, and the renovate datasource. The Valve wiki returned 403 and must be retried or sourced elsewhere before a PR.
- Wine prefix in `/tmp` means a rebuild on every start, which is slow. Consider a `/config` prefix if persistence is needed; this trades read-only compatibility for speed, so decide with the user.
- First start downloads several GB, so the first start needs internet and time.
- The configmap-mounted `dedicatedserver.cfg` may be overwritten on restart (inferred); our seed-only-when-missing rule may differ from chart behavior.

## 11. Build and test steps

1. `cd apps/sonsoftheforest && docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name sonsoftheforest-probe --read-only --tmpfs /tmp -v sonsoftheforest-probe-config:/config <image>:<version>`
4. `docker logs -f sonsoftheforest-probe`. Expected signal: SteamCMD progress, then Wine and Xvfb starting, then the server's own ready line (UNVERIFIED). The first run may take a long time.
5. `forgetool containers test --image <image>:<version> --config ./apps/sonsoftheforest/container-test.yaml`
6. Clean up: `docker rm -f sonsoftheforest-probe; docker volume rm sonsoftheforest-probe-config`.

## 12. PR checklist

- Branch `feat/add-sonsoftheforest`, commit `feat(sonsoftheforest): add new container`, target `main`.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`. Only check boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State what was not tested: the full Wine path, the game server connection, the first-start SteamCMD download, arm64 (not applicable), and every UNVERIFIED item above.
