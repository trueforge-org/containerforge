# garrysmod — implementation plan
> Source: ./draft.md · Target: apps/garrysmod/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: no Garry's Mod server version was fetched. The game is installed by SteamCMD at start, so the container has no release tag. The draft's image tag `ghcr.io/ich777/steamcmd:garrysmod` is UNVERIFIED. Pin the image to a `VERSION` that is the steamcmd sibling version, and record the Steam build in the PR. |
| Renovate | UNVERIFIED: no versioned source. Proposed: `datasource=docker depName=ghcr.io/trueforge-org/steamcmd` for the base (a ContainerForge image, so renovate tracks its tag). |
| License | UNVERIFIED: the game is closed-source Valve software. The wrapper repo license is not confirmed. Use the license of the ContainerForge steamcmd base (`AGPL-3.0-or-later` in `apps/steamcmd/docker-bake.hcl`) and note in the PR that the game itself is proprietary. |
| Source URL | https://store.steampowered.com/app/4020/ (draft). The Valve wiki page returned 403 and the store page names no dedicated server. Garry's Mod app ID `4020` is UNVERIFIED. |
| Download / arch | The game is pulled by SteamCMD at start (not a release asset). amd64 only: the upstream base is `ich777/debian-baseimage:bullseye_amd64` (https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile). arm64 is not available. |
| Checksum source | None published. Steam content verification (the `validate` flag) is the only check. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`; apt installs `lib32gcc-s1 lib32stdc++6 lib32z1`; creates `/serverdata`, `/serverdata/steamcmd`, `/serverdata/serverfiles`; user `steam`; `ENTRYPOINT ["/opt/scripts/start.sh"]`. No EXPOSE, VOLUME, USER or CMD. |
| Ports | `GAME_PORT` default `27015` (upstream ENV; README). Client `27005/udp` and rcon `27015/tcp` are UNVERIFIED. |
| Env vars (real, upstream) | `DATA_DIR=/serverdata`, `STEAMCMD_DIR`, `SERVER_DIR`, `GAME_ID` (`template`), `GAME_NAME`, `GAME_PARAMS`, `GAME_PORT=27015`, `VALIDATE`, `UMASK=000`, `UID=99`, `GID=100`, `USERNAME` (anonymous when blank), `PASSWRD`, `USER=steam`, `DATA_PERM=770`. Source: the upstream Dockerfile and README. |
| Data/config write paths | Upstream writes `/serverdata/steamcmd` and `/serverdata/serverfiles` (README). ContainerForge uses `/config` (`/config/serverfiles`, `/config/steamcmd`). |
| Dependencies | Base `ghcr.io/trueforge-org/steamcmd` (`apps/steamcmd`). It already has the 32-bit libraries through `steamcmd:i386`. |
| GSLT | UNVERIFIED: no fetched page confirms a Game Server Login Token requirement. Treat it as optional until verified. |

## 2. Target layout

- `apps/garrysmod/Dockerfile`
- `apps/garrysmod/docker-bake.hcl`
- `apps/garrysmod/settings.yaml`
- `apps/garrysmod/container-test.yaml`
- `apps/garrysmod/start.sh`: seeds `/config`, runs SteamCMD, `exec`s `srcds_run`.

No `defaults/` or `etc/`. No `DOWNSTREAM_CHANGES.md`: no ContainerForge image uses `steamcmd` or this app as a `FROM` base, so downstream impact is none. `root/` is not used.

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:<steamcmd VERSION>@sha256:<digest>`. The digest is not yet known: the steamcmd image must be published to GHCR before this app can build (UNVERIFIED that it is published). Closest sibling: `apps/steamcmd` (SteamCMD with `lib32` packages, `/config` owned by `apps`, `start.sh` with `+` arguments).

Fallback if the steamcmd image is not published: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` and copy the SteamCMD pieces the way `apps/steamcmd/Dockerfile` installs them. This increases the Dockerfile scope and needs review.

## 4. Dockerfile

1. `ARG VERSION`, `ARG VENDOR`, `ARG TARGETARCH`. Keep `VERSION` equal to the bake default (steamcmd VERSION).
2. `FROM ghcr.io/trueforge-org/steamcmd:${VERSION}@sha256:<digest>` as the final stage (no build stage: no compile).
3. `USER root` only if a directory must be created; otherwise stay `apps`.
4. `ENV HOME=/config DATA_DIR=/config GAME_ID=4020 GAME_PORT=27015 TMPDIR=/tmp UMASK=000` (names ours where the upstream differs; `GAME_ID` is `4020` only after the app ID is verified).
5. `COPY --chmod=0755 start.sh /start.sh`.
6. `EXPOSE 27015/tcp`, `EXPOSE 27015/udp`, `VOLUME /config`, `USER apps`, `COPY --chmod=0755 . /`, `CMD ["/start.sh"]`.
7. License: `/usr/share/licenses/garrysmod/` with a note that the game is proprietary (no file copied from the game; the notice is written by hand).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "garrysmod"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd
  default = "UNVERIFIED"   # set to the steamcmd image version that is published
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/4020/"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source"   = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output   = ["type=docker"]
  tags     = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits  = ["image"]
  platforms = ["linux/amd64"]
}
```

`image-all` is amd64 only because arm64 is not supported. Validate with `cd apps/garrysmod && docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1` as in `apps/steamcmd`.
- `upstream_env_url: "https://store.steampowered.com/app/4020/"` (SOURCE).
- `ports`: `27015` `udp` required true; `27015` `tcp` required true (rcon, UNVERIFIED); `27005` `udp` (client, UNVERIFIED, leave out until verified).
- `env`:
  - `TZ` (`Etc/UTC`, required false, as in `apps/steamcmd`).
  - `GAME_PARAMS` (default `+map gm_flatgrass +maxplayers 16`, required false: example only, UNVERIFIED).
  - `STEAM_USERNAME` (default `anonymous`, required false). Reuse the steamcmd naming.
  - `STEAM_PASSWORD` (default empty, required false, secret).
  - `GAME_PORT` (default `27015`).
  - Do not list the upstream names `UID`, `GID`, `PASSWRD`, `VALIDATE` unless the script reads them.
- `volumes`: `/config` required true.
- `dependencies`: none. `steamcmd` (`apps/steamcmd`) is the base, not a dependency.

## 7. start.sh

- Start from `apps/steamcmd/start.sh` (it already seeds `/config/Steam` and handles `+` arguments and anonymous login). Do not reimplement SteamCMD.
- `export HOME=/config`, `mkdir -p /config/serverfiles /config/steamcmd`.
- Install or update the server: `/usr/local/bin/steamcmd +force_install_dir /config/serverfiles +login "${STEAM_USERNAME}" ${STEAM_PASSWORD:+"${STEAM_PASSWORD}"} +app_update 4020 validate +quit`. App ID `4020` is UNVERIFIED (see section 1). Build the login arguments with the same escape rules as `apps/steamcmd`.
- Run `exec /config/serverfiles/srcds_run -game garrysmod -console -port "${GAME_PORT}" ${GAME_PARAMS}`. The launcher path and `-game` name are UNVERIFIED for the Garry's Mod server layout.
- Idempotent: the steamcmd update runs on every start (fine for Steam); the directory is seeded only when missing.
- Never write to `/app`. Caches and temp files go to `/tmp` (`TMPDIR=/tmp`).
- Bind to `0.0.0.0` (Source servers default to all interfaces; confirm in the first run log).

## 8. container-test.yaml

- forgetool schema header.
- `tcp`: `port: '27015'` (rcon and game share 27015/tcp). The probe must pass against the container, so it is only reliable after the server is installed (see section 10).
- `filePaths`: `/start.sh`, `/usr/local/bin/steamcmd`, `/usr/local/share/steamcmd/steamcmd.sh` (same as `apps/steamcmd`).
- `timeoutSeconds`: large enough for the first download (see risks), taken from the longest-running sibling game server. UNVERIFIED value.
- No database dependency, so the narrowing exception does not apply. The test must run the real install.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps`. The upstream wrapper runs as root and creates the `steam` user; the ContainerForge image does not.
- Read-only rootfs: the server (`/config/serverfiles`) and the SteamCMD state (`/config/steamcmd`) live in `/config`. Temp and download scratch go to `/tmp`.
- Upstream write paths `/serverdata/steamcmd` and `/serverdata/serverfiles` are remapped to `/config/steamcmd` and `/config/serverfiles`.
- Ports 27015 are above 1024, so no privilege is needed.
- Chart security expectations (runAsUser 0, readOnlyRootFilesystem false) are not reproduced. The image will run non-root and read-only, and that difference goes in the PR.

## 10. Risks, caveats and open questions

- Blocker: the steamcmd base image must be published to GHCR (with a digest) before this app can build. UNVERIFIED whether it is.
- Blocker: the Garry's Mod app ID `4020` could not be confirmed (Valve wiki and SteamDB returned 403). Do not merge until verified.
- The first start downloads the full server through Steam and needs internet access. This makes the test slow: the protocol requires a real install run, and this app is not a database app, so the narrowing exception does not apply. Decide the test strategy (e.g. a warm cache in CI, or a documented longer timeout) before implementing.
- amd64 only: arm64 is not supported (base `bullseye_amd64`, SteamCMD 32-bit bootstrap). Record this in `settings.yaml` and the PR.
- GSLT: UNVERIFIED whether a login token is required for a public listing. If it is, add `GSLT` to `env` with `required: false`.
- Ports: 27005/udp and 27015/tcp are UNVERIFIED. Only `27015` is confirmed.
- License: the game is closed-source; state this in the PR and do not claim an open license for the game.

## 11. Build and test steps

From `apps/garrysmod`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name garrysmod-probe --read-only --tmpfs /tmp -v garrysmod-probe-config:/config garrysmod:<VERSION>`, then `docker logs -f garrysmod-probe`. Expected readiness signal: a `srcds` line that the server is running and listening on 27015 (exact text UNVERIFIED until the first run). Long download: allow time. Then `docker rm -f garrysmod-probe; docker volume rm garrysmod-probe-config`.
4. `forgetool containers test --image garrysmod:<VERSION> --config ./apps/garrysmod/container-test.yaml`.
5. Clean up scratch containers and volumes between rounds.

## 12. PR checklist

- Branch `feat/add-garrysmod`, commit `feat(garrysmod): add new container`, targets `main`.
- PR description uses `.github/PULL_REQUEST_TEMPLATE.md`; only check the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it.
- State what is not tested: image not built or run locally, unverified app ID, unverified GSLT and port list, and the steamcmd base not yet published, if still true.
- State the amd64-only support and that the game is proprietary.
