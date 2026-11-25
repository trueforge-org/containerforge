# dayofdefeatsource — implementation plan
> Source: ./draft.md · Target: apps/dayofdefeatsource/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No upstream release or tag we can pin; the server is downloaded by SteamCMD at start. Chart image `ghcr.io/ich777/steamcmd:dods@sha256:5e0ed6189a9f94d0cd6f69eff78b6162d76f97b127046085de0061931348a7a9`. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dayofdefeatsource/values.yaml . The game build number is UNVERIFIED. |
| Steam IDs | SteamCMD `GAME_ID` = `232290` (chart), matching the draft's store link `https://store.steampowered.com/app/232290` (not fetched). |
| Renovate | Game: none. Base: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (from `apps/steamcmd/docker-bake.hcl`). |
| License | UNVERIFIED. The ich777 wrapper repo has no LICENSE at the path we tried (HTTP 404; `gh api` license lookup 404). Valve / DoD:S server terms not fetched. |
| Source URL | https://store.steampowered.com/app/232290 (draft; not fetched). |
| Download | SteamCMD `app_update 232290` (anonymous login), amd64 only. No prebuilt binary. |
| Checksum source | None. SteamCMD `validate` (chart `VALIDATE=false`) is the only integrity check. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile : `FROM ich777/debian-baseimage:bullseye_amd64`, apt `lib32gcc-s1 lib32stdc++6 lib32z1`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no `USER` (root), data in `/serverdata`, `UID=99`, `GID=100`. |
| Ports | Chart: `27015/udp` (main game, `GAME_PORT=27015`) and `27015/tcp` (rcon, service `tcprcon`). Source: chart values above. The draft's `27020/udp` (SourceTV) is NOT in the chart: UNVERIFIED. |
| Env (chart) | `GAME_ID=232290`, `GAME_NAME=dod`, `GAME_PARAMS="-secure +maxplayers 24 +map dod_kalt"`, `GAME_PORT=27015`, `USERNAME=""`, `VALIDATE=false`, `PASSWRD` from secret `env-secrets` (Steam login password, not a server password). Source: chart values above. |
| Persistence (chart) | `/serverdata/serverfiles`, `/serverdata/steamcmd`. ContainerForge uses `/config` (section 9). |
| Chart security | `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. Source: chart values above. |
| Dependencies | None. `apps/steamcmd` exists and is the runtime base. |

## 2. Target layout

- `apps/dayofdefeatsource/Dockerfile`
- `apps/dayofdefeatsource/docker-bake.hcl`
- `apps/dayofdefeatsource/settings.yaml`
- `apps/dayofdefeatsource/container-test.yaml`
- `apps/dayofdefeatsource/start.sh`

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

USER root
RUN cp /start.sh /usr/local/bin/steamcmd-base.sh
COPY --chmod=0755 start.sh /start.sh

USER apps
COPY --chmod=0755 . /

EXPOSE 27015/udp 27015/tcp
VOLUME /config
```

- No `apt-get` step: the 32-bit libs come from the base. If the server fails for a missing lib, add a pinned package in a `USER root` step, as `apps/steamcmd` does, and record it.
- `ARG VERSION` only matches the bake target (section 5).
- `USER apps` is final, per the Dockerfile rules.
- License file not copied (no license text fetched). When confirmed, copy to `/usr/share/licenses/dayofdefeatsource/LICENSE`.

## 5. docker-bake.hcl

- `APP` = `dayofdefeatsource`
- `VERSION` = `20180105-5build1`, with `// renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (copied from `apps/steamcmd`). Open decision: the game is downloaded at start, so no game version is in the image. The base SteamCMD version keeps the tag honest.
- `LICENSE` = UNVERIFIED. Must be set to the confirmed license before merge.
- `SOURCE` = `https://store.steampowered.com/app/232290`
- Four standard targets and the `default` group copied from `apps/steamcmd/docker-bake.hcl`. `image-all` platforms = `["linux/amd64"]` only (no arm64, section 10).

Validate with `docker buildx bake --print` from `apps/dayofdefeatsource`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/232290"
ports:
  - port: 27015
    protocol: udp
    required: true
  - port: 27015
    protocol: tcp
    required: false
env:
  - name: STEAM_APP_IDS
    default: "232290"
    required: false
  - name: STEAM_APP_VALIDATE
    default: "false"
    required: false
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: GAME_PARAMS
    default: "-secure +maxplayers 24 +map dod_kalt"
    required: false
  - name: GAME_PORT
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

- Names are the ones `start.sh` reads. `STEAM_*` names follow `apps/steamcmd`. `GAME_PARAMS` and `GAME_PORT` follow the chart.
- Chart `PASSWRD` maps to `STEAM_PASSWORD`, needed only for authenticated login. No default. Keep it out of logs.
- `GAME_PARAMS` default includes `-secure`. Check that the default is a safe starting point (UNVERIFIED).

## 7. start.sh

Requirements (start-script rules): idempotent, `app_update` on each start, write only to `/config` and `/tmp`, `exec` the final process.

Plan:

1. Install or update with the base SteamCMD start script:
   `STEAM_APP_IDS="${STEAM_APP_IDS}" STEAM_INSTALL_DIR=/config/serverfiles /usr/local/bin/steamcmd-base.sh +quit`
   The app's own `start.sh` replaces the base `/start.sh` (and the base `/usr/local/bin/steamcmd` wrapper execs `/start.sh`), so the Dockerfile first copies the base script to `/usr/local/bin/steamcmd-base.sh`. Calling `/start.sh` here would recurse.
   The base only runs `app_update` when `STEAM_APP_IDS` is set and `STEAMCMD_SKIP_APP_UPDATE` is not `true`. The base ends with `exec steamcmd.sh "$@"`, so run it as a child process (not `exec`) to return after `+quit`.
2. `mkdir -p /config/serverfiles` when missing. Seed nothing else.
3. `cd /config/serverfiles`, then start the server with `GAME_PARAMS` and `GAME_PORT`, and `exec` it.

Server launch line: UNVERIFIED. The ich777 wrapper's `start-server.sh` was not fetched, so the binary (likely `srcds_run` with `-game dod`) and its arguments are not confirmed. Read them from the upstream source at build time. Do not invent them.

Other requirements:
- Bind to all interfaces. Confirm from outside the container that the game listens on `0.0.0.0`: UNVERIFIED.
- 32-bit SDK libs: the upstream copies `linux32` libs to `${DATA_DIR}/.steam/sdk32`. Whether DoD:S needs this is UNVERIFIED. If it does, create it under `/config/.steam/sdk32`, not `/tmp`.
- No writes to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: UNVERIFIED
tcp:
- port: '27015'
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
```

- The `tcp` probe on `27015` covers the rcon port. It only passes if the server is listening, and with no env vars the test starts a SteamCMD download first. Whether the server reaches a listening state within the timeout is UNVERIFIED: measure on the first run.
- The game port is UDP. A `tcp` check cannot probe it. Whether forgetool supports UDP probes is UNVERIFIED. Record the gap, do not invent a probe.
- `timeoutSeconds` has no sibling value to copy; set it from the first measured run.
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
- Ports: the draft's `27020/udp` (SourceTV) is not in the chart. Use the chart's `27015` only until a source confirms SourceTV.
- First start is a large SteamCMD download and needs Steam network access.
- Base writes its run script under `/config/steamcmd/tmp` (section 9).
- Steam login password (`PASSWRD`) goes through the base's run-script file (mode 600). Do not log it.
- Blockers: none beyond the open items above. No privileged mode, no GPU, no musl-only build.

## 11. Build and test steps

```sh
cd apps/dayofdefeatsource
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dayofdefeatsource-probe --read-only --tmpfs /tmp \
  -v dayofdefeatsource-probe-config:/config dayofdefeatsource:20180105-5build1
docker logs -f dayofdefeatsource-probe
forgetool containers test --image dayofdefeatsource:20180105-5build1 --config ./apps/dayofdefeatsource/container-test.yaml
docker rm -f dayofdefeatsource-probe; docker volume rm dayofdefeatsource-probe-config
```

Expected readiness signals (UNVERIFIED until run): SteamCMD's install success line for app `232290`, then the server's startup and listen lines on `27015`. Confirm the `/config/serverfiles` tree persists across a restart.

## 12. PR checklist

- Branch `feat/add-dayofdefeatsource`, commit and PR title `feat(dayofdefeatsource): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say what is untested: the image build, the `--read-only` run, the server start, the UDP port, and arm64 (not planned).
- `docker buildx bake --print` passes, and bake `VERSION` equals the Dockerfile `ARG VERSION`. No assertion was weakened.
