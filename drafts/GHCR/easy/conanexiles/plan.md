# conanexiles — implementation plan
> Source: ./draft.md · Target: apps/conanexiles/ · Difficulty: easy (blocked on launch command, see section 10) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No versioned upstream release. Steam app ID **443030** (`GAME_ID`, TrueCharts chart, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/conanexiles/values.yaml). Server build: UNVERIFIED (no Steam build check). The container version is the ContainerForge revision of the steamcmd base. |
| Renovate | Base only: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (from `apps/steamcmd/docker-bake.hcl`). Game server: no versioned source, UNVERIFIED. |
| License | Game server: proprietary Steam content, UNVERIFIED. Wrapper `ich777/docker-steamcmd-server`: no license statement, GitHub API `license` null. Image `LICENSE` label: maintainer decision (section 10). |
| Source URL | https://store.steampowered.com/app/443030/ (draft link, confirmed as the app ID). |
| Download | SteamCMD from apt via the steamcmd base; the server is pulled at start by SteamCMD. No prebuilt binary in our Dockerfile. |
| Checksum source | None for the game. Base SteamCMD from apt (signed). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, lib32 libs, ENV `DATA_DIR=/serverdata`, `STEAMCMD_DIR=/serverdata/steamcmd`, `SERVER_DIR=/serverdata/serverfiles`, `UID=99`, `GID=100`, `USER=steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. No USER, VOLUME or EXPOSE. |
| Upstream start scripts reviewed | `scripts/start.sh` and `scripts/start-server.sh` (https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh): `+force_install_dir ${SERVER_DIR}`, `+login anonymous`, `+app_update ${GAME_ID}` (`validate` when `VALIDATE=true`), then `${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`. **The srcds_run line is Source-engine specific and does not apply to Conan Exiles.** |
| Ports (chart, `service.main.ports`) | **7777/udp** (`main`), **7778/udp** (`gameport1`), **27015/udp** (`steamport`, Steam query). The draft's 7778 "inferred" is confirmed by the chart. |
| Env vars the chart sets | `GAME_ID=443030`, `GAME_PARAMS=""`, `VALIDATE=false`, `USERNAME=""`, `WS_CONTENT=""`, `PASSWRD` (secret). No `GAME_PORT` in the chart. |
| Persistence in chart | `/serverdata/serverfiles`, `/serverdata/steamcmd`. We use `/config` (section 9). |
| Launch command | UNVERIFIED: the Conan Exiles Linux server executable and its arguments were not confirmed on any fetched page. |
| arm64 | no. SteamCMD's 32-bit bootstrap; `apps/steamcmd` publishes amd64 only. |
| Blockers | Launch command UNVERIFIED; no arm64; very large first download from Steam. |

## 2. Target layout

- `apps/conanexiles/Dockerfile`
- `apps/conanexiles/docker-bake.hcl`
- `apps/conanexiles/settings.yaml`
- `apps/conanexiles/container-test.yaml`
- `apps/conanexiles/start.sh`

No `defaults/`, `etc/`, `health/`, `scripts/` (not needed). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<digest: UNVERIFIED, read from the registry at build time and pin>`. Tag = `VERSION` of `apps/steamcmd/docker-bake.hcl`. Provides SteamCMD with lib32 libs, `USER apps`, `/config`. Closest sibling: `apps/steamcmd`. Ubuntu root not used directly.

## 4. Dockerfile

1. `ARG VERSION`, `ARG VENDOR`, then the `FROM` from section 3.
2. No apt, pip or npm packages.
3. `ENV TMPDIR=/tmp` (caches to `/tmp`). `HOME=/config` only if the base does not already set it.
4. `COPY --chmod=0755 start.sh /start.sh` (replaces the base `/start.sh`, see section 10).
5. `USER apps`, `COPY --chmod=0755 . /`.
6. `EXPOSE 7777/udp 7778/udp 27015/udp`, `VOLUME /config`.

```dockerfile
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<digest>
ARG VERSION
ARG VENDOR
ENV TMPDIR=/tmp
COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /
EXPOSE 7777/udp 7778/udp 27015/udp
VOLUME /config
```

## 5. docker-bake.hcl

- `APP` = `conanexiles`.
- `VERSION` with `// renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu`, `default = "20180105-5build1"` (matches the `FROM` tag).
- `LICENSE`: maintainer decision (section 10).
- `SOURCE` = `https://store.steampowered.com/app/443030/`.
- Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 only), `group "default"`. Mirror `apps/steamcmd/docker-bake.hcl`.
- Validate: `cd apps/conanexiles && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/443030/"
ports:
  - port: 7777
    protocol: udp
    required: true
  - port: 7778
    protocol: udp
    required: true
  - port: 27015
    protocol: udp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Add game env vars only after the launch command and config keys are confirmed. Chart's `VALIDATE`, `USERNAME`, `PASSWRD` map to SteamCMD login; decide whether to expose `STEAM_APP_VALIDATE` / `STEAM_USERNAME` and `STEAM_PASSWORD` (the base already reads `STEAM_USERNAME`, `STEAM_PASSWORD`).
- `dependencies`: none.

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`.
1. `export HOME=/config`; `mkdir -p /config/serverfiles /tmp/steam`.
2. Seed `/config/Steam/steamcmd` from `/usr/local/share/steamcmd/` only if `steamcmd.sh` is missing (same as `apps/steamcmd/start.sh`).
3. Install/update idempotently: `/config/Steam/steamcmd/steamcmd.sh +force_install_dir /config/serverfiles +login anonymous +app_update 443030 [validate] +quit`. `validate` only when `STEAM_APP_VALIDATE=true`.
4. If the server needs `steamclient.so` under `$HOME/.steam/sdk32`, copy it from `linux32/` (UNVERIFIED that Conan Exiles needs it; add only when confirmed).
5. Launch: `cd /config/serverfiles` then `exec <server binary> <args>`. **Binary and args UNVERIFIED.** Do not use the wrapper's `srcds_run` line.
6. Bind `0.0.0.0`. Ports 7777 and 7778 (UDP) are game ports; the bind/port arguments are UNVERIFIED.
7. No writes to `/app`. Caches in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /usr/local/share/steamcmd/steamcmd.sh
```

- `tcp` probes check TCP only. All three game ports are UDP, so no TCP probe applies. Open question (section 10).
- `timeoutSeconds`: UNVERIFIED, set from a measured first start (the download is very large).
- A readiness test needs a full Steam download and internet; not satisfiable in a no-network test run.

## 9. Rootless and read-only-rootfs adaptations

- Drop the UID/GID remap and `su` from the wrapper (we run as `apps`).
- Writes only to `/config` (`/config/serverfiles`, `/config/Steam`) and `/tmp`.
- Chart PVCs `/serverdata/serverfiles` and `/serverdata/steamcmd` are remapped to `/config/serverfiles` and `/config/Steam/steamcmd`.
- `--read-only --tmpfs /tmp` with an empty `/config` must work: the first start seeds and downloads into `/config`.

## 10. Risks, caveats and open questions

- **Launch command UNVERIFIED (blocker).** Confirm the Conan Exiles server executable and arguments before writing the last line of `start.sh`.
- **Three UDP game/query ports.** 7777 and 7778 are game ports, 27015 is the Steam query port (chart). Confirm which ports the server binds, and how it advertises them.
- **`/start.sh` override.** Our `start.sh` replaces the base `/start.sh`, which `/usr/local/bin/steamcmd` execs. Decide on a rename, and update `filePaths` and the exec path.
- **Probes.** No TCP port to probe. Readiness needs a real install.
- **License.** Game server license UNVERIFIED; wrapper has no license. Maintainer decision for `LICENSE`.
- **Architecture.** amd64 only.
- **Security (chart values):** chart runs as root and `readOnlyRootFilesystem: false`; our target is non-root and read-only-rootfs compatible. The chart's `/serverdata` PVCs need a migration note for existing users.
- **Download size and time.** Very large first download from Steam; first start is slow.

## 11. Build and test steps

From `apps/conanexiles/`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name conanexiles-probe --read-only --tmpfs /tmp -v conanexiles-probe-config:/config conanexiles:20180105-5build1`, then `docker logs -f conanexiles-probe`. Readiness signal UNVERIFIED until the launch command is known. Clean up `docker rm -f conanexiles-probe; docker volume rm conanexiles-probe-config`.
4. `forgetool containers test --image conanexiles:20180105-5build1 --config ./apps/conanexiles/container-test.yaml`. If forgetool is unavailable, check file paths by hand.
- Without internet the download cannot finish; record as blocked, not passed.

## 12. PR checklist

- Branch `feat/add-conanexiles`, commit `feat(conanexiles): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep its sections and check only applicable boxes.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge); only they can sign it.
- Say what was not tested: server launch, arm64, first real start, UDP probing, and the digest pin unless checked.
- Downstream: none.
