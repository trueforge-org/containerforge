# frigate — implementation plan
> Source: ./draft.md · Target: apps/frigate/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.18.3, published 2026-11-19 (https://api.github.com/repos/blakeblackshear/frigate/releases/latest). The draft's chart tags `0.18.3` and `0.18.3-tensorrt` match this release. |
| Renovate | `datasource=github-releases depName=blakeblackshear/frigate versioning=semver` |
| License | MIT (GitHub license API, `spdx_id` MIT: https://api.github.com/repos/blakeblackshear/frigate/license) |
| Source URL | https://github.com/blakeblackshear/frigate |
| Download | No uploaded assets on the release. Source at tag `v0.18.3`. The build is from source. |
| Per-arch binary | None shipped. Python backend plus a node-built web UI. The Dockerfile pulls `go2rtc` v1.9.14 per architecture from `https://github.com/AlexxIT/go2rtc/releases/download/v1.9.14/go2rtc_linux_${TARGETARCH}` (confirmed in the Dockerfile). |
| Checksum source | None published for the release. The Dockerfile reviewed is at commit `a19e23ae2dd3dd1082bf82a0ad5d2b62a5813676`; pin that commit for the source. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/blakeblackshear/frigate/a19e23ae2dd3dd1082bf82a0ad5d2b62a5813676/docker/main/Dockerfile |
| Upstream base | `ARG BASE_IMAGE=debian:12` and `SLIM_BASE=debian:12-slim` (not ubuntu). |
| Upstream stages | Many: nginx built from source, sqlite-vec built from source, intel-media-driver built from source, libusb without udev, tempio, OpenVINO model conversion, models download, s6-overlay, Python wheels, deps, node web-build, final `frigate` stage. |
| Entrypoint | `ENTRYPOINT ["/init"]` (s6-overlay), `CMD []`. |
| Ports (EXPOSE) | `5000`, `8554`, `8555/tcp`, `8555/udp`. |
| Env (Dockerfile) | `PATH` (adds go2rtc, tempio, nginx), `S6_LOGGING_SCRIPT`, `S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0`. App config env is not in this file (UNVERIFIED). |
| Python requirements | `docker/main/requirements.txt` was not read in full. A fetch returned only `scikit-build == 0.18.*`, so the full list is UNVERIFIED. |
| Config and media paths | UNVERIFIED: the config file path (draft: `/config/config.yml`) and the recording path (draft: `/media`) were not confirmed from upstream in this run. |
| 8971 (web UI) | UNVERIFIED: the draft says 8971/https through nginx. Not in the Dockerfile `EXPOSE` and the nginx config was not read. Do not list it in `settings.yaml` until confirmed. |
| arm64 | UNVERIFIED on ghcr. The draft says upstream publishes amd64 and arm64 images. |

## 2. Target layout

This app is not ready for a single-pass port. The plan below is the layout a full port would need, and section 10 lists why the port is blocked.

Exact file list for `apps/frigate/`, if the port proceeds:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required) or the s6 service tree (see section 7)
- `root/` is never used (reserved for run-time copy-to-rootfs; do not create it).
- `etc/` (required reason: the nginx config and the s6 service definitions, if the s6 tree is kept)
- `defaults/` (required reason: a default `config.yml` seeded into `/config` only when missing)
- `DOWNSTREAM_CHANGES.md` is not needed (not a `FROM` base).

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Python is the runtime, so the python base is the closest fit. The draft says so, and the porter table says Python uses the python base.
- Node is needed only for the web UI build. A build stage on `python-node` (`ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`) or on ubuntu with node is a choice for the build stage (UNVERIFIED: which is available at the required node version).
- Closest sibling: `apps/bazarr` (python, `USER apps`, `COPY --chmod=0755 . /`). `apps/changedetection` and `apps/budge` are python-node siblings.
- Important mismatch: upstream is `debian:12`, not ubuntu. The ContainerForge rule is the ubuntu or python base, so the upstream Debian package set cannot be copied as-is. This is a real blocker, see section 10.

## 4. Dockerfile

Not written. The upstream Dockerfile has about a dozen stages, and most of them are hardware or optional features. The plan for a port is to keep only the backend:

1. Build stage on the python base: build the Python venv for the pinned wheels (`/tmp/venv` for build scratch; the final venv goes to `/app/venv`, read-only at runtime per the python-runtime rule).
2. Build stage on a node base: `npm ci` and `npm run build` for the web UI from the `web/` folder of the same commit.
3. Get `go2rtc` v1.9.14 for `${TARGETARCH}` from the upstream release URL above. No checksum is published; pin the URL and note that no checksum is published.
4. Install ffmpeg and any runtime libs by apt on the final stage, with versions pinned and checked against the ContainerForge base (UNVERIFIED: the apt package names on ubuntu 26.04 and the ffmpeg version Frigate needs).
5. Copy the built web UI and backend to `/app/frigate`. License to `/usr/share/licenses/frigate/LICENSE`.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5000 8554 8555/tcp 8555/udp`, `VOLUME /config`.

Blocked items in this list are in section 10.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "frigate"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=blakeblackshear/frigate versioning=semver
  default = "0.18.3"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/blakeblackshear/frigate"
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

- Renovate: the upstream tag is `v0.18.3`. The bake value is `0.18.3`. Check the tag form in the build, and align the Dockerfile `ARG VERSION` with the bake value.
- Validate with `docker buildx bake --print` from `apps/frigate`. Not run in this pass.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/blakeblackshear/frigate"
ports:
  - port: 5000
    protocol: tcp
    required: true
  - port: 8554
    protocol: tcp
    required: false
  - port: 8555
    protocol: tcp
    required: false
  - port: 8555
    protocol: udp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Ports are the EXPOSE list only. 8971 is left out until it is confirmed (section 1). Do not list ports the container does not open.
- `env` holds only `TZ`. Frigate's own env names were not confirmed; do not invent any.
- `dependencies`: none in the chart. Frigate needs a camera or RTSP source, which is user config, not a ContainerForge dependency.

## 7. start.sh

Not written. The upstream Dockerfile uses s6-overlay (`ENTRYPOINT ["/init"]`). The ContainerForge pattern is a `start.sh` with `exec`, so a port would replace the s6 tree with one `start.sh` that starts the backend, or keep s6 if the s6 tree can run under read-only rootfs (UNVERIFIED: s6-overlay writes to `/run` and `/var/run` at boot). The choice is open (section 10).

A possible `start.sh` shape, if the backend is run directly:

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/frigate
[ -f /config/config.yml ] || cp /app/frigate/defaults/config.yml /config/config.yml
cd /app/frigate
exec python3 -m frigate
```

- UNVERIFIED: the backend entry point (`python3 -m frigate` is a guess), the config path (`/config/config.yml`), and the default config file content.
- Idempotent: the config is seeded only when missing. No writes to `/app`.
- Caches and temp to `/tmp` (for example `/tmp/frigate` for the media scratch).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
  - port: '5000'
  - port: '8554'
filePaths:
  - /app/frigate/frigate
  - /usr/share/licenses/frigate/LICENSE
```

- Every port in `settings.yaml` with a TCP protocol has a probe. The UDP 8555 port cannot be probed with `tcp`; a UDP check is not in the schema as used here (UNVERIFIED: forgetool UDP probe support).
- The backend may fail on start without a camera config. The test needs `defaults/config.yml` to be valid and to start without a camera, or a test config must be shipped through `filePaths`. Do not add a camera to make the test pass.
- UNVERIFIED: the `frigate/frigate` path. The file list is a placeholder; confirm with the build.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write or path | ContainerForge remap |
| --- | --- |
| `/config` (upstream config dir, camera config) | `/config` (kept) |
| `/media` (recordings, draft) | UNVERIFIED path. Remap to `/config/media` if the app allows a path override, or document the bind mount |
| `/tmp/cache`, nginx runtime paths, s6 `/run` | `/tmp` (ephemeral); s6 `/run` needs checking under `--read-only` |
| nginx built from source with prefix `/usr/local/nginx` (upstream) | Keep only if the nginx binary is needed. Its pid and temp paths must move to `/tmp` |
| `root` user (chart `runAsUser 0`) | `USER apps` (ContainerForge rule). Camera device access for non-root is UNVERIFIED and may need a host group |
| Device passthrough (camera, USB Coral, GPU) | Not in `settings.yaml` (not declared by the container). The chart's device config is the user's responsibility |

- Chart expectations (non-root no, read-only no, privileged no) are the chart's defaults. The ContainerForge target is non-root and read-only compatible. Privileged is not needed for the CPU path.

## 10. Risks, caveats and open questions

Blockers (these stop a single-pass port):

- Upstream base is `debian:12` and the build uses Debian packages and tooling (`apt`, `ccache`, `libusb` build, nginx build). The ContainerForge target is ubuntu or the python base. A port means rebuilding the dependency set on ubuntu 26.04, and that is not verified.
- The upstream build has about a dozen stages and compiles native code (sqlite-vec, libusb, intel-media-driver, nginx). Each is a build risk, and the plan has no verified path for them.
- s6-overlay is the upstream PID 1. Replacing it with `start.sh` needs a process model decision, and the backend's real entry point is UNVERIFIED.
- Camera access needs a device or an RTSP stream configured by the user, and a config file must exist before the backend starts. The test cannot cover a real camera. The protocol's test cannot prove the detection path.
- CPU detection is slow (draft caveat, confirmed as an inference only). A detector (USB Coral, GPU or similar) is practically required for real use. The CPU path is the only one a single-container test can cover.
- The tensorrt tag (draft) needs CUDA and an NVIDIA runtime. Out of scope for this plan.
- arm64 is UNVERIFIED on ghcr. The draft says arm64 wheels exist for the main Python deps, which was not checked.

Recommendation: keep the draft at `hard`. Do not start a PR until the open questions in this section are answered. A phased port (backend only, CPU, no GPU or Coral, no web UI until the backend passes) is the smallest step that could be tested.

Open questions: the backend entry point and config path; the full Python requirements list (only `scikit-build` was confirmed); whether 8971 is the web UI port and whether nginx serves it; the ffmpeg source on ubuntu 26.04; whether s6-overlay works under `--read-only`.

## 11. Build and test steps

Not runnable yet. When the port is approved, run from `apps/frigate`:

```sh
cd apps/frigate
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name frigate-probe --read-only --tmpfs /tmp \
  -v frigate-probe-config:/config frigate:0.18.3
docker logs -f frigate-probe
forgetool containers test --image frigate:0.18.3 --config ./container-test.yaml
docker rm -f frigate-probe; docker volume rm frigate-probe-config
```

- Expected readiness signal: the backend's startup log and port 5000 open. The exact line is UNVERIFIED.
- Empty `/config`: fresh named volume each round.
- The build is heavy (native code, a node build, many apt packages). Expect the build to take a long time and to need the round limit in the protocol.

## 12. PR checklist

- Branch: `feat/add-frigate`.
- Commit: `feat(frigate): add new container`.
- PR title matches the commit.
- Use `.github/PULL_REQUEST_TEMPLATE.md`. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State that this plan is a planning document, not a working image. Nothing was built or run. The blockers in section 10 are open, so the PR (if any) must say that the port is partial or blocked.
