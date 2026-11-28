# minecraft-bedrock — implementation plan
> Source: ./draft.md · Target: apps/minecraft-bedrock/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream image `2026.11.1` (tag, published 2026-11-19, not prerelease). TrueCharts pins the same tag `2026.11.1@sha256:463ea4ac99a3e5b67de0fc590a61cca7ea758520f67d9e4a4512fc3afcc97044`. Source: https://api.github.com/repos/itzg/docker-minecraft-bedrock-server/releases/latest and https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-bedrock/values.yaml |
| The game server | Mojang Bedrock Dedicated Server, a closed-source zip for x86_64. Its version is resolved at runtime from Mojang's download API by `bedrock-entry.sh` (`VERSION=LATEST` default). It is not an upstream GitHub release. Version to pin: UNVERIFIED (no version chosen in this plan; see section 4). |
| Renovate (upstream image) | `datasource=github-releases packageName=itzg/<tool>` for `easy-add`, `entrypoint-demoter`, `set-property`, `mc-monitor`, `mc-server-runner` (https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/Dockerfile). For the Mojang zip itself: UNVERIFIED (no datasource; not defined upstream). |
| License (upstream image repo) | MIT (GitHub API `license.spdx_id`, via gh api). |
| License (game server) | Minecraft EULA, https://www.minecraft.net/en-us/eula. Not an open-source licence. The image must not redistribute the Mojang zip (see section 4). |
| Source URL | https://github.com/itzg/docker-minecraft-bedrock-server (image source). Vendor page: https://www.minecraft.net/en-us/download/server/bedrock |
| Helper release checksums (latest, from GitHub release `checksums.txt` or asset digest) | easy-add 0.8.20; entrypoint-demoter 0.5.4; set-property 0.2.0; mc-monitor 1.21.0; mc-server-runner 1.17.0. Per-arch values: the cited `facts/129.md` does not exist in the repo (UNVERIFIED for arm64); amd64 `set-property` `05166594474b95e349b4b10a1c3944135cdf39b135540e4375d5373f4a327ca2`, `mc-monitor` `1228beab448b3dcd94e7ca2120334283f2a4037f62c607c292d5fbab3f85169c`, `mc-server-runner` `ff0959ea8b37ea80da9c6b80d08be6283eb1b5616d2ee40a45322369ba93d65c`. Source: https://api.github.com/repos/itzg/<tool>/releases/latest |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/Dockerfile: `FROM debian`; `build/install-packages`; `build/setup-arm64` (box64 on arm64, `BOX64_PACKAGE`); `EXPOSE 19132/tcp`, `19132/udp`, `19133/udp`; `VOLUME ["/data"]`; `ENTRYPOINT ["/opt/demoter-entry.sh"]` (runs as root, demotes); `VERSION=LATEST`, `SERVER_PORT=19132`, `SERVER_PORT_V6=19133`, `ENABLE_BDS_V6BIND_FIX=false`; `HEALTHCHECK` via `mc-monitor status-bedrock`; `bds-ipv6fix.so` from GitHub (no checksum). |
| Entry script reviewed | https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/bedrock-entry.sh: `export HOME="${PWD}"`; `DOWNLOAD_DIR` defaults to `${PWD}/.downloads`; download links from `https://net.web.minecraft-services.net/api/v1.0/download/links` with fallback `https://raw.githubusercontent.com/kittizz/bedrock-server-downloads/refs/heads/main/bedrock-server-downloads.json`; `set-property --file server.properties --bulk /etc/bds-property-definitions.json`; final `exec mc-server-runner ... box64 ./"$SERVER"` (box64 only if `/usr/local/bin/box64` exists and `USE_BOX64`) or `exec mc-server-runner ... ./"$SERVER"`. |
| Demoter wrapper | https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/demoter-entry.sh: launches `entrypoint-demoter --match /data --debug ...` as PID 1. Root-only design; not used in this plan (section 9). |
| Ports | TCP 19132 (NetherNet signalling, `SERVER_PORT`); UDP 19132 and 19133 (only for `TRANSPORT=raknet`, `SERVER_PORT` and `SERVER_PORT_V6`) (README https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/README.md). TrueCharts exposes UDP 19132 only and sets `TRANSPORT: raknet` in env (`tc_mcb` values). |
| Env vars (real, read by `bedrock-entry.sh`) | `EULA` (must be TRUE), `VERSION` (LATEST default; or PREVIEW, EXISTING, a specific version), `PREVIEW`, `DIRECT_DOWNLOAD_URL`, `DOWNLOAD_DIR`, `DOWNLOAD_LINKS_URL`, `DOWNLOAD_SECONDARY_LINKS_URL`, `PROCESSED_DOWNLOAD_LINKS_URL`, `USE_MINECRAFT_SERVICES` (true), `USE_BOX64` (true), `DOWNLOAD_PROGRESS` (false), `DEBUG`, `DEBUG_CURL` (false), `ENABLE_BDS_V6BIND_FIX` (false), `ENABLE_SSH` (false), `LEVEL_NAME` ("Bedrock level"), `MC_PACK`, `FORCE_PACK_COPY`, `FORCE_WORLD_COPY`, `RESOLVE_XUID_API_URL`, `ALLOW_LIST`, `ALLOW_LIST_USERS`, `OPS`, `MEMBERS`, `VISITORS`, `WHITE_LIST_USERS`, `SERVER_PORT`, `SERVER_UDP_PORTS`, `REMOTE_CONSOLE_BIND_ADDRESS`, `RCON_PASSWORD`, `PACKAGE_BACKUP_KEEP`, `TMPDIR`, `TMP_ZIP`. Server properties (via `set-property`): `SERVER_NAME`, `GAMEMODE`, `DIFFICULTY`, `LEVEL_TYPE`, `LEVEL_SEED`, `ALLOW_CHEATS`, `MAX_PLAYERS`, `ONLINE_MODE`, `WHITE_LIST`, `TRANSPORT`, `VIEW_DISTANCE`, `TICK_DISTANCE`, `PLAYER_IDLE_TIMEOUT`, `MAX_THREADS`, `DEFAULT_PLAYER_PERMISSION_LEVEL`, `TEXTUREPACK_REQUIRED`, `SERVER_AUTHORITATIVE_MOVEMENT`, `PLAYER_MOVEMENT_*`, `CORRECT_PLAYER_MOVEMENT` (names from TrueCharts values; the bulk definitions file is `property-definitions.json` in the upstream image, not fetched). |
| Helper binaries used by the entry script | `set-property` (line 263), `mc-server-runner` (lines 603-605, always the final `exec`), `box64` (optional, arm64). `entrypoint-demoter` is only used by the demoter wrapper. |
| Data write paths (upstream) | `/data` (the server dir, `server.properties`, worlds, packs, the zip, `/data/.downloads`, `TMPDIR`). Entry script sets `HOME=${PWD}` so `HOME` is the server dir. |
| TrueCharts chart | `persistence.config` at `/data`. Liveness, readiness and startup probes run `mc-monitor status-bedrock --host 127.0.0.1 --port 19132`, period 60 s. `EULA: true`, `ALLOW_CHEATS: false`, `TRANSPORT: raknet`, `ONLINE_MODE: true`. No securityContext override. |
| arm64 | Mojang's binary is x86_64 only. Upstream runs it on arm64 through box64 (apt package `box64`, `setup-arm64` in upstream Dockerfile). Feasibility on ubuntu 26.04 apt is UNVERIFIED. |
| Dependencies | None (no database). |

## 2. Target layout

- `apps/minecraft-bedrock/Dockerfile`
- `apps/minecraft-bedrock/docker-bake.hcl`
- `apps/minecraft-bedrock/settings.yaml`
- `apps/minecraft-bedrock/container-test.yaml`
- `apps/minecraft-bedrock/start.sh`

No `defaults/` (the entry script writes its own `server.properties`). No `etc/` unless a property-definitions file is copied in (section 4, step 4). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The upstream image is `debian`; ContainerForge uses ubuntu. Ubuntu is the final stage and the build stage, because no runtime above ubuntu is needed (no python, java or node).
- Closest sibling: a single-binary server app on ubuntu (`apps/adguardhome-sync`: release tarball, `chown -R apps:apps`, `USER apps`, `COPY --chmod=0755 . /`), plus `apps/valkey` for a pinned apt package if box64 is later added.

## 4. Dockerfile

1. `ARG VERSION` (= bake `VERSION`, the image-recipe tag `2026.11.1`, not the Mojang version; the Mojang version is the runtime `ENV VERSION=LATEST`, section 10), `ARG TARGETARCH`, plus the pinned helper versions and sha256 values:
   - `ARG EASY_ADD_VERSION=0.8.20` is NOT needed: download the helper tarballs directly from their GitHub release with `curl`, and check each against its `checksums.txt`. This avoids `easy-add` in the image.
   - `ARG SET_PROPERTY_VERSION=0.2.0` and `MC_SERVER_RUNNER_VERSION=1.17.0`, `MC_MONITOR_VERSION=1.21.0` with the amd64 sha256 values from section 1 (arm64 values: UNVERIFIED, re-read from the release assets; the cited `facts/129.md` does not exist in the repo).
2. `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb...`.
3. `USER root`. Install only what the base lacks (check first): `bash`, `curl`, `unzip` and `ca-certificates` are expected in the base (UNVERIFIED: check with `which unzip jq`). The entry script uses `jq` (for the links lookup and XUID resolution; UNVERIFIED that the base ships `jq`). If missing, `apt-get install -y --no-install-recommends jq unzip` and `rm -rf /var/lib/apt/lists/*`.
4. Helpers (amd64 only for the first PR, section 10):

```dockerfile
RUN set -eux; \
    curl -fL -o /tmp/set-property.tgz "https://github.com/itzg/set-property/releases/download/${SET_PROPERTY_VERSION}/set-property_${SET_PROPERTY_VERSION}_linux_amd64.tar.gz"; \
    echo "${SET_PROPERTY_SHA256}  /tmp/set-property.tgz" | sha256sum -c -; \
    tar -xzf /tmp/set-property.tgz -C /usr/local/bin set-property; \
    rm -f /tmp/set-property.tgz
```

   Repeat for `mc-server-runner` (`/usr/local/bin/mc-server-runner`, checksum from `mc-server-runner_${VER}_checksums.txt`) and `mc-monitor` (for the healthcheck, if used). Do not add `entrypoint-demoter`: it is root-only (section 9).

5. Entry scripts: `COPY bedrock-entry.sh /opt/bedrock-entry.sh` (upstream layout) and `COPY property-definitions.json /etc/bds-property-definitions.json` are NOT possible from the draft folder. Fetch both from upstream at a pinned commit in the same `RUN` with sha256 checks, or vendor them into `apps/minecraft-bedrock/` (it is an MIT script; copy with its licence notice). Decision in section 10; the plan's default is to vendor `bedrock-entry.sh` and `property-definitions.json` into `apps/minecraft-bedrock/etc/` (allowed by `.dockerignore` as `etc/`), with the MIT notice in `/usr/share/licenses/minecraft-bedrock/`. Note: `include/.dockerignore` is an allow-list (`start.sh`, `etc/`, `usr/`, `defaults/`, `scripts/` ...), not arbitrary top-level files. Files in `etc/` land under `/etc/`, so the entry script is installed at `/etc/bedrock-entry.sh` (not `/opt`) and made executable by `COPY --chmod=0755 . /`.
6. Licence: `/usr/share/licenses/minecraft-bedrock/LICENSE` (MIT of the upstream image repo; https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/master/LICENSE, UNVERIFIED the URL path, check on the build). The Mojang EULA is not shipped; the user accepts it at runtime with `EULA=TRUE`.
7. Ownership and runtime dirs: `mkdir -p /config`, `chown -R apps:apps /config` is NOT done in the image (the `/config` volume is created by Docker; `start.sh` makes the subdirectories). Make `/opt` read-only for the apps user: `chmod -R 755 /opt`.
8. ENV: `HOME=/config`, `SERVER_PORT=19132`, `SERVER_PORT_V6=19133`, `ENABLE_BDS_V6BIND_FIX=false`, `USE_BOX64=false` (amd64 only), `DOWNLOAD_DIR=/tmp/bedrock-downloads`, `TMPDIR=/tmp`, `VERSION=LATEST`, `EULA=` (empty, must be set by the user), `TZ=Etc/UTC`.
9. `EXPOSE 19132/tcp`, `EXPOSE 19132/udp`, `EXPOSE 19133/udp`, `VOLUME /config`, `WORKDIR /config`.
10. Tail: `USER apps`, `COPY --chmod=0755 . /`.

Pin the Mojang version: decision in section 10. The Dockerfile does not download the Mojang zip at build time (the default below), so no Mojang binary is in the image.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "minecraft-bedrock"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=itzg/docker-minecraft-bedrock-server versioning=loose
  default = "2026.11.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/itzg/docker-minecraft-bedrock-server"
}
```

Note the `VERSION` here is the image-recipe version (the upstream tag this app is ported from), not the Mojang server version. `LICENSE` is the licence of the software in the image: the MIT licence of the scripts and helpers. The Mojang server is not in the image (EULA at runtime). Four standard targets and default group as in `apps/adguardhome-sync/docker-bake.hcl`. Validate with `cd apps/minecraft-bedrock && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/itzg/docker-minecraft-bedrock-server"
ports:
  - port: 19132
    protocol: udp
    required: true
  - port: 19132
    protocol: tcp
    required: false
  - port: 19133
    protocol: udp
    required: false
env:
  - name: EULA
    default: ""
    required: true
  - name: VERSION
    default: "LATEST"
    required: false
  - name: SERVER_NAME
    default: "Bedrock Dedicated Server"
    required: false
  - name: SERVER_PORT
    default: "19132"
    required: false
  - name: SERVER_PORT_V6
    default: "19133"
    required: false
  - name: TRANSPORT
    default: "raknet"
    required: false
  - name: LEVEL_NAME
    default: "Bedrock level"
    required: false
  - name: ENABLE_BDS_V6BIND_FIX
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `EULA` is `required: true` with an empty default: the rule says a required var needs a non-empty default OR start.sh handles it. `start.sh` exits with a clear message when `EULA` is not `TRUE`, so the handling is in `start.sh` (section 7). Confirm the schema accepts an empty default; if not, use `required: false` and keep the `start.sh` check (open question, section 10).
- `SERVER_NAME`, `SERVER_PORT`, `TRANSPORT`, `LEVEL_NAME` are set through `set-property` by the entry script (names from TrueCharts values). Keep the list to these plus those `start.sh` or the entry script reads; add the rest of the server-property variables only if the bake and the schema allow many entries (decision, section 10).
- TCP 19132 is `required: false` because the chart uses raknet (UDP). 19133/udp is `required: false` (IPv6 only).

## 7. start.sh

```bash
#!/usr/bin/env bash

if [[ "${EULA:-}" != "TRUE" ]]; then
  echo "EULA must be set to TRUE to run the Minecraft Bedrock server (https://www.minecraft.net/en-us/eula)." >&2
  exit 1
fi

# Server files live under /config (persistent). Downloads and scratch go to /tmp.
mkdir -p /config/bedrock /tmp/bedrock-downloads
cd /config/bedrock

export HOME=/config/bedrock
export DOWNLOAD_DIR=/tmp/bedrock-downloads
export TMPDIR=/tmp

exec /etc/bedrock-entry.sh
```

- Refuses to start without `EULA=TRUE` (clear message, non-zero exit). This is the required-env handling the rules ask for, and the test cannot run without it (section 8).
- Idempotent: the entry script keeps the existing server and `server.properties` between starts (upstream behaviour; confirm). `mkdir -p` only otherwise.
- Never writes to `/opt` or `/usr`; the server dir is `/config/bedrock`; downloads and scratch are `/tmp`.
- `exec` hands PID 1 to the entry script, which `exec`s `mc-server-runner` (upstream), which runs the server. Signals reach the server through `mc-server-runner` (upstream design).
- Upstream's `demoter-entry.sh` (root only) is not used. Graceful stop is therefore the `mc-server-runner` default (UNVERIFIED for the save-on-stop behaviour; check on the first stop).
- The entry script's `UID`/`GID` handling from `/data` ownership (README) is not reproduced: the server runs as `apps` (568).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /etc/bedrock-entry.sh
- /usr/local/bin/mc-server-runner
- /usr/local/bin/set-property
- /usr/share/licenses/minecraft-bedrock/LICENSE
```

- The test runs with no env, so `EULA` is empty and the container exits at the EULA check in `start.sh`. That is correct behaviour, but it means the default test can only check files. The rule "tcp/http probes for every port" cannot pass without `EULA=TRUE`, and the test cannot set env. Resolution (decision): check the forgetool schema for an env or `runners` option in `container-test.yaml` (UNVERIFIED that one exists); if it supports env, add `EULA=TRUE` and the UDP probe. If it does not, the test is limited to files and the PR must say so. Do not drop the EULA check to make the test pass.
- UDP 19132 cannot be probed by `tcp`; forgetool's UDP support is UNVERIFIED. Do not invent a TCP probe on a UDP port.
- The mc-monitor healthcheck (chart and upstream) needs a running server. Not used in the file-only test.
- `timeoutSeconds: 120` is a guess; the Mojang download can take longer than that on the first real start (section 10).
- Adding the `tcp` probe on 19132 would test TCP, which the server does not open for raknet (the chart sets raknet). If `TRANSPORT=raknet`, TCP 19132 is not open; the `required: false` entry for TCP is not probed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | ContainerForge change |
| --- | --- |
| Entrypoint `demoter-entry.sh` runs as root and demotes to the `/data` owner (`--match /data`) | Not used. The image starts as `apps` (568). The demoter's `--match /data` is replaced by a `/config` path, if needed. Its absence means no UID/GID remap (UID/GID via `/data` owner, README, is not reproduced). |
| `UID`/`GID` derived from `/data` owner | Not reproduced. Fixed UID 568. |
| `/data` (server dir, worlds, packs, downloads) | `/config/bedrock` (persistent). The Docker `VOLUME /config` is the only volume. Chart persistence `/data` maps to `/config` in ContainerForge. |
| `DOWNLOAD_DIR=${PWD}/.downloads` (default, in `/data`) | `DOWNLOAD_DIR=/tmp/bedrock-downloads`. Caveat: the server zip is downloaded again at each start (section 10). |
| `TMPDIR` default | `/tmp`. |
| `HOME=${PWD}` (entry script) | Same behaviour, set to `/config/bedrock` by `start.sh`. Fine for read-only rootfs. |
| box64 on arm64 (apt) | Out of scope for the first PR (amd64 only). |
| `ENABLE_SSH` (2222) | Not included. No SSH server in the image. |
| `ENABLE_BDS_V6BIND_FIX` `.so` from GitHub (no checksum) | Not included; default `false`. If added later, pin and checksum it. |
| `/etc/image.properties` written at build time (upstream) | Not reproduced (no build metadata needed). |
| Healthcheck `mc-monitor` | Not in the image by default; add only if the schema and chart need it (open question). |

Security expectations (draft: non-root possible, read-only compatible, `privileged` false): the rootless variant is read-only compatible (all writes in `/config` or `/tmp`). The draft's "non-root: possible" is now a fact for this plan.

## 10. Risks, caveats and open questions

- Mojang zip, not in the image: the plan downloads it at runtime into `/config/bedrock`, the same as upstream, so the image carries no Mojang binary. Consequence: the first start needs internet access to `minecraft-services.net`, and the `container-test` run needs the same access (UNVERIFIED that the test runner has it). The URL can change; upstream falls back to a third-party JSON (kittizz/bedrock-server-downloads) and the lookup is not checksum-verified upstream.
- Version pinning vs LATEST: `VERSION=LATEST` (chart default) upgrades the server on each start, as upstream does. That matches the chart. Pinning a specific Bedrock version would need a manual bump. Decision: keep `LATEST` (chart parity) and record in the PR that the server version is not pinned.
- `bedrock-entry.sh` and `property-definitions.json` source: they are not in the draft folder. Two options: vendor them into `apps/minecraft-bedrock/etc/` with the MIT notice (default in section 4), or fetch from the upstream tag with sha256. Vendoring makes the build reproducible; the plan chooses it. The files must come from the same upstream tag as `VERSION` (2026.11.1), not `master` (`master` was fetched in this run, so the tag must be re-fetched).
- Helper checksums: sha256 values are from the GitHub release assets (`checksums.txt` / asset digest). The plan pins each helper version and checks it at build time.
- EULA: a required env with no default. The `start.sh` check handles it. The schema may reject an empty default for a `required: true` env (open question, section 6).
- Test coverage: the default container test runs with no env, so it cannot reach the server start. Without env support in `container-test.yaml` (UNVERIFIED), the PR can only prove files and the EULA refusal. The run step (section 11) with `EULA=TRUE` is the real proof and must be recorded in the PR.
- UDP 19132 probe: forgetool may not support UDP. Say so in the PR.
- arm64: upstream uses box64 (apt). Feasibility on ubuntu 26.04 apt is UNVERIFIED. The first PR is amd64 only (`image-all` must not be used until arm64 is tested). The draft's "arm64 no" holds for the native Mojang binary; emulation is possible later.
- The draft's `/config` path for the server data is correct for ContainerForge. The chart's `/data` is a chart detail.
- The draft's Mojang "amd64 only" statement is consistent with upstream (`box64` exists for arm64), so no contradiction. The draft's `arm64 no` should read "no (native); emulated via box64 upstream, not in this PR".
- Caveats kept from the draft: EULA acceptance (licensing), network needed on first start, runtime download URL can change.
- The draft listed "unzip (inferred)" and "box64 (arm64 only, explicit)". unzip is needed only if the zip is unpacked by hand; the entry script unzips it (UNVERIFIED which tool it uses; check `unzip` or `python`/`jq`). box64 is deferred.
- Dependencies: none.

## 11. Build and test steps

```sh
cd apps/minecraft-bedrock
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

# 1. Refusal without EULA (expected: exit 1 with the EULA message)
docker run --rm --name mcb-noeula --read-only --tmpfs /tmp \
  -v mcb-probe-config:/config minecraft-bedrock:2026.11.1
docker volume rm mcb-probe-config

# 2. Real start with EULA on an empty /config (needs internet for the Mojang zip)
docker volume create mcb-probe-config
docker run --rm -d --name mcb-probe --read-only --tmpfs /tmp \
  -e EULA=TRUE -v mcb-probe-config:/config minecraft-bedrock:2026.11.1
docker logs -f mcb-probe          # wait for "Starting Bedrock server..." and the server's "Server started." line
docker exec mcb-probe ss -lun     # UDP 19132 and 19133 (if TRANSPORT=raknet)
docker rm -f mcb-probe; docker volume rm mcb-probe-config

forgetool containers test \
  --image minecraft-bedrock:2026.11.1 \
  --config ./apps/minecraft-bedrock/container-test.yaml
```

- Expected readiness signal: the entry script logs the download and version, `mc-server-runner` starts the server, the server logs that it has started and is listening on UDP 19132. The exact line is UNVERIFIED; record it from the first run.
- Also run a second start on the same `/config` volume to confirm `server.properties` and the world persist and are not overwritten.
- Stop test: `docker stop` the probe and confirm the server saves (look for the save log line; UNVERIFIED for this image without the demoter).
- arm64: not built in this PR.
- If `ss` is missing in the base, check the port with a UDP probe from another container or by the log line.

## 12. PR checklist

- Branch `feat/add-minecraft-bedrock` from `main`; commit `feat(minecraft-bedrock): add new container`; PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user the CLA is required before merge: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Say the Mojang server is downloaded at runtime under the Minecraft EULA; the image does not contain it.
- State what is not tested: arm64 and box64, the UDP probe (if forgetool lacks it), the server version floating on `LATEST`, the TCP 19132 listener (raknet), a real player connection, and any test that needed `EULA=TRUE` if the container-test schema has no env option.
- Confirm `docker buildx bake --print` ran and passed before pushing.
