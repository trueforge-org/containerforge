# survivethenights — implementation plan
> Source: ./draft.md · Target: apps/survivethenights/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: the upstream image has no release version. The chart uses the moving tag `ghcr.io/ich777/steamcmd:stn`. Docker Hub `ich777/steamcmd:stn` was last updated 2024-12-19 and has one platform, linux/amd64 (https://hub.docker.com/v2/repositories/ich777/steamcmd/tags/stn). The game version is whatever Steam serves at start. |
| Renovate | UNVERIFIED: no stable version to track. Propose `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (the sibling `apps/steamcmd` precedent) for the SteamCMD package, and leave the game server unpinned (Steam serves it). |
| License | Wrapper repo `ich777/docker-steamcmd-server`: GitHub reports no SPDX (`license: null`). UNVERIFIED for the wrapper's own license text. The game is a Steam dedicated server under the Steam subscriber agreement (UNVERIFIED: not fetched). The container's `LICENSE` value must be decided on the sibling precedent (`apps/steamcmd` uses `AGPL-3.0-or-later` for its own packaging). |
| Source URL | Store page https://store.steampowered.com/app/541300/ (draft). Dedicated server app ID: UNVERIFIED (the store page is a client page; not confirmed on a fetched page). |
| Download | Game server: `steamcmd +login anonymous +app_update <APP_ID> validate` at start, content served by Steam. No release asset, no `COPY --from` route. |
| Checksum source | None published for the game files. SteamCMD itself is verified by the Ubuntu package (`steamcmd:i386=0~<VERSION>` in the sibling). |
| Upstream Dockerfile reviewed | `ich777/docker-steamcmd-server` master `Dockerfile` (base `ich777/debian-baseimage:bullseye_amd64`, `lib32gcc-s1 lib32stdc++6 lib32z1`, ENV `DATA_DIR=/serverdata`, `STEAMCMD_DIR`, `SERVER_DIR`, `GAME_ID`, `GAME_PORT=27015`, `UID=99`, `GID=100`, `USER=steam`, `UMASK=000`; `ENTRYPOINT ["/opt/scripts/start.sh"]`). Source: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile. The `stn` branch (commit `6b14a6890f5bc71dbee9f0b0088ed6a993ad241b`, 2022-10-25) was also reviewed: base `ich777/debian-baseimage`, `libsqlite3-0`, `GAME_ID="template"`, `LOG_FILE="stn.log"`, scripts `start.sh` and `start-server.sh` (`+app_update ${GAME_ID} validate`, `cd ${SERVER_DIR}`). |
| Ports | UNVERIFIED: `GAME_PORT=27015` is a wrapper default (master only). The draft's 27015/udp and 27016/udp (query) are inferred; the Steam server's real ports are not confirmed on a fetched page. |
| Env vars (real, wrapper) | `GAME_ID`, `GAME_PARAMS`, `GAME_PORT`, `VALIDATE`, `UMASK`, `UID`, `GID`, `USERNAME`, `PASSWRD`, `USER`, `DATA_PERM`, `DATA_DIR`, `STEAMCMD_DIR`, `SERVER_DIR` (master wrapper). The stn branch also has `LOG_FILE`, `DELETE_LOG`, `DEBUG_OUTPUT`, `LOG_OUTPUT`. These are the wrapper's variables, not ContainerForge's; the ContainerForge `steamcmd` base uses its own names (`STEAM_APP_IDS`, `STEAM_INSTALL_DIR`, `STEAM_APP_VALIDATE`, `STEAMCMD_PRE_UPDATE`, `STEAMCMD_SKIP_APP_UPDATE`, `STEAM_USERNAME`, `STEAM_PASSWORD`; see `apps/steamcmd/start.sh`). |
| Data / config write paths (wrapper) | `/serverdata/steamcmd` (SteamCMD), `/serverdata/serverfiles` (game files), user home `/serverdata` or `$SERVER_DIR`. The ContainerForge base writes to `/config/Steam`, `/config/steamcmd`, `/config/steamapps` (default `STEAM_INSTALL_DIR`). |
| arm64 | No. SteamCMD bootstrap is 32-bit x86 (`steamcmd_linux.tar.gz`, lib32 libs). Draft and wrapper agree: amd64 only. |
| Dependencies | None (the wrapper has no external DB). |
| Blockers | Dedicated server app ID and the server binary name/command are UNVERIFIED. First start downloads the server from Steam (large, network required). The wrapper's scripts run as root for `usermod`/`chown`; our base already drops to `apps`. |

## 2. Target layout

- `apps/survivethenights/Dockerfile`
- `apps/survivethenights/docker-bake.hcl`
- `apps/survivethenights/settings.yaml`
- `apps/survivethenights/container-test.yaml`
- `apps/survivethenights/scripts/survivethenights-start.sh` (the game start wrapper; not a top-level `start.sh`, which would replace the base's `/start.sh` through `COPY . /`)

No `defaults/`, `etc/`, `health/` needed (SteamCMD writes its own state into `/config`). No `root/` (never touched by agents). No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

Use the ContainerForge steamcmd base, not the wrapper image:

`FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`: UNVERIFIED tag and digest. No sibling app in `apps/` uses `trueforge-org/steamcmd` as `FROM` (grep of `apps/*/Dockerfile` finds none), so copy the exact tag and digest from the registry at build time, or build the base locally first (`apps/steamcmd`). The sibling `apps/steamcmd` itself is built on `ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Why: it already has the 32-bit SteamCMD (`steamcmd:i386`), the `lib32` runtime, `HOME=/config`, the `apps` user, and a start script that installs Steam apps into `/config`. Closest sibling for layout: `apps/steamcmd`. Wrapper image is not used.

## 4. Dockerfile

1. `ARG VERSION` / `ARG VENDOR` are not needed for the game; keep only what the base needs.
2. Final stage: `FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`.
3. Do not copy a `start.sh` over `/start.sh` (the base's script, which `/usr/local/bin/steamcmd` execs). The `.dockerignore` allow-list includes `scripts/`, so `COPY --chmod=0755 . /` delivers `scripts/survivethenights-start.sh` to `/scripts/survivethenights-start.sh`; that is the entrypoint to use.
4. `USER root` only if a package install is needed. The draft needs none (lib32 comes from the base).
5. `USER apps`, then `COPY --chmod=0755 . /`.
6. `VOLUME /config`, and `ENV STEAM_INSTALL_DIR=/config/serverfiles` with the Steam app ID supplied at run time through `STEAM_APP_IDS` (UNVERIFIED app ID: do not bake a guessed ID).
7. No `EXPOSE` until the ports are verified (section 10).

Note: the base `start.sh` (`apps/steamcmd/start.sh`) writes its temp scripts to `/config/steamcmd/tmp`, not `/tmp`. The brief asks for caches in `/tmp`, but this is the base's behaviour and must not be changed in this app PR (see section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "survivethenights"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd versioning=loose
  default = "<steamcmd base tag, UNVERIFIED>"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/541300/"
}
```

Then the four standard targets (`image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }`, copied from `apps/steamcmd/docker-bake.hcl`. `image-all` lists `linux/amd64` only (arm64 not supported). Validate with `docker buildx bake --print` in `apps/survivethenights/`. `LICENSE` must match the software in the image: the game is Steam-licensed and the packaging is a wrapper, so this value is UNVERIFIED until a maintainer decides it (follow `apps/steamcmd` precedent).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/541300/"
ports:
  []   # UNVERIFIED: 27015/udp and 27016/udp are inferred, add only after the server's real ports are confirmed
env:
  - name: STEAM_APP_IDS
    default: ""              # UNVERIFIED app ID: set by the chart or the user
    required: true
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Rules applied: only variables the start script reads are listed (`STEAM_APP_IDS`, `STEAM_USERNAME` come from the base). `required: true` on `STEAM_APP_IDS` needs a default or first-run handling: an empty default is only acceptable if `start.sh` fails clearly when it is missing (see section 7). Ports stay empty until verified, so no port without a probe.

## 7. scripts/survivethenights-start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ -z "${STEAM_APP_IDS:-}" ]; then
  echo "Error: STEAM_APP_IDS is required (Steam dedicated server app ID)." >&2
  exit 1
fi

export STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"
export STEAM_APP_VALIDATE="${STEAM_APP_VALIDATE:-false}"

# Base /start.sh installs/updates STEAM_APP_IDS only when its first argument starts with "+";
# a non-"+" first argument is exec'd immediately without installing (apps/steamcmd/start.sh).
/start.sh +quit
exec "${STEAM_INSTALL_DIR}/<SERVER_BINARY>" "$@"   # UNVERIFIED binary name and arguments
```

Notes:
- Verified in `apps/steamcmd/start.sh`: a non-`+` first argument is `exec`ed straight away (no install), while a `+` argument runs the `app_update` loop first and then `exec`s `steamcmd.sh`. Hence the `/start.sh +quit` step above.
- `<SERVER_BINARY>` and its launch arguments are UNVERIFIED (not fetched). Do not guess.
- No writes to `/app` (none used). Caches stay where the base puts them.
- Seeding: nothing to seed; SteamCMD fills `/config` on first start.
- Bind address and game ports are UNVERIFIED until the server is observed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

- Port probes: none until ports are confirmed (no `tcp` or `http` entry without a declared port, to avoid a false positive). Add a `tcp`/UDP check once `settings.yaml` lists the port.
- The test runs without `STEAM_APP_IDS`, so the game-download path is NOT covered by this test. Add the start script path to `filePaths` only if it is a real file the test can check, and run the download path manually (protocol step 3) with a fresh `/config` volume and `STEAM_APP_IDS` set.
- `timeoutSeconds: 120` is the value used by the base's `container-test.yaml`-style apps; the game download is far longer, so the first real run needs a longer manual timeout, and CI will not exercise the download.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/steamcmd` (wrapper SteamCMD dir) | `/config/Steam/steamcmd` (base) |
| `/serverdata/serverfiles` (wrapper game files) | `STEAM_INSTALL_DIR=/config/serverfiles` (default in `start.sh`) |
| `/serverdata` home of `steam` user | Base sets `HOME=/config`, `XDG_DATA_HOME=/config`. |
| `/config/steamcmd/tmp` (base temp scripts) | Stays in `/config` (base behaviour). The brief asks for `/tmp` caches; changing the base is out of scope for this app PR. Record as a caveat. |
| wrapper `chown`/`usermod` at start | Not used: the base already runs as `apps` and the wrapper is not used. |

Read-only rootfs: the base's `start.sh` does `mkdir`/`cp` only under `/config`, which is writable. `/tmp` is a tmpfs at test time. The `steamcmd` binary and script live in `/usr/local` and are read-only.

Security expectations (draft, chart values; unverified): chart runs root (`runAsUser 0`), not read-only, extra PVCs for `/serverdata/serverfiles` and `/serverdata/steamcmd`. The ContainerForge plan runs as `apps`, is read-only-rootfs compatible, and maps the two PVC paths onto `/config`. The root-run chart is not copied.

## 10. Risks, caveats and open questions

- BLOCKER: dedicated server Steam app ID is UNVERIFIED. The draft's 541300 is the store page ID, not confirmed to be the server app. Read it from `charts/stable/survivethenights` (`GAME_ID` / the chart's app id) before writing `STEAM_APP_IDS`.
- BLOCKER: server binary name, launch arguments and listen ports are UNVERIFIED.
- Base image tag and digest for `ghcr.io/trueforge-org/steamcmd` are UNVERIFIED (no sibling uses it as `FROM`).
- Draft expects 27015/udp and 27016/udp. Unverified, and the probe type for UDP is not covered by `tcp`/`http` checks, so no probe is written.
- First start downloads a large Steam server; needs network; time to first ready is long.
- `steamcmd` interactive mode: running the base with no arguments starts an interactive shell; the start script must always pass the server command, never leave it empty.
- arm64 not supported (x86 SteamCMD bootstrap). `image-all` lists amd64 only.
- The chart runs as root and without a read-only rootfs. This plan intentionally differs (apps user, read-only).
- License value for the container is UNVERIFIED (section 5).
- `DOWNSTREAM_CHANGES.md` not needed.

## 11. Build and test steps

```sh
cd apps/survivethenights
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name survivethenights-probe --read-only --tmpfs /tmp \
  -e STEAM_APP_IDS=<APP_ID> \
  -v survivethenights-probe-config:/config survivethenights:<VERSION>
docker logs -f survivethenights-probe
forgetool containers test --image survivethenights:<VERSION> --config ./apps/survivethenights/container-test.yaml
docker rm -f survivethenights-probe; docker volume rm survivethenights-probe-config
```

- Expected readiness signal: SteamCMD prints `Success! App '<APP_ID>' fully installed` and then the server binary's own ready line (UNVERIFIED text; take it from the first real run's log).
- Empty `/config` start is mandatory: use a fresh volume per round.
- Protocol step 3 cannot complete in a no-network CI run; record the download step as not tested if the network is unavailable.

## 12. PR checklist

- Branch `feat/add-survivethenights`, commit `feat(survivethenights): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; only check what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- Say what was not tested: the Steam download and game start (network and app ID unverified), arm64 (not supported), UDP ports.
- Confirm `docker buildx bake --print` ran, and state whether the image built.
