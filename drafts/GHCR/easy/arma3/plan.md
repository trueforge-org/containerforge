# arma3 — implementation plan
> Source: ./draft.md · Target: apps/arma3/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | The game is installed from Steam at start, so there is no pinned game version. The image version is the base's SteamCMD package and the Steam app id: **Steam app 233780** (Arma 3 dedicated server; `GAME_ID "233780"` in https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/arma3/values.yaml). Chart image tag: `ghcr.io/ich777/steamcmd:arma3@sha256:0823a8e9faa4b2d1db640c839ff3915388442d4b5f9cdd5227c1a60ee1fdf1bf`. |
| Renovate | Base steamcmd only: `apps/steamcmd` uses `datasource=deb depName=steamcmd`. The game itself is not pinned, so there is no renovate line for it (see section 10). |
| License | Image LICENSE: open question (section 10). The game is commercial (Bohemia Interactive EULA, not fetched: UNVERIFIED). The image ships only scripts. |
| Source URL | https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide (draft link) |
| Download | SteamCMD tarball (used by the upstream wrapper, not by us): https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz (HTTP 200, 2428561 bytes, last-modified 2018-01-05). The game is pulled by `steamcmd +app_update 233780` at start. |
| Checksum source | None published for the steamcmd tarball or for the game (UNVERIFIED). The base `apps/steamcmd` already installs steamcmd from the Ubuntu archive with a pinned package version. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, apt `lib32gcc-s1 lib32stdc++6 lib32z1`, `ENV DATA_DIR=/serverdata`, `GAME_ID`, `GAME_PARAMS`, `GAME_PORT=27015`, `UID=99`, `GID=100`, `USER=steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. |
| Upstream start script | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh: fetches steamcmd if missing, `+login anonymous +app_update ${GAME_ID}` (validate if `VALIDATE=true`), copies `linux32` into `${DATA_DIR}/.steam/sdk32`, then `${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`. `srcds_run` is Source-engine, so this script does not fit Arma 3. |
| Chart launch args | `GAME_PARAMS: -config=server.cfg -mod=` and `GAME_PORT: "2302"` (chart values.yaml). |
| Ports (chart) | 2302 (game), 2303, 2304, 2305 (`udpvonport`), 2306. The chart lists them as UDP-style game ports. Protocol per port is UNVERIFIED beyond the chart; the chart's `tcp`/`udp` split is not shown in the fetched lines. |
| Data paths (chart) | `/serverdata/.local/share` (profiles pvc), `/serverdata/serverfiles`, `/serverdata/steamcmd`. |
| Arch | amd64 yes (the base is an i386 steamcmd package with 64-bit server). arm64 no: Docker Hub `ich777/steamcmd` tags for arma3 list only amd64 (https://hub.docker.com/v2/repositories/ich777/steamcmd/tags/?page_size=100&name=arma3). |
| copy-from | amd64: `ghcr.io/ich777/steamcmd:arma3` (not used: we do not copy from it). arm64: no. |
| Server binary name and Linux launch line | UNVERIFIED: the Arma 3 Linux server binary name (for example `arma3server_x64`) and its exact arguments were not fetched from https://community.bistudio.com/wiki/Arma_3_Dedicated_Server. Confirm before writing `start.sh`. |

## 2. Target layout

- `apps/arma3/Dockerfile`
- `apps/arma3/docker-bake.hcl`
- `apps/arma3/settings.yaml`
- `apps/arma3/container-test.yaml`
- `apps/arma3/start.sh` (game install on first start and server launch)
- `apps/arma3/defaults/server.cfg` (seed only when missing; minimal, see section 7)

No `etc/`, `root/`, or `DOWNSTREAM_CHANGES.md` (not a FROM base). `defaults/` and `start.sh` are on the `include/.dockerignore` allow-list.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<UNVERIFIED: digest of the published steamcmd image>`

Why: `apps/steamcmd` already provides the 32-bit steamcmd install, `/usr/local/bin/steamcmd`, `HOME=/config`, `USER apps`, and the install logic (`STEAM_APP_IDS`, `STEAM_INSTALL_DIR`). Using it avoids reinstalling Steam and lib32 packages. The steamcmd image is amd64 only, which matches the game.

- Note: `apps/steamcmd` must be published (or built locally) before this FROM line resolves. Its digest is not in the repo, so the value is UNVERIFIED and must be taken from the published tag.
- Closest sibling: `apps/steamcmd` (the base itself). No other game server exists in `apps/`.

## 4. Dockerfile

Single stage on the steamcmd base:

1. `ARG VERSION` (must match `docker-bake.hcl`, the steamcmd base version, used only for labels).
2. Runtime-only: the steamcmd base already runs as `apps`. Copy the seed file and start script:
   - `USER root` only if a `mkdir`/`chown` for `/config/arma3` is needed (it is not: the base creates `/config` and `apps` owns it). Otherwise stay `USER apps`.
3. `COPY --chmod=0755 . /` and `USER apps` as the last lines, as in `apps/steamcmd`.
4. `EXPOSE 2302/udp 2303/udp 2304/udp 2305/udp 2306/udp`.
5. `VOLUME`/`/config` is provided by the base.
6. `ENV`: `HOME=/config` and `XDG_DATA_HOME=/config` are set by the base's start.sh; set `STEAM_INSTALL_DIR=/config/arma3` in `start.sh`, not in the Dockerfile.
7. No ENTRYPOINT change needed: use `CMD ["/start.sh"]` only if the base has none (its Dockerfile has no CMD, so set `ENTRYPOINT ["/start.sh"]` in this image, which runs our start script with no extra args).

Key snippet:

```dockerfile
ARG VERSION
COPY --chmod=0755 start.sh /start.sh
COPY --chmod=0644 defaults/server.cfg /defaults/server.cfg
USER apps
COPY --chmod=0755 . /
EXPOSE 2302/udp 2303/udp 2304/udp 2305/udp 2306/udp
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "arma3" }

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" { default = "LicenseRef-Arma3-EULA" }   // open question, section 10
variable "SOURCE" { default = "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide" }
```

- Renovate: the steamcmd base version is the only pinned component. The game is not pinned (Steam app 233780 installs the latest build at start); call this out in the PR.
- Four standard targets and `group "default" { targets = ["image-local"] }`. `image-all` platforms: `linux/amd64` only (matches the base).
- Validate with `docker buildx bake --print` from `apps/arma3/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"
ports:
  - port: 2302
    protocol: udp
    required: true
  - port: 2303
    protocol: udp
    required: false
  - port: 2304
    protocol: udp
    required: false
  - port: 2305
    protocol: udp
    required: false
  - port: 2306
    protocol: udp
    required: false
env:
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: STEAM_APP_IDS
    default: "233780"
    required: false
  - name: STEAM_APP_VALIDATE
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `STEAM_USERNAME`/`STEAM_PASSWORD` are read by the base; list only those this image really uses. The base reads `STEAM_USERNAME` (or `STEAM_USER`) and `STEAM_PASSWORD`; add `STEAM_PASSWORD` (`required: false`, no default) only if private Steam logins are supported.
- Port protocols: UDP is per the chart's game ports; confirm with the Arma 3 docs (section 10).
- `dependencies`: none (the server downloads from Steam; no database).

## 7. start.sh

Plan (idempotent; installs on the first start; seeds config only when missing):

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
ARMA_DIR="/config/arma3"
mkdir -p "${ARMA_DIR}"

# Seed a minimal server.cfg only when missing (never overwrite user state)
[ -f "${ARMA_DIR}/server.cfg" ] || cp /defaults/server.cfg "${ARMA_DIR}/server.cfg"

# Install or update the server via the base's steamcmd wrapper.
# Args starting with "+" make the base run steamcmd directly (no interactive shell).
STEAMCMD_PRE_UPDATE=false STEAM_INSTALL_DIR="${ARMA_DIR}" \
  /start.sh +force_install_dir "${ARMA_DIR}" +login anonymous +app_update 233780 +quit

cd "${ARMA_DIR}"
exec ./arma3server_x64 -config=server.cfg -port=2302   # binary name: UNVERIFIED
```

- Notes: the base's `start.sh` runs `exec steamcmd.sh "$@"` when args begin with `+`, so the install is a one-shot call. Setting `STEAMCMD_PRE_UPDATE=false` avoids a second login. The `-mod=` and `-config=` flags come from the chart; the binary name and any further flags are UNVERIFIED.
- Use `exec` for the final server process (signal handling, PID 1 rule).
- Bind: the Arma server listens on `-port`; it must bind on all interfaces (the server's default is expected to be all interfaces; UNVERIFIED, test from outside the container).
- Cache: SteamCMD writes its own temp files under `/config/steamcmd/tmp` (the base's design). The protocol rule says caches go to `/tmp`: this is a known deviation to review; leaving it is the base's behaviour.
- Empty `/config`: the first start downloads the server (large). Document it in the PR.
- No `/app` writes.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 1800   # first start downloads the game; size and time UNVERIFIED
udp:                   # forgetool udp probe support: UNVERIFIED
- port: '2302'
filePaths:
- /start.sh
- /defaults/server.cfg
```

- Coverage: every port in settings.yaml should have a probe (coverage minimum). Probes for UDP ports need forgetool's udp support: **UNVERIFIED**. If there is no udp probe, the tcp probe cannot pass for a UDP-only server, so either (a) narrow the test with a file/process assertion and an explicit comment, or (b) ask forgetool to add a UDP probe. Do not fake a tcp probe.
- The test runs with no env vars, so the Steam login branch is not exercised. `STEAM_PASSWORD` code paths go to `filePaths` only if they are added.
- `timeoutSeconds` must cover the full game download in CI; check the value against the forgetool default and sibling game tests before merging.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in this plan |
| --- | --- |
| `/serverdata/.local/share` (profiles pvc) | `XDG_DATA_HOME=/config` (profiles under `/config/...`). |
| `/serverdata/serverfiles`, `/serverdata/steamcmd` | `/config/arma3` (server), `/config/Steam/steamcmd` (base's steamcmd). |
| SteamCMD temp | `/config/steamcmd/tmp` (base). Known deviation (section 7). |
| Upstream runs as root with `UID=99`, `GID=100` | `USER apps` (UID 568); no `UID/GID` env in this image. |
| `UMASK`, `DATA_PERM=770` | Not needed; the base's file ownership is `apps`. |

Draft expectations reconciled: chart runs as UID 0 (this image runs as `apps`), chart `readOnlyRootFilesystem: false` (this plan is compatible with `--read-only --tmpfs /tmp` only if steamcmd temp writes stay in `/config`, which they do), not privileged, no extra capabilities. Persistence: `/config` only. The chart's separate `/serverdata/.local/share` mount becomes part of `/config`.

## 10. Risks, caveats and open questions

- **Server binary and launch args**: UNVERIFIED (section 1). Must be confirmed from the BI wiki before the start script is final.
- **Port protocol and probes**: the chart lists 2302 to 2306; UDP per port is inferred from game-server convention. Confirm, and check forgetool udp probe support (section 8).
- **Image LICENSE**: the game is commercial. Options: `LicenseRef-Arma3-EULA` (proposed, needs review), or the base's `AGPL-3.0-or-later` (wrong for the game). The image contains only scripts; decide before merge.
- **Unpinned game**: Steam app 233780 installs the current build at first start, so builds are not reproducible. Document; no renovate line for the game.
- **First-start size and time**: large Steam download; CI test timeout and disk use must be checked (UNVERIFIED sizes).
- **server.cfg**: the chart says users must create it by hand. This plan seeds a minimal file only when missing (keys to confirm on the wiki: `hostname`, `maxPlayers`, UNVERIFIED).
- **Mods from the Steam Workshop** need internet at runtime (inferred; not in scope for the first version).
- **Blockers**: amd64 only (no arm64 game build found). The base is i386 steamcmd; the 64-bit server needs the same lib32 deps the base already provides (UNVERIFIED for the server binary).

## 11. Build and test steps

```sh
cd apps/arma3
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name arma3-probe --read-only --tmpfs /tmp \
  -v arma3-probe-config:/config arma3:20180105-5build1
docker logs -f arma3-probe     # expect: steamcmd install lines, then the server start line
forgetool containers test --image arma3:20180105-5build1 --config ./apps/arma3/container-test.yaml
docker rm -f arma3-probe; docker volume rm arma3-probe-config
```

- Readiness signal: the steamcmd output shows `Success! App '233780' fully installed`, then the server prints its own startup/listening line (exact text UNVERIFIED). The process stays up.
- Empty `/config` must work; a restart with the same volume must reuse the install and keep `server.cfg`.
- Check the UDP port from outside the container (`-p 2302:2302/udp`) since a localhost check is not enough (`tcp`/`http` probes run inside the container).

## 12. PR checklist

- Branch `feat/add-arma3`, commit and PR title `feat(arma3): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; tick only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows status.
- State what is not tested (a full Arma 3 install and a client connection are unlikely in CI).
- `docker buildx bake --print` passes; `VERSION` equals `ARG VERSION`; the steamcmd base digest is filled in from the published image.
- Downstream: not a FROM base, so no `DOWNSTREAM_CHANGES.md`. Note that `arma3exilemod` will share this structure (see its plan).
