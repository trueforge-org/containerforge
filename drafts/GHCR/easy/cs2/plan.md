# cs2 — implementation plan
> Source: ./draft.md · Target: apps/cs2/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No release version: the server is a Steam app (app id 730) that SteamCMD installs at first start. The chart pins the image by branch tag `cs2@sha256:6c8e46d4300d27c33548a1a151da87b02d8afba37bd8b94970b9d14fcd4d2288` (TrueCharts `charts/stable/cs2/values.yaml`). The image version in our bake is therefore the SteamCMD base version, not the game build. |
| Renovate | Base: `// renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (taken from `apps/steamcmd/docker-bake.hcl`, not a new convention). Game build is not pinned (SteamCMD `app_update` pulls latest). |
| License | Wrapper repo license not fetched: UNVERIFIED. Game is proprietary Valve software. Our LICENSE for the bake: `AGPL-3.0-or-later` only if we follow `apps/steamcmd`; otherwise UNVERIFIED. |
| Source URL | https://store.steampowered.com/app/730 (Steam store). Docs: https://developer.valvesoftware.com/wiki/Counter-Strike_2/Dedicated_Servers |
| Download | Not a prebuilt binary we fetch. SteamCMD (`steamcmd:i386` from Ubuntu multiverse) downloads app 730 at first start into `/config/serverfiles`. |
| Checksum source | None on the fetched path. SteamCMD verifies depots itself via `validate`. UNVERIFIED for the bootstrap download. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cs2/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`; installs `lib32gcc-s1 lib32stdc++6 lib32z1 lsof libicu67`; `ENV USER=steam UID=99 GID=100 DATA_DIR=/serverdata STEAMCMD_DIR=${DATA_DIR}/steamcmd SERVER_DIR=${DATA_DIR}/serverfiles GAME_PORT=27015 VALIDATE="" UMASK=000 USERNAME="" PASSWRD="" DATA_PERM=770`; `ENTRYPOINT ["/opt/scripts/start.sh"]`; no VOLUME, EXPOSE or CMD. |
| Upstream start scripts reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cs2/scripts/start.sh and `.../scripts/start-server.sh`. SteamCMD tarball from `http://media.steampowered.com/client/steamcmd_linux.tar.gz`. Login `+login anonymous` or `+login ${USERNAME} ${PASSWRD}`. `+force_install_dir ${SERVER_DIR}`. `+app_update ${GAME_ID} validate`. Launch `${SERVER_DIR}/game/bin/linuxsteamrt64/cs2 ${GAME_PARAMS}`, with `LD_LIBRARY_PATH=${SERVER_DIR}/bin/linuxsteamrt64`. Steam client libs copied to `${DATA_DIR}/.steam/sdk64/`. Ports only through `GAME_PARAMS`. |
| Port | `main` 27015/udp (game and query). `rcon` 27020/tcp per TrueCharts chart. **The draft says 27015/tcp for rcon: the chart says 27020/tcp, so the draft is wrong here.** SourceTV 27020/udp is inferred only, not in the chart. |
| Env vars (real) | Upstream: `DATA_DIR`, `STEAMCMD_DIR`, `SERVER_DIR`, `GAME_ID`, `GAME_NAME`, `GAME_PARAMS`, `GAME_PORT`, `VALIDATE`, `UMASK`, `USERNAME`, `PASSWRD`, `UID`, `GID`, `USER`, `DATA_PERM`. Chart sets `STEAMCMD_DIR`, `SERVER_DIR`, `GAME_PORT`, `GAME_ID`, `USERNAME`, `PASSWRD`, `GAME_PARAMS`, `VALIDATE`. Chart `GAME_ID` value is set by the chart (cs2.game.id, default 730 expected: UNVERIFIED for the default value). |
| Data path | Upstream writes to `/serverdata` (steamcmd and serverfiles). Our target: `/config/steamcmd` and `/config/serverfiles`. |
| arm64 | No. SteamCMD's bootstrap is 32-bit x86 and the upstream base is `bullseye_amd64`. |
| Dependency | None. |

## 2. Target layout

- `apps/cs2/Dockerfile`
- `apps/cs2/docker-bake.hcl`
- `apps/cs2/settings.yaml`
- `apps/cs2/container-test.yaml`
- `apps/cs2/start.sh` (replaces upstream `start.sh` and `start-server.sh`)

No `defaults/`, `etc/`, `health/`, `scripts/` or `root/` needed: the wrapper's scripts are replaced by one `start.sh`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:UNVERIFIED` (digest must be read from the registry at build time; not in any fetched page). Fits because the steamcmd base already has SteamCMD at `/usr/local/share/steamcmd/steamcmd.sh`, `i386` arch enabled, `HOME`-agnostic wrapper and `/config`. Closest sibling: `apps/steamcmd` (the base itself). The ubuntu base is the steamcmd base's parent, so no separate `FROM ubuntu` is needed.

## 4. Dockerfile

1. `FROM ghcr.io/trueforge-org/steamcmd:<VERSION>@sha256:<digest>` with `ARG VERSION` and `ARG VENDOR` as in sibling.
2. `USER root`.
3. Install the 64-bit and 32-bit runtime libs the server needs and the base does not have: check with `ldd` on the downloaded binary during the build test. Candidates from upstream: `lib32gcc-s1 lib32stdc++6 lib32z1 lsof`, plus `libicu78` on Ubuntu 26.04 (upstream `libicu67` is Debian bullseye and does not apply). Use `apt-get install -y --no-install-recommends ... && rm -rf /var/lib/apt/lists/*`. Pin only if the package is needed beyond the base (no pin requirement for apt packages used only as runtime libs; UNVERIFIED for exact versions).
4. `mkdir -p /config/serverfiles /config/steamcmd`; `chown -R apps:apps /config`.
5. `ENV HOME=/config XDG_DATA_HOME=/config GAME_PORT=27015 GAME_ID=730 GAME_PARAMS="" VALIDATE="" STEAMCMD_DIR=/config/steamcmd SERVER_DIR=/config/serverfiles UMASK=002`.
6. `USER apps`, `COPY --chmod=0755 . /`.
7. `EXPOSE 27015/udp 27015/tcp 27020/tcp` (the tcp rcon port per chart; UNVERIFIED whether the game needs a separate tcp listener on 27015).
8. `VOLUME /config`.
9. `WORKDIR /config`.

## 5. docker-bake.hcl

- `variable "APP" { default = "cs2" }`
- `variable "VERSION"` with `// renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` and default `20180105-5build1` (must match the FROM tag).
- `variable "LICENSE"`: UNVERIFIED (use `AGPL-3.0-or-later` only if the wrapper is replaced by our own script; this is our own script, so the license for our files follows the repo default; confirm with maintainers).
- `variable "SOURCE" { default = "https://store.steampowered.com/app/730" }`
- Standard 4 targets plus `group "default" { targets = ["image-local"] }`.
- Validate with `docker buildx bake --print` before any build.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://developer.valvesoftware.com/wiki/Counter-Strike_2/Dedicated_Servers"
ports:
  - port: 27015
    protocol: udp
    required: true
  - port: 27015
    protocol: tcp
    required: false
  - port: 27020
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: GAME_PARAMS
    default: ""
    required: false
  - name: VALIDATE
    default: ""
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Env: `GAME_PARAMS` and `VALIDATE` are the ones the upstream reads. Confirm the exact `ports` and `env` schema against the forgetool schema before writing (schema fetch not done in this batch: UNVERIFIED).

## 7. start.sh

1. `set -euo pipefail`; `export HOME=/config`.
2. `mkdir -p /config/steamcmd /config/serverfiles`; idempotent.
3. SteamCMD (`/usr/local/share/steamcmd/steamcmd.sh`) runs `+force_install_dir /config/serverfiles +login anonymous +app_update 730 [validate] +quit` (credentials from `STEAM_USERNAME`/`STEAM_PASSWORD` if set, same convention as `apps/steamcmd`). Note: how `apps/steamcmd/start.sh` handles `+` args was not fully read (UNVERIFIED): read the rest of that file first and reuse its helper rather than invent a new one.
4. Copy `steamclient.so` (or the sdk64 libs) from `/config/serverfiles` into `/config/.steam/sdk64/` (mirrors upstream `${DATA_DIR}/.steam/sdk64`).
5. `export LD_LIBRARY_PATH=/config/serverfiles/bin/linuxsteamrt64:${LD_LIBRARY_PATH:-}`.
6. Final: `exec /config/serverfiles/game/bin/linuxsteamrt64/cs2 -dedicated -port ${GAME_PORT} ${GAME_PARAMS}`. The `-dedicated` and `-port` flags are upstream-observed only via `GAME_PARAMS` (UNVERIFIED that `-port` is the exact flag; verify with `cs2 -help` during the build test).
7. No writes to `/app`. Caches in `/config`; `/tmp` only for temp files.
8. Bind 0.0.0.0 (CS2 default).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
filePaths:
- /start.sh
- /usr/local/share/steamcmd/steamcmd.sh
```

Probes: add a tcp probe on 27020 (rcon) and the udp game port only if the forgetool schema supports udp probes (UNVERIFIED). A first start downloads the CS2 server (very large), so a readiness probe inside the test window is not reliable. Test runs with no env vars: keep `GAME_PARAMS` empty and do not depend on a Steam login.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with `usermod` for `UID`/`GID`. We drop this: `USER apps`, no `usermod`, no `su`.
- Writes move from `/serverdata` to `/config`. `HOME`, `XDG_DATA_HOME` to `/config`.
- Read-only rootfs: `--read-only --tmpfs /tmp` in the test. SteamCMD temp files go to `/config/steamcmd/tmp`.
- Upstream `chown -R ${UID}:${GID}` is removed (apps owns `/config`).
- Chart securityContext (readOnlyRootFilesystem false, runAsUser 0) is NOT carried over: the container must run as `apps`. Confirm this is allowed for the chart: the chart's override is a TrueCharts concern, not ours.

## 10. Risks, caveats and open questions

- Draft caveats confirmed: arm64 not supported; GSLT normally needed for public listing (user supplies it; no env var name confirmed on fetched pages, UNVERIFIED for the var name); first start downloads a very large game (multi-GB, time and disk).
- Draft port error: rcon is 27020/tcp per chart, not 27015/tcp. Plan follows the chart.
- Draft security expectations confirmed by chart: runAsUser 0, readOnlyRootFilesystem false. Our target differs by design.
- Draft expects `/config` for persistence: chart persists `/serverdata/serverfiles` and `/serverdata/steamcmd`, which we map to `/config/serverfiles` and `/config/steamcmd`. Existing data from the chart is not migrated (note for users).
- Chart image is a digest pin of a branch tag; we have no version to pin against. Document in PR.
- Blockers: none known beyond the arm64 gap and the unverified steamcmd base digest.

## 11. Build and test steps

From `apps/cs2/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run with an empty config volume: `docker volume create cs2-probe-config`; `docker run --rm -d --name cs2-probe --read-only --tmpfs /tmp -v cs2-probe-config:/config ghcr.io/trueforge-org/cs2:<VERSION>` (tag per bake).
4. Readiness signal: SteamCMD logs `Success! App '730' fully installed` (UNVERIFIED wording; confirm during run) and the server starts printing `Server` startup lines. The first run is long: allow a long timeout.
5. `forgetool containers test` (or the protocol's `forgetool` call) with the container-test.yaml.
6. Cleanup: `docker rm -f cs2-probe; docker volume rm cs2-probe-config`.

## 12. PR checklist

- Branch `feat/add-cs2`; commit `feat(cs2): add new container`.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- Not tested: full CS2 server startup (first download is very large) unless the build test completes; state what was and was not run. Do not tick "Built container locally" unless it was built.
- Note the rcon port correction (27020/tcp) versus the draft.
