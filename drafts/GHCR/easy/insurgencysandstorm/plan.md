# insurgencysandstorm — implementation plan
> Source: ./draft.md · Target: apps/insurgencysandstorm/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No upstream version (Steam depot). The chart uses `ghcr.io/ich777/steamcmd:insurgencysandstorm@sha256:755cb75b05690879a7dea1f6945b44cf62edea61ef5d90106fb209e1b2bebbd2`. Source: https://api.github.com/repos/trueforge-org/truecharts/contents/charts/stable/insurgencysandstorm/values.yaml. Build version: UNVERIFIED; use the Steam build id recorded at build time. |
| Dedicated server app id | Chart `GAME_ID` is **581330**. The draft's 581320 is the store (client) app: https://store.steampowered.com/api/appdetails?appids=581320 returns "Insurgency: Sandstorm". Steam appdetails for 581330 returns `success: false`, so 581330 is UNVERIFIED as a store app; confirm with SteamCMD (`app_info_print 581330`) in step 2. |
| Renovate | No versioned artifact. UNVERIFIED: choose a datasource once the Steam build id is known. |
| License | UNVERIFIED: Steam EULA, not fetched. |
| Source URL | Draft: https://store.steampowered.com/app/581320/ (client). Server app page UNVERIFIED. Docs cited by the draft: https://developer.valvesoftware.com/wiki/Insurgency:_Sandstorm_Dedicated_Server (not fetched). |
| Download | SteamCMD at start, from the Steam depot (anonymous login). No direct URL, no checksum. |
| Checksum source | None. SteamCMD `validate` only. |
| Upstream wrapper reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile and `scripts/start.sh`, `scripts/start-server.sh` (same wrapper as hurtworld). Root wrapper, replaced by the plan. |
| Ports (chart) | Game `27102/udp` (GAME_PORT), query `27131/udp`. Source: chart values URL above. |
| Chart GAME_PARAMS | `Oilfield?Scenario=Scenario_Refinery_Push_Security?MaxPlayers=28?Password=Docker` (chart default). The `Password=Docker` value is a placeholder and must not be a default in this image. |
| Launch binary | UNVERIFIED: the Sandstorm dedicated server executable and its launch arguments were not confirmed. |
| arm64 | No (draft; not contradicted by any fetched page). |

## 2. Target layout

- `apps/insurgencysandstorm/Dockerfile`
- `apps/insurgencysandstorm/docker-bake.hcl`
- `apps/insurgencysandstorm/settings.yaml`
- `apps/insurgencysandstorm/container-test.yaml`
- `apps/insurgencysandstorm/start.sh`

No `defaults/`, `etc/`, `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Runtime base `ghcr.io/trueforge-org/steamcmd` (`apps/steamcmd`): its `start.sh` installs SteamCMD under `/config/Steam/steamcmd`, runs `app_update` from `STEAM_APP_IDS` into `STEAM_INSTALL_DIR`, and ships the 32-bit libraries. Built from `ghcr.io/trueforge-org/ubuntu:26.04` (digest `sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`). No sibling app uses the steamcmd base yet, so the steamcmd image digest is UNVERIFIED: resolve it with `docker buildx imagetools inspect ghcr.io/trueforge-org/steamcmd:<VERSION>` and pin it. Closest sibling: `apps/steamcmd`, and `hurtworld` in this same batch (same pattern).

## 4. Dockerfile

1. `FROM ghcr.io/trueforge-org/steamcmd:<pinned tag>@sha256:<UNVERIFIED>`, `ARG VERSION`.
2. Because `COPY --chmod=0755 . /` overwrites the base's `/start.sh` with this app's `start.sh`, first save the base script as root: `RUN cp /start.sh /usr/local/bin/steamcmd-base.sh` (before the tail `COPY`, with `USER root` then back), and call that copy from `start.sh`. Calling `/start.sh` would recurse into itself.
3. No apt installs: steamcmd and the 32-bit libraries come from the base.
4. `ENV HOME=/config STEAM_INSTALL_DIR=/config/serverfiles`.
5. No download in the Dockerfile. The server is fetched at start by the base's SteamCMD path.
6. Tail:

```dockerfile
COPY --chmod=0755 . /
USER apps

EXPOSE 27102/udp
EXPOSE 27131/udp
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "insurgencysandstorm"
}

variable "VERSION" {
  // renovate: datasource=... depName=... (UNVERIFIED: no versioned upstream; choose once the Steam build id is confirmed)
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "UNVERIFIED: Steam EULA"
}

variable "SOURCE" {
  default = "https://store.steampowered.com/app/581320/"
}
```

Then the standard default group, `image`, `image-local`, `image-all` copied from `apps/adguardhome-sync/docker-bake.hcl`. `VERSION` must not stay `UNVERIFIED`. `image-all` is amd64 only. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://store.steampowered.com/app/581320/"
ports:
  - port: 27102
    protocol: udp
    required: true
  - port: 27131
    protocol: udp
    required: false
env:
  - name: STEAM_APP_IDS
    default: "581330"
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
    default: "27102"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `STEAM_APP_IDS` = 581330 (chart value, UNVERIFIED as a store id).
- Only env the start.sh and the base read. Do not ship `Password=Docker`. `GAME_PARAMS` is optional: if added, its default must be empty, not the chart's scenario string.
- No dependencies.

## 7. start.sh

Game start.sh (replaces the ich777 wrapper). Sketch:

```bash
#!/usr/bin/env bash
set -euo pipefail

export STEAM_APP_IDS="${STEAM_APP_IDS:-581330}"
export STEAM_INSTALL_DIR="${STEAM_INSTALL_DIR:-/config/serverfiles}"

# Install or update via the steamcmd base; "+quit" makes the base run its pre-update and
# app_update, then exit. UNVERIFIED: confirm this path.
/usr/local/bin/steamcmd-base.sh +quit

cd "${STEAM_INSTALL_DIR}"
exec ./<UNVERIFIED Insurgency Sandstorm server binary> ${GAME_PARAMS:-}
```

- Idempotent: the base only updates what is missing. Writes go to `/config` only.
- No writes to `/app` or `/`.
- Server must listen on all interfaces (UNVERIFIED for this binary's flags). Check the bound address from outside the container.
- `exec` the server so signals propagate.
- Launch binary and arguments UNVERIFIED; do not invent flags.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 900
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
```

- No env vars in the suite, so the download path is not exercised. Required-env code paths go in `filePaths` and are run by hand (step 11).
- UDP ports 27102 and 27131 have no probe. tcp cannot test UDP. UNVERIFIED whether forgetool supports a udp probe; if not, state the gap in the PR.
- `timeoutSeconds` 900 is an estimate for a multi-GB first download (inferred). Set it from the nearest game sibling.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/serverdata/steamcmd` | `/config/Steam/steamcmd` (steamcmd base) |
| `/serverdata/serverfiles` | `/config/serverfiles` via `STEAM_INSTALL_DIR` |
| `/serverdata/.steam/sdk32` | Handled by the base; UNVERIFIED that the server needs the copy step |
| `HOME=/serverdata` | `HOME=/config` |

Chart security (verify, not guarantees): `runAsUser 0`, `readOnlyRootFilesystem false`. The plan runs as `apps`, with no root wrapper. The chart's `/serverdata` mounts map to one `/config` volume.

## 10. Risks, caveats and open questions

- Store vs server id: the draft's 581320 is the client. The chart's 581330 is the server, unconfirmed on the Steam store API. Confirm with SteamCMD before writing `STEAM_APP_IDS`.
- Launch binary and arguments unknown (section 7). Blocker until confirmed.
- `steamcmd-base.sh +quit` path: from the base's source; UNVERIFIED that it exits after the update.
- Multi-GB first download; needs internet and a long first start (inferred).
- arm64 is `no`. `image-all` is amd64 only.
- Game ports UDP; players need UDP forwarding. No tcp probe possible.
- Blockers: launch binary unknown; steamcmd image digest unknown; `VERSION` and `LICENSE` unknown.

## 11. Build and test steps

From `apps/insurgencysandstorm`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name insurgencysandstorm-probe --read-only --tmpfs /tmp \
  -v insurgencysandstorm-probe-config:/config -e STEAM_APP_IDS=581330 insurgencysandstorm:<VERSION>
docker logs -f insurgencysandstorm-probe
forgetool containers test --image insurgencysandstorm:<VERSION> --config ./apps/insurgencysandstorm/container-test.yaml
docker rm -f insurgencysandstorm-probe; docker volume rm insurgencysandstorm-probe-config
```

- Run once with an empty `/config` and once with a populated one to confirm the second start skips the download.
- Readiness signal: base `app_update` output, then the server's own ready line (UNVERIFIED wording; capture from the first run).
- Steam must be reachable; if not, the run is blocked, not passed.

## 12. PR checklist

- Branch `feat/add-insurgencysandstorm`, commit `feat(insurgencysandstorm): add new container`, PR title matches.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State in the PR what was not tested: arm64 (no), the UDP ports (no tcp probe), the full server start (only if step 11 ran), and every UNVERIFIED item above.
- Do not check "Built container locally" unless step 11 build and run were done.
