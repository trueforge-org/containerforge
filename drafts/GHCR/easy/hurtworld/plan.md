# hurtworld — implementation plan
> Source: ./draft.md · Target: apps/hurtworld/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No upstream version (Steam depot). The chart uses the ich777 image `ghcr.io/ich777/steamcmd:hurtworld@sha256:c12cb82fa4a2e2e4a214241428469a88bb52993634f2a3a2097259c63d1acac9`. Source: https://api.github.com/repos/trueforge-org/truecharts/contents/charts/stable/hurtworld/values.yaml. Build version: UNVERIFIED; use the Steam build id recorded at build time, or a steamcmd base version. |
| Dedicated server app id | Chart `GAME_ID` is **405100**. The draft's 393420 is the Hurtworld store (client) app: https://store.steampowered.com/api/appdetails?appids=393420 returns name "Hurtworld". Steam appdetails for 405100 returns `success: false`, so 405100 is UNVERIFIED as a store app; it is the chart value and must be confirmed with SteamCMD (`app_info_print 405100`) in step 2. |
| Renovate | No versioned artifact. The steamcmd base uses `datasource=deb`. For this game, a renovate annotation is UNVERIFIED: a `VERSION` needs a value that changes with the server build. Pick one when the Steam build id is known. |
| License | UNVERIFIED: Steam EULA, not fetched. Use `LICENSE` as the Steam EULA string once confirmed. |
| Source URL | Draft: https://store.steampowered.com/app/393420/ (client). Server app page UNVERIFIED. |
| Download | SteamCMD at start, from the Steam depot (anonymous login). No direct URL, no checksum. |
| Checksum source | None. SteamCMD `validate` only. |
| Upstream wrapper reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile (bullseye glibc, `steam` user, `DATA_DIR=/serverdata`, `GAME_ID`/`GAME_PARAMS`/`GAME_PORT` env) and its `scripts/start.sh` and `scripts/start-server.sh` (root wrapper: usermod/chown, then `su steam` running steamcmd and `srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`). This wrapper is replaced, not reused. |
| Ports (chart) | Game `12871/udp` (GAME_PORT), query `12881/udp`. Source: chart values URL above. |
| Chart GAME_PARAMS | `;autosaveenabled 1;addadmin 76561197963117432` (chart default, not a requirement; do not ship the admin SteamID). |
| Launch binary | UNVERIFIED: the Hurtworld dedicated server executable name and its launch arguments were not confirmed. The wrapper's `srcds_run` line is generic. |
| arm64 | No (draft; not contradicted by any fetched page). |

## 2. Target layout

- `apps/hurtworld/Dockerfile`
- `apps/hurtworld/docker-bake.hcl`
- `apps/hurtworld/settings.yaml`
- `apps/hurtworld/container-test.yaml`
- `apps/hurtworld/start.sh`

No `defaults/`, `etc/`, `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime base `ghcr.io/trueforge-org/steamcmd` (`apps/steamcmd`): its `start.sh` already installs SteamCMD under `/config/Steam/steamcmd`, runs `app_update` from `STEAM_APP_IDS` into `STEAM_INSTALL_DIR`, and ships the 32-bit libraries. The base is built from `ghcr.io/trueforge-org/ubuntu:26.04` (digest `sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`). No sibling app uses this base yet (checked: no `apps/*/Dockerfile` has `FROM ghcr.io/trueforge-org/steamcmd`), so the digest for the steamcmd image itself is UNVERIFIED: resolve it with `docker buildx imagetools inspect ghcr.io/trueforge-org/steamcmd:<VERSION>` in step 1 and pin it. Closest sibling: `apps/steamcmd`.

## 4. Dockerfile

1. `FROM ghcr.io/trueforge-org/steamcmd:<pinned tag>@sha256:<UNVERIFIED>`, `ARG VERSION`, `USER root` only if a step needs it.
2. No apt installs: the base already has steamcmd and 32-bit libs. Do not repeat `apt-get install lib32*`.
3. `ENV HOME=/config STEAM_INSTALL_DIR=/config/serverfiles`.
4. No download in the Dockerfile. The server is fetched at start, through the base's SteamCMD path.
5. Tail:

```dockerfile
COPY --chmod=0755 . /
USER apps

EXPOSE 12871/udp
EXPOSE 12881/udp
VOLUME /config
```

`COPY --chmod=0755 . /` brings in `start.sh` (and `scripts/` only if one is added). `VERSION` is a label-only arg, matching the bake.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "hurtworld"
}

variable "VERSION" {
  // renovate: datasource=... depName=... (UNVERIFIED: no versioned upstream; choose once the Steam build id is confirmed)
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "UNVERIFIED: Steam EULA"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/393420/"
}
```

Then the standard default group, `image`, `image-local`, `image-all` copied from `apps/adguardhome-sync/docker-bake.hcl`. `VERSION` must not stay `UNVERIFIED`; the plan is not buildable until a real value is chosen. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/393420/"
ports:
  - port: 12871
    protocol: udp
    required: true
  - port: 12881
    protocol: udp
    required: false
env:
  - name: STEAM_APP_IDS
    default: "405100"
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
  - name: STEAM_PASSWORD
    default: ""
    required: false
  - name: GAME_PORT
    default: "12871"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `STEAM_APP_IDS` names the dedicated server id (405100, UNVERIFIED as a store id). The base reads `STEAM_APP_IDS`, `STEAM_INSTALL_DIR`, `STEAM_APP_VALIDATE`, `STEAM_USERNAME`, `STEAM_PASSWORD`, `STEAMCMD_PRE_UPDATE` and `STEAMCMD_SKIP_APP_UPDATE`. Only list the ones the game start.sh reads. `GAME_PORT` is read only by the game start.sh, so it stays.
- Keep `STEAM_PASSWORD` out of any default, and do not log it.
- Ports: `12871/udp` and `12881/udp`. Both taken from the chart. Protocol UDP.
- No dependencies.

## 7. start.sh

Game start.sh (replaces the ich777 wrapper). Sketch:

```bash
#!/usr/bin/env bash
set -euo pipefail

export STEAM_APP_IDS="${STEAM_APP_IDS:-405100}"
export STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"

# Install or update the dedicated server with the steamcmd base. "+quit" makes the base
# run its own pre-update and app_update, then exit (base start.sh only execs steamcmd
# when the first argument does not start with "+"). UNVERIFIED: confirm this path.
/start.sh +quit

cd "${STEAM_INSTALL_DIR}"
exec ./<UNVERIFIED Hurtworld server binary> -port "${GAME_PORT:-12871}" ${GAME_PARAMS:-}
```

- Idempotent: the base updates only what is missing. `/config` is the only write target (`HOME=/config`, serverfiles under `/config`).
- Do not write to `/start.sh` or `/app`. The steamcmd base writes to `/config/Steam` and `/config/steamcmd`, which is allowed.
- Bind: the server must listen on all interfaces (UNVERIFIED for this binary's flags). Per the protocol, check what it binds to and connect from outside.
- Use `exec` for the server so signals reach it.
- Launch arguments and `GAME_PARAMS` are UNVERIFIED for this game; do not invent flags.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 900
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
```

- The test runs with no env vars, so `STEAM_APP_IDS` is empty and the download path is not exercised by the suite. Per the test rules, the required-env code paths go in `filePaths` and are run by hand (step 11).
- Ports: 12871/udp and 12881/udp have no probe. The `tcp` probe cannot test UDP. UNVERIFIED whether forgetool's schema has a `udp` probe; if not, state the gap in the PR.
- `timeoutSeconds` 900 is an estimate for a first-start server download (multi-GB, inferred). Check against the nearest game sibling and set it from there.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/steamcmd` (SteamCMD install) | `/config/Steam/steamcmd` via the steamcmd base |
| `/serverdata/serverfiles` (game files) | `/config/serverfiles` via `STEAM_INSTALL_DIR` |
| `/serverdata/.steam/sdk32` (steamclient libs) | Handled by the base (32-bit libs in the base image); UNVERIFIED that the server needs the copy step |
| `HOME=/serverdata` | `HOME=/config` |
| `/tmp` (steamcmd temp) | Base uses `/config/steamcmd/tmp`; the base's choice is kept |

Chart security (verify, not guarantees): `runAsUser 0`, `readOnlyRootFilesystem false`. The plan runs as `apps` and needs no root; the root wrapper is removed. The chart's `/serverdata` mounts map to `/config` (one volume).

## 10. Risks, caveats and open questions

- Store vs server id: the draft's 393420 is the client. The chart's 405100 is the dedicated server, and it did not resolve on the Steam store API. Confirm with SteamCMD before writing `STEAM_APP_IDS`.
- Launch binary and arguments unknown (section 7). Blocker until confirmed.
- `/start.sh +quit` path: the base's behavior with a `+` argument is taken from its source; UNVERIFIED that it exits after the update.
- arm64 is `no`. Only `image-local` amd64 is built and tested. `image-all` should be amd64 only.
- Game ports are UDP. Players need UDP forwarding (draft caveat). No tcp probe possible (section 8).
- First start is a large download (inferred).
- Blockers: launch binary unknown; steamcmd image digest unknown; `VERSION` and `LICENSE` values unknown.

## 11. Build and test steps

From `apps/hurtworld`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name hurtworld-probe --read-only --tmpfs /tmp \
  -v hurtworld-probe-config:/config -e STEAM_APP_IDS=405100 hurtworld:<VERSION>
docker logs -f hurtworld-probe
forgetool containers test --image hurtworld:<VERSION> --config ./apps/hurtworld/container-test.yaml
docker rm -f hurtworld-probe; docker volume rm hurtworld-probe-config
```

- Run once with an empty `/config` and once with a populated one to check the second start skips the download.
- Readiness signal: the base prints `Update SteamCMD` and `app_update` results, and then the server's own "ready"-type line (UNVERIFIED wording; capture from the first run).
- Anonymous login needs internet. If Steam is unreachable, the run is blocked, not passed.

## 12. PR checklist

- Branch `feat/add-hurtworld`, commit `feat(hurtworld): add new container`, PR title matches.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Say in the PR what was not tested: arm64 (no), the UDP ports (no tcp probe), the full server start (only if step 11 ran), and every UNVERIFIED item above.
- Do not check "Built container locally" unless step 11 build and run were done.
