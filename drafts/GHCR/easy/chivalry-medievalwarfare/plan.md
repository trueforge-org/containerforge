# chivalry-medievalwarfare — implementation plan
> Source: ./draft.md · Target: apps/chivalry-medievalwarfare/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No upstream release. The Steam dedicated server (app `220070`) is downloaded at start, so the version is whatever Steam serves; pin the base (`apps/steamcmd` VERSION `20180105-5build1`). Source: https://api.github.com/repos/trueforge-org/truecharts/contents/charts/stable/chivalry-medievalwarfare/values.yaml |
| Draft tag | Draft does not name a version. Chart runs `ghcr.io/ich777/steamcmd:chivalrymw@sha256:d8b91714e90aa923171ada13b54a4a5ce38ece9aa1669e976f4f0eeae712bc5e` (same chart values URL). |
| Renovate | Base only: `datasource=deb depName=steamcmd` (from `apps/steamcmd/docker-bake.hcl`). Game version is not tracked (Steam build), so no renovate datasource exists for `GAME_ID`. |
| License | Game is closed-source (Steam EULA). Base `apps/steamcmd` is AGPL-3.0-or-later (its bake). The image LICENSE is the base license of the packaged wrapper; see section 10 (UNVERIFIED which value reviewers want). |
| Source URL | Steam app page not resolvable: `https://store.steampowered.com/api/appdetails?appids=220070` returned `success: false`. UNVERIFIED on Steam side. Use `https://store.steampowered.com/app/220070/` only after confirming. |
| Per-arch download | amd64 only: SteamCMD bootstrap is 32-bit x86. arm64 not available. Steam delivers the server at runtime, so no URL is baked in. |
| Checksum source | None published for the Steam server. The SteamCMD tarball is fetched by the upstream wrapper from `http://media.steampowered.com/client/steamcmd_linux.tar.gz` (no checksum). Base `apps/steamcmd` installs `steamcmd` from Ubuntu apt (signed by the Ubuntu archive). |
| Upstream wrapper | Tag branch `chivalrymw` of https://github.com/ich777/docker-steamcmd-server (last commit 2022-10-25). Dockerfile: `FROM ich777/debian-baseimage`, apt `lib32gcc-s1 libstdc++6:i386`, `ENV GAME_ID, GAME_PARAMS, VALIDATE, USERNAME, PASSWRD, UID=99, GID=100, UMASK=000, DATA_DIR=/serverdata`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. Confirmed via https://api.github.com/repos/ich777/docker-steamcmd-server/contents/Dockerfile?ref=chivalrymw |
| Upstream start-server | `chivalrymw` `scripts/start-server.sh`: downloads SteamCMD if missing, `+force_install_dir ${SERVER_DIR} +login anonymous +app_update ${GAME_ID} [validate]`, copies `steamclient.so` into `Binaries/Linux/lib`, writes `steam_appid.txt` = `219640`, seds `ServerName` and `MessageOfTheDay` in `UDKGame/Config/PCServer-UDKGame.ini`, then runs `${SERVER_DIR}/Binaries/Linux/UDKGameServer-Linux ${MAP}?adminpassword=${ADMIN_PWD}?steamsockets${GAME_PARAMS} ${GAME_PARAMS_EXTRA}`. Source: https://api.github.com/repos/ich777/docker-steamcmd-server/contents/scripts/start-server.sh?ref=chivalrymw |
| Env (chart, real) | `GAME_ID=220070`, `GAME_PARAMS=?port=7000?queryport=7010`, `GAME_PARAMS_EXTRA=-seekfreeloadingserver`, `MAP=aocffa-moor_p`, `ADMIN_PWD` (secret), `PASSWRD` (secret), `USERNAME=""`, `VALIDATE=true`. Source: chart values URL above. |
| Ports (chart, real) | udp 7000 (main), udp 7010 (gamequery), udp 27015 (steamquery). Source: chart values URL above. |
| Security (chart) | `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`; persistence `/serverdata/serverfiles`, `/serverdata/steamcmd`. Source: chart values URL above. |
| Dependencies | None. |
| Blockers | arm64 unsupported. Steam download on every start (VALIDATE=true slows start). |

Draft corrections: the draft's ports `7777/udp` are wrong. The chart uses `7000`, `7010` and `27015` (udp). The draft's `apt steamcmd` binary route is not how the chart's image gets SteamCMD; the chart uses the ich777 wrapper, and ContainerForge's `apps/steamcmd` provides the SteamCMD layer instead.

## 2. Target layout

- `apps/chivalry-medievalwarfare/Dockerfile`
- `apps/chivalry-medievalwarfare/docker-bake.hcl`
- `apps/chivalry-medievalwarfare/settings.yaml`
- `apps/chivalry-medievalwarfare/container-test.yaml`
- `apps/chivalry-medievalwarfare/start.sh`

No `defaults/`, `etc/`, `scripts/`, `health/` needed: the server config is written by the game on first start under `/config`. No `root/`. No `DOWNSTREAM_CHANGES.md` (this app is not a `FROM` base; `apps/steamcmd` has no downstream FROM consumers in this repo).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<VERSION>@sha256:<digest>`, where `<VERSION>` is `apps/steamcmd` `VERSION` (`20180105-5build1`). The digest must be read from the registry at build time (`docker buildx imagetools inspect ghcr.io/trueforge-org/steamcmd:20180105-5build1`); UNVERIFIED here because no digest is in the repo's pinned list. Fits because the base already provides SteamCMD under `/usr/local/share/steamcmd`, the `steamcmd` wrapper and `/config` owned by `apps`. Closest sibling: `apps/steamcmd` (same family). Do not use `ghcr.io/ich777/steamcmd` as the runtime base.

## 4. Dockerfile

1. `FROM ghcr.io/trueforge-org/steamcmd:<VERSION>@sha256:<digest>`, then `ARG VERSION` and `ARG VENDOR`.
2. No apt installs. The base ships `lib32` support through `steamcmd:i386`; do not add packages (base image reuse rule).
3. `COPY --chmod=0755 start.sh /start.sh` then `USER apps`. UNVERIFIED design flaw to resolve: this overwrites the base image's `/start.sh` (the SteamCMD wrapper that `/usr/local/bin/steamcmd` execs), so the plan's `start.sh` must reimplement the SteamCMD seeding (step 2 of section 7) or use a different file name.
4. `COPY --chmod=0755 . /`, `EXPOSE 7000/udp 7010/udp 27015/udp`, add `VOLUME /config` explicitly (the `apps/steamcmd` Dockerfile has no `VOLUME` line, so it is not provided by the base).
5. Final `USER apps`. No build stage, no downloads, no version to pin (the server version comes from Steam at runtime; `VERSION` in bake is the base version).
6. The `apps/steamcmd` Dockerfile sets no `ENV HOME`; set `ENV HOME=/config` here (start.sh also exports it).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "chivalry-medievalwarfare"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  default = "LicenseRef-Proprietary"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/220070/"
}
```

Use the four standard targets and the default group copied from `apps/steamcmd/docker-bake.hcl`, with `platforms = ["linux/amd64"]` for `image-all`. `VERSION` tracks the base (`apps/steamcmd`), so the Dockerfile `ARG VERSION` and the base tag stay aligned. Validate with `docker buildx bake --print` in `apps/chivalry-medievalwarfare`. LICENSE value needs a decision (section 10).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/220070/"
ports:
  - port: 7000
    protocol: udp
    required: true
  - port: 7010
    protocol: udp
    required: false
  - port: 27015
    protocol: udp
    required: false
env:
  - name: GAME_ID
    default: "220070"
    required: false
  - name: MAP
    default: "aocffa-moor_p"
    required: false
  - name: GAME_PARAMS
    default: "?port=7000?queryport=7010"
    required: false
  - name: GAME_PARAMS_EXTRA
    default: "-seekfreeloadingserver"
    required: false
  - name: VALIDATE
    default: "false"
    required: false
  - name: ADMIN_PWD
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none (no `dependencies:` block). `GAME_ID` is an upstream name kept for parity with the chart; `VALIDATE` defaults to `false` (chart uses `true`; a validate pass on every start is slow, so this is a decision, see section 10). Do not list env vars the app does not read.

## 7. start.sh

Plan (idempotent, empty `/config` safe, no writes to `/app`):

1. `set -euo pipefail`; `export HOME=/config`; `SERVER_DIR=/config/serverfiles`, `STEAMCMD_DIR=/config/steamcmd` (base wrapper's SteamCMD location `/config/Steam/steamcmd` is used by `apps/steamcmd`; reuse it, do not duplicate).
2. Seed SteamCMD only when missing, copying from `/usr/local/share/steamcmd` the same way as `apps/steamcmd/start.sh` does.
3. `mkdir -p "${SERVER_DIR}"`; run SteamCMD: `+force_install_dir ${SERVER_DIR} +login anonymous +app_update ${GAME_ID} [validate] +quit` (anonymous login only; `USERNAME` and `PASSWRD` are not exposed, so no password handling here).
4. Post-install: write `steam_appid.txt` with `219640` in `${SERVER_DIR}/Binaries/Linux/` only when missing; copy `steamclient.so` into `${SERVER_DIR}/Binaries/Linux/lib/` only when missing (both as the upstream does, both idempotent).
5. Config: the upstream seds `ServerName` and `MessageOfTheDay`. Do not overwrite existing user config. Seed `UDKGame/Config/PCServer-UDKGame.ini` only if missing (UNVERIFIED that the game creates it on first run).
6. `cd ${SERVER_DIR}/Binaries/Linux`; `exec ./UDKGameServer-Linux "${MAP}?adminpassword=${ADMIN_PWD}?steamsockets${GAME_PARAMS}" ${GAME_PARAMS_EXTRA}` (`exec` so signals reach the server). Quote the URL argument so spaces in `ADMIN_PWD` do not break it (see start-script rules on special characters).
7. Bind address: the server binds per its ini; it has no `0.0.0.0` flag in upstream. UNVERIFIED that the default bind is all interfaces; check in the test run.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

Probe gap: all three ports are UDP and the test primitives used in this repo are `tcp` and `http`, so no port probe can run. Per the test rules, every port needs a probe; the UDP case is UNVERIFIED for forgetool (check the schema for a `udp` key before the run). A full game download is not part of the container test (no network download in CI); the readiness signal is verified manually in section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/steamcmd` (chart PVC, SteamCMD) | `/config/Steam/steamcmd` (base behaviour, reused from `apps/steamcmd`). |
| `/serverdata/serverfiles` (chart PVC, game) | `/config/serverfiles`. |
| `HOME` / SteamCMD caches | `HOME=/config` from base. Steam may write `~/.steam` under `/config`; that is persistent state, acceptable, but caches should move to `/tmp` where the tool allows (UNVERIFIED which SteamCMD cache path to redirect). |
| `/opt/scripts` (ich777 wrapper) | Not used; the plan replaces it with `/start.sh`. |
| Upstream `chmod -R 770 ${DATA_DIR}` and `chown` | Not needed; the image runs as `apps` and `/config` is owned by `apps`. |

Security reconciliation: chart expects `runAsUser: 0`, `readOnlyRootFilesystem: false`. Plan: `USER apps`, works with `--read-only --tmpfs /tmp` since all writes go to `/config` and `/tmp`. Privileged: no. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- **Port correction**: draft's 7777 is wrong; use 7000, 7010, 27015 (udp), per chart.
- **App ID**: `GAME_ID=220070` comes from the chart. Steam store API returned no data, so the app ID is UNVERIFIED on Steam itself. `steam_appid.txt=219640` is taken from the upstream start script.
- **Launch binary**: `UDKGameServer-Linux` and its arguments are from upstream `start-server.sh` (`chivalrymw`), not from a running test. UNVERIFIED that the current Steam build keeps the same name.
- **First start**: Steam download of the full server; slow and needs internet. Expect `VALIDATE=false` by default.
- **UDP**: forwarding must be UDP; the host must forward 7000, 7010 and 27015 as UDP.
- **LICENSE**: the packaged game is proprietary, the base wrapper is AGPL-3.0-or-later. Decide what `LICENSE` in bake should say (proposal: `LicenseRef-Proprietary`); UNVERIFIED against project policy.
- **Cosmetic seds**: upstream sets server name and MOTD. Not ported (would overwrite user config).
- **Draft's binary route** (`apt:steamcmd`): superseded by the base image; no apt install in the plan.
- **arm64**: not supported; `image-all` is amd64 only.

## 11. Build and test steps

From `apps/chivalry-medievalwarfare`:

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with empty config: `docker run --rm -d --name chivalry-probe --read-only --tmpfs /tmp -v chivalry-probe-config:/config -e GAME_ID=220070 -e VALIDATE=true chivalry-medievalwarfare:<VERSION>`, then `docker logs -f chivalry-probe`. Pass signal: `Starting` / Steam `Success! App '220070' fully installed.` followed by the server process staying up; no fatal line from `start.sh`. Full download takes a long time; run for as long as the protocol requires and record the result.
4. Cleanup: `docker rm -f chivalry-probe; docker volume rm chivalry-probe-config`.
5. `forgetool containers test --image chivalry-medievalwarfare:<VERSION> --config ./container-test.yaml` (or by-hand checks if forgetool is missing).

## 12. PR checklist

- Branch `feat/add-chivalry-medievalwarfare`, commit `feat(chivalry-medievalwarfare): add new container`, PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, all sections and checkboxes kept; only tick what applies.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows status.
- Say what was not tested: the full Steam download, UDP probes, arm64 (not applicable), and any UNVERIFIED item above.
- Do not tick "Built container locally" unless the bake and build actually ran.
