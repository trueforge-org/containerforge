# unturned — implementation plan
> Source: ./draft.md · Target: apps/unturned/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | The game server is not a versioned download: SteamCMD pulls the current Unturned dedicated server at start. Chart image `ghcr.io/ich777/steamcmd:unturned`. The wrapper has no release tags; pin the upstream Dockerfile by commit when the branch is read. |
| Renovate | UNVERIFIED: no pinnable version source confirmed. The sibling pins the SteamCMD package with `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu`; the Unturned app itself has no version feed here. |
| License | Unturned: proprietary (Smartly Dressed Games; EULA UNVERIFIED). Upstream wrapper repo `ich777/docker-steamcmd-server`: license field null on GitHub; not archived; last pushed 2026-07-18. Source: https://api.github.com/repos/ich777/docker-steamcmd-server. Wrapper license UNVERIFIED. |
| Source URL | https://unturned.net/ (draft). Wrapper: https://github.com/ich777/docker-steamcmd-server (branch `unturned`). |
| Download | No release asset. SteamCMD downloads the dedicated server at runtime. Store page https://store.steampowered.com/app/1110390/ is in the draft (dedicated server app id UNVERIFIED). |
| Checksum source | None (SteamCMD verifies depots itself; not checked here). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/unturned/Dockerfile (read through WebFetch). `FROM ich777/debian-baseimage`; apt: `lib32gcc-s1`, `unzip`; `ENV DATA_DIR=/serverdata`, `STEAMCMD_DIR=${DATA_DIR}/steamcmd`, `SERVER_DIR=${DATA_DIR}/serverfiles`, `GAME_PORT=27015`, `VALIDATE=""`, `ROCKET_MOD=true`, `ROCKET_URL=...`, `UMASK=000`, `UID=99`, `GID=100`, `USERNAME=""`, `PASSWRD=""`, `USER=steam`, `DATA_PERM=770`; creates `/serverdata` dirs and user `steam`; `ENTRYPOINT ["/opt/scripts/start.sh"]`; no `USER` (runs as root); no EXPOSE, no VOLUME. |
| Master branch differs | `master` Dockerfile uses `FROM ich777/debian-baseimage:bullseye_amd64` and no Rocket variables. The `unturned` branch is the reference for this plan. |
| Ports | GAME_PORT=27015 (env default, UDP per draft). Query port 27016 is UNVERIFIED (draft inferred). |
| Sibling base | `apps/steamcmd`: `FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`; installs `steamcmd:i386` at `0~${VERSION}` (VERSION `20180105-5build1` from `apps/steamcmd/docker-bake.hcl`); `start.sh` copies the SteamCMD bootstrap into `/config/Steam/steamcmd`, runs `app_update` for `STEAM_APP_IDS`, and then `exec`s steamcmd. It does not start the game server. |
| Sibling env | `STEAM_USERNAME`, `STEAM_USER`, `STEAM_PASSWORD`, `STEAMCMD_PRE_UPDATE` (default true), `STEAM_APP_IDS`, `STEAM_INSTALL_DIR` (default `/config/steamapps`), `STEAM_APP_VALIDATE`, `STEAMCMD_SKIP_APP_UPDATE`. Verified from `apps/steamcmd/start.sh`. |

## 2. Target layout

- `apps/unturned/Dockerfile`
- `apps/unturned/docker-bake.hcl`
- `apps/unturned/settings.yaml`
- `apps/unturned/container-test.yaml`
- `apps/unturned/start.sh` (installs the server with the steamcmd sibling logic, then `exec`s the server)

No `defaults/`, `etc/` or `health/` needed unless a seed config is required (decide in step 4). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1@<digest>`

- Runtime base: `apps/steamcmd` (its image is tagged `${APP}:${VERSION}`; the digest must be resolved after `apps/steamcmd` is built or read from the registry, UNVERIFIED here).
- The ubuntu base in `apps/steamcmd` is the same digest as the brief's ubuntu base, so the steamcmd image is the correct foundation.
- Closest sibling for a steamcmd game server: `apps/steamcmd` itself. The draft's Reason ("reuses apps/steamcmd") is correct.
- Do not use the upstream `ich777/debian-baseimage`.

## 4. Dockerfile

1. `ARG VERSION`, `USER root` only if a package is needed (none expected: `lib32gcc-s1` is in the steamcmd base; `unzip` is UNVERIFIED in the base, and Rocket is not ported, so it is not needed).
2. Do not copy the upstream ENV set: `DATA_DIR`, `STEAMCMD_DIR`, `SERVER_DIR`, `UID`, `GID`, `USER`, `DATA_PERM`, `UMASK`. The app runs as `apps` and uses `/config` as its persistent root.
3. `ENV HOME=/config XDG_DATA_HOME=/config` as in the sibling, plus the server defaults from section 6.
4. Start script is the only app-specific file; copy it:

```dockerfile
USER root
COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /

EXPOSE 27015/udp
VOLUME /config
```

   Note: `COPY . /` already includes `start.sh` (allow-list), so the explicit `COPY start.sh` is only needed if the sibling pattern is copied verbatim. Keep one of them.
5. License of the wrapper and game: not in the image; record `UNVERIFIED` in the PR, do not invent a license file.
6. Do not set `ROCKET_MOD`, `ROCKET_URL`, or any mod variables: they are out of scope for the draft.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "unturned"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  default = "LicenseRef-Unturned-EULA"
}

variable "SOURCE" {
  default = "https://unturned.net/"
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
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = ["linux/amd64"]
}
```

- VERSION: the value is the steamcmd base version, not a game version, so the renovate line follows the base. Confirm that the `VERSION` arg in the Dockerfile is used only for the `FROM` tag, not as the game version. The `FROM` line needs a `${VERSION}` build arg to tag consistency: decide in step 4 and check the sibling pattern.
- `LICENSE` is a placeholder (UNVERIFIED): the game is proprietary.
- `image-all` is amd64 only (section 9).
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://unturned.net/"
ports:
  - port: 27015
    protocol: udp
    required: true
env:
  - name: STEAM_APP_IDS
    default: "1110390"
    required: true
  - name: STEAM_INSTALL_DIR
    default: "/config/serverfiles"
    required: false
  - name: STEAM_APP_VALIDATE
    default: "false"
    required: false
  - name: STEAM_USERNAME
    default: "anonymous"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `STEAM_APP_IDS` default `1110390` is from the draft's store URL; it must be confirmed as the dedicated server app id (UNVERIFIED). Do not ship it without confirmation.
- `STEAM_INSTALL_DIR` default: the sibling default is `/config/steamapps`; the value here is a proposal, pick one and keep the start script consistent.
- Ports: 27015/udp from GAME_PORT (upstream env, UDP per draft). Query port 27016 is UNVERIFIED and is not listed.
- `dependencies: []`: SteamCMD is in the base image, not a ContainerForge app dependency.

## 7. start.sh

Build on the sibling `apps/steamcmd/start.sh` logic (do not reinvent SteamCMD handling):

- Source the sibling install logic (copy, do not symlink across apps): bootstrap into `/config/Steam/steamcmd` only when missing; `app_update` into `${STEAM_INSTALL_DIR}` for `STEAM_APP_IDS`; `STEAM_APP_VALIDATE` controls `validate`.
- Idempotent: safe with an empty `/config` and on restarts. Skipping the update when `STEAMCMD_SKIP_APP_UPDATE=true` is kept from the sibling.
- Start the server: launcher path inside the installed Unturned tree is UNVERIFIED (the server launcher name and arguments were not fetched). Use the launcher from the Unturned server install, with `GAME_PORT` mapped to its port argument (UNVERIFIED flag).
- Bind: the server must listen on all interfaces (check launcher options, UNVERIFIED).
- Never write to `/app`. Caches go to `/tmp` (the steamcmd sibling uses `/config/steamcmd/tmp`; decide whether that is persistent, per the Dockerfile rules scratch belongs in `/tmp`).
- End with `exec` of the server process so signals reach it.

## 8. container-test.yaml

- Schema header from `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh`, `/usr/local/share/steamcmd/steamcmd.sh` (from the sibling base).
- Readiness: a `udp` port check on 27015 is needed. forgetool UDP support is UNVERIFIED; if unsupported, use a process check or a log-line check.
- `timeoutSeconds`: first start downloads the server from Steam (large). Use a higher value; mirror sibling timing for steamcmd (not verified here).
- Test runs with no env vars: `STEAM_APP_IDS` defaults to a value, so the install path runs and needs internet access. If the CI test has no internet, the test cannot pass without narrowing; do not narrow silently. Record the result per the protocol.
- No database dependency, so the narrowing exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (no `USER`), `UID`/`GID` env remap. ContainerForge target: `USER apps`. Drop `UID`, `GID`, `USER`, `DATA_PERM`.
- Read-only rootfs: steamcmd downloads into `/config`; scratch goes to `/tmp`. Verify with `--read-only --tmpfs /tmp`.
- `lib32gcc-s1` and 32-bit libs: provided by the steamcmd base (verified: `apps/steamcmd` installs `steamcmd:i386`).
- Persistence: `/config` holds the steamcmd bootstrap and game install. Draft says `/serverdata/serverfiles` and `/serverdata/steamcmd` as PVCs; in ContainerForge these become `/config/...`.
- Upstream security expectations from the draft (non-root no, read-only rootfs no) are not met as shipped. This plan targets non-root and read-only rootfs.
- arm64: not supported. The SteamCMD bootstrap is x86 only (draft; consistent with the steamcmd sibling, which is amd64-only in `image-all`). `copy-from` arm64: no.

## 10. Risks, caveats and open questions

- Dedicated server app id is UNVERIFIED (the store URL is the game page, not the server app).
- Server launcher name, arguments and port flags are UNVERIFIED (not fetched).
- Query port 27016 is UNVERIFIED.
- First start downloads a large game; CI needs internet. Test runtime is a risk.
- Wrapper license and game EULA are UNVERIFIED.
- The upstream ROCKET mod variables are out of scope for this port.
- Renovate for the game version is UNVERIFIED; the only pinned version here is the steamcmd base version.
- arm64 not supported (x86 bootstrap). Blocker for arm64.
- The steamcmd base image digest is not in the repo's brief list and must be resolved before pinning.

## 11. Build and test steps

From `apps/unturned/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run with an empty `/config`:
   `docker run --rm -d --name unturned-probe --read-only --tmpfs /tmp -v unturned-probe-config:/config unturned:20180105-5build1`
   `docker logs -f unturned-probe`
   Expected readiness: process running; SteamCMD reports the app update complete; then a server-ready line from the launcher (exact text UNVERIFIED). No fatal errors.
4. Cleanup: `docker rm -f unturned-probe; docker volume rm unturned-probe-config`
5. `forgetool containers test --image unturned:20180105-5build1 --config ./apps/unturned/container-test.yaml`
6. arm64 is not built (x86 bootstrap).

## 12. PR checklist

- Branch `feat/add-unturned`, commit `feat(unturned): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what is untested: the live server start (depends on Steam download), query port, UDP check, and arm64 (not supported).
