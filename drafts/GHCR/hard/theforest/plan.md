# theforest — implementation plan
> Source: ./draft.md · Target: apps/theforest/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: no upstream release or tag was fetched for theforest. The TrueCharts chart pins `ghcr.io/ich777/steamcmd:theforest@sha256:afb14d903e73ea3a1a610d848b54b0c459c529c1168839cda73bf5fe6c4df56e` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/theforest/values.yaml). The game server version is whatever SteamCMD serves at build or first start. |
| Renovate | UNVERIFIED: no renovate source chosen. The steamcmd sibling uses a deb datasource; the game has no version feed here. |
| License | UNVERIFIED: no license was fetched for ich777/docker-steamcmd-server (no license label in its Dockerfile). The game's own license is closed (Steam). Check the repo before setting `LICENSE`. |
| Source URL | Draft says the Steam store page (https://store.steampowered.com/app/242760/). The dedicated server app is in the SteamCMD catalogue, not a download URL. |
| Download | No direct download. Server files come from SteamCMD (`+app_update <id>`). Draft gives app id 556450; UNVERIFIED (not confirmed on a fetched page). |
| Checksum source | UNVERIFIED: none. SteamCMD validates with the `VALIDATE` flag (upstream env, below). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64` (Debian bullseye, amd64 only); apt `lib32gcc-s1 lib32stdc++6 lib32z1`; ENV `DATA_DIR=/serverdata`, `STEAMCMD_DIR=${DATA_DIR}/steamcmd`, `SERVER_DIR=${DATA_DIR}/serverfiles`, `GAME_ID`, `GAME_NAME`, `GAME_PARAMS`, `GAME_PORT=27015`, `VALIDATE`, `UMASK=000`, `UID=99`, `GID=100`, `USERNAME`, `PASSWRD`, `USER=steam`, `DATA_PERM=770`; creates user `steam` but has no `USER` line; `ENTRYPOINT ["/opt/scripts/start.sh"]`; no VOLUME, WORKDIR, EXPOSE, CMD. |
| Wine and Xvfb | Not in the steamcmd base Dockerfile. The draft's Wine/Xvfb layer belongs to ich777's theforest image, which was not fetched: UNVERIFIED. |
| Ports (chart) | Game `27015/udp`, steam query `27016/udp`, `main` `8766/udp` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/theforest/values.yaml). Matches the draft's inferred ports. |
| Data and config paths (chart) | `/serverdata/serverfiles`, `/serverdata/steamcmd`. Upstream `DATA_DIR=/serverdata`. |
| arm64 | No. The upstream base is amd64 only (`bullseye_amd64`). Draft says arm64 not possible (Windows-only server under Wine). |
| Dependencies | None (draft). Base app `apps/steamcmd` exists (checked in `apps/steamcmd/Dockerfile`: ubuntu base, `steamcmd:i386` from apt, `/usr/local/bin/steamcmd` wrapper, `/config` owned by apps, `USER apps`). |

## 2. Target layout

Files under `apps/theforest/`:

- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh`

`defaults/` is not planned. `etc/` and `health/` only if a probe is added. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime: `FROM ghcr.io/trueforge-org/steamcmd:<VERSION>`, built on `apps/steamcmd` (closest sibling, which the draft names). Reason: it already has SteamCMD, `/config` owned by `apps`, and `USER apps`. The draft's alternative, `ghcr.io/trueforge-org/ubuntu`, is only needed if `apps/steamcmd` cannot be used. The tag is the `VERSION` default of `apps/steamcmd/docker-bake.hcl` (currently `20180105-5build1`); whether a published `ghcr.io/trueforge-org/steamcmd` image exists under that tag is UNVERIFIED. The sibling's own `FROM` is `ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`; no repo Dockerfile currently uses `steamcmd` as a `FROM` base, so there is no precedent. Caveat: `apps/steamcmd` ships `/start.sh` and its `/usr/local/bin/steamcmd` wrapper does `exec /start.sh`. A `start.sh` in this app would replace `/start.sh` via `COPY . /`, so the wrapper would then launch the game script. Call `/usr/games/steamcmd` or `/usr/local/share/steamcmd/steamcmd.sh` directly (or ship the server script under another name) and drop `/usr/local/bin/steamcmd` from `filePaths` if it no longer works as steamcmd.

## 4. Dockerfile

1. `ARG VERSION`, matching this app's own `docker-bake.hcl` default (which is what the plan sets from the steamcmd base version, see section 5).
2. `FROM` the steamcmd base as above, `USER root`.
3. Install Wine and Xvfb with apt, only what the base lacks (UNVERIFIED package names on ubuntu 26.04: `wine64`, `xvfb`, `lib32gcc-s1`). Pin versions where apt is used and check them against `VERSION`.
4. Create `/config/wine` for the Wine prefix only at runtime (see section 9), not at build time.
5. `ENV WINEPREFIX=/tmp/wine WINEDEBUG=-all DISPLAY=:99` (or `/config/wine` if persistence is needed, see section 9).
6. `USER apps`, then `COPY --chmod=0755 . /`.
7. Tail:

```dockerfile
EXPOSE 27015/udp 27016/udp 8766/udp
VOLUME /config
```

Ports are the chart's (section 1). Remove any port the server does not bind.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "theforest" }
variable "VERSION" {
  // renovate: UNVERIFIED datasource (no feed confirmed for theforest); use the steamcmd sibling's version until one is found
  default = "20180105-5build1"   // value of apps/steamcmd/docker-bake.hcl at plan time; re-check
}
variable "LICENSE" { default = "UNVERIFIED" }
variable "SOURCE" { default = "https://store.steampowered.com/app/242760/" }
```

Four standard targets and the default group as in `apps/steamcmd/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/242760/"
ports:
  - port: 27015
    protocol: udp
    required: true
  - port: 27016
    protocol: udp
    required: false
  - port: 8766
    protocol: udp
    required: false
env:
  - name: GAME_PARAMS          # UNVERIFIED: confirm the theforest start arguments
    default: ""
    required: false
  - name: VALIDATE
    default: "true"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only list env vars the start script reads. Ports must match the ones the server binds (confirm on a run). The three ports are udp and have no probe in `container-test.yaml` (see section 8): the reason is that a tcp or http probe cannot test udp, and udp probe support in forgetool is UNVERIFIED. The persistent server files live under `/config/serverfiles` (the chart's `/serverdata/serverfiles` is remapped, section 9), so no extra volume is listed.

## 7. start.sh

- Idempotent: create `/config/serverfiles` and the Wine prefix only when missing.
- Run SteamCMD with `+app_update <id> validate` when `VALIDATE` is set, into `SERVER_DIR`.
- Start `Xvfb :99` in the background, then `exec wine <server exe> <params>` as the final process (the server is a Windows binary).
- Never write to `/app`. Wine prefix and caches go to `/tmp` or `/config` (see section 9).
- Bind to `0.0.0.0` where the server has a setting (UNVERIFIED for theforest).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 1800   # first start downloads several GB via SteamCMD; UNVERIFIED size
filePaths:
- /start.sh
- /usr/local/bin/steamcmd   # only valid if it still reaches steamcmd, see section 3
```

Add a `udp` probe only if the forgetool schema supports it (UNVERIFIED). A full functional test needs a multi-GB download, so the suite should be narrowed: the test asserts the start script and SteamCMD exist, and the start path runs. Annotate any narrowed assertion per the protocol.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/serverfiles` | `/config/serverfiles`, set through a new `SERVER_DIR` variable read by this app's own `start.sh`. `apps/steamcmd/start.sh` does not read `SERVER_DIR`, and it also reads `STEAM_USERNAME`/`STEAM_USER`/`STEAM_PASSWORD`. |
| `/serverdata/steamcmd` | `/config/steamcmd` or `/tmp/steamcmd` (SteamCMD cache). Use `/tmp` if not persistent. |
| Wine prefix | `/tmp/wine` (ephemeral) or `/config/wine` (persistent; the draft notes a read-only prefix fails silently). Decide: persistence needs `/config`. |
| `/tmp` | Xvfb and Wine temp. |
| Root user | Chart runs `runAsUser 0`, `readOnlyRootFilesystem false` (chart values, confirmed). Rework: `USER apps`, read-only rootfs. |
| `UID=99 GID=100` | Upstream UID is ignored; ContainerForge runs as `apps`. |

## 10. Risks, caveats and open questions

- The game is Windows-only and runs under Wine. amd64 only. Slow first start (draft, inferred).
- The upstream steamcmd base is Debian bullseye, while the ContainerForge `apps/steamcmd` base is ubuntu, so the upstream Dockerfile cannot be reused as is.
- Wine and Xvfb package names and versions on ubuntu 26.04 are UNVERIFIED.
- SteamCMD downloads several GB on first start; the test budget (section 8) depends on it.
- The Steam store link (draft `Application binary` field) is not a download. The dedicated server app id needs confirming against SteamCMD.
- License is UNVERIFIED.
- Blockers: Wine under read-only rootfs (prefix must be writable), and no arm64.

## 11. Build and test steps

From `apps/theforest/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name theforest-probe --read-only --tmpfs /tmp -v theforest-probe-config:/config ghcr.io/trueforge-org/theforest:<VERSION>`, then `docker logs -f theforest-probe`. Expected readiness signal: UNVERIFIED (the server's "started" line).
4. `forgetool containers test --image <image>:<VERSION> --config ./apps/theforest/container-test.yaml`
5. Clean up: `docker rm -f theforest-probe; docker volume rm theforest-probe-config`.

## 12. PR checklist

- Branch: `feat/add-theforest`
- Commit: `feat(theforest): add new container`
- PR title: same as commit
- Use `.github/PULL_REQUEST_TEMPLATE.md`; only tick boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what was not tested: the full SteamCMD download, Wine behaviour under read-only rootfs, and any game session.
