# electrum — implementation plan
> Source: ./draft.md · Target: apps/electrum/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Git tag `4.8.4` exists (commit `460c117c4f4a6ae2e1dc13f2934b14fac6a1b9d9`, `gh api repos/spesmilo/electrum/git/ref/tags/4.8.4`). **No GitHub Release object** for 4.8.4 (release API returns 404, release list empty). `UNVERIFIED: release assets and checksums`. |
| Renovate | `datasource=github-tags depName=spesmilo/electrum versioning=loose` (no releases; tags are plain `4.8.4`, not `v`-prefixed) |
| License | MIT (GitHub license API, `repos/spesmilo/electrum/license`) |
| Source URL | https://github.com/spesmilo/electrum |
| Per-arch download | No GitHub release assets confirmed. Install by pip from the source tag, or from apt (`python3-pyqt5`, `libsecp256k1`). `UNVERIFIED: arm64 wheels or install path`. |
| Checksum source | None confirmed. `UNVERIFIED`. Pin the git tag commit (`460c117…`). |
| Upstream image Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-electrum/master/Dockerfile (draft's pinned Dockerfile link is `master`) |
| Upstream base | `FROM ich777/novnc-baseimage` (no tag, so `latest`). Libc not confirmed (`UNVERIFIED`). |
| Upstream apt packages | `python3-pyqt5`, `libsecp256k1-2`, `python3-cryptography`, `python3-pyqt6` (`--no-install-recommends`). Timezone Europe/Rome. noVNC title patched. |
| Upstream runtime | `ENTRYPOINT ["/opt/scripts/start.sh"]`, no CMD, no USER (runs as root unless `start.sh` switches), `EXPOSE 8080`, no VOLUME. `DATA_DIR=/electrum`. |
| Upstream env vars | `DATA_DIR=/electrum`, `CUSTOM_RES_W=1024`, `CUSTOM_RES_H=768`, `CUSTOM_DEPTH=16`, `NOVNC_PORT=8080`, `RFB_PORT=5900`, `TURBOVNC_PARAMS="-securitytypes none"`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=electrum` |
| Ports | `8080/http` (noVNC, `EXPOSE`). `5900/tcp` (VNC, `RFB_PORT`, not exposed). `8000` JSON-RPC daemon: **not in the upstream Dockerfile** (`UNVERIFIED`, draft claim). |
| Image on Docker Hub | `ghcr.io/ich777/electrum:latest`. Hub lists `latest` amd64-only, pushed 2025-12-11, digest `sha256:49553d30a105fd61624c87bf9928e1574908e0b7fb1abd40b134ab4809485ae4`. Source: `hub.docker.com/v2/repositories/ich777/electrum/tags` |
| arm64 | Upstream image is amd64-only per Hub. Not usable as `COPY --from` on arm64. |
| Docs | https://electrum.readthedocs.io/ and https://electrum.org not fetched (`UNVERIFIED`). |

## 2. Target layout

- `apps/electrum/Dockerfile`
- `apps/electrum/docker-bake.hcl`
- `apps/electrum/settings.yaml`
- `apps/electrum/container-test.yaml`
- `apps/electrum/start.sh` (replaces the upstream `start.sh`)
- `etc/.fluxbox/` (window manager config, if kept): needed because the desktop needs it. Reason: the allow-listed `etc/` path is the only way the config reaches the image with `COPY . /`.

`root/` is not used. No `DOWNSTREAM_CHANGES.md`. `sibling`: `apps/xvfb` exists and can be the base for the display stack (`xvfb` is in `apps/`).

## 3. Base image

`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Electrum is a Python app with Qt. Ubuntu carries `python3-pyqt5` and `libsecp256k1` in apt, so a Python venv is not required. Alternative: `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` if pip install of electrum is preferred. Decide after checking Qt availability on 26.04.

Closest siblings: `apps/xvfb` (display), `apps/kasmvnc` (VNC/noVNC stack), `apps/python` (Python base).

## 4. Dockerfile

1. Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build`, `ARG VERSION`, `USER root`. Clone or download `https://github.com/spesmilo/electrum/archive/refs/tags/${VERSION}.tar.gz`, verify against the pinned tag commit (`460c117…`).
2. Install runtime apt packages in the final stage: `python3-pyqt5 libsecp256k1-2 python3-cryptography python3-venv` with `--no-install-recommends`. Pin apt versions where needed (`UNVERIFIED`: exact versions on 26.04).
3. Install electrum into a venv under `/app/venv` (created with `--system-site-packages` so the apt `python3-pyqt5` is visible; UNVERIFIED; read-only at runtime, python-runtime rule), or use the apt `python3-electrum` package if it exists (`UNVERIFIED`).
4. VNC and window manager: reuse the `apps/xvfb` and `apps/kasmvnc` pattern, or install `novnc`, `websockify`, `x11vnc` (or `tigervnc-standalone-server`) and `fluxbox` via apt. Pin versions.
5. License: `COPY --from=build /tmp/src/LICENCE /usr/share/licenses/electrum/LICENSE`.
6. ENV: `HOME=/config`, `XDG_CACHE_HOME=/tmp/.cache`, `DATA_DIR=/config/electrum`, `DISPLAY=:99`, `CUSTOM_RES_W=1024`, `CUSTOM_RES_H=768`, `CUSTOM_DEPTH=16`, `NOVNC_PORT=6080`.
7. `VOLUME /config`, `EXPOSE 6080`.
8. Final: `COPY --chmod=0755 . /`, `USER apps`.

Note: the upstream image runs as root. The rootless rework must drop root. Xvfb and the VNC server on unprivileged ports (`>1024`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "electrum"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=spesmilo/electrum versioning=loose
  default = "4.8.4"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/spesmilo/electrum"
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
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Validate with `docker buildx bake --print` from `apps/electrum/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/spesmilo/electrum"
ports:
  - port: 6080
    protocol: tcp
    required: true
env:
  - name: NOVNC_PORT
    default: "6080"
    required: false
  - name: CUSTOM_RES_W
    default: "1024"
    required: false
  - name: CUSTOM_RES_H
    default: "768"
    required: false
  - name: CUSTOM_DEPTH
    default: "16"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

The draft's 8000 JSON-RPC port and 5900 VNC port are **not** listed. Add them only after `start.sh` is written and confirmed to bind them (`UNVERIFIED`). Defaults here follow the ContainerForge rootless port choice (6080 instead of the upstream 8080) and must match `start.sh`.

## 7. start.sh

1. `set -eu`. Create `/config/electrum` on first start only. Seed nothing else.
2. Export `HOME=/config`, `DATA_DIR=/config/electrum`, `XDG_CACHE_HOME=/tmp/.cache`.
3. Start Xvfb on `:99` with `CUSTOM_RES_W`, `CUSTOM_RES_H`, `CUSTOM_DEPTH`, then fluxbox, then the VNC server bound to `127.0.0.1:5900` (`-securitytypes none` replaced by a documented choice; see section 10), then websockify/noVNC on `0.0.0.0:${NOVNC_PORT}`.
4. Start electrum with `--dir "${DATA_DIR}"` and no password prompt.
5. `exec` the final long-running process (the supervisor or the electrum process) so signals propagate.

No writes to `/app`. Caches in `/tmp`. Wallet data only under `/config`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '6080'
http:
- port: '6080'
  path: /vnc.html
filePaths:
- /usr/share/licenses/electrum/LICENSE
- /app/venv/bin/electrum
```

Every port in settings.yaml has a tcp probe. The http path depends on noVNC (`/vnc.html` is the default in noVNC; `UNVERIFIED` for the chosen build). `filePaths` covers the electrum binary and license. No env vars are needed to start.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/electrum` (`DATA_DIR`, wallet and seed) | `/config/electrum` (persistent). Must be backed up by the user (draft caveat). |
| `/etc/.fluxbox` (window manager config) | Built into the image at build time, read-only. |
| `/tmp/.X11-unix`, `/tmp/.X99-lock` | `/tmp` (tmpfs). |
| `/home/electrum` or `/root` (any cache) | `/tmp/.cache` via `XDG_CACHE_HOME`. |
| `UMASK=000`, `DATA_PERM=770` | Replace with a fixed permission model in `start.sh`; do not keep world-writable `UMASK=000`. |

Upstream runs as root with no `USER`, so rootless `apps` UID is a behaviour change. Confirm that the `apps` user can write `/config/electrum`.

## 10. Risks, caveats and open questions

- **Hard band:** Qt desktop app behind noVNC and fluxbox, root-by-default upstream, no headless path. This is a multi-service desktop stack to rebuild rootless.
- **No GitHub release assets for 4.8.4:** `UNVERIFIED` whether an official binary exists. Install from source tag or apt.
- **arm64:** upstream image is amd64-only. `copy-from arm64: no`. The arm64 build depends on whether `python3-pyqt5` and `libsecp256k1` exist in 26.04 arm64.
- **VNC auth:** upstream uses `-securitytypes none` (no password). Exposing that on the network is a security risk. Decide whether to bind VNC to localhost only or require a password. Requires a documented choice.
- **Seed and wallet loss:** losing `/config/electrum` loses funds. Document in PR and settings.
- **Public servers:** the wallet connects to public Electrum servers over the internet. Note in docs.
- **Draft ports 8000 and 5900:** 5900 is `RFB_PORT` upstream but not exposed; 8000 is not in the upstream Dockerfile (`UNVERIFIED`).
- **Docs not read:** electrum.readthedocs.io and electrum.org not fetched.
- Blockers: no headless mode, VNC security, and arm64 availability.

## 11. Build and test steps

Run from `apps/electrum/`, one app at a time:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe run with a fresh config volume:
   ```sh
   docker run --rm -d --name electrum-probe --read-only --tmpfs /tmp \
     -v electrum-probe-config:/config electrum:4.8.4
   docker logs -f electrum-probe
   ```
   Expected readiness signal: websockify/noVNC listening on `6080` (`UNVERIFIED` exact string; confirm from the built start.sh).
4. `forgetool containers test --image electrum:4.8.4 --config ./apps/electrum/container-test.yaml`.
5. Cleanup: `docker rm -f electrum-probe; docker volume rm electrum-probe-config`.

## 12. PR checklist

- Branch: `feat/add-electrum`
- Commit: `feat(electrum): add new container`
- PR title: `feat(electrum): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes. Only check boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State what was not tested: arm64, VNC security and wallet persistence are not validated until built.
- If the image is not built, do not check "Built container locally".
