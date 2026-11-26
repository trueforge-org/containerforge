# satisfactory — implementation plan
> Source: ./draft.md · Target: apps/satisfactory/ · Difficulty: easy (medium in practice, see section 10) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Wrapper version | Latest release is `v1.10.0` (published 2026-11-24). The draft pins `v1.9.11`, and the files reviewed below are at commit `89015af`. This is the image/wrapper version, not the game build. 1.10.0 adds `SERVERADMINPASSWORD`, `SERVERNAME`, `SERVERPASSWORD` and `BACKUPLIMIT` (default 10, timestamped backup rotation), falls back to the installed version when a Steam update fails, and shuts down cleanly on `docker stop` (per release notes; see `context/github-wolveix-satisfactory-server.md`). |
| Game | Satisfactory Dedicated Server, Steam app id `1690800`, downloaded at runtime with SteamCMD (anonymous login). Linux depot is x86_64 only. |
| Renovate | Nothing tracks the game build. Proposed `datasource=github-releases depName=robtme/satisfactory-server versioning=semver` so the tag follows the wrapper whose behavior this plan copies. |
| License | The wrapper repo is MIT (GitHub API), but its code is not shipped. UNVERIFIED: the license value for this image; the game server is proprietary (Coffee Stain) and SteamCMD is under Valve's license. See section 10. |
| Source URL | https://github.com/robtme/satisfactory-server (the GitHub API resolves `wolveix/satisfactory-server` to this name) |
| Download | amd64 only: `steamcmd +force_install_dir /config/gamefiles +login anonymous +app_update 1690800 -beta <branch> [-betapassword <key>] validate +quit`. No arm64. No static URL, no checksum (Steam verifies with `validate`). |
| Launch command | `cd /config/gamefiles && ./FactoryServer.sh -Port=$SERVERGAMEPORT -ReliablePort=$SERVERMESSAGINGPORT -ExternalReliablePort=$SERVERMESSAGINGPORT <ini overrides> [-DisableSeasonalEvents] [-multihome=<addr>]`. The ini overrides: `-ini:Engine:` (autosave count, max objects, tick rates, timeouts, streaming), `-ini:Game:` and `-ini:GameUserSettings:` (MaxPlayers). |
| Ports | 7777/udp (game), 7777/tcp (server API, HTTPS `/api/v1`), 8888/tcp (reliable messaging). The draft's 15000/udp and 15777/udp are inferred, pre-1.0 ports; the wrapper's README and `EXPOSE 7777/udp 7777/tcp 8888/tcp` do not use them. Do not list them. |
| Env (wrapper) | `AUTOSAVENUM` 5, `DEBUG` false, `DISABLESEASONALEVENTS` false, `LOG` false, `MAXOBJECTS` 2162688, `MAXPLAYERS` 4, `MAXTICKRATE` 30, `MULTIHOME` `::`, `PGID`/`PUID` 1000, `SERVERGAMEPORT` 7777, `SERVERMESSAGINGPORT` 8888, `SERVERSTREAMING` true, `SKIPUPDATE` false, `STEAMAPPID` 1690800, `STEAMBETA` false, `STEAMBETAID`, `STEAMBETAKEY`, `TIMEOUT` 30, `VMOVERRIDE` false, `GAMECONFIGDIR` `/config/gamefiles/FactoryGame/Saved`, `GAMESAVESDIR` `/home/steam/.config/Epic/FactoryGame/Saved/SaveGames`. |
| Volume layout | `/config/{backups,gamefiles,logs,saved}`; saves dir symlinked to `/config/saved`. About 8 GB+ download; recommended RAM 8 to 16 GB. |
| Health | Upstream `healthcheck.sh`: HTTPS POST `https://127.0.0.1:$SERVERGAMEPORT/api/v1` with `{"function":"HealthCheck","data":{"clientCustomData":""}}`, success when `.data.health == "healthy"`. |
| Upstream Dockerfile reviewed | https://github.com/wolveix/satisfactory-server/blob/89015af92e8d2c8c88a2bd07e214d85ca368c161/Dockerfile (`FROM steamcmd/steamcmd:ubuntu-22`, gosu, runs as root then drops to PUID/PGID, `/init.sh` entrypoint) plus `run.sh` and `healthcheck.sh`. Not reviewed: `init.sh`. |

## 2. Target layout

```
apps/satisfactory/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  health/healthcheck.sh     # optional, only if the repo's HEALTHCHECK convention is wanted (reason: the API call above)
```
- No `defaults/`: nothing to seed; the ini overrides are CLI args. No `root/`, no `DOWNSTREAM_CHANGES.md` (nothing uses it as a base).

## 3. Base image

Reuse the existing sibling: `FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`, matching `apps/steamcmd` (it installs `steamcmd:i386` and has `dpkg --add-architecture i386`, runs as `apps`, and copies its own `/start.sh`).
- UNVERIFIED: the published tag format. `apps/steamcmd/docker-bake.hcl` has `VERSION=20180105-5build1` and its Dockerfile uses `0~${VERSION}`; look up the real tag and digest with `docker buildx imagetools inspect ghcr.io/trueforge-org/steamcmd` or in `.github` workflows before writing the FROM line.
- This app's `COPY --chmod=0755 . /` overwrites the steamcmd image's `/start.sh` with this app's `start.sh`; that is intended, but keep using `/usr/local/share/steamcmd/steamcmd.sh` from the base as the seed.
- Fallback if the steamcmd image tag is not usable: ubuntu `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` plus the same apt block as `apps/steamcmd/Dockerfile` (pinned `steamcmd:i386=0~${VERSION}`).
- Closest sibling: `apps/steamcmd`. `apps/hytale` is also a game server downloaded at runtime (on `java25`), and its `container-test.yaml` only checks `filePaths`. No `apps/*/Dockerfile` uses the steamcmd image as FROM yet.
- The steamcmd base's `/usr/local/bin/steamcmd` runs `exec /start.sh`, which in this image is the game's `start.sh`. Never call that wrapper from `start.sh` or a test: it would recurse.

## 4. Dockerfile

1. `FROM` the steamcmd base (above). `ARG VERSION`.
2. `USER root` only if extra packages are needed. The wrapper installs `gosu xdg-user-dirs curl jq tzdata`; here: `curl` is probably in the base, `jq` is needed only if the health script is added, `gosu` is not needed (no user switching). Check the base before adding; add `jq` with `apt-get install --no-install-recommends` and clean lists if kept. UNVERIFIED: further runtime libraries of `FactoryServer` on Ubuntu 26.04 (the wrapper runs on Ubuntu 22.04); find out in the first run and install what `ldd` reports as missing.
3. `ENV HOME=/config XDG_CONFIG_HOME=/config/.config XDG_DATA_HOME=/config/.local/share` (the server writes `~/.config/Epic/...`; SteamCMD writes `~/.steam`, `~/Steam`).
4. `USER apps`, then `COPY --chmod=0755 . /`. Add `STOPSIGNAL SIGINT`, as upstream does.
5. `EXPOSE 7777/tcp 7777/udp 8888/tcp`, `VOLUME /config`.
- No game download at build time (about 8 GB, Steam license). No license files to ship at build; add `/usr/share/licenses/satisfactory/NOTICE` only if upstream licensing is clarified.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "satisfactory" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=robtme/satisfactory-server versioning=semver
  default = "1.9.11"   // draft version; v1.10.0 is out, see section 1
}
variable "LICENSE" { default = "LicenseRef-Proprietary" }   // see section 10; sibling apps/steamcmd uses AGPL-3.0-or-later
variable "SOURCE"  { default = "https://github.com/robtme/satisfactory-server" }
```
Targets as in `apps/steamcmd/docker-bake.hcl`: `image-all` has `platforms = ["linux/amd64"]` only. Standard `docker-metadata-action`, `image`, `image-local`, `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/robtme/satisfactory-server"
ports:
  - port: 7777
    protocol: udp
    required: true
  - port: 7777
    protocol: tcp
    required: true
  - port: 8888
    protocol: tcp
    required: true
env:
  - name: AUTOSAVENUM
    default: "5"
    required: false
  - name: DISABLESEASONALEVENTS
    default: "false"
    required: false
  - name: MAXOBJECTS
    default: "2162688"
    required: false
  - name: MAXPLAYERS
    default: "4"
    required: false
  - name: MAXTICKRATE
    default: "30"
    required: false
  - name: MULTIHOME
    default: "::"
    required: false
  - name: SERVERGAMEPORT
    default: "7777"
    required: false
  - name: SERVERMESSAGINGPORT
    default: "8888"
    required: false
  - name: SERVERSTREAMING
    default: "true"
    required: false
  - name: SKIPUPDATE
    default: "false"
    required: false
  - name: STEAMBETA
    default: "false"
    required: false
  - name: STEAMBETAID
    default: ""
    required: false
  - name: STEAMBETAKEY
    default: ""
    required: false
  - name: TIMEOUT
    default: "30"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
Names come from the wrapper (verified in its Dockerfile and README). `PUID`/`PGID`, `DEBUG`, `LOG`, `VMOVERRIDE` and `STEAMAPPID` are left out: the image runs as `apps` (no ids to switch), and the others are wrapper internals not needed here; add `LOG` if the log handling is ported. Keep `start.sh` defaults identical to these. `/tmp/dumps` (chart emptyDir) is ephemeral, not a volume. No dependencies.

## 7. start.sh

Idempotent, `set -euo pipefail`, no writes to `/app`:
1. `export HOME=/config XDG_CONFIG_HOME=/config/.config XDG_DATA_HOME=/config/.local/share`; `mkdir -p /config/{gamefiles,saved,backups,logs/steam}`.
2. Seed SteamCMD into `/config/Steam/steamcmd` from `/usr/local/share/steamcmd/steamcmd.sh` only when missing (same logic as `apps/steamcmd/start.sh`; do not call that script's `exec` path).
3. Link saves: `mkdir -p /config/.config/Epic/FactoryGame/Saved`; `ln -sfn /config/saved /config/.config/Epic/FactoryGame/Saved/SaveGames` (replaces the wrapper's `rm -rf $GAMESAVESDIR` plus symlink). Back up existing saves to `/config/backups` before first link, only if `/config/saved` is empty.
4. Update unless `SKIPUPDATE=true`, and always when `/config/gamefiles/FactoryServer.sh` is missing. Upstream first removes `/config/gamefiles/steamapps/appmanifest_1690800.acf` to force the update check. Run `/config/Steam/steamcmd/steamcmd.sh +force_install_dir /config/gamefiles +login anonymous +app_update 1690800 [-beta experimental|<STEAMBETAID> [-betapassword <STEAMBETAKEY>]] validate +quit`. Warn when free space is under 8 GB. Branch: `STEAMBETAID` wins, else `STEAMBETA=true` means `experimental`, else `public`. Keep the key out of logs.
5. Validate numeric env (ports, `MAXPLAYERS`, etc.) and fall back to defaults when invalid.
6. `cd /config/gamefiles && chmod +x FactoryServer.sh` (it lives under `/config`, so writable).
7. `exec ./FactoryServer.sh -Port="$SERVERGAMEPORT" -ReliablePort="$SERVERMESSAGINGPORT" -ExternalReliablePort="$SERVERMESSAGINGPORT" <ini args> -multihome="${MULTIHOME}"` so signals reach the server. The wrapper sets `STOPSIGNAL SIGINT`, and its `run.sh` traps SIGINT/SIGTERM and sends SIGINT to the game. With `exec`, keep `STOPSIGNAL SIGINT` in the Dockerfile. UNVERIFIED: that `FactoryServer.sh` passes the signal on and that the game saves; if only SIGTERM arrives and it does not save, use a trap that forwards SIGINT.
- Network: `MULTIHOME` default `::` binds all interfaces.
- Exact ini args from upstream `run.sh` at `89015af`:
```bash
ini_args=(
  "-ini:Engine:[/Script/FactoryGame.FGSaveSession]:mNumRotatingAutosaves=$AUTOSAVENUM"
  "-ini:Engine:[/Script/Engine.GarbageCollectionSettings]:gc.MaxObjectsInEditor=$MAXOBJECTS"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:LanServerMaxTickRate=$MAXTICKRATE"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:NetServerMaxTickRate=$MAXTICKRATE"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:ConnectionTimeout=$TIMEOUT"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:InitialConnectTimeout=$TIMEOUT"
  "-ini:Engine:[ConsoleVariables]:wp.Runtime.EnableServerStreaming=$SERVERSTREAMING"   # true -> 1, else 0
  "-ini:Game:[/Script/Engine.GameSession]:ConnectionTimeout=$TIMEOUT"
  "-ini:Game:[/Script/Engine.GameSession]:InitialConnectTimeout=$TIMEOUT"
  "-ini:Game:[/Script/Engine.GameSession]:MaxPlayers=$MAXPLAYERS"
  "-ini:GameUserSettings:[/Script/Engine.GameSession]:MaxPlayers=$MAXPLAYERS"
)
```
  `-DisableSeasonalEvents` and `-multihome=` are added only when set; do not pass empty arguments.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /start.sh
- /usr/local/share/steamcmd/steamcmd.sh
```
- Deviation from "a probe for every port": the test runs with no env and CI cannot wait for an 8 GB Steam download, so ports 7777 and 8888 never open inside the test. This is not the database exception of the protocol, so the deviation needs maintainer sign-off. Add this comment in the file: `# narrowed: game server (~8 GB) is downloaded by SteamCMD at first start; port probes are not feasible in the single-container suite`.
- Alternatives to discuss: a `runners` entry with `entrypoint: /config/Steam/steamcmd/steamcmd.sh` is not possible on an unseeded volume, and `/usr/local/bin/steamcmd` would start this app's `start.sh`; `/usr/local/share/steamcmd/steamcmd.sh` with `cmd: +quit` is a candidate (UNVERIFIED output and that Steam servers are reachable from CI), or a TCP probe with a very high `timeoutSeconds`.
- The real check is the manual run in section 11, with a persistent volume so the download happens once.

## 9. Rootless and read-only-rootfs adaptations

- Draft/chart: runAsUser 0, readOnlyRootFilesystem false, extra emptyDir `/tmp/dumps`. Wrapper starts as root and drops to 1000. Target: user `apps` from start, read-only rootfs, no gosu.
- Writes and remaps: game files, saves, logs, backups all under `/config` (as the wrapper does); `~/.config/Epic` and `~/.steam` follow `HOME=/config`; SteamCMD working files in `/config/Steam`; crash dumps `/tmp/dumps` already on the tmpfs; scratch to `/tmp`.
- `/config` needs about 8 GB or more and must be writable by `apps`.
- UNVERIFIED: whether SteamCMD or the server need `/home/steam/.steam/sdk64/steamclient.so` or other paths outside `HOME`; remap by symlink into `/config` if so.

## 10. Risks, caveats and open questions

- Draft caveats confirmed: first start downloads the server (slow, needs internet); amd64 only; saves must be persisted; UDP/TCP ports must be reachable.
- Blockers/limits: no arm64 (set `image-all` to amd64 only, as `apps/steamcmd` does); CI cannot test the server port; the image cannot contain the version it is tagged with because the game is fetched at runtime. The tag only follows the wrapper release; document this clearly or choose a different versioning approach.
- Licensing: the game server and SteamCMD are proprietary; shipping only scripts and SteamCMD is similar to `apps/steamcmd` (which declares AGPL-3.0-or-later; UNVERIFIED how that was decided). Confirm the `LICENSE` value with a maintainer.
- Memory: 8 to 16 GB recommended (wrapper README).
- The wrapper repo now resolves to `robtme/satisfactory-server`, and v1.10.0 (2026-11-24) is newer than the draft's v1.9.11. Review it and choose the version.
- The Dockerfile rule says the image must contain the version it is tagged with. A runtime-downloaded game cannot meet this, so a maintainer must approve the versioning.
- Possible missing libraries on Ubuntu 26.04 (the wrapper uses 22.04). Verify on first run.
- Healthcheck: upstream uses an API call with `-k` (self-signed cert). Port optional `health/healthcheck.sh`; not required for the test.
- Draft's extra ports 15000 and 15777 are not used by the 1.x wrapper; omitted.

## 11. Build and test steps

```sh
cd apps/satisfactory
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name satisfactory-probe --read-only --tmpfs /tmp -v satisfactory-probe-config:/config satisfactory:1.9.11
docker logs -f satisfactory-probe
# expected: steamcmd "Success! App '1690800' fully installed", then the server log line showing the game listening on 7777 (exact text UNVERIFIED);
# confirm: ss -ltnu inside the container shows 7777 tcp+udp and 8888 tcp; from another container:
#   curl -ksS -X POST https://<ip>:7777/api/v1 -H 'Content-Type: application/json' -d '{"function":"HealthCheck","data":{"clientCustomData":""}}'
docker rm -f satisfactory-probe; docker volume rm satisfactory-probe-config
forgetool containers test --image satisfactory:1.9.11 --config ./apps/satisfactory/container-test.yaml
```
Run a second start with the same volume and `SKIPUPDATE=true` to prove idempotency and that saves persist; test with `--read-only --tmpfs /tmp`. Allow about 8 GB disk and 8 GB RAM; build arm64 is out of scope.

## 12. PR checklist

- Branch `feat/add-satisfactory`, commit and PR title `feat(satisfactory): add new container`, target `main`.
- PR template filled; Notes contain `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested if not run: the SteamCMD download in this base, server startup on Ubuntu 26.04, SIGTERM save behavior, missing libraries, the FROM tag/digest of the steamcmd image, and the narrowed container test (needs maintainer approval).
