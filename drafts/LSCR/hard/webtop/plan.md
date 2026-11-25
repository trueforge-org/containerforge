# webtop — implementation plan
> Source: ./draft.md · Target: apps/webtop/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No single version: the chart uses many LinuxServer webtop tags (`alpine-i3`, `alpine-icewm`, `alpine-kde`, +21 more). Draft gives no pin. Upstream release/tag for the image: UNVERIFIED (not fetched). |
| Difference from draft | The draft's `copy-from: no` is CONFIRMED for the alpine i3 variant: the upstream Dockerfile at commit `b1c6c9e22abe066d2d637377229de773dd45044f` starts `FROM ghcr.io/linuxserver/baseimage-selkies:alpine324` (Alpine, musl) and installs packages with `apk add --no-cache` (i3wm, sway, st, chromium). Source: https://raw.githubusercontent.com/linuxserver/docker-webtop/b1c6c9e22abe066d2d637377229de773dd45044f/Dockerfile |
| Renovate | UNVERIFIED for a single datasource: the image is a family of tags. Choose once the variant is decided (see section 10). |
| License | UNVERIFIED (not fetched). |
| Source URL | https://github.com/selkies-project/selkies (from draft). The draft's application binary is `pip:selkies`; the selkies PyPI version and license are UNVERIFIED (not fetched). |
| Download | `pip:selkies` (from draft, UNVERIFIED on PyPI). Desktop packages from the distro package manager (apt on Ubuntu, not apk). |
| Checksum source | PyPI hashes for selkies (UNVERIFIED); apt signatures for the desktop packages. |
| Upstream Dockerfile reviewed | Only the alpine i3 variant (`alpine324`). `EXPOSE 3000`, `VOLUME /config`, `ENV TITLE="Alpine i3"`, `ENV SELKIES_WAYLAND_SOCKET_INDEX=2`, `ARG BUILD_DATE VERSION I3_VERSION` (I3_VERSION declared but unused), `LABEL maintainer="thelamer"`, `COPY /root /`. ENTRYPOINT, CMD, USER: UNVERIFIED (not set in this file). Other variants: UNVERIFIED. |
| Port | 3000 (upstream alpine i3 EXPOSE). Draft's 3001/https is UNVERIFIED. Draft's 33000 (chart desktop session) is UNVERIFIED. |
| Env vars (real) | `TITLE`, `SELKIES_WAYLAND_SOCKET_INDEX` (alpine i3 Dockerfile). Others UNVERIFIED. |
| Data path | `/config` (upstream `VOLUME /config`). |

## 2. Target layout

- `apps/webtop/Dockerfile`
- `apps/webtop/docker-bake.hcl`
- `apps/webtop/settings.yaml`
- `apps/webtop/container-test.yaml`
- `apps/webtop/start.sh`
- `apps/webtop/etc/` or `defaults/` only for seeded desktop config (decide during build; UNVERIFIED need)

No `root/`. No `DOWNSTREAM_CHANGES.md`: not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The LinuxServer `baseimage-selkies` images are Alpine (`alpine324`) or Arch (`arch`, see sibling plan for kdenlive), so neither can be the base for a glibc Ubuntu app. The draft says "ubuntu alone is enough": the upstream selkies stack is not reused, so every desktop and streaming piece must come from apt or pip on Ubuntu. Closest desktop siblings: `apps/kasmvnc` and `apps/rdesktop` (both ship `root/`; do not copy it).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Desktop packages from apt, pinned against the chosen variant. The draft's variant set is "many" (i3, icewm, kde, and 21 more). Scope to ONE variant first (section 10). For a single variant, for example icewm: `apt-get install -y --no-install-recommends <de-packages>` with versions pinned where practical.
3. `pip install selkies` (draft says `pip:selkies`; version and license UNVERIFIED). Install into `/app/venv` at build time with `PIP_CACHE_DIR=/tmp/pip`, not at runtime. Python base is not used, so install with the Ubuntu system python or a venv under `/app/venv`, following the python-runtime rules (UNVERIFIED which python is bundled).
4. Browser: upstream installs chromium (alpine i3). Ubuntu chromium is a snap, which does not work in a container. Use a non-snap browser or drop it from the first variant (UNVERIFIED availability on 26.04).
5. License: copy the licences of selkies and the desktop packages to `/usr/share/licenses/webtop/`.
6. Cleanup: `rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache`.
7. Environment: `ENV HOME=/config TITLE="Ubuntu i3" SELKIES_WAYLAND_SOCKET_INDEX=2` (only the vars the chosen stack reads).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 3000
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "webtop"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource (image is a family of tags; choose after the variant decision)
  default = "UNVERIFIED"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/selkies-project/selkies"
}

group "default" {
  targets = ["image-local"]
}

# image, image-local, image-all copied from apps/bazarr/docker-bake.hcl
```

`VERSION` must be pinned to the selkies PyPI version or an explicit release tag once confirmed. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/selkies-project/selkies"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: TITLE
    default: "Ubuntu i3"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 3000 is confirmed by the alpine i3 EXPOSE only; keep it only if the chosen stack listens there. Desktop shm and session settings are added only after confirmation. No dependencies.

## 7. start.sh

Plan only; the shape depends on the chosen stack. Required properties:

- `mkdir -p /config`; seed desktop config only when missing (idempotent).
- Writes only to `/config` and `/tmp`; never `/app`.
- Read `TITLE` and other env with defaults matching `settings.yaml`.
- Bind the selkies web listener to `0.0.0.0:3000`.
- `exec` the selkies process so signals reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /usr/share/licenses/webtop/
```

Add `filePaths` for the selkies entry point once its install path is confirmed (UNVERIFIED). Timeout 300 is an estimate for a desktop start; confirm against a sibling.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Desktop home and config (`~/.config`) | `HOME=/config` |
| Session runtime (`XDG_RUNTIME_DIR`) | `/tmp/runtime-apps` (mode 0700, created at start) |
| Caches | `XDG_CACHE_HOME=/tmp/cache` |
| Shared memory for browsers | `/dev/shm` must be large (draft caveat, UNVERIFIED size); Kubernetes sets it via `emptyDir medium: Memory` in the chart, not the image |

The draft expectations: chart runs as UID 0 and `readOnlyRootFilesystem: false`, not privileged. This image should run as `apps` and work with `--read-only --tmpfs /tmp` once the remaps are in place. The chart's desktop session port 33000 is UNVERIFIED and not used by this plan.

## 10. Risks, caveats and open questions

- BLOCKER (draft: musl-only): the upstream variant the chart uses (alpine i3) is musl-only and cannot run on glibc Ubuntu. The Ubuntu route is a rebuild of the desktop, not a copy. Decide the variant before building.
- SCOPE: the chart uses ~24 tags across desktops (i3, icewm, kde, ...). One app cannot cover them all in one PR. Recommend one variant first; the rest are follow-ups (UNVERIFIED which variants the chart needs).
- Browser: chromium on Ubuntu is a snap, which does not run in the container. A non-snap browser or no browser in the first variant (UNVERIFIED).
- selkies: PyPI version, license, and the Ubuntu-compatible install are UNVERIFIED.
- Large package set makes the image big and slow to build and start (draft caveat).
- Difficulty: hard. This is a desktop with a display, not a single application.

## 11. Build and test steps

```sh
cd apps/webtop
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name webtop-probe --read-only --tmpfs /tmp --shm-size=1g \
  -v webtop-probe-config:/config webtop:<VERSION>
docker logs -f webtop-probe
forgetool containers test --image webtop:<VERSION> --config ./apps/webtop/container-test.yaml
docker rm -f webtop-probe; docker volume rm webtop-probe-config
```

Readiness signal: the selkies listening line on port 3000 (UNVERIFIED text). `--shm-size` is needed for the browser (draft caveat). `<VERSION>` is filled in after the variant decision.

## 12. PR checklist

- Branch `feat/add-webtop`, commit and PR title `feat(webtop): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested, to state honestly: every variant except the one built, the browser session, the arm64 runtime, shm sizing, and the port and probe choice.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile pin; no assertion weakened.
