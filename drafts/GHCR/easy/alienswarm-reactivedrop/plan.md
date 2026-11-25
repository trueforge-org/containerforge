# alienswarm-reactivedrop — implementation plan
> Source: ./draft.md · Target: apps/alienswarm-reactivedrop/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No versioned upstream release. The Steam dedicated server (app 563560) is pulled at start, so the container version is the ContainerForge build of the steamcmd base. Steam build id: UNVERIFIED (Valve wiki returned HTTP 403). |
| Renovate | Base only: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (inherited pattern from `apps/steamcmd`). Game server: UNVERIFIED, no versioned source. |
| License | Server: UNVERIFIED (proprietary Valve Steam content). Wrapper repo `ich777/docker-steamcmd-server` has no SPDX (GitHub `license: null`). Use `LICENSE` of ContainerForge's own steamcmd base (`AGPL-3.0-or-later`) for the image label only after confirming with the maintainer. |
| Source URL | https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide (chart/draft link; wiki returned 403, UNVERIFIED) |
| Steam app id | 563560 (`GAME_ID` in TrueCharts chart `charts/stable/alienswarm-reactivedrop/values.yaml`, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm-reactivedrop/values.yaml) |
| Launch params (chart) | `GAME_PARAMS` = `+map lobby -maxplayers 4 +exec server.cfg`, `GAME_PORT` = `27015`, `VALIDATE` = `false` (same chart values source) |
| Per-arch download | amd64: SteamCMD bootstrap `https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz` (draft link, not fetched). arm64: no (SteamCMD bootstrap is 32-bit x86). |
| Checksum source | None fetched. UNVERIFIED. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, lib32gcc-s1 / lib32stdc++6 / lib32z1, user `steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no `USER`, `VOLUME`, `EXPOSE`. Defaults: `DATA_DIR=/serverdata`, `SERVER_DIR=/serverdata/serverfiles`, `STEAMCMD_DIR=/serverdata/steamcmd`, `UID=99`, `GID=100`, `UMASK=000`. |
| Upstream start.sh reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh: `usermod -u ${UID}`, `groupmod -g ${GID}`, `umask ${UMASK}`, `chown -R ${UID}:${GID} ${DATA_DIR}`, then `su ${USER} -c "/opt/scripts/start-server.sh" &`. `start-server.sh` (steamcmd install and launch) was NOT fetched: UNVERIFIED. |
| Server binary name and launch command | UNVERIFIED (not in any fetched page). Must be confirmed from the Steam depot before writing `start.sh`. |
| Ports | 27015/udp (game and query, chart `service.main`), 27015/tcp (rcon, chart `tcprconport`). |
| Env vars the chart sets | `GAME_ID`, `GAME_NAME` (`reactivedrop`), `GAME_PARAMS`, `GAME_PORT`, `VALIDATE`, `USERNAME`, `PASSWRD`. |
| Persistence in chart | `/serverdata/serverfiles`, `/serverdata/steamcmd`. |
| arm64 | no |

## 2. Target layout

- `apps/alienswarm-reactivedrop/Dockerfile`
- `apps/alienswarm-reactivedrop/docker-bake.hcl`
- `apps/alienswarm-reactivedrop/settings.yaml`
- `apps/alienswarm-reactivedrop/container-test.yaml`
- `apps/alienswarm-reactivedrop/start.sh`

No `defaults/`, `etc/`, `health/`, `scripts/` (the steamcmd base provides `/usr/local/bin/steamcmd`; it also ships `/start.sh`, which this app's `start.sh` replaces, and the base wrapper `steamcmd` execs `/start.sh`, so keep the SteamCMD bootstrap logic or call SteamCMD directly: UNVERIFIED how best to reconcile). No `root/`. `DOWNSTREAM_CHANGES.md` not needed (this app is not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>` where the tag is the `VERSION` of `apps/steamcmd/docker-bake.hcl` (currently `20180105-5build1`). The digest is UNVERIFIED: read it from the registry at build time and pin it, do not guess. Fits because it already provides steamcmd (i386 package with lib32 libs), `USER apps`, and `/config`. Closest sibling: `apps/steamcmd` itself. The ubuntu base (`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`) is the root of that chain and is not used directly.

## 4. Dockerfile

1. `ARG VERSION` and `ARG VENDOR` (match sibling pattern), `FROM` as in section 3.
2. `USER root` only if an install step is needed. Otherwise none: the Reactive Drop server is downloaded by SteamCMD at runtime into `/config`, so no build-time install is required.
3. Copy the start script: `COPY --chmod=0755 start.sh /start.sh`, `USER apps`.
4. `ENV HOME=/config`, `ENV XDG_DATA_HOME=/config` only if the base does not set them (check base first). Steam caches go to `/tmp` (`ENV TMPDIR=/tmp`), never `/config` (see Dockerfile rules).
5. `EXPOSE 27015/udp 27015/tcp`.
6. `VOLUME /config` (required; `apps/steamcmd` only creates `/config` and does not declare VOLUME, so add it here).
7. Final `COPY --chmod=0755 . /` (required directive) and `USER apps`.
8. No apt packages, no pip, no npm needed.

## 5. docker-bake.hcl

- `variable "APP" { default = "alienswarm-reactivedrop" }`
- `variable "VERSION"`: Steam has no version; use the ContainerForge build version (`0.1.0`) or the base steamcmd tag. Renovate annotation: `// renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (inherited from `apps/steamcmd`), and note that the game version is not tracked.
- `variable "LICENSE"`: UNVERIFIED for the game; follow the decision in section 1.
- `variable "SOURCE"`: `https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide`.
- Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 only, arm64 unavailable), `group "default" { targets = ["image-local"] }`.
- Validate: `docker buildx bake --print` from `apps/alienswarm-reactivedrop/`.

## 6. settings.yaml

- Header: the forgetool schema header with `schema_version: 1`.
- `upstream_env_url: "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"`.
- `ports`: `27015/udp` (game, required: true), `27015/tcp` (rcon, required: false).
- `env`: `GAME_PARAMS` default `+map lobby -maxplayers 4 +exec server.cfg`; `GAME_PORT` default `27015`; `VALIDATE` default `false`; `TZ` default `Etc/UTC` (required: false); `PASSWRD` (required: false, no default). Only names that `start.sh` actually reads.
- `volumes`: `/config` (required: true).
- `dependencies`: none.

## 7. start.sh

- Idempotent: create `/config/serverfiles` and `/config/steamcmd` only when missing. Do not overwrite existing server config.
- Caches and temp files to `/tmp`.
- Install/update: `steamcmd +force_install_dir /config/serverfiles +login anonymous +app_update 563560 validate +quit` (validate only when `VALIDATE=true`). Exact flags to confirm with the upstream start-server script (UNVERIFIED).
- Write `server.cfg` into `/config/serverfiles` only when missing. Set `PASSWRD` as `sv_password` each start.
- Bind to `0.0.0.0` where the server allows it (check server options; UNVERIFIED).
- Final step: `exec` the server binary with `GAME_PARAMS` (binary name UNVERIFIED) so signals reach the process.
- No writes to `/app`.

## 8. container-test.yaml

- Header: the forgetool schema header used by `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh`, `/usr/local/bin/steamcmd`, `/usr/local/share/steamcmd/steamcmd.sh` (inherited from base), and the server launcher once confirmed.
- Probes: `tcp` on 27015 (rcon, inferred from chart; UNVERIFIED that the server listens) only. The game port 27015/udp cannot be probed with `tcp`: note in the PR and record as a known gap.
- `timeoutSeconds`: large (first start downloads the server); match a sibling Steam app if one exists, else use a conservative value and say so.
- Tests run without env vars, so the `PASSWRD` path must go to `filePaths` and be run manually per the build protocol.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with `usermod` and `chown` at runtime. Replace with `USER apps` and writes only to `/config` and `/tmp`. Drop `UID`/`GID`/`UMASK` handling; the base user is `apps`.
- `readOnlyRootFilesystem`: chart sets `false`; target is `true` if SteamCMD writes only to `/config` and `/tmp`. Verify with `--read-only --tmpfs /tmp`.
- `privileged`: no. `runAsUser`: chart 0; target is the `apps` user.
- Extra persistence: `/serverdata/serverfiles` and `/serverdata/steamcmd` map to `/config/serverfiles` and `/config/steamcmd`. Only `/config` is declared in settings.

## 10. Risks, caveats and open questions

- First start is slow and needs internet access (Steam download). Inferred.
- Server launch command and binary name UNVERIFIED (not fetched). Blocker until confirmed.
- Valve wiki returned HTTP 403: game version, license and ports (beyond chart values) are UNVERIFIED.
- amd64 only. Blocker for arm64 users.
- The chart's `GAME_PARAMS` contains a password placeholder path (`PASSWRD` secret); handle secrets without writing them to files or the process list.

## 11. Build and test steps

From `apps/alienswarm-reactivedrop/`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run with a fresh volume: `docker run --rm --read-only --tmpfs /tmp -v alienswarm-cfg:/config alienswarm-reactivedrop:<VERSION>`; expected readiness signal: SteamCMD reports `Success! App '563560' fully installed` on first run (UNVERIFIED until a real run).
4. `forgetool containers test` per `container-test.yaml`.
Clean up with `docker rm -f` and `docker volume rm` between rounds.

## 12. PR checklist

- Branch `feat/add-alienswarm-reactivedrop`, commit `feat(alienswarm-reactivedrop): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested (game launch, UDP probe, arm64 not applicable).
