# mediainfo — implementation plan
> Source: ./draft.md · Target: apps/mediainfo/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version (upstream container) | `v26.10.1`, published 2026-10-09, not prerelease. Source: https://api.github.com/repos/jlesage/docker-mediainfo/releases/latest |
| Draft tag | `ghcr.io/jlesage/mediainfo:v26.10.1` (matches the GitHub release tag). GHCR manifest not fetched: UNVERIFIED |
| MediaInfo version | `MEDIAINFO_VERSION=26.10` in upstream Dockerfile at tag `v26.10.1`: https://raw.githubusercontent.com/jlesage/docker-mediainfo/v26.10.1/Dockerfile |
| Library versions | `MEDIAINFOLIB_VERSION=26.10` (https://github.com/MediaArea/MediaInfoLib/archive/refs/tags/v26.10.tar.gz); `ZENLIB_VERSION=0.4.41` (https://github.com/MediaArea/ZenLib/archive/refs/tags/v0.4.41.tar.gz) |
| Source tarball | `https://github.com/MediaArea/MediaInfo/archive/refs/tags/v26.10.tar.gz` (upstream container build) |
| Renovate | `datasource=github-releases depName=MediaArea/MediaInfo` for `VERSION` (reference: upstream tags are `vX.Y`, so `versioning=loose`) |
| License | UNVERIFIED: not fetched in this run |
| Source / docs / site | https://github.com/MediaArea/MediaInfo · https://mediaarea.net/en/MediaInfo/Support · https://mediaarea.net/en/MediaInfo |
| Checksums | None in the upstream Dockerfile. Download logic lives in `/build/build.sh` (not fetched): UNVERIFIED |
| Upstream Dockerfile | `FROM jlesage/baseimage-gui:alpine-3.20-v4.14.0`. Stage `xx` = `tonistiigi/xx`. Stage `mediainfo` on `alpine:3.20` runs `/build/build.sh` with the three source URLs, then `xx-verify` on `mediainfo`, `mediainfo-gui`, `libmediainfo.so`, `libzen.so`. Final stage copies `/usr/bin` and `/usr/lib` from that stage |
| Upstream packages (apk) | tinyxml2, qt6-qtbase-x11, qt6-qtsvg, adwaita-qt, mesa-gl, font-roboto-mono |
| Upstream volumes | `VOLUME ["/storage"]`. No `EXPOSE`, no `USER`, no `ENV` (only `set-cont-env`: `APP_NAME=MediaInfo`, `APP_VERSION`, `DOCKER_IMAGE_VERSION`) |
| Ports | Not in upstream Dockerfile. Draft says 5800/http (noVNC) and 5900/tcp (VNC), both `(inferred)` |
| arm64 | Build runs on `$BUILDPLATFORM` and cross-targets `TARGETPLATFORM` via `xx`. Upstream comment says `mesa-gl` is not pulled automatically on some arches (arm64), so it is installed explicitly |
| apt package | Draft's `apt:mediainfo-gui`: not used upstream (upstream compiles from source). Availability of `mediainfo-gui` on ubuntu 26.04: UNVERIFIED |

## 2. Target layout

- `apps/mediainfo/Dockerfile`
- `apps/mediainfo/docker-bake.hcl`
- `apps/mediainfo/settings.yaml`
- `apps/mediainfo/start.sh`
- `apps/mediainfo/container-test.yaml`
- `apps/mediainfo/defaults/` only if a default config is seeded into `/config` (reason: first-run config). Decide after the GUI launch is confirmed (UNVERIFIED)
- Not used: `root/`, `etc/`, `health/` (add only if a probe is needed beyond tcp/http), `DOWNSTREAM_CHANGES.md` (not a `FROM` base)

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the build stage and the final stage.

Why it fits: the upstream image is a jlesage Alpine GUI base over VNC. ContainerForge has no GUI base, so the GUI stack (Qt plus a VNC server and web proxy) is built on ubuntu. Closest sibling for a GUI/VNC app on ubuntu: `apps/kasmvnc`. For a compiled-from-source build stage: `apps/adguardhome-sync` (binary copy pattern) and `apps/kasmvnc` (multi-stage build).

Important: the MediaInfo tool itself is a CLI plus GUI. If only the CLI is wanted, a CLI-only image (no VNC) is much simpler. The draft's reason says the same. Decide scope before writing the Dockerfile (section 10).

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS mediainfo-build`, `ARG VERSION`, `ARG MEDIAINFOLIB_VERSION`, `ARG ZENLIB_VERSION`, `USER root`. Keep the three versions as ARGs; `VERSION` matches `docker-bake.hcl`.
2. Install build deps from apt: `build-essential`, `cmake`, `pkg-config`, `zlib1g-dev`, `libtinyxml2-dev`, Qt6 dev packages for the GUI (`qt6-base-dev`, `qt6-svg-dev`; names and availability on ubuntu 26.04 are UNVERIFIED). Use `--no-install-recommends`.
3. Download the three source tarballs from the pinned tag URLs. Upstream publishes no checksums; verify the tarball is the expected tag by pinning the URL and recording the SHA256 in the Dockerfile comment (plan decision, not an upstream fact). Do not invent a published checksum.
   ```dockerfile
   RUN curl -fsSL -o /tmp/mi.tar.gz "https://github.com/MediaArea/MediaInfo/archive/refs/tags/v${VERSION}.tar.gz" && \
       curl -fsSL -o /tmp/mil.tar.gz "https://github.com/MediaArea/MediaInfoLib/archive/refs/tags/v${MEDIAINFOLIB_VERSION}.tar.gz" && \
       curl -fsSL -o /tmp/zen.tar.gz "https://github.com/MediaArea/ZenLib/archive/refs/tags/v${ZENLIB_VERSION}.tar.gz"
   ```
4. Build ZenLib, then MediaInfoLib, then the MediaInfo CLI and GUI with CMake, installing into `/tmp/mediainfo-install` (or `/opt/mediainfo`). Exact CMake flags are UNVERIFIED (upstream `build.sh` not fetched).
5. Final stage `FROM <ubuntu>`, `USER root`. Install runtime libs only (Qt6 runtime, `libtinyxml2-*`, mesa GL, fonts). Do not reinstall anything already in the base. Clean apt lists.
6. `COPY --from=mediainfo-build /opt/mediainfo/ /opt/mediainfo/` (or the install path chosen in step 4).
7. Licences: `COPY --from=mediainfo-build` for the MediaInfo, MediaInfoLib and ZenLib license files into `/usr/share/licenses/mediainfo/` (ContainerForge rule for extracted parts of an upstream archive).
8. `chown -R apps:apps /opt/mediainfo && chmod -R 755 /opt/mediainfo`.
9. `ENV HOME=/config XDG_CACHE_HOME=/tmp/.cache`.
10. Tail:
    ```dockerfile
    USER apps
    COPY --chmod=0755 . /

    EXPOSE 5800 5900
    VOLUME /config
    VOLUME /storage
    ```
    `/storage` is the chart's mount for media files; keep it. Only expose the GUI ports if the GUI is kept (section 10).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mediainfo"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=MediaArea/MediaInfo versioning=loose
  default = "26.10"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/MediaArea/MediaInfo"
}
```

- `LICENSE` stays `UNVERIFIED` until the MediaInfo licence is fetched and confirmed. Do not publish an SPDX that is not confirmed.
- Renovate: `VERSION` tracks MediaInfo (26.10). MediaInfoLib and ZenLib versions are separate ARGs; add their renovate comments only if they are bumped with `VERSION`.
- Targets: copy the four standard targets and the default group from `apps/adguardhome-sync/docker-bake.hcl`, with `image-local` tagged `${APP}:${VERSION}`. Validate with `cd apps/mediainfo && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/MediaArea/MediaInfo"
ports:
  - port: 5800
    protocol: http
    required: false
  - port: 5900
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /storage
    required: false
dependencies: []
```

Rules applied:
- Ports 5800 and 5900 are `(inferred)` from the draft. Keep only the ports the built image opens (section 11). If the CLI-only scope is chosen, remove both ports.
- Env: upstream sets no env vars. The only one planned is `TZ`, which start.sh applies. Do not add variables the app does not read.
- Volumes: `/config` persistent, `/storage` media input (user-mounted).
- No dependencies.

## 7. start.sh

```bash
#!/usr/bin/env bash

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache

# GUI launch (VNC + noVNC wrapper) is UNVERIFIED until upstream run scripts are read
exec /opt/mediainfo/bin/mediainfo-gui "$@"
```

Notes:
- Idempotent: no first-run seeding is planned until upstream config files are confirmed (UNVERIFIED).
- Never write under `/opt/mediainfo`. Settings go to `/config`, caches to `/tmp`.
- `exec` the final process so signals propagate.
- Any VNC or noVNC server must bind `0.0.0.0` (start-script rule). Use the same wrapper pattern as `apps/kasmvnc/start.sh` (Xvnc on `:1`, then the app), and keep the nginx/websocket config writable under `/tmp` only.
- For a CLI-only image, replace the GUI launch with `exec sleep infinity` or the CLI command; decide in section 10.

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
- /opt/mediainfo/bin/mediainfo
- /opt/mediainfo/bin/mediainfo-gui
- /usr/share/licenses/mediainfo
```

Rules:
- Every port in `settings.yaml` has a probe. Drop the probes if the ports are dropped.
- The binary paths are planned install locations: UNVERIFIED until the image is built.
- The test runs with no env vars. No required-env code path exists in this plan.
- The CLI binary check (`mediainfo --Version`) is an additional real assertion if the CLI is kept. Use a process check only if forgetool supports it; do not invent assertions.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `HOME` (base image default) | `HOME=/config` (persistent) |
| Caches (`XDG_CACHE_HOME`, Qt cache) | `/tmp` |
| Media input `/storage` | user-mounted volume, unchanged path |
| X11 socket and VNC runtime (`/tmp/.X11-unix`, socket dirs) | `/tmp` (works under `--read-only --tmpfs /tmp`) |
| `/opt/mediainfo` (binaries) | read-only at runtime; no writes |

Security expectations reconciled with the draft:
- Chart runs as UID 0 with `runAsNonRoot: false`. This image runs as `apps` (`USER apps`). Expect no privilege need: MediaInfo reads files only.
- `readOnlyRootFilesystem: false` in chart. Plan targets `--read-only --tmpfs /tmp`; verify the GUI and Qt do not write elsewhere (section 11).
- Not privileged in chart. Capabilities `NET_BIND_SERVICE` and `KILL` in the chart are unnecessary for ports above 1024 (5800, 5900); do not add them.
- Extra persistence: `/storage` maps to the ContainerForge volume (section 6).

## 10. Risks, caveats and open questions

- Scope decision: GUI over VNC (draft scope) makes this hard. A CLI-only image is easier and would drop the VNC stack, the Qt6 GUI build and the ports. Confirm scope with the user before writing the Dockerfile.
- Draft claims `apt:mediainfo-gui` as the ready-made binary. Upstream does not use apt: it builds MediaInfo, MediaInfoLib and ZenLib from GitHub tags. Whether `mediainfo-gui` exists in ubuntu 26.04 apt is UNVERIFIED; if it does, it is a simpler alternative to the source build but changes the version pin (must match `VERSION`).
- Draft's `yes*` (amd64, arm64 ready-made binary): the vendor binary download is not confirmed. Source build is the verified path.
- Builds depend on GitHub being reachable (three tarballs from GitHub). Upstream has no checksums; the plan pins URLs and records SHA256 in the Dockerfile.
- Qt6 availability on ubuntu 26.04 and the exact cmake flags are UNVERIFIED.
- Ports 5800/5900 are inferred, not confirmed.
- Licence unknown (section 5).
- Upstream `/build/build.sh` and the base-image run scripts were not fetched: all build and launch details marked UNVERIFIED must be checked against them.
- Blockers: none known (no musl-only binary in the plan, no GPU, no privileged need). The GUI stack is the main effort.

## 11. Build and test steps

```sh
cd apps/mediainfo
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name mediainfo-probe --read-only --tmpfs /tmp \
  -v mediainfo-probe-config:/config mediainfo:26.10
docker logs -f mediainfo-probe
forgetool containers test --image mediainfo:26.10 --config ./apps/mediainfo/container-test.yaml
docker rm -f mediainfo-probe; docker volume rm mediainfo-probe-config
```

- Expected readiness signal: the VNC/noVNC server logs its listen line and the GUI process stays running (exact string UNVERIFIED until the image runs). For the CLI-only scope, `mediainfo --Version` prints the version and the container stays running.
- Empty `/config` must start cleanly.
- arm64: build only if the amd64 build passes; the draft's arm64 claim is `yes*` and must be rechecked.

## 12. PR checklist

- Branch `feat/add-mediainfo`, commit and PR title `feat(mediainfo): add new container`, target `main`.
- PR body fills `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and checks only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Tell the user; only the user can sign it. Check the `license/cla` status.
- State what was not tested: the GUI over VNC if not run, arm64, the licence, the Qt6 build on ubuntu 26.04, and the ports if not confirmed.
- `docker buildx bake --print` passes; `VERSION` in bake equals `ARG VERSION` in the Dockerfile; no assertion weakened.
