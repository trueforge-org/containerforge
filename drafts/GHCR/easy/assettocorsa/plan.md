# assettocorsa — implementation plan
> Source: ./draft.md · Target: apps/assettocorsa/ · Difficulty: easy (as drafted; re-rate to medium if the Steam app ID and ports cannot be verified) · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED: the Assetto Corsa dedicated server is pulled from Steam at start, so there is no release tag to pin. The Steam app ID is UNVERIFIED (Valve wiki returned HTTP 403 to WebFetch; not confirmed). |
| Renovate | UNVERIFIED: no pinned upstream version. Plan: pin the SteamCMD base instead (see section 3) and use the steamcmd app version as `VERSION` after review. |
| License | Wrapper `ich777/docker-steamcmd-server`: GitHub license null, README states no license (sources in facts file). Game server: UNVERIFIED (Kunos EULA not fetched). Plan license field: UNVERIFIED until checked; do not guess. |
| Source URL | Draft's `https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide` (not fetched). |
| Download | Server files: via SteamCMD at first start (no prebuilt binary we can copy). SteamCMD bootstrap: https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz (HTTP 200). Computed sha256 `cebf0046bfd08cf45da6bc094ae47aa39ebf4155e5ede41373b579b8f1071e7c` (our computation, not a published checksum: UNVERIFIED as official). |
| Checksum source | None published for the game server (Steam verifies its own content with `validate`). SteamCMD bootstrap checksum is UNVERIFIED as official. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile: `FROM ich777/debian-baseimage:bullseye_amd64` (amd64 only, Debian, glibc), lib32 libs, `ENTRYPOINT ["/opt/scripts/start.sh"]`, runs as root unless the script switches, no `EXPOSE`, no `VOLUME`. Draft's chart uses this image, which we do **not** reuse. |
| Upstream env (wrapper) | `DATA_DIR=/serverdata`, `STEAMCMD_DIR`, `SERVER_DIR`, `GAME_ID` (Steam app ID to download), `GAME_NAME`, `GAME_PARAMS`, `GAME_PORT=27015` (example only), `VALIDATE`, `USERNAME`, `PASSWRD`, `UID`, `GID`, `UMASK`, `DATA_PERM`. Confirmed in the Dockerfile and README. None of these are ContainerForge names. |
| Port | UNVERIFIED for the Assetto Corsa server. Draft inferred 9600 tcp/udp and 8081 http; not confirmed. |
| Data write paths | Game files under `/config` (plan) instead of `/serverdata`. |
| ContainerForge sibling | `apps/steamcmd` exists (✅, dependency-free). It is built on `ghcr.io/trueforge-org/ubuntu` and provides `/usr/local/bin/steamcmd`, `/usr/local/share/steamcmd/steamcmd.sh` and `/start.sh`. |

## 2. Target layout

- `apps/assettocorsa/Dockerfile`
- `apps/assettocorsa/docker-bake.hcl`
- `apps/assettocorsa/settings.yaml`
- `apps/assettocorsa/container-test.yaml`
- `apps/assettocorsa/start.sh`

No `defaults/` unless a server config template is shipped (recommended: `defaults/server_cfg.ini` and `defaults/entry_list.ini` only if the paths are confirmed; they are seeded to `/config` only when missing). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Preferred: `FROM ghcr.io/trueforge-org/steamcmd:<tag>@sha256:<digest>` (the image built from `apps/steamcmd`). The digest is **UNVERIFIED** (not published-checked in this run), so the exact string is set when the steamcmd image is built or published. Fallback if steamcmd is not published: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` plus the apt install that `apps/steamcmd/Dockerfile` does (`steamcmd:i386`, multiverse, debconf for the license).

Why: the Assetto Corsa server is a 32/64-bit Steam download launched through SteamCMD, so reusing `apps/steamcmd` avoids duplicating the i386/lib32 setup. The ich777 wrapper image is Debian bullseye and runs as root, so it is not used.

## 4. Dockerfile

1. `ARG VERSION` (set to the steamcmd base version, matching `docker-bake.hcl`), `ARG TARGETARCH`.
2. Platform: **amd64 only**. Skip arm64 (SteamCMD needs x86 binaries). Fail the build when `TARGETARCH` is not `amd64`.
3. If using the ubuntu fallback: `USER root`, `dpkg --add-architecture i386`, the same steamcmd apt steps as `apps/steamcmd/Dockerfile`, then `rm -rf /var/lib/apt/lists/*`.
4. Do not install packages the base already has.
5. `ENV STEAMCMD_DIR=/config/steamcmd SERVER_DIR=/config/serverfiles TZ=Etc/UTC` (names chosen by ContainerForge; they are read by `start.sh`, not by the wrapper).
6. `mkdir -p /config && chown apps:apps /config` (the steamcmd sibling does the same).
7. Final lines:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   VOLUME /config
   WORKDIR /config
   ENTRYPOINT ["/start.sh"]
   ```
   `EXPOSE` only after the ports are confirmed (section 1).
8. Caches and scratch in `/tmp` (SteamCMD `HOME` must stay on `/config` for its login state, so set `HOME=/config` as `apps/steamcmd/start.sh` does, and move temp to `/config/steamcmd/tmp` as that script already does).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "assettocorsa"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource; pin to the steamcmd base version once confirmed
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"
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

`VERSION` and `LICENSE` stay placeholders until verified; do not run `bake --print` as a pass until both are real values. Validate with `docker buildx bake --print` once filled.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://developer.valvesoftware.com/wiki/Dedicated_Server_Guide"
ports:
  []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: GAME_ID
    default: ""
    required: false
  - name: VALIDATE
    default: "false"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - steamcmd
```

- `ports` stays empty until the Assetto Corsa server's ports are verified; then list each with `protocol` and `required`.
- `GAME_ID` (Steam app ID) must be filled in once verified; it is required for the server to download, so `required: true` needs a default or start.sh handling (fail with a clear message when empty).
- Do not add env names the script does not read.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- `export HOME=/config XDG_DATA_HOME=/config`.
- `mkdir -p /config/steamcmd/tmp /config/serverfiles`.
- Call the steamcmd sibling's entry (`/usr/local/bin/steamcmd`) with `+force_install_dir /config/serverfiles +login anonymous +app_update <GAME_ID> validate +quit` (`app_update` syntax is standard SteamCMD; confirm with the steamcmd sibling's script before writing).
- Seed `/config/serverfiles/cfg/server_cfg.ini` and `entry_list.ini` only when missing (paths UNVERIFIED; confirm in the server docs).
- UNVERIFIED / needs human: this app's `start.sh` is copied to `/start.sh` and replaces the steamcmd base's `/start.sh` (which bootstraps `/config/Steam/steamcmd`); `/usr/local/bin/steamcmd` execs `/start.sh`, so the call above would loop into this script. Rename the script or call `/config/Steam/steamcmd/steamcmd.sh` directly.
- `dependencies: [steamcmd]` in settings.yaml is a build base, not a runtime dependency container (draft says none); UNVERIFIED whether it should be listed.
- Do not write to `/app`. Scratch in `/tmp`.
- Final line: `exec` the server binary from `/config/serverfiles` (the binary name and args UNVERIFIED).
- Track and car content must be copied from a licensed Assetto Corsa install by the user (draft caveat, inferred). The script does not fetch them.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /usr/local/bin/steamcmd
- /config
```

- Port probes cannot be written until the server ports are verified. Add one `tcp` (or `udp` if supported) probe per port in `settings.yaml` at that point.
- The game download needs Steam network access and is large; the run check may not be reliable in CI. Record the outcome in the PR and do not weaken assertions to make it pass.
- `timeoutSeconds`: set well above the steamcmd sibling's startup because the first start downloads the server (value to be chosen from the sibling's test; UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

- Upstream wrapper runs as root (`UID=99` env, unused by us). Final stage is `USER apps` (UID 568).
- SteamCMD writes its state under `HOME=/config` (required by SteamCMD), so `/config` must be writable and owned by `apps:apps`.
- Read-only rootfs: binaries under `/usr/local` and `/start.sh` are read-only at runtime. Writable: `/config` and `/tmp`.
- No privileged. Extra persistence beyond `/config` (draft: `/serverdata` PVCs) is replaced by `/config/serverfiles` and `/config/steamcmd`.

## 10. Risks, caveats and open questions

- **Blocker: unverified Steam app ID and ports.** The Valve wiki returned 403. Without the app ID the server cannot be installed. Re-check via `gh api` or another source before implementation.
- **License unknown**: game server EULA and wrapper license both unconfirmed.
- **Large download and Steam availability** at first start; CI may fail for network reasons (classify as infra noise per protocol only if the log shows it).
- **Content licensing**: track/car files come from a licensed install (draft, inferred).
- **amd64 only**: arm64 is not supported (SteamCMD binaries). Say so in the PR.
- **Draft's chart image** (`ghcr.io/ich777/steamcmd:assettocorsa`) is a third-party Debian wrapper. This plan does not copy from it (copy-from stays `no`).
- **Base image**: steamcmd digest UNVERIFIED; ubuntu fallback uses the brief's `26.04` string (siblings use `26.4`, same digest).

## 11. Build and test steps

```sh
cd apps/assettocorsa
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

# Run check (fresh /config volume, read-only rootfs)
docker volume create assettocorsa-probe-config
docker run --rm -d --name assettocorsa-probe --read-only --tmpfs /tmp \
  -e GAME_ID=<verified-app-id> \
  -v assettocorsa-probe-config:/config assettocorsa:<version>
docker logs -f assettocorsa-probe
docker rm -f assettocorsa-probe; docker volume rm assettocorsa-probe-config

# Test suite (mirrors CI)
forgetool containers test --image assettocorsa:<version> --config ./apps/assettocorsa/container-test.yaml
```

- Expected readiness signal: SteamCMD "Success! App ... fully installed" line, then the server's own "ready" line (exact wording UNVERIFIED).
- Not run in this planning step: nothing was built.

## 12. PR checklist

- Branch `feat/add-assettocorsa`, commit `feat(assettocorsa): add new container`, PR title matching.
- PR template at `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept; only tick what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- Say what was not tested: the Steam download, the server run, ports, arm64 (not supported).
- Protocol checks: `docker buildx bake --print` passes; image-local build; empty `/config` start; `container-test.yaml` assertions pass; no assertion weakened; scratch containers and volumes removed.
- No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
