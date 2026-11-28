# makemkv — implementation plan
> Source: ./draft.md · Target: apps/makemkv/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version (upstream container) | `v26.09.2`, published 2026-09-23, not prerelease. Source: https://api.github.com/repos/jlesage/docker-makemkv/releases/latest |
| Draft tag | `ghcr.io/jlesage/makemkv:v26.09.2` (matches the GitHub release tag). GHCR manifest not fetched: UNVERIFIED |
| MakeMKV version | `MAKEMKV_VERSION` default `2.0.0` in upstream Dockerfile at tag `v26.09.2`: https://raw.githubusercontent.com/jlesage/docker-makemkv/v26.09.2/Dockerfile |
| Renovate | Container: `datasource=github-releases depName=jlesage/docker-makemkv` (reference only). MakeMKV `VERSION`: no renovate datasource found on the vendor site, so the annotation is UNVERIFIED (see section 10) |
| License | makemkv-oss license: UNVERIFIED (not shown on fetched pages). makemkv-bin is closed-source vendor freeware: UNVERIFIED SPDX |
| Source / docs | https://www.makemkv.com/ · forum https://forum.makemkv.com/forum/ |
| Vendor tarballs | `https://www.makemkv.com/download/makemkv-bin-2.0.0.tar.gz` (HTTP 200, 18926130 bytes) and `https://www.makemkv.com/download/makemkv-oss-2.0.0.tar.gz` (HTTP 200, 6639445 bytes), both confirmed by fetch |
| Checksums | `https://www.makemkv.com/download/makemkv-sha-2.0.0.txt` (PGP-signed SHA256 list): `f1265e74875a186efdfbbbec7459a64e969033515e53cbc4d805f0a374f0a124  makemkv-bin-2.0.0.tar.gz`, `435316b2d219eb48c880526557addd076b5f5e6de5171424c7651f9cac95b161  makemkv-oss-2.0.0.tar.gz` |
| Linux download location | Linux tarballs are not on the download page (it lists only Windows and macOS 2.0.0). They are linked from the forum thread https://forum.makemkv.com/forum/viewtopic.php?f=3&t=224 |
| Upstream Dockerfile | `FROM jlesage/baseimage-gui:alpine-3.19-v4.14.0`. Stage `makemkv-bin` on `debian:12` builds libs for the closed-source binary (xx-verify: `makemkvcon`, `libmakemkv.so.1`, `libdriveio.so.0`, `libmmbd.so.0`). Stage `makemkv-oss` on `alpine:3.19` builds `makemkv`, `mmccextr`, `mmgplsrv` (musl). Final stage copies both into `/opt/makemkv` |
| Upstream build logic | `/build/build.sh` receives the two tarball URLs. Not fetched: UNVERIFIED (build steps, checksum handling) |
| Upstream packages (apk) | openjdk8-jre-base, wget, sed, findutils, xdpyinfo, lsscsi, util-linux-misc, sg3_utils, qt5-qtbase-x11, adwaita-qt, font-croscore |
| Upstream volumes | `/storage`, `/output`. `WORKDIR /tmp`. No `EXPOSE`, no `USER`, no ENTRYPOINT/CMD in the file (from base image) |
| Upstream env | `MAKEMKV_KEY=BETA`, `MAKEMKV_GUI=1`, `AUTO_DISC_RIPPER=0`, `AUTO_DISC_RIPPER_MAKEMKV_PROFILE` (empty), `AUTO_DISC_RIPPER_EJECT=0`, `AUTO_DISC_RIPPER_PARALLEL_RIP=0`, `AUTO_DISC_RIPPER_INTERVAL=5`, `AUTO_DISC_RIPPER_MIN_TITLE_LENGTH` (empty), `AUTO_DISC_RIPPER_BD_MODE=mkv`, `AUTO_DISC_RIPPER_DVD_MODE=mkv`, `AUTO_DISC_RIPPER_FORCE_UNIQUE_OUTPUT_DIR=0`, `AUTO_DISC_RIPPER_NO_GUI_PROGRESS=0` |
| Ports | Not in upstream Dockerfile. Draft says 5800/http (noVNC) and 5900/tcp (VNC), both `(inferred)`. Base-image port values: UNVERIFIED |
| arm64 | Upstream cross-builds with `xx` and `TARGETPLATFORM`, with no explicit arch branch. Whether the vendor `makemkv-bin` tarball runs on arm64: UNVERIFIED |
| Copy-from images | Upstream image is Alpine (musl) for the OSS part, so `COPY --from` is not usable on glibc Ubuntu (draft value `no` confirmed in spirit) |

## 2. Target layout

- `apps/makemkv/Dockerfile`
- `apps/makemkv/docker-bake.hcl`
- `apps/makemkv/settings.yaml`
- `apps/makemkv/start.sh`
- `apps/makemkv/container-test.yaml`
- `apps/makemkv/defaults/` only if a default MakeMKV settings file is seeded into `/config` (reason: first-run config); decide after reading upstream `/build/build.sh` (UNVERIFIED)
- Not used: `root/` (never used by plans), `etc/`, `health/` (add only if a probe is needed beyond tcp/http), `DOWNSTREAM_CHANGES.md` (not a `FROM` base)

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, for the build stage and the final stage.

Why it fits: the draft's runtime needs are a desktop GUI over VNC, which the upstream jlesage Alpine base provides but ContainerForge does not. The draft intends ubuntu alone, which is the ContainerForge default for generic userland. Closest sibling for a GUI/VNC app: `apps/kasmvnc` (ubuntu-based runtime with Xvnc and nginx, from `python-node` plus `ubuntu` build stages).

Note: the upstream jlesage base (`baseimage-gui`) is not used. Its s6 services, noVNC and VNC wiring must be reproduced or replaced, which is the main reason for the hard rating.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS makemkv-build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `ARG VERSION` must equal the `VERSION` default in `docker-bake.hcl` (`2.0.0`).
3. Download both vendor tarballs from the pinned URLs and verify them against the SHA256 values in `makemkv-sha-${VERSION}.txt`:
   ```dockerfile
   RUN curl -fsSL -o /tmp/makemkv-bin.tar.gz "https://www.makemkv.com/download/makemkv-bin-${VERSION}.tar.gz" && \
       curl -fsSL -o /tmp/makemkv-oss.tar.gz "https://www.makemkv.com/download/makemkv-oss-${VERSION}.tar.gz" && \
       curl -fsSL -o /tmp/makemkv-sha.txt "https://www.makemkv.com/download/makemkv-sha-${VERSION}.txt" && \
       cd /tmp && grep -E 'makemkv-(bin|oss)-' makemkv-sha.txt | sha256sum -c -
   ```
   The `sha256sum -c` line must read the two hashes from the signed file. The PGP signature is not verified in the image; state this in the PR as a known gap.
4. Build the OSS part on ubuntu, not alpine. The upstream OSS build is musl (alpine:3.19), so its binaries will not run on glibc ubuntu. Build with `build-essential` plus the libraries the OSS build needs (draft lists `libssl-dev`, `libexpat1-dev` as inferred; confirm against `/build/build.sh`, UNVERIFIED).
5. Install the vendor binary parts (`makemkv-bin`) into `/opt/makemkv`. Its glibc libraries were built on debian:12; running them on ubuntu 26.04 is UNVERIFIED and must be tested in section 11.
6. GUI runtime packages from apt, only those not already in the base: qt5 or qt6 X11 libs (upstream uses `qt5-qtbase-x11`, Qt5 availability on ubuntu 26.04 is UNVERIFIED), `xdpyinfo`, `lsscsi`, `sg3-utils`, `fonts-croscore`-equivalent (UNVERIFIED package name). Pin nothing from apt that is not version-aligned with `VERSION`; the apt packages are the toolchain/runtime and do not carry the app version.
7. Final stage `FROM <ubuntu>`, `USER root` for installs, then install licenses: `/usr/share/licenses/makemkv/` (makemkv-bin EULA and makemkv-oss license, both from the tarballs).
8. `ENV HOME=/config MAKEMKV_KEY=BETA MAKEMKV_GUI=1` (keep only the variables start.sh and the app really read; see section 6). Caches to `/tmp`: `ENV XDG_CACHE_HOME=/tmp/.cache`.
9. `chown -R apps:apps /opt/makemkv && chmod -R 755 /opt/makemkv` (same pattern as `apps/adguardhome-sync`).
10. Tail:
    ```dockerfile
    USER apps
    COPY --chmod=0755 . /

    EXPOSE 5800 5900
    VOLUME /config
    VOLUME /storage
    VOLUME /output
    ```
    (`/storage` and `/output` are the upstream volumes; keep them as the chart paths.)

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "makemkv"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jlesage/docker-makemkv versioning=loose
  default = "2.0.0"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://www.makemkv.com/"
}
```

Renovate note: the annotation above tracks the upstream container repo, but `VERSION` is the MakeMKV version, not the container tag. Renovate cannot read the vendor version from the vendor site (only Windows/macOS 2.0.0 is on the download page). Keep the annotation pointing at `jlesage/docker-makemkv` only as a version hint, or mark the bump as manual. UNVERIFIED: choose one (section 10).

`LICENSE` stays `UNVERIFIED` until the makemkv licence is confirmed; do not publish an SPDX that is not confirmed.

Targets: copy the four standard targets and the default group from `apps/adguardhome-sync/docker-bake.hcl` (`image`, `image-local`, `image-all`, `group "default"`), with `image-local` tagged `${APP}:${VERSION}`. Validate with `cd apps/makemkv && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.makemkv.com/"
ports:
  - port: 5800
    protocol: tcp
    required: false
  - port: 5900
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: MAKEMKV_KEY
    default: "BETA"
    required: false
volumes:
  - path: /config
    required: true
  - path: /storage
    required: false
  - path: /output
    required: false
dependencies: []
```

Rules applied:
- Ports 5800 and 5900 are `(inferred)` from the draft, not from a fetched page. Each must be confirmed in the built image (section 11) before the settings are final; drop any port the image does not open.
- Env: only variables start.sh really reads. `MAKEMKV_KEY=BETA` comes from the upstream Dockerfile and is a fact. The `AUTO_DISC_RIPPER_*` variables are read by upstream base-image scripts, not by the app; do not list them unless the port implements them (decide in section 7). Do not invent env vars.
- `MAKEMKV_KEY`: a value of `BETA` is a fact of upstream; the expiry of beta keys is a caveat (section 10), not something the chart decides.
- Volumes: `/config` persistent; `/storage` and `/output` mounted by the user for rip input and output.
- No dependencies.

## 7. start.sh

Plan (must be checked against the upstream GUI launch, which is not fetched: UNVERIFIED):

```bash
#!/usr/bin/env bash

mkdir -p /config/.MakeMKV /storage /output 2>/dev/null || true
# MakeMKV keeps its settings in ~/.MakeMKV; point HOME at /config so it persists
export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache

# Seed the beta key only when no settings exist yet (idempotent)
if [ ! -f /config/.MakeMKV/settings.conf ]; then
  : # write defaults here only after UNVERIFIED key format is confirmed
fi

exec /opt/makemkv/bin/makemkv "$@"
```

Notes:
- The exact launch command for the GUI and any VNC/noVNC wrapper is UNVERIFIED. The upstream jlesage base supplies s6 services; ContainerForge has no equivalent, so a VNC stack (Xvnc plus a websocket proxy, as in `apps/kasmvnc`) must be added, or the image is dropped as "not feasible" (section 10).
- `exec` the final process so signals reach it.
- Never write under `/opt/makemkv` or `/app`. Settings and caches go under `/config` and `/tmp`.
- Seed nothing on an empty `/config` unless the settings file format is confirmed.
- Bind VNC and noVNC to `0.0.0.0`, as required by the start-script rules.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5900'
http:
- port: '5800'
  path: /
filePaths:
- /opt/makemkv/bin/makemkv
- /opt/makemkv/lib/libmakemkv.so.1
- /usr/share/licenses/makemkv
```

Rules:
- Every port in `settings.yaml` has a probe (5800 http, 5900 tcp). Drop a probe only if the port is dropped from settings.
- Paths are the planned install locations and must be confirmed by building the image (UNVERIFIED for `bin/` layout).
- The test runs with no env vars and no optical drive. Add no drive-dependent path to `filePaths`; ripping is not tested in CI.
- `timeoutSeconds: 120` is a starting value; adjust to the GUI startup time measured in section 11 (no sibling GUI app timeout checked).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `HOME` / MakeMKV settings (`~/.MakeMKV`) | `HOME=/config` (persistent) |
| Caches (`XDG_CACHE_HOME`, X11 and Qt caches) | `/tmp` |
| Rip output `/output` and input `/storage` | user-mounted volumes, unchanged paths |
| `WORKDIR /tmp` (upstream) | keep `/tmp` as work dir |
| Xvnc / X11 socket (`/tmp/.X11-unix`) | `/tmp` (tmpfs under `--read-only --tmpfs /tmp`) |

Security expectations reconciled with the draft (expectations, not guarantees):
- Chart runs as UID 0 with `runAsNonRoot: false`. This image runs as `apps` (ContainerForge rule: `USER apps` at the end). Ripping needs device access, so the non-root user needs the disc group or a device mount; the chart shows no device mount (draft caveat, inferred). Verify before claiming rootless works.
- `readOnlyRootFilesystem: false` in chart: plan targets `--read-only --tmpfs /tmp` compatibility; the GUI stack must be checked for writes outside `/tmp` and `/config`.
- Not privileged in chart. Capabilities `NET_BIND_SERVICE` and `KILL` in the chart are not needed when ports are above 1024 (5800, 5900); do not add them.
- Extra persistence: draft's `/storage` and `/output` map to the ContainerForge volumes listed in section 6.

## 10. Risks, caveats and open questions

- Hard difficulty: GUI over VNC needs a full X stack on ubuntu. Upstream's jlesage base does not exist in ContainerForge, so this is a rebuild, not a port.
- OSS binaries are musl (alpine:3.19) upstream. Rebuild on glibc ubuntu (section 4 step 4). Without this, `COPY --from` is impossible (draft `copy-from: no` is correct).
- Optical drive: ripping needs the drive as a device (`/dev/sr*`) passed in. Chart values show none (inferred caveat). Non-privileged operation may not reach the drive; a privileged or device-mount setting may be required. Blocker until confirmed.
- MakeMKV beta key (`MAKEMKV_KEY=BETA`): keys expire and need renewal in the UI. Caveat only.
- arm64: the vendor `makemkv-bin` architecture is UNVERIFIED. If it is x86-only, arm64 is a blocker: mark `image-all` as amd64 only.
- Vendor download reliance: builds depend on makemkv.com being reachable; no mirror known.
- Checksum: the SHA256 list is PGP-signed, but the signature is not verified in the Dockerfile plan.
- Renovate: `VERSION` (MakeMKV 2.0.0) has no clean automated source; a bump is manual unless a source is found (UNVERIFIED).
- Ports 5800/5900 are inferred, not confirmed (section 6).
- Licence unknown (section 5).
- Upstream `/build/build.sh` not read: all build-step details above marked UNVERIFIED must be checked against it before the Dockerfile is written.

## 11. Build and test steps

```sh
cd apps/makemkv
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name makemkv-probe --read-only --tmpfs /tmp \
  -v makemkv-probe-config:/config makemkv:2.0.0
docker logs -f makemkv-probe
forgetool containers test --image makemkv:2.0.0 --config ./apps/makemkv/container-test.yaml
docker rm -f makemkv-probe; docker volume rm makemkv-probe-config
```

- Expected readiness signal: the VNC/noVNC server logs its listen line and the MakeMKV process stays running. The exact string is UNVERIFIED until the image runs.
- Empty `/config` must start cleanly (protocol rule).
- Do not test ripping in CI. Verify manually with a drive, if available, after the image passes.
- arm64: build only if the amd64 build passes and the vendor binary is confirmed for arm64.

## 12. PR checklist

- Branch `feat/add-makemkv`, commit and PR title `feat(makemkv): add new container`, target `main`.
- Commit message ends per repo rules; PR body fills `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and checks only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Tell the user; only the user can sign it. Check the `license/cla` status.
- State what was not tested: ripping with a real optical drive, arm64, the GUI on `--read-only` if not run, the vendor checksum signature, and the ports if not confirmed.
- `docker buildx bake --print` passes; `VERSION` in bake equals `ARG VERSION` in the Dockerfile; no assertion weakened.
