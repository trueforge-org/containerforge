# americasarmy-pg — implementation plan
> Source: ./draft.md · Target: apps/americasarmy-pg/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No versioned upstream release. Steam app 203300 is pulled at start. Steam build id: UNVERIFIED. |
| Renovate | Base only: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu`. Game server: UNVERIFIED. |
| License | Server: UNVERIFIED (proprietary). Wrapper repo `ich777/docker-steamcmd-server` has no SPDX (`license: null`). |
| Source URL | https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide (draft link; wiki returned 403, UNVERIFIED). Website https://www.americasarmy.com not fetched. |
| Steam app id | 203300 (`GAME_ID` in TrueCharts chart `charts/stable/americasarmy-pg/values.yaml`, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/americasarmy-pg/values.yaml) |
| Launch params (chart) | `GAME_PARAMS` = `-port=7778 -SAP=8778 -SQP=27015 -aauregion=1 -log=Server.log`, `SRV_NAME` = `Army Docker`, `VALIDATE` = `false` (same source) |
| Per-arch download | amd64: SteamCMD bootstrap `https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz` (draft link, not fetched). arm64: no (32-bit SteamCMD). |
| Checksum source | None fetched. UNVERIFIED. |
| Upstream Dockerfile reviewed | Same ich777 steamcmd wrapper as the alienswarm plan: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (`FROM ich777/debian-baseimage:bullseye_amd64`, lib32 libs, user `steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no `USER`/`VOLUME`/`EXPOSE`). |
| Upstream start.sh reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh: runs as root, `usermod`/`groupmod` from `UID`/`GID`, `su ${USER} -c "/opt/scripts/start-server.sh" &`. `start-server.sh` NOT fetched: UNVERIFIED. |
| Server binary name and launch command | UNVERIFIED (not fetched). |
| Ports (chart, authoritative for this plan) | 8778/udp (main, SAP), 27015/udp (steam query, SQP). Game port 7778 from `-port=7778` in `GAME_PARAMS`: protocol UNVERIFIED (assumed udp). |
| Draft ports | `8777/udp` and `8778/udp` (draft, inferred). The draft's `8777` does not appear in the chart: treat as wrong until the server is run. |
| Env vars (chart) | `GAME_ID`, `GAME_PARAMS`, `SRV_NAME`, `VALIDATE`, `USERNAME`, `PASSWRD`. |
| Persistence (chart) | `/serverdata/serverfiles`, `/serverdata/steamcmd`. |
| arm64 | no |

## 2. Target layout

- `apps/americasarmy-pg/Dockerfile`
- `apps/americasarmy-pg/docker-bake.hcl`
- `apps/americasarmy-pg/settings.yaml`
- `apps/americasarmy-pg/container-test.yaml`
- `apps/americasarmy-pg/start.sh`

No `defaults/`, `etc/`, `health/`, `scripts/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`, tag = `VERSION` of `apps/steamcmd/docker-bake.hcl` (`20180105-5build1`), digest UNVERIFIED: read from the registry at build time. Fits because the base already provides SteamCMD with lib32 libs, `USER apps`, and `/config`. Closest sibling: `apps/steamcmd`. Ubuntu root: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG VENDOR`; `FROM` as in section 3.
2. No install step needed: the server is downloaded at runtime. No `USER root` required.
3. `COPY --chmod=0755 start.sh /start.sh`, `USER apps`.
4. Caches to `/tmp` (`ENV TMPDIR=/tmp`). `HOME` and `XDG_DATA_HOME` as in the base (`/config`).
5. `EXPOSE 8778/udp 27015/udp` plus `7778/udp` once confirmed.
6. `VOLUME /config`, final `COPY --chmod=0755 . /` and `USER apps`. (The base `apps/steamcmd` has no `VOLUME`.) Note `start.sh` overwrites the base's `/start.sh`.
7. No apt, pip or npm packages.

## 5. docker-bake.hcl

- `APP` = `americasarmy-pg`.
- `VERSION`: ContainerForge build version (game has no tracked version). Renovate annotation on the base tag: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu`.
- `LICENSE`: UNVERIFIED for the game (see section 1).
- `SOURCE`: `https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide`.
- Targets: `docker-metadata-action`, `image`, `image-local`, `image-all` (amd64 only), `group "default"`.
- Validate: `docker buildx bake --print`.

## 6. settings.yaml

- Forgetool schema header, `schema_version: 1`, `upstream_env_url` as the SOURCE URL.
- `ports`: `8778/udp` (SAP, required: true), `27015/udp` (SQP, required: true), `7778/udp` (game, required: true, protocol to confirm).
- `env`: `GAME_PARAMS` (default as chart), `SRV_NAME` (default `Army Docker`), `VALIDATE` (default `false`), `TZ` (default `Etc/UTC`), `PASSWRD` (required: false, no default). Only names `start.sh` reads.
- `volumes`: `/config` (required: true).
- `dependencies`: none.

## 7. start.sh

- Idempotent: create `/config/serverfiles` and `/config/steamcmd` only when missing.
- Caches and temp files to `/tmp`.
- Install/update with SteamCMD: `+force_install_dir /config/serverfiles +login anonymous +app_update 203300 validate +quit` (validate only when `VALIDATE=true`). Flags to confirm against the upstream start-server script (UNVERIFIED).
- Write `server.cfg` only when missing. Set `PASSWRD` on every start.
- Launch with `GAME_PARAMS` via `exec` so signals reach the server. Binary name UNVERIFIED.
- No writes to `/app`.

## 8. container-test.yaml

- Forgetool schema header as in the base sibling.
- `filePaths`: `/start.sh`, `/usr/local/bin/steamcmd`, `/usr/local/share/steamcmd/steamcmd.sh`.
- Probes: no reliable `tcp` probe for UDP ports. Probes to add once the server is run: note the gap and do not claim coverage that is not tested.
- `timeoutSeconds`: large (first start downloads the server). Set conservatively and say so.
- The `PASSWRD` path goes to `filePaths` and is run manually per the build protocol.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with `usermod`/`chown`. Replace with `USER apps`; writes only to `/config` and `/tmp`.
- Chart sets `readOnlyRootFilesystem: false`, `runAsUser: 0`. Target: `true` and the `apps` user. Verify with `--read-only --tmpfs /tmp`.
- `privileged`: no.
- Extra persistence: `/serverdata/serverfiles` and `/serverdata/steamcmd` map to `/config/serverfiles` and `/config/steamcmd`.

## 10. Risks, caveats and open questions

- Port mismatch: the draft's `8777/udp` is not in the chart. The chart's `-port=7778` is the game port, not in the draft. Verify on a real run before writing `settings.yaml` ports.
- Server launch command, binary name, and Steam build id UNVERIFIED.
- Valve wiki returned HTTP 403.
- First start is large and needs internet access.
- amd64 only.

## 11. Build and test steps

From `apps/americasarmy-pg/`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm --read-only --tmpfs /tmp -v americasarmy-cfg:/config americasarmy-pg:<VERSION>`; readiness signal: SteamCMD `Success! App '203300' fully installed` (UNVERIFIED until a real run).
4. `forgetool containers test`.
Clean up with `docker rm -f` and `docker volume rm` between rounds.

## 12. PR checklist

- Branch `feat/add-americasarmy-pg`, commit `feat(americasarmy-pg): add new container`.
- PR template sections and checkboxes; check only applicable boxes.
- Notes: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested (game launch, UDP probes, port list not confirmed).
