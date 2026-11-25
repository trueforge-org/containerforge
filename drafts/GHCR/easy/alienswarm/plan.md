# alienswarm — implementation plan
> Source: ./draft.md · Target: apps/alienswarm/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Chart `appVersion` is the tag name `alienswarm`, not a SemVer. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm/Chart.yaml . The actual Alien Swarm build is UNVERIFIED (Valve wiki was behind a proof-of-work challenge and not readable). |
| Chart image pin | `ghcr.io/ich777/steamcmd:alienswarm@sha256:cb63148af51062157b8e7968f53bcfcefc7a1478925cf64b5656ef4fd9f524bc`. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm/values.yaml |
| Docker Hub mirror | `ich777/steamcmd:alienswarm`, last pushed 2024-12-19, amd64 only, digest `sha256:0a5282f9094adc7f17cbe900844ba49cae71a66f32923b4140d1219981e88e6c`. This differs from the chart pin; whether they are the same build is UNVERIFIED. Source: https://hub.docker.com/v2/repositories/ich777/steamcmd/tags/alienswarm |
| Renovate | UNVERIFIED for the Alien Swarm build. For SteamCMD, `apps/steamcmd` uses `datasource=deb`. For the game, the app ID is `635` (chart value; UNVERIFIED against Valve). |
| License | UNVERIFIED: Valve SteamCMD and Alien Swarm server terms are not confirmed on a fetched page. The ich777 repo license was not read. |
| Source URL | https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide (the draft's source link; not readable, see above) |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile : `FROM ich777/debian-baseimage:bullseye_amd64`, apt `lib32gcc-s1 lib32stdc++6 lib32z1`, `USER=steam`, `UID=99`, `GID=100`, `DATA_DIR=/serverdata`, `ENTRYPOINT /opt/scripts/start.sh`. This is the master branch; whether the `alienswarm` tag was built from it is UNVERIFIED. |
| Upstream start.sh | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh : runs as root, `usermod`/`groupmod` to `UID`/`GID`, `chown -R ${UID}:${GID} ${DATA_DIR}`, then `su ${USER} -c /opt/scripts/start-server.sh`. |
| Upstream start-server.sh | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh : downloads SteamCMD if missing, `app_update ${GAME_ID}` (`validate` when `VALIDATE=true`), copies `linux32` libs to `${DATA_DIR}/.steam/sdk32`, then `${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`. |
| Binary download | https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz (fetched, 2428561 bytes, gzip). Contents: `steamcmd.sh`, `linux32/steamcmd`, `linux32/steamerrorreporter`, `linux32/libstdc++.so.6`, `linux32/crashhandler.so`. x86 (linux32) only. |
| Checksum source | UNVERIFIED: no published checksum was fetched for `steamcmd_linux.tar.gz`. |
| Ports (chart) | 27015/udp (game, main service), 27015/tcp (tcprconport, used by probes). Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/alienswarm/values.yaml |
| Chart env | `GAME_ID=635`, `GAME_NAME=swarm`, `GAME_PARAMS=+map lobby -maxplayers 4 +exec server.cfg`, `GAME_PORT=27015`, `VALIDATE=false`, `USERNAME=""`, `PASSWRD` (secret). Same source. |
| Data paths (chart) | `/serverdata/serverfiles`, `/serverdata/steamcmd`. Same source. |
| Chart security | `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`. Same source. |
| Dependencies | None. `apps/steamcmd` exists in this repo and is the runtime base the draft names. |

## 2. Target layout

- `apps/alienswarm/Dockerfile`
- `apps/alienswarm/docker-bake.hcl`
- `apps/alienswarm/settings.yaml`
- `apps/alienswarm/start.sh`
- `apps/alienswarm/container-test.yaml`

No `defaults/`, `etc/`, `scripts/` or `health/` are planned: the game and SteamCMD data are created at first start. No `root/` (reserved). No `DOWNSTREAM_CHANGES.md`: this app is not a `FROM` base.

## 3. Base image

Foundation: `FROM ghcr.io/trueforge-org/steamcmd` (the runtime image named in the draft, which is built from `apps/steamcmd`). Its digest is UNVERIFIED: it must be read from the image that the `apps/steamcmd` build publishes, following the same rule as the other `FROM` lines. The steamcmd image is itself built on `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Closest siblings: `apps/steamcmd` (base) and `apps/ubuntu` (foundation).

Open point: the 32-bit libraries (`lib32gcc-s1`, `lib32stdc++6`, `lib32z1`) are required by the upstream image. `apps/steamcmd` installs `steamcmd:i386` with `dpkg --add-architecture i386`, which should provide them. This is UNVERIFIED for the Alien Swarm server; check at build time.

## 4. Dockerfile

1. The `steamcmd` base already provides SteamCMD and the 32-bit libs. Do not re-install them (dockerfile rule: base reuse).
2. Build stage not needed: no compilation.
3. Final stage:
   - `ARG VERSION`, `USER root` only if a step needs it. Nothing in the planned steps does, so keep `USER apps` throughout.
   - `ENV HOME=/config XDG_DATA_HOME=/config`, with `STEAMCMD_DIR=/config/Steam/steamcmd` and `SERVER_DIR=/config/serverfiles` (`/config` is the only persistent path).
   - No `apt-get` step is planned. If a required lib is missing at build time, add a pinned `apt` package matching the base, and note it.
   - `COPY --chmod=0755 start.sh /start.sh`
   - `EXPOSE 27015/udp 27015/tcp`, `VOLUME /config`
   - `USER apps`, then `COPY --chmod=0755 . /` as the last step.
4. License file: UNVERIFIED (no license text was fetched). If the ich777 repo's license is confirmed, copy it to `/usr/share/licenses/alienswarm/LICENSE`.

Example snippet (to confirm at build):

```dockerfile
FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>
ARG VERSION
ENV HOME=/config XDG_DATA_HOME=/config
COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /
EXPOSE 27015/udp 27015/tcp
VOLUME /config
```

## 5. docker-bake.hcl

- `APP` = `alienswarm`
- `VERSION` = the chart `appVersion` `alienswarm` for the image tag, or a pinned game build once known. Renovate annotation: `// renovate: datasource=docker depName=ich777/steamcmd versioning=loose` (the tag is not semver; UNVERIFIED whether renovate tracks it).
- `LICENSE` = UNVERIFIED (see section 1).
- `SOURCE` = `https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide`
- Four standard targets and the `default` group copied from `apps/steamcmd/docker-bake.hcl`.

Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"
ports:
  - port: 27015
    protocol: udp
    required: true
  - port: 27015
    protocol: tcp
    required: false
env:
  - name: STEAM_APP_IDS
    default: "635"
    required: false
  - name: GAME_NAME
    default: "swarm"
    required: false
  - name: GAME_PARAMS
    default: "+map lobby -maxplayers 4 +exec server.cfg"
    required: false
  - name: GAME_PORT
    default: "27015"
    required: false
  - name: VALIDATE
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Notes: the names above must match what `start.sh` actually reads. The env names here are the upstream ich777 names; if `start.sh` is written on top of `apps/steamcmd`, the app-ID variable is `STEAM_APP_IDS` (the steamcmd app's own variable). Keep one naming scheme and document it. Dependencies: none. The port list matches the chart (27015 UDP and TCP).

## 7. start.sh

Requirements (per the start-script rules):

- Idempotent: download SteamCMD into `/config` only if missing; run `app_update` on every start; create the server folder only when missing.
- Write only to `/config` and `/tmp`. Never write under `/app`.
- Seed nothing else.
- Bind to all interfaces: the server binds via `-console +port ${GAME_PORT}`. Confirm the server listens on `0.0.0.0`, not `127.0.0.1`, from outside the container (UNVERIFIED).
- End with `exec` of `srcds_run`, so signals reach the game server.

Outline:

```bash
#!/usr/bin/env bash
set -euo pipefail
export HOME=/config XDG_DATA_HOME=/config
GAME_ID="${STEAM_APP_IDS:-635}"
GAME_NAME="${GAME_NAME:-swarm}"
GAME_PARAMS="${GAME_PARAMS:-+map lobby -maxplayers 4 +exec server.cfg}"
GAME_PORT="${GAME_PORT:-27015}"
SERVER_DIR="/config/serverfiles"
mkdir -p "${SERVER_DIR}"
# steamcmd install and app_update via the steamcmd base
# ...
cd "${SERVER_DIR}"
exec ./srcds_run -game "${GAME_NAME}" ${GAME_PARAMS} -console +port "${GAME_PORT}"
```

The upstream start-server.sh does `chmod -R 770`; drop it, because it is not needed when the process runs as `apps`. Replace the `su` and `usermod` steps: the image already runs as `apps`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 900
tcp:
- port: '27015'
filePaths:
- /start.sh
```

The probes are TCP on 27015 (the TCP RCON port). A UDP probe is not in the schema the sibling apps use, so the UDP port is checked by `settings.yaml` only (UNVERIFIED that forgetool supports UDP probes). The `timeoutSeconds` value is long because the first start downloads the game; it is a guess (UNVERIFIED), to be checked against sibling `apps/steamcmd` (which has no timeout set here).

The test runs with no env vars, so `STEAM_APP_IDS` is unset and the download path does not run. Add a `filePaths` entry for any file that only exists after the download (for example `/config/serverfiles/srcds_run`) only if the test can reach it without network. Otherwise, note in `container-test.yaml` that the download path is not covered.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/steamcmd` (chart PVC) | `/config/Steam/steamcmd` (matches `apps/steamcmd`) |
| `/serverdata/serverfiles` (chart PVC) | `/config/serverfiles` |
| `/serverdata/.steam/sdk32` (copied by upstream start-server.sh) | `/config/.steam/sdk32` (under `HOME=/config`) |
| SteamCMD temp files | `/tmp` for scratch; `STEAMCMD_TMP_DIR` as in `apps/steamcmd` (currently under `/config/steamcmd/tmp`: keep it there only if it is needed for resume, otherwise move it to `/tmp`) |

Draft expectations reconciled: the chart runs as UID 0 (`runAsUser: 0`) and sets `readOnlyRootFilesystem: false`. This image runs as `apps` and is planned to work with `--read-only --tmpfs /tmp`, which is untested. Not privileged (chart default). The chart's two PVCs both map to `/config` here.

## 10. Risks, caveats and open questions

- Game download at first start needs internet and takes a long time. Expect slow first boot.
- SteamCMD binary is x86 (`linux32`) only. arm64 is not supported. Build for amd64 only.
- Game and RCON both use port 27015, which must be forwarded as UDP and TCP.
- The Alien Swarm server app ID `635` and the `GAME_NAME=swarm` value come from the chart only and were not checked against Valve (UNVERIFIED).
- The Valve wiki was not readable (proof-of-work challenge), so the server's own requirements are UNVERIFIED.
- The chart pins `ich777/steamcmd:alienswarm` by digest `cb63148a...`, but the Docker Hub mirror shows a different digest (`0a5282f9...`). Check which one the GHCR image resolves to before pinning (UNVERIFIED).
- The upstream image runs as root and uses `usermod` at start. The ContainerForge version must not do that; it must run as `apps`.
- No blocker for the ContainerForge build itself (amd64 only is a known limit).

## 11. Build and test steps

```sh
cd apps/alienswarm
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name alienswarm-probe --read-only --tmpfs /tmp \
  -v alienswarm-probe-config:/config alienswarm:alienswarm
docker logs -f alienswarm-probe
forgetool containers test --image alienswarm:alienswarm --config ./apps/alienswarm/container-test.yaml
docker rm -f alienswarm-probe; docker volume rm alienswarm-probe-config
```

Readiness signal: UNVERIFIED for this app. The upstream start-server.sh prints `---Start Server---` and then runs `srcds_run`; the Source engine prints a console line when listening, which is not confirmed. Also run the game download once with network to check that the game files land in `/config/serverfiles`.

## 12. PR checklist

- Branch `feat/add-alienswarm`, commit and PR title `feat(alienswarm): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows the status.
- Untested to state honestly: the game download and start on `--read-only`, the probe on UDP, the app ID, and arm64 (not supported).
- `docker buildx bake --print` passes and bake `VERSION` equals the Dockerfile `ARG VERSION` before any PR.
