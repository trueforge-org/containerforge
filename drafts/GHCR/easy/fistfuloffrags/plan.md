# fistfuloffrags — implementation plan
> Source: ./draft.md · Target: apps/fistfuloffrags/ · Difficulty: easy · Role: main · Verified on 2026-11-25
> Status: BLOCKED on the dedicated server Steam app ID and the game ports. See sections 1 and 10.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Game | Fistful of Frags, Steam app 265630 (type game, Windows/macOS/Linux). Source: https://store.steampowered.com/api/appdetails?appids=265630 |
| Dedicated server Steam app ID | UNVERIFIED: the Steam appdetails data for 265630 links no dedicated server app. The server app ID must be confirmed (SteamDB or the game's docs) before the install step is written. |
| Version to build | UNVERIFIED: no versioned upstream artifact. The server is pulled from Steam at start. |
| Renovate | UNVERIFIED: no datasource fits. Base image only (section 3). |
| License | UNVERIFIED: closed source Steam title under the Steam subscriber agreement. Use the container's license (section 5). |
| Source URL | https://store.steampowered.com/app/265630/ (draft) |
| Download | amd64 only: SteamCMD downloads the server into `/config` at start. No direct URL. |
| Checksum source | SteamCMD `validate` only. |
| Upstream container | Same ich777 wrapper as dontstarvetogether: `FROM ich777/debian-baseimage:bullseye_amd64`, apt `lib32gcc-s1 lib32stdc++6 lib32z1`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, no VOLUME, no EXPOSE, no USER, runs as root. Source: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile |
| Upstream env (wrapper) | `DATA_DIR=/serverdata`, `STEAMCMD_DIR=/serverdata/steamcmd`, `SERVER_DIR=/serverdata/serverfiles`, `GAME_PORT=27015`, `VALIDATE`, `UMASK=000`, `UID=99`, `GID=100`, `USERNAME`, `PASSWRD`, `USER=steam`, `DATA_PERM=770`. Source: the Dockerfile above and https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/README.md. Wrapper variables, not game variables. |
| Ports | UNVERIFIED: the draft's 27015/tcp and 27015/udp are inferred. 27015 appears only as the wrapper's example `GAME_PORT`. |
| Data paths | Server files under `/config` in our layout (section 2). The game's own save path is UNVERIFIED. |
| arm64 | No. SteamCMD's 32-bit x86 bootstrap does not run on arm64. |
| Compatibility | Draft flags an old Source-engine title with uncertain Steam support (inferred). UNVERIFIED. |

## 2. Target layout

apps/fistfuloffrags/
- Dockerfile (FROM steamcmd base, `USER apps`, `COPY --chmod=0755 . /`)
- docker-bake.hcl
- settings.yaml
- start.sh
- container-test.yaml

No `defaults/`, `etc/` or `health/`. No `root/`. No DOWNSTREAM_CHANGES.md (not a FROM base).

## 3. Base image

- FROM `ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`. Digest UNVERIFIED: take it from the published steamcmd manifest at build time.
- Foundation: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, through steamcmd.
- Closest sibling: `apps/steamcmd` (its start.sh seeds SteamCMD and reads `STEAM_APP_IDS`). No other game server in `apps/` uses it yet.

## 4. Dockerfile

1. `FROM` steamcmd base. `ARG VERSION` / `ARG VENDOR` only if the base needs them.
2. No install step expected. If apt is needed, `USER root`, install, `USER apps`.
3. Do not re-install the `lib32*` packages: the base provides the 32-bit stack. Check the base before adding anything.
4. `ENV HOME=/config XDG_DATA_HOME=/config`, `TMPDIR=/tmp`.
5. Files come in through `COPY --chmod=0755 . /`, and `start.sh` is on the include/.dockerignore allow-list.
6. No VOLUME or EXPOSE in the Dockerfile. Those go in settings.yaml.
7. Final: `USER apps`.

## 5. docker-bake.hcl

- `target "docker-metadata-action" {}`
- `variable "APP" { default = "fistfuloffrags" }`
- `variable "VERSION"`: the steamcmd base tag, aligned with the Dockerfile. UNVERIFIED tag scheme.
- `variable "LICENSE"`: `AGPL-3.0-or-later` to match the steamcmd and nginx siblings. The game is not open source; say so in the PR.
- `variable "SOURCE" { default = "https://store.steampowered.com/app/265630/" }`
- `group "default" { targets = ["image-local"] }`, `image`, `image-local` (`output = ["type=docker"]`, tags `${APP}:${VERSION}`), `image-all` (`linux/amd64` only).
- Validate: `cd apps/fistfuloffrags && docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://store.steampowered.com/app/265630/"`.
- `ports`: UNVERIFIED. Leave `ports: []` until the server ports are confirmed; do not list 27015 on the draft's inference alone.
- `env`: `TZ` (default `Etc/UTC`, required false). Game-specific names UNVERIFIED; add only names the start script reads.
- `volumes`: `- path: /config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`, `export HOME=/config XDG_DATA_HOME=/config`.
- Install or update the server into `/config/serverfiles` with `/config/Steam/steamcmd/steamcmd.sh`, seeded on first run from `/usr/local/share/steamcmd` (same pattern as the steamcmd base). Call SteamCMD directly: `+force_install_dir /config/serverfiles +login anonymous +app_update <APPID> validate +quit`. Do not reuse the base's final `exec`, which starts an interactive SteamCMD.
- Idempotent: `app_update` runs on each start. Write only to `/config` and `/tmp`, never `/app`.
- Bind to all interfaces: confirm the server's bind option (UNVERIFIED).
- Final step: `exec` the server binary with its launch args. Binary path and args UNVERIFIED.

## 8. container-test.yaml

- Schema header from `apps/steamcmd/container-test.yaml`.
- `filePaths`: `/start.sh`, `/usr/local/share/steamcmd/steamcmd.sh`.
- `timeoutSeconds`: large (for example 600), because the first run downloads the server. Compare with steamcmd-family values before fixing it.
- `tcp`/`udp` probes: only for confirmed ports (none yet; UNVERIFIED).
- Tests run with no env vars. Any path that needs a variable goes to `filePaths`.
- No weakened assertions. No DB dependency, so the DB exception does not apply.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (chart `runAsUser 0`, `runAsGroup 0`). Our image runs as `apps`; chart changes go in a separate PR.
- `readOnlyRootFilesystem`: chart sets false. Our image uses only `/config` and `/tmp`, so it can run read-only. Verify with `--read-only --tmpfs /tmp`.
- Upstream persistence (`/serverdata/serverfiles`, `/serverdata/steamcmd`) becomes `/config` subpaths. Remap every write.
- UID: `apps`. Do not use the wrapper's `UID=99`/`GID=100`.
- `privileged`: no.

## 10. Risks, caveats and open questions

- BLOCKER: dedicated server Steam app ID UNVERIFIED.
- BLOCKER: game ports UNVERIFIED (27015 is the wrapper example only).
- Steam support for this old Source title is uncertain (draft inference). If the server app is gone from Steam, the image cannot be built as planned.
- arm64 unsupported: `image-all` is amd64 only.
- First start downloads the server, so the test timeout must allow for it.
- Game version is not pinned: updates happen at container start.
- The upstream wrapper runs as root; the rootless start script is new work.

## 11. Build and test steps

From `apps/fistfuloffrags/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name fistfuloffrags-probe --read-only --tmpfs /tmp -v fistfuloffrags-probe-config:/config fistfuloffrags:<VERSION>`, then `docker logs -f fistfuloffrags-probe`. Expected readiness line: UNVERIFIED until a real run.
4. Cleanup: `docker rm -f fistfuloffrags-probe; docker volume rm fistfuloffrags-probe-config`.
5. `forgetool containers test --image fistfuloffrags:<VERSION> --config ./container-test.yaml`.
6. Steps 2 to 5 need Steam network access and are long. Not run in this plan.

## 12. PR checklist

- Branch: `feat/add-fistfuloffrags`
- Commit and PR title: `feat(fistfuloffrags): add new container`
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge; only they can sign it.
- PR template: `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only what applies.
- Not tested: say so unless step 3 passed. Do not check "Built container locally" unless step 2 passed.
- List the blockers from section 10 in the PR description.
