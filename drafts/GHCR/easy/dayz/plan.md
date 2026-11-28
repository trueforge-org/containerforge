# dayz — implementation plan
> Source: ./draft.md · Target: apps/dayz/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No upstream release or tag is published for the DayZ server in a form we can pin; the server is downloaded by SteamCMD at start. Chart image is `ghcr.io/ich777/steamcmd:dayz@sha256:e29a926edc29addf4067c3a1c785df265b84c6533e0877650c5553b138037816`. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dayz/values.yaml . The game build number is UNVERIFIED. |
| Steam IDs | SteamCMD download ID `GAME_ID` = `1042420` (chart). Store page ID in the draft = `223350`. The relation between them is UNVERIFIED. Source: chart values above; https://store.steampowered.com/app/223350 (draft link, not fetched). |
| Renovate | Game: none (no versioned artifact). Base: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (from `apps/steamcmd/docker-bake.hcl`). |
| License | UNVERIFIED. The ich777 wrapper repo has no LICENSE at the path we tried (HTTP 404, and `gh api` license lookup 404). DayZ server terms are not fetched. |
| Source URL | https://store.steampowered.com/app/223350 (draft). Hosting docs https://community.bistudio.com/wiki/DayZ:Hosting_a_Linux_Server (draft, UNVERIFIED: not fetched). |
| Download | SteamCMD `app_update 1042420` (anonymous login), amd64 only. No prebuilt binary is ours to ship. |
| Checksum source | None. SteamCMD `validate` (chart `VALIDATE=false`) is the only integrity check. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile : `FROM ich777/debian-baseimage:bullseye_amd64`, apt `lib32gcc-s1 lib32stdc++6 lib32z1`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no `USER` (root), data in `/serverdata`, `UID=99`, `GID=100`. |
| Ports | Chart: `2302/udp` (main, `GAME_PORT=2302`) and `27016/udp` (steam query). Source: chart values above. The draft's `2303/udp` and `2304/udp` are NOT in the chart: UNVERIFIED. |
| Env (chart) | `GAME_ID=1042420`, `GAME_PARAMS=""`, `GAME_PORT=2302`, `USERNAME=""`, `VALIDATE=false`, `PASSWRD` from secret `env-secrets` (the Steam login password, not a server password). Source: chart values above. |
| Persistence (chart) | `/serverdata/serverfiles`, `/serverdata/steamcmd`. ContainerForge uses `/config` (see section 9). |
| Chart security | `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. Source: chart values above. |
| Dependencies | None. `apps/steamcmd` exists and is the runtime base. |
| Server config | Draft says the server needs a `serverDZ.cfg` the user supplies. Not confirmed on a fetched page: UNVERIFIED. |

## 2. Target layout

- `apps/dayz/Dockerfile`
- `apps/dayz/docker-bake.hcl`
- `apps/dayz/settings.yaml`
- `apps/dayz/container-test.yaml`
- `apps/dayz/start.sh`

No `defaults/`, `etc/`, `health/` or `root/` is planned: SteamCMD and the server data are created at first start. No `DOWNSTREAM_CHANGES.md`: this app is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@sha256:<DIGEST UNVERIFIED>`. Reason: `apps/steamcmd` already provides SteamCMD (`/usr/local/share/steamcmd/steamcmd.sh`, `/usr/local/bin/steamcmd`), the i386 build with 32-bit libs, and `/start.sh`, which installs apps through `STEAM_APP_IDS`. The tag is the `apps/steamcmd` VERSION; the published digest is UNVERIFIED because no fetched source or local build output provides it. Closest siblings: `apps/steamcmd` (base) and `apps/adguardhome-sync` (exemplar layout). Foundation: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.

## 4. Dockerfile

No build stage: nothing is compiled, and the server is not in the image.

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

EXPOSE 2302/udp 27016/udp
VOLUME /config
```

- No `apt-get` step: the 32-bit libs come from the base (`steamcmd:i386`). If the server then fails for a missing lib, add a pinned package in a `USER root` step, as in `apps/steamcmd`, and record it here.
- `ARG VERSION` is consumed only to match the bake target; see section 5.
- `USER apps` is the final directive, per the Dockerfile rules.
- License file: not copied (no license text was fetched). When confirmed, copy to `/usr/share/licenses/dayz/LICENSE`.

## 5. docker-bake.hcl

- `APP` = `dayz`
- `VERSION` = `20180105-5build1`, with the annotation `// renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` (copied from `apps/steamcmd`). Open decision: the game is downloaded at start, so no game version is in the image. Using the base SteamCMD version keeps the tag honest. A game-build tag would be a lie about the image contents.
- `LICENSE` = UNVERIFIED. Must be set to the confirmed license before merge.
- `SOURCE` = `https://store.steampowered.com/app/223350`
- Four standard targets and the `default` group copied from `apps/steamcmd/docker-bake.hcl`, with `platforms = ["linux/amd64"]` for `image-all` (no arm64, see section 10).

Validate with `docker buildx bake --print` from `apps/dayz`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/223350"
ports:
  - port: 2302
    protocol: udp
    required: true
  - port: 27016
    protocol: udp
    required: false
env:
  - name: STEAM_APP_IDS
    default: "1042420"
    required: false
  - name: STEAM_APP_VALIDATE
    default: "false"
    required: false
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: GAME_PARAMS
    default: ""
    required: false
  - name: GAME_PORT
    default: "2302"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Names are the ones `start.sh` reads. `STEAM_APP_IDS`, `STEAM_APP_VALIDATE`, `STEAM_USERNAME` and `STEAM_PASSWORD` follow the `apps/steamcmd` names. `GAME_PARAMS` and `GAME_PORT` follow the chart.
- The chart's `PASSWRD` maps to `STEAM_PASSWORD`. It is only needed for authenticated login. Keep it out of the settings default and out of logs.
- Dependencies: none.

## 7. start.sh

Requirements (start-script rules): idempotent, install only what is missing or on each start `app_update`, write only to `/config` and `/tmp`, `exec` the final process.

Plan:

1. Install or update with the base SteamCMD start script, which already handles login escaping and writes its run script under `/config`:
   `STEAM_APP_IDS="${STEAM_APP_IDS}" STEAM_INSTALL_DIR=/config/serverfiles /usr/local/bin/steamcmd-base.sh +quit`
   The app's own `start.sh` replaces the base `/start.sh` (and the base `/usr/local/bin/steamcmd` wrapper execs `/start.sh`), so the Dockerfile first copies the base script to `/usr/local/bin/steamcmd-base.sh`. Calling `/start.sh` here would recurse.
   The base start script only performs `app_update` when `STEAM_APP_IDS` is set and `STEAMCMD_SKIP_APP_UPDATE` is not `true`. The base ends with `exec steamcmd.sh "$@"`, so run it as a child process (not `exec`) to return after `+quit`.
2. `mkdir -p /config/serverfiles` only when missing. Seed nothing else.
3. `cd /config/serverfiles`, then start the server with `GAME_PARAMS` and `GAME_PORT`, and `exec` the server binary.

Server launch line: UNVERIFIED. The ich777 wrapper's `start-server.sh` was not fetched, so the DayZ server binary, its arguments and the `serverDZ.cfg` path are not confirmed. Plan to read them from the DayZ hosting doc at build time. Do not invent them.

Other requirements:
- Bind to all interfaces. Confirm from outside the container that the game listens on `0.0.0.0`, not `127.0.0.1`: UNVERIFIED.
- Libraries: the upstream copies `linux32` libs to `${DATA_DIR}/.steam/sdk32`. Whether the DayZ server needs this is UNVERIFIED. If it does, create it under `/config/.steam/sdk32`, not `/tmp`, because Steam expects it to persist.
- No writes to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: UNVERIFIED
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
```

- Every port needs a probe (coverage minimum). The `tcp` check only covers TCP. Both ports here are UDP, so no `tcp` probe is possible for the game. Whether forgetool supports UDP probes is UNVERIFIED. Record this and do not invent a probe.
- The test runs with no env vars, so `start.sh` will try the SteamCMD download (`STEAM_APP_IDS` default `1042420`). That needs network and a long time. `timeoutSeconds` has no sibling value to copy; set it from the first measured run.
- Code paths that need a set `STEAM_PASSWORD` or a `serverDZ.cfg` are not run by the test. Put their files in `filePaths` where they exist, and test them by hand per the protocol.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/serverfiles` (game files) | `/config/serverfiles` (`STEAM_INSTALL_DIR`). |
| `/serverdata/steamcmd` (SteamCMD) | `/config/Steam` (base default). |
| `/serverdata` as `HOME` | `HOME=/config`. Steam state goes to `/config`, which is persistent config and acceptable under the rules. |
| Base run-script temp dir `/config/steamcmd/tmp` | Written by the base `start.sh` under `/config`. This deviates from "caches go to `/tmp`". Record it as a caveat (section 10). It is a temporary script, not a cache. |
| UID 0 in chart | Runs as `apps` (the base's `USER apps`). |
| `readOnlyRootFilesystem: false` in chart | Target `--read-only --tmpfs /tmp`. |

## 10. Risks, caveats and open questions

- arm64: not supported. SteamCMD's i386 bootstrap and the upstream Debian bullseye amd64 base are x86 only. `image-all` must stay `linux/amd64`.
- License: UNVERIFIED (see section 1). Blocks merge until set.
- Version tag: the game is downloaded at start, so the image tag is the SteamCMD base version. Confirm this choice before merge.
- DayZ server config: the draft says a `serverDZ.cfg` is needed. Without it, the server may exit. That would fail the protocol's "stays running" criterion. Blocker until the config behavior is confirmed (UNVERIFIED).
- Ports: draft listed `2303/udp` and `2304/udp`. The chart shows `27016/udp` for the steam query. Use the chart values until proven otherwise.
- First start is a multi-GB SteamCMD download and needs Steam network access (draft, UNVERIFIED size).
- Base writes its SteamCMD run script under `/config/steamcmd/tmp`, not `/tmp` (section 9).
- Steam login password (`PASSWRD` in the chart) is passed through the base's run-script file (mode 600), which is good. Do not log it.
- Blockers: none that are not in this list. No privileged mode, no GPU, no musl-only build.

## 11. Build and test steps

```sh
cd apps/dayz
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dayz-probe --read-only --tmpfs /tmp \
  -v dayz-probe-config:/config dayz:20180105-5build1
docker logs -f dayz-probe
forgetool containers test --image dayz:20180105-5build1 --config ./apps/dayz/container-test.yaml
docker rm -f dayz-probe; docker volume rm dayz-probe-config
```

Expected readiness signals (UNVERIFIED until run): a SteamCMD line such as `Success! App '1042420' fully installed.` during install, then the server's own startup and listen lines on UDP 2302. Confirm the `/config/serverfiles` tree exists after a restart and that the second start does not re-download fully.

## 12. PR checklist

- Branch `feat/add-dayz`, commit and PR title `feat(dayz): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say what is untested: the image build, the `--read-only` run, the server start, the UDP probe, and arm64 (not planned).
- `docker buildx bake --print` passes, and bake `VERSION` equals the Dockerfile `ARG VERSION`. No assertion was weakened.
