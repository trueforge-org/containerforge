# craftopia — implementation plan
> Source: ./draft.md · Target: apps/craftopia/ · Difficulty: easy (blocked on launch command, see section 10) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No versioned upstream release. Steam app ID **1670340** (`GAME_ID`, TrueCharts chart, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/craftopia/values.yaml). Server build: UNVERIFIED (no Steam build check). The container version is the ContainerForge revision of the steamcmd base. |
| Renovate | Base only: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (from `apps/steamcmd/docker-bake.hcl`). Game server: no versioned source, UNVERIFIED. |
| License | Game server: proprietary Steam content, UNVERIFIED. Wrapper `ich777/docker-steamcmd-server`: no license statement, GitHub API `license` null. Image `LICENSE` label: maintainer decision (section 10). |
| Source URL | https://store.steampowered.com/app/1670340/ (app ID from chart; draft's search URL replaced with the app page). |
| Download | SteamCMD from apt via the steamcmd base; the server is pulled at start by SteamCMD. |
| Checksum source | None for the game. Base SteamCMD from apt (signed). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, lib32 libs, ENV `DATA_DIR=/serverdata`, `STEAMCMD_DIR=/serverdata/steamcmd`, `SERVER_DIR=/serverdata/serverfiles`, `UID=99`, `GID=100`, `USER=steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. No USER, VOLUME or EXPOSE. |
| Upstream start scripts reviewed | `scripts/start.sh` and `scripts/start-server.sh` (https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh): `+force_install_dir ${SERVER_DIR}`, `+login anonymous`, `+app_update ${GAME_ID}` (`validate` when `VALIDATE=true`), then `${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`. **The srcds_run line is Source-engine specific and does not apply to Craftopia.** |
| Ports (chart, `service.main.ports`) | **8787/tcp** (`main`) and **8787/udp** (`udpgameport`). The draft's 27015/udp and 27016/udp are inferred and NOT confirmed by the chart. |
| Env vars the chart sets | `GAME_ID=1670340`, `GAME_PARAMS=""`, `VALIDATE=false`, `USERNAME=""`, `PASSWRD` (secret). No `GAME_PORT` in the chart. |
| Persistence in chart | `/serverdata/serverfiles`, `/serverdata/steamcmd`. We use `/config` (section 9). |
| Launch command | UNVERIFIED: the Craftopia dedicated server executable and its arguments were not confirmed on any fetched page. |
| arm64 | no. SteamCMD's 32-bit bootstrap; `apps/steamcmd` publishes amd64 only. |
| Blockers | Launch command UNVERIFIED; no arm64; server fetched from Steam at start (needs Steam reachable). |

## 2. Target layout

- `apps/craftopia/Dockerfile`
- `apps/craftopia/docker-bake.hcl`
- `apps/craftopia/settings.yaml`
- `apps/craftopia/container-test.yaml`
- `apps/craftopia/start.sh`

No `defaults/`, `etc/`, `health/`, `scripts/` (not needed). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<digest: UNVERIFIED, read from the registry at build time and pin>`. Tag = `VERSION` of `apps/steamcmd/docker-bake.hcl`. Provides SteamCMD with lib32 libs, `USER apps`, `/config`. Closest sibling: `apps/steamcmd`. Ubuntu root not used directly.

## 4. Dockerfile

1. `ARG VERSION`, `ARG VENDOR`, then the `FROM` from section 3.
2. No apt, pip or npm packages.
3. `ENV TMPDIR=/tmp` (caches to `/tmp`). `HOME=/config` only if the base does not already set it.
4. `COPY --chmod=0755 start.sh /start.sh` (replaces the base `/start.sh`, see section 10).
5. `USER apps`, `COPY --chmod=0755 . /`.
6. `EXPOSE 8787/tcp 8787/udp`, `VOLUME /config`.

```dockerfile
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<digest>
ARG VERSION
ARG VENDOR
ENV TMPDIR=/tmp
COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /
EXPOSE 8787/tcp 8787/udp
VOLUME /config
```

## 5. docker-bake.hcl

- `APP` = `craftopia`.
- `VERSION` with `// renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu`, `default = "20180105-5build1"` (matches the `FROM` tag).
- `LICENSE`: maintainer decision (section 10).
- `SOURCE` = `https://store.steampowered.com/app/1670340/`.
- Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 only), `group "default"`. Mirror `apps/steamcmd/docker-bake.hcl`.
- Validate: `cd apps/craftopia && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/1670340/"
ports:
  - port: 8787
    protocol: tcp
    required: true
  - port: 8787
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

- Add game env vars only after the launch command and config keys are confirmed. Base already reads `STEAM_USERNAME` and `STEAM_PASSWORD`; decide whether to expose them and `STEAM_APP_VALIDATE`.
- `dependencies`: none.

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`.
1. `export HOME=/config`; `mkdir -p /config/serverfiles /tmp/steam`.
2. Seed `/config/Steam/steamcmd` from `/usr/local/share/steamcmd/` only if `steamcmd.sh` is missing (same as `apps/steamcmd/start.sh`).
3. Install/update idempotently: `/config/Steam/steamcmd/steamcmd.sh +force_install_dir /config/serverfiles +login anonymous +app_update 1670340 [validate] +quit`. `validate` only when `STEAM_APP_VALIDATE=true`.
4. If the server needs `steamclient.so` under `$HOME/.steam/sdk32`, copy it from `linux32/` (UNVERIFIED; add only when confirmed).
5. Launch: `cd /config/serverfiles` then `exec <server binary> <args>`. **Binary and args UNVERIFIED.** Do not use the wrapper's `srcds_run` line.
6. Bind `0.0.0.0` on 8787 (TCP and UDP). The bind/port arguments are UNVERIFIED.
7. No writes to `/app`. Caches in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /usr/local/share/steamcmd/steamcmd.sh
tcp:
- port: '8787'
```

- The `tcp` probe covers the TCP side of 8787 (`main`). The UDP side of 8787 has no probe primitive. Open question (section 10).
- The probe only passes once the server is listening, which needs a real Steam download. A no-network test run cannot reach that; record as blocked, not passed, and do not weaken or drop the probe to pass.
- `timeoutSeconds`: UNVERIFIED, set from a measured first start.

## 9. Rootless and read-only-rootfs adaptations

- Drop the UID/GID remap and `su` from the wrapper (we run as `apps`).
- Writes only to `/config` (`/config/serverfiles`, `/config/Steam`) and `/tmp`.
- Chart PVCs `/serverdata/serverfiles` and `/serverdata/steamcmd` are remapped to `/config/serverfiles` and `/config/Steam/steamcmd`.
- `--read-only --tmpfs /tmp` with an empty `/config` must work: the first start seeds and downloads into `/config`.

## 10. Risks, caveats and open questions

- **Launch command UNVERIFIED (blocker).** Confirm the Craftopia server executable and arguments before writing the last line of `start.sh`.
- **Port 8787 (chart) vs draft.** Draft's 27015/27016 udp are not confirmed. The chart uses 8787 for both TCP and UDP. Confirm which ones the server uses.
- **`/start.sh` override.** Our `start.sh` replaces the base `/start.sh`, which `/usr/local/bin/steamcmd` execs. Decide on a rename, and update `filePaths` and the exec path.
- **UDP probing.** `tcp` probes cannot check the UDP side of 8787.
- **License.** Game server license UNVERIFIED; wrapper has no license. Maintainer decision for `LICENSE`.
- **Architecture.** amd64 only.
- **Security (chart values):** chart runs as root and `readOnlyRootFilesystem: false`; our target is non-root and read-only-rootfs compatible. Migration note for `/serverdata` PVC users.
- **Steam reachability.** Server files are fetched from Steam at start, so the first start needs Steam reachable.

## 11. Build and test steps

From `apps/craftopia/`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name craftopia-probe --read-only --tmpfs /tmp -v craftopia-probe-config:/config craftopia:20180105-5build1`, then `docker logs -f craftopia-probe`. Readiness signal UNVERIFIED until the launch command is known. Clean up `docker rm -f craftopia-probe; docker volume rm craftopia-probe-config`.
4. `forgetool containers test --image craftopia:20180105-5build1 --config ./apps/craftopia/container-test.yaml`. If forgetool is unavailable, check file paths and the TCP port by hand.
- Without Steam reachable the readiness check cannot pass; record as blocked.

## 12. PR checklist

- Branch `feat/add-craftopia`, commit `feat(craftopia): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep its sections and check only applicable boxes.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge); only they can sign it.
- Say what was not tested: server launch, arm64, first real start, UDP probing, and the digest pin unless checked.
- Downstream: none.
