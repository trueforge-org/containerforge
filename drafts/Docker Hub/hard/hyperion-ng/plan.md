# hyperion-ng — implementation plan
> Source: ./draft.md · Target: apps/hyperion-ng/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 2.2.1 (tag `2.2.1`, published 2026-04-06, latest). The draft links 2.2.0. |
| Renovate | `datasource=github-releases depName=hyperion-project/hyperion.ng versioning=loose` (tags have no `v`) |
| License | MIT (GitHub API SPDX `MIT`, checked 2026-11-25) |
| Source URL | https://github.com/hyperion-project/hyperion.ng |
| amd64 URL | https://github.com/hyperion-project/hyperion.ng/releases/download/2.2.1/Hyperion-2.2.1-Linux-amd64.deb (sha256 `8e30585049421297455387564f8df2c87603f0f8557bc95abca102be27e872b9`) |
| arm64 URL | https://github.com/hyperion-project/hyperion.ng/releases/download/2.2.1/Hyperion-2.2.1-Linux-arm64.deb (sha256 `ee5e9eaeeb4a6bc69174b15dcb316de274cc77dab93fc5c370905e04ca2f056b`) |
| Alternative assets | `Hyperion-2.2.1-Linux-amd64.tar.gz` (sha256 `75ba1ed3f6d177d17d78d81d34776cdd36b1b564192c5e79475c6207999caf70`), `Hyperion-2.2.1-Linux-arm64.tar.gz` (sha256 `39e7e8211e576e2dea89825ce016f02649eb2e3dff2fb1fc2a8b5da09879b229`). Prefer the tar.gz: no maintainer scripts or systemd side effects, extract to `/app/hyperion` (layout UNVERIFIED, inspect with `tar tzf`). |
| Checksums | GitHub API asset digests (above); no checksum file. Fetch the digest at build time from `https://api.github.com/repos/hyperion-project/hyperion.ng/releases/tags/${VERSION}` and verify with `sha256sum -c`. |
| Upstream Dockerfile | None at the tag; Docker Hub image `sirfragalot/hyperion.ng` provenance UNVERIFIED. The upstream repo has no official runtime Docker image reviewed. |
| Ports | From the draft (inferred): 8090 web UI, 8092 web UI TLS, 19444 JSON server, 19400 FlatBuffers server. Boblight (draft mentions), Proto 19445 and their exact defaults are UNVERIFIED. Confirm in `hyperiond` with `ss -ltn` after first start. |
| Config/data | Draft: `/root/.hyperion` (runs as root). Hyperion accepts a user-data directory flag (`--userdata <path>` per upstream CLI docs; no `-u` short form documented). |
| Hardware | LED output needs USB serial (`/dev/ttyUSB*`), SPI, GPIO, or network LEDs; capture needs V4L2 or DRM devices. Without device passthrough, only network LED devices and the UI work. |
| Dependencies | none |

## 2. Target layout

```
apps/hyperion-ng/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (Hyperion generates its own default config in the userdata dir on first start; UNVERIFIED). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. C++/Qt application distributed as prebuilt Linux packages (draft: ubuntu alone). Closest sibling: `apps/adguardhome-sync` (binary on ubuntu) and `apps/steamcmd` for download plus runtime libs.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config XDG_CACHE_HOME=/tmp/.cache`.
2. Download `Hyperion-${VERSION}-Linux-${TARGETARCH}.tar.gz` (amd64 and arm64 match Docker's `TARGETARCH` names, so no mapping needed) with `curl -fsSL`, verify sha256 from the release API digest, `tar xzf` into `/app/hyperion` (strip components per actual layout). Fallback if the tarball lacks needed pieces: `dpkg-deb -x` the `.deb` into `/app/hyperion-pkg` and relocate `usr/bin/hyperiond` and `usr/share/hyperion`.
3. Install runtime libraries via apt after inspecting `ldd /app/hyperion/bin/hyperiond`: expected Qt6 or Qt5 base libraries, libusb, libssl, `libcec`/`libv4l`/`libx11`/`libxcb`/`libdrm` family, `libglib`/`libpulse` etc. Package names on Ubuntu 26.04 UNVERIFIED; the `.deb` `Depends:` field (`dpkg-deb -I`) is the authoritative list and must be mapped. Skip anything the ubuntu base already ships (check `apps/ubuntu/Dockerfile`; it includes libicu and curl but not Qt).
4. Symlink `/usr/local/bin/hyperiond` -> `/app/hyperion/bin/hyperiond` (path UNVERIFIED).
5. License: copy `LICENSE` and any third-party notices from the package or repo tag to `/usr/share/licenses/hyperion-ng/` (hyperion.ng bundles several third-party components, so ship what the tarball includes; UNVERIFIED).
6. `COPY --chmod=0755 . /`, `EXPOSE 8090 19444 19400`, `VOLUME /config`, `WORKDIR /config`, final `USER apps`. Device access is a runtime option (supplemental groups for `dialout`/`video` are added in `apps/ubuntu` via `usermod -aG` for the apps user; confirm that includes the groups needed, group 20 is `dialout`).

## 5. docker-bake.hcl

`APP="hyperion-ng"`, `LICENSE="MIT"`, `SOURCE="https://github.com/hyperion-project/hyperion.ng"`, `VERSION` default `"2.2.1"` under `// renovate: datasource=github-releases depName=hyperion-project/hyperion.ng versioning=loose`. Targets: `docker-metadata-action`, `image` (args VERSION, source and licenses labels), `image-local`, `image-all` (amd64+arm64), group default `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url` = SOURCE.
- ports: `8090 tcp`, `19444 tcp`, `19400 tcp`, all `required: false`. Do not list 8092 or boblight until confirmed open by default (they are TLS and an optional server, UNVERIFIED), and per rules only list ports the container actually opens.
- env: `TZ` (`"Etc/UTC"`). Add other vars only if `hyperiond` is shown to read them (none confirmed).
- volumes: `/config` required true (Hyperion userdata, mapped from `/root/.hyperion`).
- dependencies: none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- `mkdir -p /config` when missing; Hyperion creates its default DB/config on first start (UNVERIFIED), so no seeding.
- Log a warning if no `/dev/ttyUSB*`, `/dev/spidev*`, `/dev/video*` are visible (hardware features unavailable).
- Never write to `/app`; caches and Qt runtime to `/tmp` (`XDG_RUNTIME_DIR=/tmp/runtime`, mode 0700; `QT_QPA_PLATFORM=offscreen` if Qt tries to open a display, UNVERIFIED).
- `exec hyperiond --userdata /config -s`-style invocation (`--userdata <path>` and `-s` per upstream CLI docs; no `-u` or `--silent` documented; verify with `hyperiond --help`; avoid `--daemon`/`--service` since the process must stay in foreground).
- Servers must bind all interfaces: Hyperion's web UI/JSON server default binding is UNVERIFIED; verify from outside the container, and adjust the Hyperion setting through its settings JSON if it binds localhost.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '8090'
- port: '19444'
- port: '19400'
http:
- port: '8090'
  path: /
filePaths:
- /app/hyperion/bin/hyperiond
- /start.sh
- /usr/share/licenses/hyperion-ng/LICENSE
```

Only keep a port probe if the port is confirmed open by default on an empty `/config` (the plan must not list unverified ports in settings either). Timeout from siblings (120 to 180).

## 9. Rootless and read-only-rootfs adaptations

- Draft: chart UID 0 (`runAsNonRoot: false`), data in `/root/.hyperion`; readOnlyRootFilesystem unknown. Target UID 568, read-only rootfs, data in `/config`.
- Hardware: USB serial/SPI/GPIO/V4L2 need `--device` mappings and matching supplemental groups (the ubuntu base adds apps to groups 10,20,29,44,39,101,107,129; confirm `dialout` 20 and `video` 44 cover the host devices). No `privileged` should be required for USB serial; SPI/GPIO may. Not verified.
- Writes: userdata to `/config`; Qt/runtime to `/tmp`; none to `/app`.

## 10. Risks, caveats and open questions

- Hardware access is the product's core: the container without devices only supports network LED targets.
- Library mapping from Debian-built package to Ubuntu 26.04 may fail (Qt major version, libs not packaged); would block one or both arches.
- Port list and flags are inferred, not verified.
- Upstream warns its web UI has optional password auth only; expose carefully.
- 2.2.1 vs the draft's 2.2.0; use 2.2.1.

## 11. Build and test steps

```sh
cd apps/hyperion-ng
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name hyperion-ng-probe --read-only --tmpfs /tmp -v hyperion-ng-probe-config:/config hyperion-ng:2.2.1
docker logs -f hyperion-ng-probe
docker exec hyperion-ng-probe bash -c 'ss -ltn'
forgetool containers test --image hyperion-ng:2.2.1 --config ./apps/hyperion-ng/container-test.yaml
docker rm -f hyperion-ng-probe; docker volume rm hyperion-ng-probe-config
```

Expected readiness: Hyperion log lines about the web server and JSON server starting (exact text UNVERIFIED) and 8090 open; no "no capture device" fatal exit (soft warnings are fine).

## 12. PR checklist

- Branch `feat/add-hyperion-ng`; commit and PR title `feat(hyperion-ng): add new container`.
- PR template filled; Notes contain `🤖 This PR is AI generated.`
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- bake print, version alignment, `USER apps`, empty `/config`, read-only rootfs, checksums verified.
- Untested at plan time: build, run, shared-library mapping, hardware passthrough, arm64, exact ports and flags, license identifier.
