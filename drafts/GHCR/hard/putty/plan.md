# putty — implementation plan
> Source: ./draft.md · Target: apps/putty/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart image | `ghcr.io/jlesage/putty:v26.09.1` (TrueCharts `charts/stable/putty`, draft) |
| Latest upstream release | `v26.09.1`, published 2026-09-22 (`gh api repos/jlesage/docker-putty/releases/latest`). Tags `v26.08.3`, `v26.08.2` also exist. |
| Renovate | `datasource=github-releases depName=jlesage/docker-putty` is for the upstream image, not the PuTTY software. PuTTY software version is `0.85` (default `PUTTY_VERSION` in the upstream Dockerfile). Renovate for the software: UNVERIFIED for the source host `the.earth.li` (no GitHub release); use `datasource=custom` only if a version feed is confirmed. |
| License | PuTTY is MIT for PuTTY (PuTTY's own license is MIT-style; the `jlesage/docker-putty` repo license is MIT per gh api, which covers the packaging only). Put `LICENSE = "MIT"` in bake; confirm against `/usr/share/doc/putty/copyright` in the built image (UNVERIFIED). |
| Source URL | https://www.putty.org/ (website, draft); source tarball `https://the.earth.li/~sgtatham/putty/0.85/putty-0.85.tar.gz` (from upstream `ARG PUTTY_URL`) |
| Per-arch download | Source tarball, one for both arches. The upstream image is multi-arch via `tonistiigi/xx`. The draft's apt route avoids a compile. |
| Checksum source | None in the upstream Dockerfile. PuTTY publishes checksums on its site (UNVERIFIED: not fetched). Verify the tarball if built from source. |
| Upstream Dockerfile reviewed | `jlesage/docker-putty` tag v26.09.1 `Dockerfile`: `FROM jlesage/baseimage-gui:alpine-3.20-v4.14.0` (Alpine); build stage `alpine:3.20 AS putty` with `tonistiigi/xx`; `add-pkg gtk+3.0 adwaita-icon-theme ttf-dejavu`; no `EXPOSE`, `VOLUME`, `USER` or `ENTRYPOINT`; `set-cont-env APP_NAME=PuTTY`. |
| Ports | Not declared by the upstream Dockerfile. The noVNC (5800/http) and VNC (5900/tcp) ports come from the jlesage GUI base convention (UNVERIFIED for this image). |
| Env | Upstream sets `APP_NAME`, `APP_VERSION`, `DOCKER_IMAGE_VERSION` only. No user-facing env var was confirmed. |
| apt package | `putty` on ubuntu 26.04: UNVERIFIED (not confirmed on a fetched page). This is the draft's assumption and must be checked in the build. |
| arm64 | Upstream image is multi-arch (`xx`), so the software builds on arm64. The apt route for arm64 is UNVERIFIED. |
| Dependencies | None. |

## 2. Target layout

- `apps/putty/Dockerfile`
- `apps/putty/docker-bake.hcl`
- `apps/putty/settings.yaml`
- `apps/putty/container-test.yaml`
- `apps/putty/start.sh`
- `apps/putty/root/` is not used (reserved).

No `defaults/` or `etc/` unless the GUI session needs a config file (reason: UNVERIFIED). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Why: the draft's app is a GTK terminal installed from apt, so the generic ubuntu base is enough (draft: "Runtime image: none"). The upstream jlesage base is Alpine and is not reused. Closest sibling: `apps/kasmvnc` (ubuntu 26.04 with noVNC, ports 3000/3001, `CUSTOM_PORT`, `PASSWORD`); it is a VNC server app, not a base, but its noVNC/VNC setup is the precedent to reuse. No other VNC or noVNC app exists in `apps/`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends putty xvfb x11vnc novnc websockify` (package names UNVERIFIED for ubuntu 26.04; the desktop stack is needed to reach the GUI over VNC). Pin `putty` to an exact apt version and check it against `VERSION` in bake, as `apps/valkey` does. The resolved Ubuntu 26.04 package version is UNVERIFIED and may not be `0.85`; set bake `VERSION` to the resolved package version.
3. `rm -rf /var/lib/apt/lists/*`.
4. `COPY --chmod=0755 start.sh /start.sh`, `USER apps`, `COPY --chmod=0755 . /`.
5. `ENV HOME=/config`.
6. `EXPOSE 5800 5900`, `VOLUME /config`.

Draft says the chart uses a source compile; the apt route removes it, so no compile stage. License file for PuTTY `/usr/share/licenses/putty/LICENSE` if the apt package does not ship it (check `/usr/share/doc/putty/copyright`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "putty"
}

variable "VERSION" {
  // renovate: datasource=UNVERIFIED depName=putty
  default = "0.85" // UNVERIFIED: this is the upstream image's PUTTY_VERSION, not the Ubuntu apt package version
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://www.putty.org/"
}
```

Keep the four standard targets and default group as in `apps/adguardhome-sync`. Renovate source for the apt version is UNVERIFIED; state the chosen one in the PR. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://www.putty.org/"
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
volumes:
  - path: /config
    required: true
```

Port list follows the GUI convention (UNVERIFIED). Only list env vars the start script reads. Dependencies: none.

## 7. start.sh

- Create `/config` subfolders only when missing; PuTTY saves sessions and keys in `/config/.putty` (HOME=/config).
- Start `Xvfb :0` and `x11vnc` on 5900, `websockify` on 5800 to the noVNC web root, then `exec putty` (or a window manager wrapper, UNVERIFIED).
- Bind VNC and noVNC to `0.0.0.0`.
- Use `HOME=/config` so PuTTY stores sessions in `/config/.putty`; no writes to `/app`.
- X sockets and logs go to `/tmp`.
- `exec` the final process.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '5900'
- port: '5800'
http:
- port: '5800'
  path: /
filePaths:
- /start.sh
- /usr/bin/putty
```

Each port in `settings.yaml` has a probe. The `http` probe path is UNVERIFIED until noVNC is running.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Saved sessions and keys (`~/.putty`) | `HOME=/config`, so `/config/.putty` |
| X11 socket, Xvfb lock, VNC logs | `/tmp` |
| Chart `readOnlyRootFilesystem: false`, `runAsUser: 0`, caps `NET_BIND_SERVICE` and `KILL` | ContainerForge image runs as `apps` and needs no capabilities; ports are above 1024, so `NET_BIND_SERVICE` is not needed. Document in the PR. |

## 10. Risks, caveats and open questions

- Hard: a GUI over VNC is needed. This is a desktop app, not a CLI SSH client (draft, inferred).
- Hard: apt `putty` on ubuntu 26.04 is UNVERIFIED. If absent, fall back to the source tarball with checksum verification, and then the compile step is back.
- Hard: x11vnc and noVNC package names on ubuntu are UNVERIFIED.
- arm64: upstream builds on arm64, but the apt route is UNVERIFIED per arch.
- Caveat: without the `/config` mount, saved sessions are lost on recreation (draft, inferred).
- The chart's `NET_BIND_SERVICE` and `KILL` capabilities are not needed by this image (see section 9).

## 11. Build and test steps

```sh
cd apps/putty
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name putty-probe --read-only --tmpfs /tmp \
  -v putty-probe-config:/config putty:<version>
docker logs -f putty-probe
forgetool containers test --image putty:<version> --config ./apps/putty/container-test.yaml
docker rm -f putty-probe; docker volume rm putty-probe-config
```

Readiness signal: VNC port 5900 open, noVNC port 5800 answers HTTP (log line UNVERIFIED until run).

## 12. PR checklist

- Branch `feat/add-putty`, commit and PR title `feat(putty): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it; `license/cla` shows status.
- Untested to state honestly: the build, the apt package availability on 26.04, VNC and noVNC on `--read-only`, arm64.
- Do not check "Built container locally" unless a build ran.
