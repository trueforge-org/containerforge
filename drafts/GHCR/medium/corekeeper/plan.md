# corekeeper — implementation plan
> Source: ./draft.md · Target: apps/corekeeper/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: Core Keeper has no release tags. The game build is fetched by SteamCMD at start, so there is no version to pin in the image. Draft gives no version. Open question in section 10. |
| Renovate | UNVERIFIED: no upstream release feed. Plan tracks the SteamCMD apt package the same way `apps/steamcmd` does: `datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu` |
| License | Upstream repo license not set on GitHub (`license: null`): https://api.github.com/repos/ich777/docker-steamcmd-server. Game license is the Steam EULA; SteamCMD is AGPL-3.0-or-later per `apps/steamcmd`. Bake `LICENSE` value to be decided in PR (UNVERIFIED). |
| Source URL | Game: https://store.steampowered.com/app/1963720 (draft). UNVERIFIED: the Steam app ID 1963720 for the dedicated server: the store fetch returned the Steam homepage, not the game page. |
| Download | Server files via SteamCMD `app_update` at first start (not a prebuilt binary). Dedicated server app ID and install line: UNVERIFIED. |
| Checksum source | None: SteamCMD validates the depot files itself. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64`, installs `lib32gcc-s1 lib32stdc++6 lib32z1`, creates user `steam`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, runs as root, no USER/VOLUME/EXPOSE. |
| Upstream start script reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh: root wrapper that `usermod`s to UID/GID, `chown`s `DATA_DIR`, then `su ${USER} -c /opt/scripts/start-server.sh` in the background with a SIGTERM trap. |
| Game start script | UNVERIFIED: `start-server.sh` for Core Keeper (app_update line, binary path, arguments, Xvfb use) was not fetched in this run. |
| Ports | 27015/udp (`GAME_PORT=27015` in upstream Dockerfile). 27016/udp (query): UNVERIFIED. |
| Env vars (real, upstream) | `DATA_DIR=/serverdata`, `STEAMCMD_DIR=${DATA_DIR}/steamcmd`, `SERVER_DIR=${DATA_DIR}/serverfiles`, `GAME_ID`, `GAME_NAME`, `GAME_PARAMS` (placeholders `template`), `GAME_PORT=27015`, `VALIDATE`, `UMASK=000`, `UID=99`, `GID=100`, `USERNAME`, `PASSWRD`, `USER=steam`, `DATA_PERM=770`. Game-specific values UNVERIFIED. |
| arm64 | No (draft; Core Keeper server is an x86-64 Unity build, and the ich777 base is amd64-only) |
| copy-from amd64 | ghcr.io/ich777/steamcmd:corekeeper (draft; upstream image, glibc Debian). Not used: the plan installs SteamCMD from apt, see section 3. |
| copy-from arm64 | no |

## 2. Target layout

- `apps/corekeeper/Dockerfile`
- `apps/corekeeper/docker-bake.hcl`
- `apps/corekeeper/settings.yaml`
- `apps/corekeeper/container-test.yaml`
- `apps/corekeeper/start.sh`

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage.

Why: the draft says reuse `apps/steamcmd` and `apps/xvfb`. Both are built on the same ubuntu base and install SteamCMD from the Ubuntu multiverse archive (`apps/steamcmd/Dockerfile`: `steamcmd:i386=0~${VERSION}`). Using that pattern keeps the image glibc Ubuntu and rootless. Closest siblings: `apps/steamcmd` (SteamCMD install and `/config/steamcmd` layout) and `apps/xvfb` (virtual display).

Not used: `ghcr.io/ich777/steamcmd` (upstream debian-baseimage, root wrapper) and `ghcr.io/trueforge-org/steamcmd` as a `FROM` (its digest is not in this repo's bake files, so it would be UNVERIFIED; if the writer wants the ContainerForge steamcmd image, read its digest from its published manifest and record it in the PR).

## 4. Dockerfile

1. `ARG VERSION` (SteamCMD apt version, matches `apps/steamcmd/docker-bake.hcl`, see section 5).
2. `USER root`.
3. Install SteamCMD with the sibling's steps (reuse them verbatim, do not restate from memory):
   - `dpkg --add-architecture i386`, `add-apt-repository -y multiverse`, debconf accept for steamcmd license, `apt-get install -y --no-install-recommends steamcmd:i386=0~${VERSION}`, symlink `/usr/local/share/steamcmd/steamcmd.sh`.
   - Pin: `steamcmd:i386=0~${VERSION}` (same as sibling). Check the pin against `VERSION` in `docker-bake.hcl`.
4. Install `xvfb` only if the Core Keeper start script needs a display (UNVERIFIED, section 1). If it does: `apt-get install -y --no-install-recommends xvfb xauth` and pin to the Ubuntu 26.04 archive version; record the version in the PR.
5. 32-bit libraries needed by SteamCMD: `lib32gcc-s1 lib32stdc++6 lib32z1` (from upstream Dockerfile; check whether the ubuntu base or the steamcmd apt package already pulls them, and do not install twice).
6. No `ENV HOME` override in the Dockerfile: `start.sh` exports `HOME=/config` and `XDG_DATA_HOME=/config` (sibling pattern, section 7), the base image already sets `HOME=/config`. Scratch files go to `/tmp`; server files go to `/config` via `start.sh`.
7. `mkdir -p /config`, `chown -R apps:apps /config /usr/local/share/steamcmd` (same as sibling), `rm -rf /var/lib/apt/lists/*`.
8. Final stage tail:
   ```dockerfile
   COPY --chmod=0755 start.sh /start.sh
   USER apps
   COPY --chmod=0755 . /

   VOLUME /config
   EXPOSE 27015/udp
   EXPOSE 27016/udp
   ENTRYPOINT ["/start.sh"]
   ```
   `EXPOSE 27016/udp` only if confirmed (section 1). No `WORKDIR` needed (`start.sh` `cd`s to `/config`).
9. License file: `install -Dm0644 <upstream license file> /usr/share/licenses/corekeeper/LICENSE` only if a license file is fetched (UNVERIFIED). Otherwise write `/usr/share/licenses/corekeeper/NOTICE` pointing to the Steam EULA and the SteamCMD license.
10. The upstream root wrapper (`usermod`, `chown` of `/opt/scripts`) is NOT copied: the image runs as `apps`, and `usermod` needs root. UID and GID come from the base `apps` user.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "corekeeper"
}

variable "VERSION" {
  // renovate: datasource=deb depName=steamcmd registryUrl=https://archive.ubuntu.com/ubuntu
  default = "20180105-5build1"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/1963720"
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

- `VERSION` is the SteamCMD apt pin (same value as `apps/steamcmd`). The game build is not pinned here: it updates at start (open question, section 10).
- `LICENSE` is UNVERIFIED; do not ship a value until the PR decides it.
- `image-all` is amd64 only (draft says no arm64).
- Validate with `docker buildx bake --print` from `apps/corekeeper`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/1963720"
ports:
  - port: 27015
    protocol: udp
    required: true
  - port: 27016
    protocol: udp
    required: false
env:
  - name: GAME_PORT
    default: "27015"
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
```

- `27016/udp` stays only if confirmed (section 1). Remove the entry if not.
- `STEAM_USERNAME`/`STEAM_PASSWORD` are read by the `steamcmd` script pattern in `apps/steamcmd/start.sh`; keep the anonymous default. Do not list `STEAM_PASSWORD` in `settings.yaml` with a default: it is a secret; list it as `required: false` with no default if the writer wants it visible.
- `GAME_PORT` is used only if `start-server.sh` reads it (UNVERIFIED); remove it otherwise. Do not invent env vars.
- No database dependency.

## 7. start.sh

Built on the sibling `apps/steamcmd/start.sh` pattern:

- `export HOME=/config`, `XDG_DATA_HOME=/config` (sibling pattern) so Steam state lives in `/config`.
- Server install directory: `SERVER_DIR="/config/serverfiles"` (draft: `/config`; upstream `/serverdata/serverfiles` is remapped here). Steam tools dir: `/config/steamcmd`.
- Create `/config/serverfiles` and `/config/steamcmd` only if missing. Do not overwrite existing saves or config.
- `steamcmd +force_install_dir "${SERVER_DIR}" +login "${STEAM_LOGIN_USER}" +app_update "${GAME_ID}" validate +quit`: the `app_update` line and `GAME_ID` are UNVERIFIED (section 1). Keep `validate` gated behind an env flag (upstream `VALIDATE`) if that matches the game's behaviour (UNVERIFIED).
- Anonymous login by default; if `STEAM_USERNAME` is set to a real account, require `STEAM_PASSWORD` (sibling pattern).
- Start the server: `exec "${SERVER_DIR}/<server binary>" ${GAME_PARAMS}` with the binary path and flags UNVERIFIED. If Xvfb is needed (section 1), start `Xvfb :99` in the background and set `DISPLAY=:99` before `exec`.
- Never write to `/app`. Caches (`HOME`, SteamCMD temp) go to `/tmp` or `/config/steamcmd/tmp` (sibling uses `/config/steamcmd/tmp` for script files; change to `/tmp` if the writer prefers, since it is scratch).
- Binds: the game server listens on UDP 27015 (UNVERIFIED that it binds to 0.0.0.0; confirm from the running process with `ss -lun`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 600
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

- `udp` probes are not in the forgetool probe list used by siblings (only `tcp` and `http` are used in `apps/steamcmd`), so no port probe for 27015/udp unless forgetool supports `udp` (UNVERIFIED: check the schema). Do not invent a probe. Record the gap in the PR.
- `timeoutSeconds`: 600, because SteamCMD and the server download may run on an empty `/config`. Check the value against `apps/steamcmd` (no timeout set there, UNVERIFIED family value).
- No env var is needed to start (anonymous login). The authenticated-login branch is an env-only code path, so add its file to `filePaths` (the script itself is already listed) and run it once by hand per the protocol.
- No database: no narrowing exception applies.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata` (`DATA_DIR`) | `/config` (`SERVER_DIR=/config/serverfiles`, `STEAMCMD_DIR=/config/steamcmd`) |
| `/opt/scripts` (ownership and mode by root wrapper) | Not used. No root wrapper in this image. |
| SteamCMD temp, script files | `/tmp` (or `/config/steamcmd/tmp` as in sibling, scratch only) |
| `HOME` | `/config` (sibling pattern); acceptable because Steam login state is persistent data |
| 32-bit libs | Installed at build time into `/usr/lib` (read-only at runtime) |

Draft expectations reconciled:
- Draft says non-root "possible, root wrapper dropped": this plan runs as `apps` with no `usermod`. SteamCMD and Xvfb must run as `apps`; verify that the apt SteamCMD runs without root (sibling `steamcmd` image runs as `apps`, so it does).
- Draft says `readOnlyRootFilesystem` possible: `/app` is not used; writes go to `/config` and `/tmp`; proved by the `--read-only --tmpfs /tmp` run in section 11.
- Not privileged. No extra security settings.
- Draft expects extra persistence `/serverdata/serverfiles` and `/serverdata/steamcmd`: this image uses `/config/serverfiles` and `/config/steamcmd`, so chart users must move their data (PR note).

## 10. Risks, caveats and open questions

- The game build is not versioned by this image (it updates at each start via SteamCMD). Decide whether the PR tracks Steam build IDs or leaves it open (UNVERIFIED).
- UNVERIFIED: Steam dedicated server app ID (1963720 in the draft) and the `app_update` line. The fetch returned the Steam homepage, so the ID is not confirmed. Confirm on the Steam dedicated-server page or from the SteamDB entry before building.
- UNVERIFIED: Core Keeper server binary path, arguments, config file location, and whether Xvfb is required. Upstream `start-server.sh` was not fetched: fetch https://raw.githubusercontent.com/ich777/docker-steamcmd-server (Core Keeper branch or template) and confirm before writing `start.sh`.
- UNVERIFIED: query port 27016.
- Large first-start download (SteamCMD). Caveat from the draft; the readiness test may take long, which is why `timeoutSeconds` is 600.
- amd64 only: arm64 hosts cannot run it (draft and section 1).
- The `forgetool` test has no UDP probe (section 8): the readiness check in section 11 is manual.
- The upstream steamcmd repo has no license set on GitHub: LICENSE value needs a decision (section 5).
- No blockers beyond the above: no privileged mode, no musl issue (glibc ubuntu base).

## 11. Build and test steps

```sh
cd apps/corekeeper
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name corekeeper-probe --read-only --tmpfs /tmp \
  -p 27015:27015/udp \
  -v corekeeper-probe-config:/config corekeeper:<VERSION>
docker logs -f corekeeper-probe
docker exec corekeeper-probe ss -lun
docker rm -f corekeeper-probe; docker volume rm corekeeper-probe-config

forgetool containers test --image corekeeper:<VERSION> --config ./apps/corekeeper/container-test.yaml
```

- The first run downloads the server with SteamCMD: allow a long startup (up to 10 minutes) and keep the same volume for a second start to prove the download is skipped or validated.
- Expected readiness signal: SteamCMD prints `Success! App '<app id>' fully installed.`, then the server log shows it listening on UDP 27015 (exact line UNVERIFIED). `ss -lun` shows the port bound.
- Also run an authenticated-login path by hand if the writer exposes `STEAM_USERNAME` (env-only path, section 8).
- Check that the server is reachable from another container or the host (UDP is not covered by forgetool).

## 12. PR checklist

- Branch `feat/add-corekeeper`, commit `feat(corekeeper): add new container`, PR title matches, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it; `license/cla` shows the status.
- Note the data migration from `/serverdata` to `/config` (section 9).
- Untested to say in the PR: the Steam app ID, the `app_update` line, the server binary and readiness line, Xvfb need, UDP probe, arm64 (not applicable), and any run longer than one start.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION` and the SteamCMD apt pin.
