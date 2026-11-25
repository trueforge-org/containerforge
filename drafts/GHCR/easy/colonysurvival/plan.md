# colonysurvival — implementation plan
> Source: ./draft.md · Target: apps/colonysurvival/ · Difficulty: easy (blocked on launch command, see section 10) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No versioned upstream release. Steam app ID **748090** (`GAME_ID`, TrueCharts chart, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/colonysurvival/values.yaml). Server build/version: UNVERIFIED (no Steam build check; Valve wiki returned HTTP 403). The container version is the ContainerForge revision of the steamcmd base, as in `apps/steamcmd`. |
| Renovate | Base only: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (inherited from `apps/steamcmd/docker-bake.hcl`). Game server: no versioned source, UNVERIFIED. |
| License | Game server: proprietary Steam content, UNVERIFIED. Wrapper `ich777/docker-steamcmd-server`: no license statement in README, GitHub API `license` null (see batch 039 facts). Image `LICENSE` label: decision for the maintainer, see section 10. |
| Source URL | https://store.steampowered.com/app/748090/ (store page for app 748090; draft's search URL replaced with the app page). |
| Download (SteamCMD bootstrap, amd64 only) | `http://media.steampowered.com/client/steamcmd_linux.tar.gz` is what the wrapper uses (`start-server.sh`). The image gets SteamCMD from apt via the steamcmd base, so no download in our Dockerfile. |
| Checksum source | None for the game. Base SteamCMD comes from apt, which is signed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, lib32gcc-s1 / lib32stdc++6 / lib32z1, ENV `DATA_DIR=/serverdata`, `STEAMCMD_DIR=/serverdata/steamcmd`, `SERVER_DIR=/serverdata/serverfiles`, `UID=99`, `GID=100`, `USER=steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. No USER, VOLUME or EXPOSE. |
| Upstream start scripts reviewed | `scripts/start.sh` (user/UID remap, chown, then `su ${USER} -c start-server.sh`) and `scripts/start-server.sh` (https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh): `+force_install_dir ${SERVER_DIR}`, `+login anonymous`, `+app_update ${GAME_ID}` (plus `validate` when `VALIDATE=true`), then launches `${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`. **The srcds_run line is a Source-engine launcher and does not apply to Colony Survival.** |
| Ports (chart, `service.main.ports`) | **27016/udp** (target 27016). The chart sets it through `GAME_PARAMS="+server.gameport 27016"`, not a `GAME_PORT` variable. The draft's 27004/27015 udp are inferred and wrong; no fetched page confirms them. |
| Env vars the chart sets | `GAME_ID=748090`, `GAME_PARAMS=+server.gameport 27016`, `SRV_NAME="Colony Survival Docker"`, `SRV_NETTYPE=SteamOnline`, `SRV_WORLDNAME=ColonySurvival`, `VALIDATE=false`, `USERNAME=""`, `PASSWRD` (secret). Whether the game reads the `SRV_*` names is UNVERIFIED (they are chart-side, not confirmed in the game's docs). |
| Persistence in chart | `/serverdata/serverfiles`, `/serverdata/steamcmd`. We use `/config` (see section 9). |
| Launch command | UNVERIFIED: the Colony Survival server executable and its arguments were not confirmed on any fetched page. |
| arm64 | no. SteamCMD's 32-bit bootstrap (`linux32/` copied into `sdk32` by the wrapper) and `apps/steamcmd` is `image-all` amd64 only. |
| Blockers | Launch command UNVERIFIED; no arm64; first start downloads the server from Steam. |

## 2. Target layout

- `apps/colonysurvival/Dockerfile`
- `apps/colonysurvival/docker-bake.hcl`
- `apps/colonysurvival/settings.yaml`
- `apps/colonysurvival/container-test.yaml`
- `apps/colonysurvival/start.sh`

No `defaults/`, `etc/`, `health/`, `scripts/` (not needed; the start logic is one file). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<digest: UNVERIFIED, read from the registry at build time and pin, do not guess>`. The tag is the `VERSION` of `apps/steamcmd/docker-bake.hcl`. It provides SteamCMD with lib32 libs, `USER apps`, and `/config`. Closest sibling: `apps/steamcmd`. The ubuntu root (`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`) is not used directly.

## 4. Dockerfile

1. `ARG VERSION`, `ARG VENDOR` (sibling pattern), then the `FROM` from section 3.
2. No apt, pip or npm packages are needed. The game is pulled at start, not built.
3. No `USER root` step is needed. Keep the file minimal.
4. `ENV HOME=/config XDG_DATA_HOME=/config` only if the base does not set them (check the base before writing; `apps/steamcmd/start.sh` sets both at runtime). Steam download caches go to `/tmp` (`ENV TMPDIR=/tmp`), not `/config`, per the Dockerfile rules.
5. `COPY --chmod=0755 start.sh /start.sh`. This replaces the base's `/start.sh` (see section 10).
6. Final: `USER apps`, `COPY --chmod=0755 . /`.
7. `EXPOSE 27016/udp`. `VOLUME /config`.

```dockerfile
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<digest>
ARG VERSION
ARG VENDOR
ENV TMPDIR=/tmp
COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /
EXPOSE 27016/udp
VOLUME /config
```

## 5. docker-bake.hcl

- `variable "APP" { default = "colonysurvival" }`
- `variable "VERSION" { // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` then `default = "20180105-5build1"` } (must match the Dockerfile `FROM` tag, and the sibling base).
- `variable "LICENSE" { default = "AGPL-3.0-or-later" }` only after the maintainer decision in section 10. Otherwise UNVERIFIED.
- `variable "SOURCE" { default = "https://store.steampowered.com/app/748090/" }`
- Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 only), `group "default" { targets = ["image-local"] }`. Mirror `apps/steamcmd/docker-bake.hcl`.
- Validate with `cd apps/colonysurvival && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/748090/"
ports:
  - port: 27016
    protocol: udp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Game env vars (`SRV_NAME`, `SRV_WORLDNAME`, `SRV_NETTYPE`, `GAME_PORT`-equivalent): add only after the launch command and the server config keys are confirmed. Do not list them now (they are chart-side, see section 1).
- `STEAM_APP_ID=748090` is a constant in `start.sh`, not a user env var.
- `dependencies`: none.

## 7. start.sh

Behaviour, in order (`#!/usr/bin/env bash`, `set -euo pipefail`):
1. `export HOME=/config`; `mkdir -p /config/serverfiles /tmp/steam`.
2. Seed SteamCMD into `/config/Steam/steamcmd` only when `steamcmd.sh` is missing, copying from `/usr/local/share/steamcmd/` the way `apps/steamcmd/start.sh` does. SteamCMD self-updates, so it cannot run from the read-only `/usr/games`.
3. Install or update the server, idempotent on restart: `/config/Steam/steamcmd/steamcmd.sh +force_install_dir /config/serverfiles +login anonymous +app_update 748090 validate +quit`. `validate` only when the optional env `STEAM_APP_VALIDATE=true`.
4. Copy `steamclient.so` into `$HOME/.steam/sdk32` if the server needs it (wrapper step). UNVERIFIED that the Colony Survival binary needs `sdk32`; add only when confirmed.
5. Launch: `cd /config/serverfiles` then `exec <server binary> <args>`. **The binary and arguments are UNVERIFIED.** Until they are confirmed, `start.sh` must not be written with the wrapper's `srcds_run` line.
6. Bind `0.0.0.0` on port 27016 (UDP); the arg for the port (`+server.gameport 27016` as in the chart) is UNVERIFIED for the real server.
7. No writes to `/app` (none exist). Caches in `/tmp`. Passwords are not written to files and not echoed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /usr/local/share/steamcmd/steamcmd.sh
```

- The test runs with no env vars and no network guarantee. Install happens at start, so a tcp probe on 27016 (UDP) cannot be used: forgetool `tcp` checks TCP only, so the UDP port has no probe primitive. Open question, section 10.
- Add a `filePaths` entry for the install/launch path only if it is written as a separate file.
- `timeoutSeconds`: UNVERIFIED for the family (no siblings with probes here). Set after measuring a real first start.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root and remaps `steam` to UID 99 / GID 100. ContainerForge runs as `apps` only, so remove the UID/GID remap and the `su`.
- All writes go to `/config` (server files `/config/serverfiles`, SteamCMD `/config/Steam`) and `/tmp` (caches, TMPDIR). Nothing is written under `/app` or `/usr`.
- Upstream chart paths `/serverdata/serverfiles` and `/serverdata/steamcmd` are remapped to `/config/serverfiles` and `/config/Steam/steamcmd`. The chart's PVCs are not part of the container.
- `--read-only --tmpfs /tmp` must work with an empty `/config`: the first start seeds and downloads into `/config` only.

## 10. Risks, caveats and open questions

- **Launch command UNVERIFIED (blocker).** The only fetched launcher is `srcds_run`, which is for Source games. Confirm the Colony Survival server executable and its args from the Steam depot or a fetched source before writing the last line of `start.sh`.
- **UDP port 27016 (chart) vs draft.** Draft's 27004/27015 udp are not confirmed; use 27016/udp per the TrueCharts chart. The chart sets it through `GAME_PARAMS`, which must be confirmed as the server's real setting.
- **`/start.sh` override.** The steamcmd base ships `/start.sh` (which `/usr/local/bin/steamcmd` execs). Our `start.sh` replaces it, so `steamcmd` invoked through the base's wrapper would run our script. Decide whether to keep the base name or rename (for example `/start-colonysurvival.sh`), and then update `filePaths` and `ENTRYPOINT`/`exec`.
- **Probes.** `container-test` `tcp` can only check TCP. No fetched page shows a TCP port for this game, so no `tcp` probe is listed. A readiness check needs a real game install (large download, internet needed); this is not satisfiable in a no-network test run.
- **License.** Game server license UNVERIFIED (Steam EULA not fetched). Wrapper has no license. Maintainer to choose the image `LICENSE` label.
- **Architecture.** amd64 only. `apps/steamcmd` publishes amd64 only; the 32-bit SteamCMD bootstrap does not run on arm64.
- **Security (from draft, chart values):** the chart runs as root and has `readOnlyRootFilesystem: false`; our target is non-root and read-only-rootfs compatible, so the security expectations are not carried over. The draft's `/config` expectation is in fact `/serverdata/*` PVCs in the chart; migration of existing data is an open question.
- **Downloads.** Server files are fetched over Steam on every start unless `validate` is off and the files exist.

## 11. Build and test steps

From `apps/colonysurvival/` (protocol: `.github/instructions/build-test-protocol.instructions.md`):
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name colonysurvival-probe --read-only --tmpfs /tmp -v colonysurvival-probe-config:/config colonysurvival:20180105-5build1`, then `docker logs -f colonysurvival-probe`. Expected readiness signal: the server's own "ready"/listening line (UNVERIFIED until the launch command is known). Clean up with `docker rm -f colonysurvival-probe; docker volume rm colonysurvival-probe-config`.
4. `forgetool containers test --image colonysurvival:20180105-5build1 --config ./apps/colonysurvival/container-test.yaml`. If forgetool is unavailable, check the file paths by hand.
- The steam download needs internet. A test run without it cannot reach readiness and is recorded as blocked, not passed.

## 12. PR checklist

- Branch `feat/add-colonysurvival`, commit `feat(colonysurvival): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep its sections and check only applicable boxes.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge); only they can sign it. The `license/cla` check shows the status.
- Say what was not tested: the server launch, arm64, a real first start, UDP probing, and the image digest pin unless checked.
- Downstream: none (not a `FROM` base).
