# palworld — implementation plan
> Source: ./draft.md · Target: apps/palworld/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED. Steam app ID `2394010` (store page https://store.steampowered.com/app/2394010/, and the ich777 palworld branch). No build number was fetched. The server is updated by SteamCMD, so there is no release tag; pin the SteamCMD base instead and record the build at first install. |
| Renovate | For the base only: the steamcmd image tag (see section 3). No upstream release datasource exists. |
| License | Proprietary (Pocketpair). The image contains a server downloaded from Steam under the publisher's EULA; `LICENSE` cannot be an OSS SPDX. UNVERIFIED which value the repo uses for proprietary-server apps: check a sibling with a closed server (for example an existing game app) before setting it. |
| Source URL | https://www.pocketpair.jp/ (draft); game files come from Steam app 2394010. Wrapper source: https://github.com/ich777/docker-steamcmd-server/tree/palworld |
| Download | SteamCMD download of app `2394010` into `/config` at first start (no archive, no checksum source; Steam validates the depot). |
| Checksum source | None published. Steam `validate` (SteamCMD) verifies depots. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/palworld/Dockerfile: `FROM ich777/debian-baseimage`, apt `lib32gcc-s1 curl gdb libc++1`, libc++ copy workaround, `ENTRYPOINT ["/opt/scripts/start.sh"]`, runs as root, no VOLUME, no EXPOSE. Its env defaults (`GAME_ID=template`, `GAME_PORT=27015`, `USER=steam`) are the generic template values; palworld-specific values were not confirmed. |
| Local sibling `apps/steamcmd` (repo, not web) | Base `ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, installs `steamcmd:i386` pinned to `0~${VERSION}` (VERSION `20180105-5build1`), runs as `apps`, `/config` volume. `start.sh` reads `STEAM_APP_IDS` (comma-separated numeric), `STEAM_INSTALL_DIR` (default `/config/steamapps`), `STEAM_APP_VALIDATE`, `STEAM_USERNAME`/`STEAM_PASSWORD` (default anonymous), `STEAMCMD_PRE_UPDATE` (default true), `STEAMCMD_SKIP_APP_UPDATE`. A first argument that does not start with `+` is exec'd directly, before any install. |
| Ports | UNVERIFIED. Draft lists 8211/udp (game), 27015/udp (Steam query), 25575/tcp (RCON), 8212 (REST), all marked inferred. No Palworld docs were fetched. Do not list until confirmed. |
| Env vars | UNVERIFIED for palworld. Names that matter for the server come from the palworld server settings file and docs, not yet fetched. |
| Data path | Upstream: `/serverdata/serverfiles` and `/serverdata/steamcmd`. ContainerForge: `/config` (draft). |
| Dependencies | `apps/steamcmd` exists in this repo. No database. |

## 2. Target layout

- `apps/palworld/Dockerfile`
- `apps/palworld/docker-bake.hcl`
- `apps/palworld/settings.yaml`
- `apps/palworld/container-test.yaml`
- `apps/palworld/start.sh`

No `defaults/` unless a default `PalWorldSettings.ini` must be seeded (decide after the settings file path is verified). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Reuse the steamcmd app as the base so the SteamCMD bootstrap is not duplicated: `FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`. The tag and digest are UNVERIFIED: `apps/steamcmd` is not yet a `FROM` base in any Dockerfile, so its published tag and digest must be taken from GHCR and confirmed once that image is published. If it is not published, the fallback is the ubuntu base with the same SteamCMD apt steps as `apps/steamcmd`. Closest sibling: `apps/steamcmd` (base) and any `apps/` game server with a `start.sh` wrapper.

## 4. Dockerfile

1. `ARG VERSION`, `FROM` the steamcmd image above.
2. `USER root` only if any apt step is needed. Palworld needs 32-bit libs (`lib32gcc-s1`), which `apps/steamcmd` already installs through `steamcmd:i386`, so check first and skip if present. `libc++1` is needed by the server; add it only if the steamcmd image lacks it (UNVERIFIED).
3. The steamcmd base already ships its own wrapper at `/start.sh`, and `COPY --chmod=0755 . /` would overwrite it with palworld's `start.sh` (and `/usr/local/bin/steamcmd` execs `/start.sh`). So, as `root` and before the final `COPY`, copy the base wrapper aside: `RUN cp /start.sh /usr/local/share/steamcmd/steamcmd-init.sh`. Then `COPY --chmod=0755 . /` (repo rule), `USER apps` last. Palworld's `start.sh` lands at `/start.sh` and calls `steamcmd-init.sh`.
4. `ENV HOME=/config XDG_DATA_HOME=/config STEAM_INSTALL_DIR=/config/palworld STEAM_APP_IDS=2394010`.
5. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE <ports after verification>
VOLUME /config
```

Do not compile anything; no build stage.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "palworld" }

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd versioning=loose
  default = "<steamcmd tag, UNVERIFIED>"
}

variable "LICENSE" { default = "LicenseRef-Proprietary" } // UNVERIFIED: confirm the repo's convention for proprietary servers
variable "SOURCE" { default = "https://www.pocketpair.jp/" }
```

Four standard targets and the default group as in `apps/adguardhome-sync`. `VERSION` must equal the Dockerfile `ARG VERSION` and the steamcmd base tag. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.pocketpair.jp/"
ports:
  []   # UNVERIFIED: add the game/query/RCON/REST ports only after confirmation
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: STEAM_APP_IDS
    default: "2394010"
    required: false
  - name: STEAM_INSTALL_DIR
    default: "/config/palworld"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`STEAM_APP_IDS` and `STEAM_INSTALL_DIR` are read by `apps/steamcmd/start.sh`, so names and defaults match. The palworld-specific settings (for example an admin password) are added only when the server settings file is verified. Dependencies: none beyond the steamcmd base image, which is a base, not a runtime dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
install_dir="${STEAM_INSTALL_DIR:-/config/palworld}"

# 1. Install or update the server through the copied steamcmd wrapper. It reads STEAM_APP_IDS,
#    STEAM_INSTALL_DIR and STEAM_APP_VALIDATE, installs, then runs `steamcmd.sh +quit`.
#    (Do not call /start.sh: that is this script. A first argument not starting with + is exec'd
#    by the wrapper before any install.)
STEAMCMD_PRE_UPDATE=false STEAM_APP_IDS=2394010 STEAM_INSTALL_DIR="${install_dir}" STEAM_APP_VALIDATE=true \
  /usr/local/share/steamcmd/steamcmd-init.sh +quit
```

Then exec the server binary: `exec "${install_dir}/PalServer.sh" -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS` (the path `PalServer.sh` and these flags are UNVERIFIED; confirm from the installed tree and the server's documented launch options before finalising). Rules: idempotent (a re-run only updates), `/config` is seeded only by SteamCMD, no writes to `/app`, caches go to `/tmp`, `exec` the server for signal handoff, and bind to `0.0.0.0` (the server bind address is UNVERIFIED and must be checked against its config). Note: the wrapper `exec`s any first argument that does not start with `+` before installing, so the install trigger arguments must start with `+` (`+quit`, as shown).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 1800
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

Timeout is a placeholder: a first start downloads several GB, so the test cannot prove the server runs without the download. Add a tcp/http probe per settings port only after ports are verified. The test runs without env vars, so the install path is exercised in the protocol's manual run, not by the test; note this in the PR. Do not weaken: if the server start cannot be tested in CI, say so and keep the file-path checks.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/serverdata/steamcmd` (SteamCMD binaries and state) | `/config/steamcmd` (set by `apps/steamcmd`), `/tmp` for scripts |
| `/serverdata/serverfiles` (server install) | `/config/palworld` (`STEAM_INSTALL_DIR`) |
| Upstream runs as root (`USER` absent), `USER=steam` | `USER apps` (repo rule) |
| `DATA_PERM=770`, `UMASK=000`, `UID=99`, `GID=100` | Not carried over; `apps` owns `/config` |

Draft security expectations, reconciled: the chart sets `runAsUser 0`; the image runs as `apps`, so the chart must drop the root UID (UNVERIFIED value). `readOnlyRootFilesystem` is achievable because the server and SteamCMD write only under `/config` and `/tmp`; verify on `--read-only --tmpfs /tmp`. Not privileged. Extra persistence: none beyond `/config`.

## 10. Risks, caveats and open questions

- Multi-GB first start via SteamCMD; a network failure must fail `start.sh` clearly (the steamcmd wrapper already exits when `STEAM_APP_IDS` install fails).
- arm64: no. The Steam Linux server is not published for arm64 (draft; UNVERIFIED). Keep `image-all` as amd64 only, as the draft says.
- RCON and REST admin password must be set in the server settings file and changed from the default before use (draft, UNVERIFIED). Start.sh must not invent a default password; if one is set, it must come from env and be applied on each start.
- Base image not yet proven: `ghcr.io/trueforge-org/steamcmd` tag and digest unverified; this is the main blocker for the `FROM` line.
- Ports and launch flags unverified: the settings may only be listed once confirmed.
- Blockers: none that are inherent to the app; the base image publication and the unverified ports and launch command are the blockers to clear first.

## 11. Build and test steps

```sh
cd apps/palworld
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name palworld-probe --read-only --tmpfs /tmp \
  -v palworld-probe-config:/config palworld:<VERSION>
docker logs -f palworld-probe
forgetool containers test --image palworld:<VERSION> --config ./apps/palworld/container-test.yaml
docker rm -f palworld-probe; docker volume rm palworld-probe-config
```

Expected readiness: SteamCMD prints `Success! App '2394010' fully installed` (UNVERIFIED exact text), then the server starts and logs its ready line (UNVERIFIED). Allow a long first start. Confirm that a restart with the same `/config` does not re-download everything.

## 12. PR checklist

- Branch `feat/add-palworld`, commit and PR title `feat(palworld): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- State honestly what is untested: the full server start (multi-GB download is not in CI), ports, RCON/REST, the admin password path, and arm64 (not applicable per draft).
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION` and the steamcmd base tag.
