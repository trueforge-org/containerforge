# mordhau — implementation plan
> Source: ./draft.md · Target: apps/mordhau/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Steam app **629800** (Mordhau dedicated server), installed at start by SteamCMD. The server build is not versioned in the image; the image version is the SteamCMD package pin from `apps/steamcmd` (`VERSION` 20180105-5build1, see below). Chart: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mordhau/values.yaml (`GAME_ID "629800"`). |
| Renovate | UNVERIFIED for the game: no version is published as a release. Image pin follows `apps/steamcmd` (`datasource=deb`). |
| License | The image wrapper and SteamCMD are AGPL-3.0-or-later per the sibling `apps/steamcmd/docker-bake.hcl`. The Mordhau server is proprietary Steam content. `LICENSE` in bake should describe the wrapper, and the EULA/Steam terms must be stated in docs (UNVERIFIED: Steam store and EULA not fetched). |
| Source URL | Steam store page https://store.steampowered.com/app/629800/ (from draft; UNVERIFIED: not fetched). Vendor: https://mordhau.com |
| Chart image (reference) | `ghcr.io/ich777/steamcmd:mordhau@sha256:fec246a17d24f63f17cdb4c1cdf6a6a2763afbaba7dbe5b4dec875de1c186384`. Upstream wrapper: https://github.com/ich777/docker-steamcmd-server (Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, `ENV DATA_DIR=/serverdata`, `SERVER_DIR=/serverdata/serverfiles`, `ENTRYPOINT ["/opt/scripts/start.sh"]`; its start.sh runs as root, remaps UID/GID, chowns the data dir, then runs `start-server.sh` as `USER`). We do not copy that wrapper. |
| Env vars (chart) | `GAME_ID=629800`, `GAME_PORT=7777`, `QUERY_PORT=27015`, `BEACON_PORT=15000`, `VALIDATE=false`, `USERNAME=""`, `PASSWRD` (secret, empty), `GAME_PARAMS=""`. Source: chart values above. |
| Ports (chart) | 7777/UDP (game), 15000/UDP (beacon), 27015/UDP (query). **Draft's query port 7787 is wrong**: the chart uses 27015. The draft's "7787 (inferred)" is replaced. |
| Data write paths (chart) | `/serverdata/serverfiles` and `/serverdata/steamcmd`. Draft plans `/config` (serverfiles) and `/tmp` (cache) instead. |
| Security (chart) | `runAsUser 0`, `runAsGroup 0`, `readOnlyRootFilesystem false`, `privileged` not set. |
| arm64 | No. Draft says `arm64: no`. UNVERIFIED: SteamCMD's Linux binary is 32-bit x86 (`steamcmd:i386`, see `apps/steamcmd/Dockerfile`), so arm64 is not runnable; this is consistent with the sibling. |
| SteamCMD sibling | `apps/steamcmd` installs `steamcmd:i386=0~20180105-5build1` from Ubuntu multiverse, provides `/start.sh` and `/usr/local/bin/steamcmd`, and already has `STEAM_APP_IDS`, `STEAM_INSTALL_DIR` (default `/config/steamapps`), `STEAM_APP_VALIDATE`, `STEAMCMD_SKIP_APP_UPDATE`, `STEAM_USERNAME`, `STEAM_PASSWORD`. Its image is `amd64` only (`image-all` has only `linux/amd64`). |
| Dependencies | None at runtime. Reuses `apps/steamcmd` logic (no sibling uses it as a `FROM` base). |

## 2. Target layout

- `apps/mordhau/Dockerfile`: required.
- `apps/mordhau/docker-bake.hcl`: required.
- `apps/mordhau/settings.yaml`: required.
- `apps/mordhau/container-test.yaml`: required.
- `apps/mordhau/start.sh`: required (installs/updates the server into `/config`, then `exec`s the server).

Not needed: `defaults/`, `root/`. `DOWNSTREAM_CHANGES.md` not needed (not a FROM base).

## 3. Base image

- FROM: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Why: SteamCMD needs 32-bit libs (`lib32gcc-s1`, `lib32stdc++6`, `lib32z1`) and Ubuntu multiverse, which `apps/steamcmd` already sets up on the ubuntu base.
- Alternative considered: `FROM ghcr.io/trueforge-org/steamcmd:<tag>`. Rejected for now: no sibling uses `steamcmd` as a `FROM` base and the published tag/digest scheme was not checked (open question, section 10).
- Closest sibling: `apps/steamcmd` (same family, same base, same start-script pattern).

## 4. Dockerfile

Single stage, amd64 only:

1. `ARG VERSION` (steamcmd package pin, `0~20180105-5build1`); `USER root`.
2. Repeat the install block from `apps/steamcmd/Dockerfile` (`dpkg --add-architecture i386`, multiverse, debconf for licence, `steamcmd:i386=0~${VERSION}`), then `rm -rf /var/lib/apt/lists/*`. Do not re-install packages already in the base.
3. `ENV HOME=/config STEAM_INSTALL_DIR=/config/serverfiles`, and `XDG_DATA_HOME=/config` as the steamcmd start script does.
4. Install the start script: `COPY --chmod=0755 start.sh /start.sh` (as in `apps/steamcmd`), `chown -R apps:apps /config`.
5. `mkdir -p /config`; `chown apps:apps /config`.
6. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 7777/udp 15000/udp 27015/udp
   VOLUME /config
   ```
7. Cache: `STEAMCMD_TMP_DIR` is under `/config/steamcmd/tmp` in the sibling. Keep it there only if persistence of steamcmd state is wanted; otherwise move to `/tmp` (open question, section 10).

Caveat for the Dockerfile rule that caches belong in `/tmp`: the SteamCMD install itself needs `/config/Steam` (the sibling copies `steamcmd.sh` there on first start).

## 5. docker-bake.hcl

Copy the layout of `apps/steamcmd/docker-bake.hcl`, with the mordhau name:

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mordhau"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/629800/"
}
```

- `image-all` lists only `linux/amd64` (same as `apps/steamcmd`), so arm64 is never built.
- Standard `group "default"`, `image`, `image-local` (`tags = ["${APP}:${VERSION}"]`). Validate with `docker buildx bake --print`.
- `VERSION` controls the SteamCMD package, not the game build. Game build changes at each start (`VALIDATE` and update behaviour below).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://mordhau.com"
ports:
  - port: 7777
    protocol: udp
    required: true
  - port: 15000
    protocol: udp
    required: false
  - port: 27015
    protocol: udp
    required: false
env:
  - name: STEAM_APP_IDS
    default: "629800"
    required: true
  - name: STEAM_INSTALL_DIR
    default: "/config/serverfiles"
    required: false
  - name: STEAM_APP_VALIDATE
    default: "false"
    required: false
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: STEAM_PASSWORD
    default: ""
    required: false
  - name: GAME_PORT
    default: "7777"
    required: false
  - name: QUERY_PORT
    default: "27015"
    required: false
  - name: BEACON_PORT
    default: "15000"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Every env listed must be read by `start.sh` (or the server). `STEAM_*` names come from `apps/steamcmd/start.sh`. `GAME_PORT`, `QUERY_PORT`, `BEACON_PORT` are chart names; they are only valid if `start.sh` passes them to the server's command line (UNVERIFIED which flags the Mordhau server accepts; confirm in step 3).
- `STEAM_PASSWORD` is a secret: `start.sh` must not echo it (the sibling already avoids logging it).

## 7. start.sh

Built on the steamcmd sibling. Outline:

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config
GAME_PORT="${GAME_PORT:-7777}"
QUERY_PORT="${QUERY_PORT:-27015}"
BEACON_PORT="${BEACON_PORT:-15000}"

# 1. install or update the dedicated server into /config/serverfiles via the steamcmd sibling logic
STEAM_APP_IDS="${STEAM_APP_IDS:-629800}" STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}" \
  /start.sh +quit   # UNVERIFIED: whether +quit with the steamcmd wrapper performs only the app_update path

# 2. run the server binary (path UNVERIFIED)
cd /config/serverfiles
exec ./MordhauServer.sh -Port="${GAME_PORT}" -QueryPort="${QUERY_PORT}" -BeaconPort="${BEACON_PORT}"
```

- The install step is the risky part: `apps/steamcmd/start.sh` runs `run_steamcmd_script` then `exec steamcmd.sh "$@"`. Calling it with `+quit` may only exec steamcmd. Implementation option to confirm in step 3: call the install function directly by copying the minimal `app_update` script flow (`login anonymous`, `force_install_dir`, `app_update 629800`, `quit`) into `start.sh` with `/config/Steam/steamcmd/steamcmd.sh +runscript`. Pick whichever works; do not weaken the sibling.
- Server binary and launch arguments are UNVERIFIED. The name `MordhauServer.sh` and the `-Port` / `-QueryPort` / `-BeaconPort` flags were not confirmed against a fetched page; confirm from the installed files (`ls` under `/config/serverfiles`) and the Mordhau server docs.
- Idempotent: SteamCMD skips an up-to-date install; `/config` is seeded only by the install.
- Never write to `/app`. Caches (`XDG_DATA_HOME`, steamcmd temp) must be under `/config` only if persistence is wanted; otherwise `/tmp` (see section 10).
- `exec` the server so it gets signals. The steamcmd install runs before `exec`.
- Listens on `0.0.0.0` by default in the server binary (UNVERIFIED; confirm in step 3).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 600
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
# narrowed: game server needs a SteamCMD download (large, network) on first start; full functional test not feasible in the test suite
```

- The test runs with no env. With no network the install fails, so the functional path cannot run in CI. The narrowed file checks are the minimum the protocol allows. The `steamcmd` sibling uses the same kind of file-only test.
- Port coverage: settings.yaml lists UDP ports. The forgetool test has `tcp` and `http` probes only (no `udp` probe in the sibling); this is an open question (section 10). Do not add a TCP probe to a UDP port.
- `timeoutSeconds: 600` is sized for a SteamCMD first start; the sibling's value was not checked (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream/chart behaviour | Our handling |
| --- | --- |
| Wrapper runs as root and chowns `/serverdata` | Not reproduced. Runs as `apps`; `/config` owned by `apps`. |
| Chart `runAsUser 0` / `runAsGroup 0` | Not reproduced. |
| Chart `readOnlyRootFilesystem false` | Target `yes`. SteamCMD writes under `/config` (`/config/Steam`, `/config/serverfiles`), so this is a volume, not the rootfs. Verify under `--read-only --tmpfs /tmp` in step 3. |
| Chart `/serverdata/serverfiles`, `/serverdata/steamcmd` | Remapped to `/config/serverfiles` and `/config/Steam`. |
| Chart `privileged` | Not set; not needed. |

## 10. Risks, caveats and open questions

- **Ports corrected.** The draft's query port 7787 is replaced by 27015 (chart). Draft's 7777 game and 15000 beacon are confirmed by the chart.
- **Server binary and flags UNVERIFIED.** Launch command and arguments must be read from the installed server files in step 3.
- **Install path.** Whether to call the sibling's start script with `+quit` or to write the minimal `app_update` flow in `start.sh` is open (section 7).
- **FROM choice.** Ubuntu base plus steamcmd install, versus `FROM ghcr.io/trueforge-org/steamcmd:<tag>`. No sibling does the second; the tag and digest scheme for `apps/steamcmd` was not checked. Chosen: ubuntu base.
- **Caches.** The sibling keeps steamcmd temp in `/config/steamcmd/tmp`. The ContainerForge rule says caches go to `/tmp`; move them unless steamcmd needs persistence. Decide and document.
- **UDP probes.** forgetool probes (`tcp`/`http`) may not cover UDP ports; decide how each UDP port is tested. Do not fake a TCP probe.
- **arm64** is not supported (32-bit SteamCMD). `image-all` lists only amd64.
- **Steam terms.** Mordhau is proprietary Steam content downloaded at runtime. Document the Steam/EULA terms; `LICENSE` covers the wrapper only.
- **Downloads are large** and the first start is slow (draft, UNVERIFIED size).
- **Blockers:** the launch command is unknown until the install is run; no other blockers identified.

## 11. Build and test steps

From `apps/mordhau/` (protocol commands, `<app>` = `mordhau`):

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty-config run, read-only with tmpfs (needs network to Steam):
   ```sh
   docker run --rm -d --name mordhau-probe --read-only --tmpfs /tmp \
     -v mordhau-probe-config:/config mordhau:<version>
   docker logs -f mordhau-probe
   ```
   Expected readiness signal: SteamCMD reports `Success! App '629800' fully installed`, then the server starts and logs its listen lines on 7777/UDP. Container stays running. First start can take many minutes; the probe must not stop early.
   Then inspect `/config/serverfiles` to confirm the server binary and flags (section 10).
4. `forgetool containers test --image mordhau:<version> --config ./container-test.yaml` (CI mechanism). If forgetool is unavailable, run the file checks and the readiness log check by hand.
5. Cleanup: `docker rm -f mordhau-probe; docker volume rm mordhau-probe-config`.
6. arm64 is out of scope (`image-all` is amd64 only).

## 12. PR checklist

- Branch: `feat/add-mordhau`.
- Commit: `feat(mordhau): add new container`. PR title matches.
- PR body: template at `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge; only the user can sign. The `license/cla` check shows status.
- Not tested (state in the PR until done): the full Steam install and server start, the server binary path and flags, UDP reachability, the Steam store and EULA terms, arm64 (not supported). Do not check "Built container locally" unless the build ran.
