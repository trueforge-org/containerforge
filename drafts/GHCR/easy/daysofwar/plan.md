# daysofwar — implementation plan
> Source: ./draft.md · Target: apps/daysofwar/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No upstream release or tag we can pin; the server is downloaded by SteamCMD at start. Chart image `ghcr.io/ich777/steamcmd:daysofwar@sha256:59072499aaf86ab98d031fda6b5ebd5cc28079371b9835e3d48af5fab6ac907f`. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/daysofwar/values.yaml . The game build number is UNVERIFIED. |
| Steam IDs | SteamCMD `GAME_ID` = `541790` (chart). The draft's store link is a search page, not an app page, so it is not a usable source. |
| Renovate | Game: none. Base: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (from `apps/steamcmd/docker-bake.hcl`). |
| License | UNVERIFIED. The ich777 wrapper repo has no LICENSE at the path we tried (HTTP 404; `gh api` license lookup 404). Game server terms not fetched. |
| Source URL | Draft uses `https://store.steampowered.com/search/?term=Days+of+War`, which is a search page. Proposed: `https://store.steampowered.com/app/541790`: UNVERIFIED (not fetched). |
| Download | SteamCMD `app_update 541790` (anonymous login), amd64 only. No prebuilt binary. |
| Checksum source | None. SteamCMD `validate` (chart `VALIDATE=false`) is the only integrity check. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile : `FROM ich777/debian-baseimage:bullseye_amd64`, apt `lib32gcc-s1 lib32stdc++6 lib32z1`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no `USER` (root), data in `/serverdata`, `UID=99`, `GID=100`. |
| Ports | Chart: `7777/udp` (main, `GAME_PORT=7777`) and `27015/udp` (steamport, `QUERY_PORT=27015`). Source: chart values above. The draft lists only `27015/udp`, which is incomplete. |
| Env (chart) | `GAME_ID=541790`, `GAME_PARAMS=dow_cathedral`, `GAME_PORT=7777`, `QUERY_PORT=27015`, `USERNAME=""`, `VALIDATE=false`, `PASSWRD` from secret `env-secrets` (Steam login password). Source: chart values above. |
| Persistence (chart) | `/serverdata/serverfiles`, `/serverdata/steamcmd`. ContainerForge uses `/config` (section 9). |
| Chart security | `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. Source: chart values above. |
| Dependencies | None. `apps/steamcmd` exists and is the runtime base. |

## 2. Target layout

- `apps/daysofwar/Dockerfile`
- `apps/daysofwar/docker-bake.hcl`
- `apps/daysofwar/settings.yaml`
- `apps/daysofwar/container-test.yaml`
- `apps/daysofwar/start.sh`

No `defaults/`, `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md`: this app is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<DIGEST UNVERIFIED>`. Reason: `apps/steamcmd` provides SteamCMD (`/usr/local/bin/steamcmd`, `/usr/local/share/steamcmd/steamcmd.sh`) with the i386 build, plus `/start.sh`, which installs apps from `STEAM_APP_IDS`. The tag is the `apps/steamcmd` VERSION; the published digest is UNVERIFIED. Closest siblings: `apps/steamcmd` (base) and `apps/adguardhome-sync` (layout). Foundation: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

## 4. Dockerfile

No build stage: nothing is compiled.

```dockerfile
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<DIGEST UNVERIFIED>

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config \
    STEAM_INSTALL_DIR=/config/serverfiles

COPY --chmod=0755 start.sh /start.sh

USER apps
COPY --chmod=0755 . /

EXPOSE 7777/udp 27015/udp
VOLUME /config
```

- No `apt-get` step: the 32-bit libs come from the base. If the server fails for a missing lib, add a pinned package in a `USER root` step, as `apps/steamcmd` does, and record it.
- `ARG VERSION` only matches the bake target (section 5).
- `USER apps` is final, per the Dockerfile rules.
- License file not copied (no license text fetched). When confirmed, copy to `/usr/share/licenses/daysofwar/LICENSE`.

## 5. docker-bake.hcl

- `APP` = `daysofwar`
- `VERSION` = `20180105-5build1`, with `// renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (copied from `apps/steamcmd`). Open decision: the game is downloaded at start, so no game version is in the image. The base SteamCMD version keeps the tag honest.
- `LICENSE` = UNVERIFIED. Must be set to the confirmed license before merge.
- `SOURCE` = proposed `https://store.steampowered.com/app/541790` (UNVERIFIED page; see section 1).
- Four standard targets and the `default` group copied from `apps/steamcmd/docker-bake.hcl`. `image-all` platforms = `["linux/amd64"]` only (no arm64, section 10).

Validate with `docker buildx bake --print` from `apps/daysofwar`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/541790"
ports:
  - port: 7777
    protocol: udp
    required: true
  - port: 27015
    protocol: udp
    required: true
env:
  - name: STEAM_APP_IDS
    default: "541790"
    required: false
  - name: STEAM_APP_VALIDATE
    default: "false"
    required: false
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: GAME_PARAMS
    default: "dow_cathedral"
    required: false
  - name: GAME_PORT
    default: "7777"
    required: false
  - name: QUERY_PORT
    default: "27015"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Names are the ones `start.sh` reads. `STEAM_*` names follow `apps/steamcmd`. `GAME_PARAMS`, `GAME_PORT` and `QUERY_PORT` follow the chart.
- Chart `PASSWRD` maps to `STEAM_PASSWORD`, needed only for authenticated login. No default. Keep it out of logs.
- Dependencies: none.

## 7. start.sh

Requirements (start-script rules): idempotent, `app_update` on each start, write only to `/config` and `/tmp`, `exec` the final process.

Plan:

1. Install or update with the base SteamCMD start script:
   `STEAM_APP_IDS="${STEAM_APP_IDS}" STEAM_INSTALL_DIR=/config/serverfiles /start.sh +quit`
   The base only runs `app_update` when `STEAM_APP_IDS` is set and `STEAMCMD_SKIP_APP_UPDATE` is not `true`. A first argument starting with `+` does not `exec`, so the call returns after the update.
2. `mkdir -p /config/serverfiles` when missing. Seed nothing else.
3. `cd /config/serverfiles`, then start the server with `GAME_PARAMS`, `GAME_PORT` and `QUERY_PORT`, and `exec` it.

Server launch line: UNVERIFIED. The ich777 wrapper's `start-server.sh` was not fetched, so the binary and its arguments are not confirmed. Read them from the upstream source at build time. Do not invent them.

Other requirements:
- Bind to all interfaces. Confirm from outside the container that the game listens on `0.0.0.0`: UNVERIFIED.
- 32-bit SDK libs: whether the server needs `${DATA_DIR}/.steam/sdk32` is UNVERIFIED. If it does, create it under `/config/.steam/sdk32`, not `/tmp`.
- No writes to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: UNVERIFIED
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
```

- Every port needs a probe (coverage minimum). Both ports here are UDP. A `tcp` check cannot probe them. Whether forgetool supports UDP probes is UNVERIFIED. Record the gap, do not invent a probe. This is a coverage gap to call out in the PR.
- The test runs with no env vars, so `start.sh` will start a SteamCMD download first (`STEAM_APP_IDS` default `541790`). That needs network and a long time. `timeoutSeconds` has no sibling value to copy; set it from the first measured run.
- Code paths that need `STEAM_PASSWORD` are not run by the test. Test them by hand per the protocol.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/serverfiles` | `/config/serverfiles` (`STEAM_INSTALL_DIR`). |
| `/serverdata/steamcmd` | `/config/Steam` (base default). |
| `/serverdata` as `HOME` | `HOME=/config`. Steam state persists in `/config`, which is acceptable config. |
| Base run-script temp dir `/config/steamcmd/tmp` | Written by the base `start.sh` under `/config`. Deviates from "caches go to `/tmp`". Recorded as a caveat (section 10). |
| UID 0 in chart | Runs as `apps` (base `USER apps`). |
| `readOnlyRootFilesystem: false` in chart | Target `--read-only --tmpfs /tmp`. |

## 10. Risks, caveats and open questions

- arm64: not supported. SteamCMD's i386 bootstrap and the upstream amd64-only base are x86 only. `image-all` stays `linux/amd64`.
- License: UNVERIFIED. Blocks merge until set.
- Version tag: the image tag is the SteamCMD base version because the game is downloaded at start. Confirm before merge.
- Ports: the draft lists only `27015/udp`. The chart adds `7777/udp` as the game port, and that is the one to publish first.
- Store page: the draft's store link is a search page. Confirm the app page before using it as `SOURCE`.
- UDP-only ports: no TCP probe is possible (section 8).
- First start is a large SteamCMD download and needs Steam network access.
- Base writes its run script under `/config/steamcmd/tmp` (section 9).
- Steam login password (`PASSWRD`) goes through the base's run-script file (mode 600). Do not log it.
- Blockers: none beyond the open items above. No privileged mode, no GPU, no musl-only build.

## 11. Build and test steps

```sh
cd apps/daysofwar
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name daysofwar-probe --read-only --tmpfs /tmp \
  -v daysofwar-probe-config:/config daysofwar:20180105-5build1
docker logs -f daysofwar-probe
forgetool containers test --image daysofwar:20180105-5build1 --config ./apps/daysofwar/container-test.yaml
docker rm -f daysofwar-probe; docker volume rm daysofwar-probe-config
```

Expected readiness signals (UNVERIFIED until run): SteamCMD's install success line for app `541790`, then the server's startup and listen lines on UDP `7777`. Confirm the `/config/serverfiles` tree persists across a restart.

## 12. PR checklist

- Branch `feat/add-daysofwar`, commit and PR title `feat(daysofwar): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say what is untested: the image build, the `--read-only` run, the server start, the UDP ports, and arm64 (not planned).
- `docker buildx bake --print` passes, and bake `VERSION` equals the Dockerfile `ARG VERSION`. No assertion was weakened.
