# pavlovvr — implementation plan
> Source: ./draft.md · Target: apps/pavlovvr/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED. Steam app ID `622970` (store page https://store.steampowered.com/app/622970/ per draft; not fetched). The server is updated by SteamCMD, so there is no release tag; record the build at first install. |
| Renovate | For the base only: the steamcmd image tag (see section 3). No upstream release datasource exists. |
| License | Proprietary (Vankrupt Games). The server is downloaded from Steam under the publisher's EULA; `LICENSE` cannot be an OSS SPDX. UNVERIFIED which value the repo uses for proprietary-server apps: check a sibling with a closed server before setting it. |
| Source URL | https://www.vankrupt.com/ (draft); game files from Steam app 622970. Wrapper source: https://github.com/ich777/docker-steamcmd-server (branch `pavlovvr`) |
| Download | SteamCMD download of app `622970` into `/config` at first start (no archive, no checksum source; Steam validates the depot). |
| Checksum source | None published. Steam `validate` (SteamCMD) verifies depots. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/pavlovvr/Dockerfile: `FROM ich777/debian-baseimage`, apt `lib32gcc-s1 curl gdb libc++1`, libc++ copy workaround, `ENTRYPOINT ["/opt/scripts/start.sh"]`, runs as root, no VOLUME, no EXPOSE. Its env defaults (`GAME_ID=template`, `GAME_PORT=27015`, `USER=steam`) are the generic template values; pavlovvr-specific values were not confirmed. |
| Local sibling `apps/steamcmd` (repo, not web) | Base `ghcr.io/trueforge-org/ubuntu:26.4@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, installs `steamcmd:i386` pinned to `0~${VERSION}` (VERSION `20180105-5build1`), runs as `apps`, `/config` volume. `start.sh` reads `STEAM_APP_IDS` (comma-separated numeric), `STEAM_INSTALL_DIR` (default `/config/steamapps`), `STEAM_APP_VALIDATE`, `STEAM_USERNAME`/`STEAM_PASSWORD` (default anonymous), `STEAMCMD_PRE_UPDATE` (default true), `STEAMCMD_SKIP_APP_UPDATE`. A first argument that does not start with `+` is exec'd directly, before any install. |
| Ports | UNVERIFIED. Draft lists 7777/udp (game), 8803/udp (query), 27015/udp (Steam), all marked inferred. No Pavlov docs were fetched. Do not list until confirmed. |
| Env vars | UNVERIFIED for pavlovvr. Server settings names come from the Pavlov server docs, not yet fetched. |
| Data path | Upstream: `/serverdata/serverfiles` and `/serverdata/steamcmd`. ContainerForge: `/config` (draft). |
| Dependencies | `apps/steamcmd` exists in this repo. No database. |

## 2. Target layout

- `apps/pavlovvr/Dockerfile`
- `apps/pavlovvr/docker-bake.hcl`
- `apps/pavlovvr/settings.yaml`
- `apps/pavlovvr/container-test.yaml`
- `apps/pavlovvr/start.sh`

No `defaults/` unless a default server config must be seeded (decide after the config path is verified). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Reuse the steamcmd app as the base so the SteamCMD bootstrap is not duplicated: `FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>`. The tag and digest are UNVERIFIED: `apps/steamcmd` is not yet a `FROM` base in any Dockerfile, so its published tag and digest must be taken from GHCR and confirmed once that image is published. If it is not published, the fallback is the ubuntu base with the same SteamCMD apt steps as `apps/steamcmd`. Closest sibling: `apps/steamcmd` (base); the same pattern as `apps/palworld` in this batch.

## 4. Dockerfile

1. `ARG VERSION`, `FROM` the steamcmd image above.
2. `USER root` only if any apt step is needed. The 32-bit libs and `libc++1` come from `apps/steamcmd` (`steamcmd:i386`); check the base first and add `libc++1` only if it is missing (UNVERIFIED).
3. The steamcmd base already ships its own wrapper at `/start.sh`, and `COPY --chmod=0755 . /` would overwrite it with pavlovvr's `start.sh` (and `/usr/local/bin/steamcmd` execs `/start.sh`). So, as `root` and before the final `COPY`, copy the base wrapper aside: `RUN cp /start.sh /usr/local/share/steamcmd/steamcmd-init.sh`. Then `COPY --chmod=0755 . /` (repo rule), `USER apps` last. Pavlovvr's `start.sh` lands at `/start.sh` and calls `steamcmd-init.sh`.
4. `ENV HOME=/config XDG_DATA_HOME=/config STEAM_INSTALL_DIR=/config/pavlovvr STEAM_APP_IDS=622970`.
5. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE <ports after verification>
VOLUME /config
```

No build stage; nothing is compiled.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "pavlovvr" }

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/trueforge-org/steamcmd versioning=loose
  default = "<steamcmd tag, UNVERIFIED>"
}

variable "LICENSE" { default = "LicenseRef-Proprietary" } // UNVERIFIED: confirm the repo's convention for proprietary servers
variable "SOURCE" { default = "https://www.vankrupt.com/" }
```

Four standard targets and the default group as in `apps/adguardhome-sync`. `VERSION` must equal the Dockerfile `ARG VERSION` and the steamcmd base tag. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.vankrupt.com/"
ports:
  []   # UNVERIFIED: add the game/query/Steam ports only after confirmation
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: STEAM_APP_IDS
    default: "622970"
    required: false
  - name: STEAM_INSTALL_DIR
    default: "/config/pavlovvr"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`STEAM_APP_IDS` and `STEAM_INSTALL_DIR` are read by `apps/steamcmd/start.sh`, so names and defaults match. Server-specific env vars are added only once verified. Dependencies: none beyond the steamcmd base image.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
install_dir="${STEAM_INSTALL_DIR:-/config/pavlovvr}"

# 1. Install or update the server through the copied steamcmd wrapper. It reads STEAM_APP_IDS,
#    STEAM_INSTALL_DIR and STEAM_APP_VALIDATE, installs, then runs `steamcmd.sh +quit`.
#    (Do not call /start.sh: that is this script.)
STEAMCMD_PRE_UPDATE=false STEAM_APP_IDS=622970 STEAM_INSTALL_DIR="${install_dir}" STEAM_APP_VALIDATE=true \
  /usr/local/share/steamcmd/steamcmd-init.sh +quit
```

Then exec the server: the launch script name and its flags are UNVERIFIED (not fetched from the Pavlov docs or the upstream `start.sh`). Confirm from the installed tree before finalising. Rules: idempotent (a re-run only updates), `/config` is seeded only by SteamCMD, no writes to `/app`, caches go to `/tmp`, `exec` the server for signal handoff, and bind to `0.0.0.0` (bind address UNVERIFIED). The wrapper `exec`s any first argument that does not start with `+` before installing, so the trigger argument must start with `+` (`+quit`, as shown).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 1800
filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /usr/local/share/steamcmd/steamcmd.sh
```

The timeout is a placeholder: a first start downloads a large server via SteamCMD, so CI cannot prove the server runs without that download. Add tcp/http probes per settings port only after ports are verified. The test runs without env vars, so the install path is exercised in the protocol's manual run, not by the test; state this in the PR. Do not weaken: if the server start cannot be tested in CI, say so and keep the file-path checks.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/serverdata/steamcmd` (SteamCMD binaries and state) | `/config/steamcmd` (set by `apps/steamcmd`), `/tmp` for scripts |
| `/serverdata/serverfiles` (server install) | `/config/pavlovvr` (`STEAM_INSTALL_DIR`) |
| Upstream runs as root (`USER` absent), `USER=steam` | `USER apps` (repo rule) |
| `DATA_PERM=770`, `UMASK=000`, `UID=99`, `GID=100` | Not carried over; `apps` owns `/config` |

Draft security expectations, reconciled: the chart sets `runAsUser 0`; the image runs as `apps`, so the chart must drop the root UID (UNVERIFIED value). `readOnlyRootFilesystem` is achievable because SteamCMD and the server write only under `/config` and `/tmp`; verify on `--read-only --tmpfs /tmp`. Not privileged. Extra persistence: none beyond `/config`.

## 10. Risks, caveats and open questions

- Slow first start: SteamCMD downloads the server on first run; a network failure must fail `start.sh` clearly (the steamcmd wrapper already exits when the `STEAM_APP_IDS` install fails).
- arm64: no. The Steam Linux server is not published for arm64 (draft; UNVERIFIED). Keep `image-all` as amd64 only.
- UDP reachability: game port 7777/udp and query port 8803/udp must be forwarded (draft; query port inferred).
- Base image not yet proven: `ghcr.io/trueforge-org/steamcmd` tag and digest unverified; this is the main blocker for the `FROM` line.
- Ports and launch command unverified: settings may only list them once confirmed.
- Blockers: none inherent to the app; the base image publication and the unverified ports and launch command must be cleared first.

## 11. Build and test steps

```sh
cd apps/pavlovvr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name pavlovvr-probe --read-only --tmpfs /tmp \
  -v pavlovvr-probe-config:/config pavlovvr:<VERSION>
docker logs -f pavlovvr-probe
forgetool containers test --image pavlovvr:<VERSION> --config ./apps/pavlovvr/container-test.yaml
docker rm -f pavlovvr-probe; docker volume rm pavlovvr-probe-config
```

Expected readiness: SteamCMD reports the app as fully installed (UNVERIFIED exact text), then the server starts and logs its ready line (UNVERIFIED). Allow a long first start. Confirm that a restart with the same `/config` does not re-download everything.

## 12. PR checklist

- Branch `feat/add-pavlovvr`, commit and PR title `feat(pavlovvr): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- State honestly what is untested: the full server start (large download is not in CI), ports, the launch command, and arm64 (not applicable per draft).
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION` and the steamcmd base tag.
