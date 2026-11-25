# halflife2deathmatch — implementation plan
> Source: ./draft.md · Target: apps/halflife2deathmatch/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: no game build number or server version was confirmed from a fetched page. The draft's container tag is `ghcr.io/ich777/steamcmd:hl2dm`. Game content is pulled from Steam at start, so there is no pinned game version in the image. |
| Renovate | UNVERIFIED: no renovate datasource fits a Steam game. The sibling `apps/steamcmd` pins a deb version (`datasource=deb`). For this app, pin the base `steamcmd` image version and use a plain `VERSION` that matches it; confirm the choice before writing. |
| License (image) | UNVERIFIED: the ich777 repo license returned 404 (see facts file batch 052 and batch 047). Half-Life 2: Deathmatch and its dedicated server are Valve proprietary software (store page https://store.steampowered.com/app/320/ is a client listing; Valve licence not fetched). Do not set `LICENSE` to an open-source license without confirmation. |
| Source URL | https://store.steampowered.com/app/320/ (client listing, not a dedicated server). UNVERIFIED: the dedicated server Steam app ID. The store page does not state it, and the ich777 README covers CS:Source only (GAME_ID example 232330 belongs to CS:Source, not HL2DM). Do not reuse 232330. |
| Download | Pulled by SteamCMD at start (`app_update <dedicated-server-app-id>`). No release asset. The sibling `apps/steamcmd/start.sh` already runs `STEAM_APP_IDS` through `app_update`. |
| Checksum source | None from upstream. Steam content integrity is checked by `validate` (sibling `STEAM_APP_VALIDATE=true`). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (fetched): `FROM ich777/debian-baseimage:bullseye_amd64`, `ENV DATA_DIR=/serverdata`, `STEAMCMD_DIR=/serverdata/steamcmd`, `SERVER_DIR=/serverdata/serverfiles`, `GAME_ID`, `GAME_NAME`, `GAME_PARAMS`, `GAME_PORT=27015`, `VALIDATE`, `USERNAME`, `PASSWRD`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `ENTRYPOINT ["/opt/scripts/start.sh"]`. No `USER`, `VOLUME` or `EXPOSE` (runs as root). |
| Ports | `GAME_PORT` default 27015 (confirmed upstream Dockerfile). The draft's 27015/tcp (rcon), 27015/udp (game and query), 27005/udp (client) are UNVERIFIED for this Steam app. Only the `GAME_PORT` default is confirmed. |
| Env vars (real) | Upstream: `DATA_DIR`, `STEAMCMD_DIR`, `SERVER_DIR`, `GAME_ID`, `GAME_NAME`, `GAME_PARAMS`, `GAME_PORT`, `VALIDATE`, `USERNAME`, `PASSWRD`, `UMASK`, `UID`, `GID`, `DATA_PERM`. ContainerForge sibling uses `STEAM_APP_IDS`, `STEAM_APP_VALIDATE`, `STEAM_INSTALL_DIR`, `STEAM_USERNAME`, `STEAM_PASSWORD`, `STEAMCMD_PRE_UPDATE`, `STEAMCMD_SKIP_APP_UPDATE` (from `apps/steamcmd/start.sh`). Use the sibling names, not the upstream ones. |
| Data paths | Upstream: `/serverdata/steamcmd` and `/serverdata/serverfiles`. ContainerForge remap: `/config/steamapps` (sibling `STEAM_INSTALL_DIR` default), caches to `/tmp`. |
| Architecture | `amd64` only. The upstream base is `bullseye_amd64` and SteamCMD's 32-bit x86 bootstrap does not run on arm64. The sibling `apps/steamcmd` already builds `linux/amd64` only (`image-all` platforms). |
| Dependencies | None (no database). Needs internet on first start to download from Steam. |

## 2. Target layout

- `apps/halflife2deathmatch/Dockerfile`
- `apps/halflife2deathmatch/docker-bake.hcl`
- `apps/halflife2deathmatch/settings.yaml`
- `apps/halflife2deathmatch/container-test.yaml`
- `apps/halflife2deathmatch/start.sh`

No `defaults/`, `etc/` or `health/` needed; the game server is fetched at start. Never use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

Alternative: this could be a `FROM ghcr.io/trueforge-org/steamcmd:<version>` app with a thin `start.sh` that sets `STEAM_APP_IDS` and the game params. That is the preferred shape because `apps/steamcmd` already does the SteamCMD work. Confirm the steamcmd image tag before writing.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<version>` with the digest copied from the sibling `apps/steamcmd` build output, or the ubuntu base (`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`) if the steamcmd image is not published at the needed tag. Closest sibling: `apps/steamcmd` (SteamCMD wrapper, `/config` home, `STEAM_APP_IDS` dispatch). The draft's ubuntu-plus-steamcmd reason is correct; do not copy the upstream debian bullseye base.

## 4. Dockerfile

Keep it thin, because the game server is downloaded at start:

1. `FROM ghcr.io/trueforge-org/steamcmd:<VERSION>@sha256:<digest>` (the steamcmd sibling tag, not UNVERIFIED for this run; confirm the published tag). `ARG VERSION` only if the bake passes it.
2. `USER root` only if apt is needed. Sibling already installs SteamCMD (32-bit bootstrap with `i386` architecture); the app does not need extra apt packages, so do not add any.
3. `COPY --chmod=0755 start.sh /start.sh`
4. `USER apps`, `COPY --chmod=0755 . /`
5. `VOLUME /config` only if the base does not already declare it (sibling `steamcmd` does `mkdir -p /config` and chowns it).
6. No `EXPOSE` needed for a dedicated server unless the sibling pattern adds it; ports are declared in `settings.yaml`.
7. License: if a Valve license file is shipped, copy it to `/usr/share/licenses/halflife2deathmatch/`; none is confirmed, so note the gap in section 10.

## 5. docker-bake.hcl

- `target "docker-metadata-action" {}`
- `variable "APP" { default = "halflife2deathmatch" }`
- `variable "VERSION"` with a renovate comment only if a datasource is confirmed; otherwise pin the steamcmd base tag and note UNVERIFIED in the comment. Do not invent a datasource.
- `variable "LICENSE"` set to a value confirmed from the Valve license (UNVERIFIED; do not default to AGPL).
- `variable "SOURCE" { default = "https://store.steampowered.com/app/320/" }`
- `group "default" { targets = ["image-local"] }`
- `target "image"` with args `VERSION` and OCI labels `org.opencontainers.image.source` and `org.opencontainers.image.licenses`.
- `target "image-local"` inherits `image`, `output = ["type=docker"]`, `tags = ["${APP}:${VERSION}"]`.
- `target "image-all"` inherits `image`, `platforms = ["linux/amd64"]` only (arm64 is unsupported, see section 10).

Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/320/"
ports:
  - port: 27015
    protocol: tcp
    required: true
  - port: 27015
    protocol: udp
    required: true
  - port: 27005
    protocol: udp
    required: false
env:
  - name: STEAM_APP_IDS
    default: "<dedicated-server-app-id>"   # UNVERIFIED: Steam app ID for the HL2DM dedicated server
    required: true
  - name: STEAM_APP_VALIDATE
    default: "false"
    required: false
  - name: STEAM_INSTALL_DIR
    default: "/config/steamapps"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  []
```

- Ports: 27015 tcp+udp is the upstream `GAME_PORT` default plus the draft's rcon/query expectation (rcon and query are UNVERIFIED, so mark `required: true` only for the confirmed game port). 27005/udp is UNVERIFIED; drop it if the server does not bind it.
- `STEAM_APP_IDS` default is a placeholder: it MUST be replaced with the verified HL2DM dedicated server app ID before this file is valid. Blocker, see section 10.
- `env`: names are the sibling `apps/steamcmd` names, not the upstream ones (`GAME_ID` etc.). Do not add `GAME_PARAMS` until the server launch line is verified.

## 7. start.sh

Rules: idempotent, empty `/config` safe, no writes to `/app`, caches in `/tmp`, exec the final process.

1. Prefer delegating to the sibling `apps/steamcmd/start.sh` logic: `STEAM_APP_IDS` and `STEAM_INSTALL_DIR` drive `app_update` into `/config/steamapps`. Keep `HOME=/config` as the sibling does.
2. Run `app_update <dedicated-server-app-id>` (validate only if `STEAM_APP_VALIDATE=true`). The sibling already validates the numeric app ID.
3. Launch the server binary from `${STEAM_INSTALL_DIR}` with the flags the game uses (exact binary name and flags UNVERIFIED; the sibling wrapper does not know them). Add `+map`, `+maxplayers` only when verified.
4. The first start downloads from Steam and may be slow; log a clear message and do not exit on the first download.
5. Final line: `exec <server-binary> <flags> "$@"`.
6. Do not write to `/serverdata` (upstream path); everything goes to `/config`, caches to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

- Copy the steamcmd sibling's `filePaths` pattern. Add a `tcp` probe on 27015 only after the server is verified to bind it.
- The test runs with no env vars, so `STEAM_APP_IDS` is unset; `start.sh` must not fail the test by requiring it. Put the app-ID-required code path in `filePaths` only and run it manually per section 11, per the protocol's "What the test can't see" rule.
- `timeoutSeconds`: match the steamcmd sibling (the first start downloads from Steam).
- No DB dependency, so the narrowed-test exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (`runAsUser 0` in the chart). ContainerForge final stage is `USER apps`. The sibling `apps/steamcmd` already runs as `apps` with `/config` home, so this is the same model.
- Upstream writes to `/serverdata/steamcmd` and `/serverdata/serverfiles`. Remap to `/config/steamcmd` (sibling pattern) and `/config/steamapps` (`STEAM_INSTALL_DIR`).
- Caches: SteamCMD temp scripts go to `/config/steamcmd/tmp` in the sibling. Per the dockerfile rules, caches must be in `/tmp`, not `/config`. Reconcile: move SteamCMD temp to `/tmp` before shipping, or document the exception (SteamCMD requires the install tree under `/config`; its temp dir can be `/tmp`).
- Read-only rootfs: `--read-only --tmpfs /tmp` must still start the wrapper; the game install under `/config` is the only write target.
- Chart expectations (`readOnlyRootFilesystem: false`, `runAsUser 0`, `/serverdata` PVC) are chart values to remap to `/config`, not app changes.

## 10. Risks, caveats and open questions

- BLOCKER: the dedicated server Steam app ID is not verified. Without it, `STEAM_APP_IDS` cannot be set and the server cannot be downloaded. Find it on https://developer.valvesoftware.com/wiki/Dedicated_Servers_List or the Steam dedicated-server listing and confirm before writing `settings.yaml`. Do not reuse 232330 (CS:Source).
- BLOCKER for arm64: unsupported (SteamCMD 32-bit bootstrap). `image-all` is amd64 only. The draft's `arm64: no` is correct.
- License: the image license is unknown (ich777 repo 404, Valve proprietary). `LICENSE` must be confirmed before the bake file is committed.
- Upstream ports 27005 and rcon/query are inferred. Confirm the server's actual bind ports.
- Server launch binary and flags are UNVERIFIED (no fetched page covered the HL2DM server command line).
- The first start downloads from Steam and needs internet access. Functional test in CI is limited to the wrapper, not a running game.
- Steam login: anonymous is assumed; the server app is public (UNVERIFIED for HL2DM).

## 11. Build and test steps

From `apps/halflife2deathmatch/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name halflife2deathmatch-probe --read-only --tmpfs /tmp -e STEAM_APP_IDS=<verified-id> -v halflife2deathmatch-probe-config:/config halflife2deathmatch:<version>`, then `docker logs -f halflife2deathmatch-probe`. Expected readiness signal: SteamCMD reports the app update finished and the server process starts without a fatal error. A first run takes minutes (download). Clean up with `docker rm -f halflife2deathmatch-probe; docker volume rm halflife2deathmatch-probe-config`.
4. `forgetool containers test --image halflife2deathmatch:<version> --config ./apps/halflife2deathmatch/container-test.yaml`
5. Do not run arm64 (unsupported).

## 12. PR checklist

- Branch: `feat/add-halflife2deathmatch`
- Commit: `feat(halflife2deathmatch): add new container`
- Title: `feat(halflife2deathmatch): add new container`
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Use `.github/PULL_REQUEST_TEMPLATE.md`, check only the boxes that apply.
- Say what was not tested: a real HL2DM server download and launch (blocked on the verified app ID), the game's port bindings, and arm64 (unsupported).
