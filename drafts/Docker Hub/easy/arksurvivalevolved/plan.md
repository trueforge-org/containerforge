# arksurvivalevolved — implementation plan
> Source: ./draft.md · Target: apps/arksurvivalevolved/ · Difficulty: easy (steamcmd game server, but the most complex of this batch) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Wrapper under port | ark-server-tools (`arkmanager`), latest release `v1.6.69` ("Add options to override map on arkmanager run commandline", GitHub shows 5 commits on master since; publish day "06 Jun", year not shown by the page). The draft links no version; SickHub's image also pins `AMG_VERSION=v1.6.69`. |
| Game server | ARK: Survival Evolved dedicated server, Steam app id `376030` (arkmanager `appid`), downloaded at runtime through SteamCMD, never baked into the image (proprietary, very large). |
| Renovate | `datasource=github-releases depName=arkmanager/ark-server-tools extractVersion=^v(?<version>.+)$` |
| License | MIT (arkmanager repo LICENSE, 2015 Fez Vrasta; confirmed by web search, repo LICENSE page itself returned 503). The ARK server files are Valve/Studio Wildcard EULA content and are not shipped. |
| Source URLs | repo https://github.com/arkmanager/ark-server-tools, wiki https://github.com/arkmanager/ark-server-tools/wiki, tarball `https://github.com/arkmanager/ark-server-tools/archive/refs/tags/v1.6.69.tar.gz` (URL pattern standard for GitHub, not fetched) |
| Per-arch | amd64 only. ARK server and SteamCMD binaries are x86 (draft: arm64 `no`). `image-all` must list only `linux/amd64` (as `apps/steamcmd`). |
| Checksum | GitHub publishes none for the source tarball. Compute `sha256sum` of the tag tarball once during implementation and pin it as an `ARG` in the Dockerfile (value UNVERIFIED until then). Upstream's own installer pipes `netinstall.sh` into bash; we do not. |
| Upstream Dockerfile reviewed | https://github.com/SickHub/arkserver/blob/394fd7aa4f6321e5665f9dbc7d1ff4600aa6386f/Dockerfile (FROM `drpsychick/steamcmd`, apt `curl cron bzip2 perl-modules lsof libc6-i386 rsync sudo`, user `steam`, passwordless sudo, volumes `/ark` and `/arkserver`, CMD `./run.sh`, HEALTH_SERVER on 8080) and its `scripts/run.sh` (summarized below) |
| Upstream env (SickHub) | `am_ark_SessionName` (default "Ark Server"), `am_serverMap` (TheIsland), `am_ark_ServerAdminPassword`, `am_ark_MaxPlayers` (70), `am_ark_QueryPort` (27015), `am_ark_Port` (7778), `am_ark_RCONPort` (32330), `am_ark_AltSaveDirectoryName`, `am_arkwarnminutes` (15), `am_arkAutoUpdateOnStart`, `am_ark_GameModIds`, `ARKCLUSTER`, `BACKUP_ONSTART`, `VALIDATE_SAVE_EXISTS`, `LOG_RCONCHAT`, `HEALTH_SERVER(_PORT)`. Rule in `run.sh`: every other `am_*` var is copied into `arkmanager.cfg`. |
| arkmanager config vars (tools/arkmanager.cfg v1.6.69) | `steamcmdroot` (/home/steam/steamcmd), `steamcmdexec` (steamcmd.sh), `appid` (376030), `arkbackupdir` (/home/steam/ARK-Backups), `logdir` (/var/log/arktools), `steamcmd_appinfocache`, `steamcmd_workshoplog`, `arkStagingDir`, `serverMap` (TheIsland). `arkserverroot` and the `ark_*Port` names were not in the fetched file (`ark_` prefix variables are instance-level; SickHub writes `arkserverroot` itself). |
| `run.sh` flow (verified) | create `/ark/{config,log,backup,staging}`; write `arkmanager.cfg` from `am_*`; optional cron (needs sudo/crontab); if `appmanifest_376030.acf` is missing run `arkmanager install`, else (auto update) `arkmanager update --force --no-autostart`; start with `(arkmanager start --no-background --verbose) &` then `wait`; `stop` trap runs `arkmanager stop` on INT/QUIT/TERM. |
| Ports (draft, ARK defaults) | 7777/udp game, 7778/udp raw socket, 27015/udp query, 27020/tcp RCON. SickHub defaults differ (Port 7778, RCON 32330), so the RCON default 27020 is UNVERIFIED against ARK docs. |

## 2. Target layout

```
apps/arksurvivalevolved/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/arkmanager.cfg        # base config template (steamcmd paths, dirs under /config); copied only when missing
```

No `root/`, no `health/` (the base `/healthcheck.sh` reads `container-test.yaml`; there is no TCP port to probe, see section 8). No `DOWNSTREAM_CHANGES.md`. Nearest siblings: `apps/steamcmd` (the base), `apps/hytale` (java game server whose files are downloaded at runtime), `apps/luanti` (UDP-only port tests).

## 3. Base image

```
FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>
```

- The image `ghcr.io/trueforge-org/steamcmd` is built from `apps/steamcmd` (ubuntu 26.04 plus the `steamcmd:i386` deb, installs SteamCMD at `/usr/local/share/steamcmd/steamcmd.sh`). No app in this repo uses it as `FROM` yet, so **tag and digest are UNVERIFIED**. At implementation time run `docker buildx imagetools inspect ghcr.io/trueforge-org/steamcmd:<bake VERSION>` (bake `VERSION` is `20180105-5build1`) and copy the digest. If the image is not published, fall back to the ubuntu base with the same steamcmd install block as `apps/steamcmd/Dockerfile`.
- Changing `apps/steamcmd` later affects this app: add `apps/steamcmd/DOWNSTREAM_CHANGES.md` if its entrypoint (`/start.sh`) or paths change. This app replaces `/start.sh`, so it must keep the SteamCMD seeding logic itself (section 7).

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG ARKMANAGER_SHA256`; `USER root`.
2. apt packages not in the ubuntu or steamcmd base (the base already has curl, tar, ca-certificates, unzip, git, jq, yq; verify with `dpkg -l`): `bzip2 lsof perl-modules rsync libc6-i386` (taken from the SickHub image; arkmanager shells out to these). No `cron` and no `sudo` (see below). One `apt-get update && install --no-install-recommends ... && rm -rf /var/lib/apt/lists/*`. Not pinned: they are not the app's version; the app version is the arkmanager tag.
3. Install arkmanager from the tagged tarball with checksum:
   ```dockerfile
   RUN set -eux; cd /tmp; \
       curl -fsSL -o ast.tar.gz "https://github.com/arkmanager/ark-server-tools/archive/refs/tags/v${VERSION}.tar.gz"; \
       echo "${ARKMANAGER_SHA256}  ast.tar.gz" | sha256sum -c -; \
       mkdir ast && tar -xzf ast.tar.gz -C ast --strip-components=1; \
       cd ast/tools && ./install.sh <apps-user> --prefix=... ; \
       mkdir -p /usr/share/licenses/arksurvivalevolved && cp /tmp/ast/LICENSE /usr/share/licenses/arksurvivalevolved/LICENSE; \
       rm -rf /tmp/*
   ```
   The `install.sh` arguments are UNVERIFIED (not fetched). Read `tools/install.sh` of tag v1.6.69 first and choose options so that: binaries land in `/usr/local/bin` (`arkmanager`), libexec/data under `/usr/local`, the default config goes to `/etc/arkmanager/arkmanager.cfg` and **no** sudoers/cron/systemd service is installed (upstream `install.sh` normally requires a target user and may write to `/etc/sudoers.d` or init scripts; skip or delete those). If `install.sh` cannot be driven non-interactively, copy the files by hand following its `install` commands.
4. `chown -R apps:apps /config`, `ENV HOME=/config`, `ENV XDG_DATA_HOME=/config` (same as `apps/steamcmd/start.sh`).
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 7777/udp 7778/udp 27015/udp 27020/tcp`, `VOLUME /config`, `WORKDIR /config`. No ENTRYPOINT override.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "arksurvivalevolved" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=arkmanager/ark-server-tools extractVersion=^v(?<version>.+)$
  default = "1.6.69"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/arkmanager/ark-server-tools" }
```

`ARKMANAGER_SHA256` as a second `variable` with its own renovate-less default is awkward (renovate would bump VERSION and leave a stale hash). Alternative: no hash variable; verify instead by cloning the tag over git (`git clone --depth 1 --branch v${VERSION}`), since git is in the base image; pick this if the hash approach would break renovate. Targets: standard four plus default group, with `image-all` platforms `["linux/amd64"]` only (as `apps/steamcmd`). Run `docker buildx bake --print`.

## 6. settings.yaml

Header and `schema_version: 1`, `upstream_env_url: "https://github.com/arkmanager/ark-server-tools"`.

- ports: `7777` udp, `7778` udp, `27015` udp, `27020` tcp (all `required: false`; list only what start.sh really opens, so keep 27020 only if RCON is enabled in the generated config).
- env (names are the SickHub/arkmanager ones that start.sh copies into the config; defaults equal what start.sh writes):
  - `TZ` `Etc/UTC`
  - `am_serverMap` `TheIsland`
  - `am_ark_SessionName` `ARK Server`
  - `am_ark_ServerAdminPassword` `""` (empty means start.sh generates one into `/config`, see section 7; `required: false`)
  - `am_ark_MaxPlayers` `70`
  - `am_ark_Port` `7777`, `am_ark_QueryPort` `27015`, `am_ark_RCONPort` `27020`
  - `am_ark_AltSaveDirectoryName` `SavedArks`
  - `am_ark_GameModIds` `""`
  - `am_arkAutoUpdateOnStart` `false`
  - `ARKCLUSTER` `false`
  - Any other `am_*` is passed through as a generic mechanism (document, do not list).
- volumes: `/config` `required: true`. The draft/chart lists many extra volumes (`/ark`, `/arkserver`, `/ark/backup`, `/ark/staging`, `/arkserver/ShooterGame/Saved`, `.../Saved/clusters`); all collapse to subdirectories of `/config`, see section 9. Optionally list `/config/server/ShooterGame/Saved/clusters` for shared cluster saves.
- dependencies: none (steamcmd is the base image, not a runtime dependency; ✅ `apps/steamcmd` exists).

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`; no `sudo`, no cron.

1. `export HOME=/config XDG_DATA_HOME=/config`; dirs: `/config/server` (arkserverroot), `/config/backup`, `/config/staging`, `/config/log`, `/config/arkmanager`, plus `/tmp/arktools` for logs and lock files.
2. Seed SteamCMD like `apps/steamcmd/start.sh`: if `/config/Steam/steamcmd/steamcmd.sh` is missing copy `/usr/local/share/steamcmd/steamcmd.sh` (and `linux32/steamcmd` when present) there. Do not copy the base's start.sh logic wholesale; only the seeding block.
3. Config generation on every start (idempotent, values from env applied each time): start from `/defaults/arkmanager.cfg`, then append `arkserverroot="/config/server"`, `steamcmdroot="/config/Steam/steamcmd"`, `steamcmdexec="steamcmd.sh"`, `arkbackupdir="/config/backup"`, `arkStagingDir="/config/staging"`, `logdir="/tmp/arktools"`, `steamcmd_appinfocache`/`steamcmd_workshoplog` under `/config/Steam`, then one line per `am_*` env var written with proper quoting (`printf 'x="%s"'` after escaping `"`, `\`, `$`, backtick) so special characters in passwords or session names cannot break the shell-sourced file. Write to `/config/arkmanager/arkmanager.cfg` with `umask 077` (the admin password lives in it, never put it on a command line).
4. How arkmanager finds that file is UNVERIFIED (user config `~/.arkmanager.cfg` = `/config/.arkmanager.cfg`, or `/etc/arkmanager/instances/*.cfg`, which is read-only). Read `tools/arkmanager` for the lookup order in v1.6.69 and write to the user-level path; do not write `/etc`.
5. Admin password: if `am_ark_ServerAdminPassword` is empty, generate once (`tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24`) into `/config/arkmanager/admin_password` (mode 600) and reuse it on later starts; log only the file path. Never ship a default like SickHub's `k3yb04rdc4t`.
6. Install or update: if `/config/server/steamapps/appmanifest_376030.acf` is missing run `arkmanager install`; elif `am_arkAutoUpdateOnStart=true` run `arkmanager update --force --no-autostart` (flow copied from upstream `run.sh`). Failure of install must exit non-zero.
7. Stale lock/pid files in `Saved` are removed at start (as upstream).
8. Final command: `arkmanager start --no-background --verbose`. Upstream backgrounds it and traps TERM to run `arkmanager stop` (graceful world save). Do the same: `arkmanager start --no-background --verbose & pid=$!`, `trap 'arkmanager stop; wait "$pid"' TERM INT QUIT`, `wait "$pid"`. This is the one place where plain `exec` is replaced by trap and wait; justify in a comment. If testing shows `arkmanager start --no-background` handles TERM by itself, switch to `exec`.
9. Bind: ARK listens on all interfaces by default; nothing to change (verify with `ss -lun`).
10. Dropped: cron schedules (update, backup, daily restart) and the health HTTP server. Document replacements (Kubernetes CronJob or `arkmanager` run via `kubectl exec`).

## 8. container-test.yaml

The test runs with no env and starts the server, which first downloads the multi-GB game (long, needs network and disk) and listens on **UDP only** (tcp/http probes cannot see it; RCON TCP 27020 only opens after the server is up). Follow `apps/luanti` and `apps/bookstack`: do not run the main process, assert the installed files and tools.

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
mainRunner:
  enabled: false

filePaths:
- /usr/local/bin/arkmanager
- /usr/local/share/steamcmd/steamcmd.sh
- /defaults/arkmanager.cfg
- /start.sh
- /usr/share/licenses/arksurvivalevolved/LICENSE

runners:
- entrypoint: arkmanager --version
```

(`arkmanager --version` is UNVERIFIED; use `arkmanager useconfig`/`--help` if absent. Confirm `runners` syntax with the forgetool schema and `apps/bookstack/container-test.yaml`.) Deviation from "probe every port" is justified by UDP-only ports and the runtime download; state it in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream/chart path | Remap |
|---|---|
| `/arkserver` (game binaries, 15+ GB) | `/config/server` |
| `/ark` (config, log, backup, staging) | `/config/arkmanager`, `/config/log`, `/config/backup`, `/config/staging` |
| `/home/steam/.steam/steamapps` | `/config/Steam` (HOME=/config) |
| `/arkserver/ShooterGame/Saved`, `.../Saved/clusters` | stay inside `/config/server/ShooterGame/Saved` (mount a second volume there for clusters if needed) |
| `/var/spool/cron/crontabs` | dropped (no cron) |
| `/var/log/arktools`, lock files | `/tmp/arktools` |
| `/etc/arkmanager/*` | read-only defaults; user config in `/config` |

- Chart expectation: UID 1001 override, caps AUDIT_WRITE, CHOWN, FOWNER, DAC_OVERRIDE, SETGID, SETUID, `allowPrivilegeEscalation: true`, `readOnlyRootFilesystem: false`, `fsGroup: 1001`. Reconciled: UID 568, no capabilities, read-only rootfs; the root-requiring parts (sudo chown, cron) are removed because `/config` is writable by 568 directly. Migration: data owned by 1001 needs `fsGroup: 568` or a chown.
- Not privileged.

## 10. Risks, caveats and open questions

- amd64 only (draft caveat verified); `image-all` has one platform. Consider the repo CI behaviour for amd64-only apps (steamcmd precedent).
- First start downloads the ARK server (very large, slow) and then needs 8 GB+ RAM per map (draft). Container tests and `docker run` probes must not wait for it; use a bounded probe (see section 11).
- Unverified items to resolve by reading upstream during implementation: `install.sh` options, config lookup order, `--version` flag, RCON default port, arkmanager signal handling, whether `arkmanager` needs `lsof` and `perl-modules` at runtime, whether SteamCMD works with a copied-in tree under `/config/Steam` (works for `apps/steamcmd`).
- Steam EULA/license for SteamCMD and ARK files; nothing proprietary is baked into the image.
- No renovate-friendly checksum for the arkmanager tarball (see section 5).
- Base-image digest of `ghcr.io/trueforge-org/steamcmd` is unknown (section 3).
- Cluster and mod features rely on extra volumes the user must mount.

## 11. Build and test steps

```sh
cd apps/arksurvivalevolved
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name arksurvivalevolved-probe --read-only --tmpfs /tmp \
  -v arksurvivalevolved-probe-config:/config arksurvivalevolved:1.6.69
docker logs -f arksurvivalevolved-probe
```

- Expected readiness signal for the empty-volume run: config generated, SteamCMD seeded, then `arkmanager install` starts and SteamCMD prints "Update state ... downloading" lines, process still running, no traceback. Stop the probe after the download starts; a full install is a manual, optional step (ample disk, real network). If a game install is available, the full-readiness signal is arkmanager reporting the server running and the UDP query port answering (`arkmanager status`).
- Check with `ss -lun` and `docker top` only after the server is up; check `/config` for the generated `arkmanager/arkmanager.cfg` mode 600.
- Cleanup: `docker rm -f arksurvivalevolved-probe; docker volume rm arksurvivalevolved-probe-config`.
- `forgetool containers test --image arksurvivalevolved:1.6.69 --config ./apps/arksurvivalevolved/container-test.yaml`.
- Max 10 rounds.

## 12. PR checklist

- Branch `feat/add-arksurvivalevolved`, commit and PR title `feat(arksurvivalevolved): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick "New container/image" and only boxes that apply; `🤖 This PR is AI generated.` in Notes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; check `license/cla`).
- Notes: amd64 only, runtime download of the game, volumes collapsed into `/config`, UID 568 migration, cron and sudo removed, UDP-only test deviation.
- Untested until run: the full game install and server start, install.sh options, config lookup path, graceful stop, memory use. Say so honestly and do not tick "Verified image in staging" unless done.
- Checklist: app-scoped, instructions read, `VERSION` aligned (1.6.69), rootless and read-only OK, empty `/config` OK, `bake --print` run. Add `apps/steamcmd/DOWNSTREAM_CHANGES.md` only if steamcmd itself changes.
