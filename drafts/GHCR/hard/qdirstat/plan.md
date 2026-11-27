# qdirstat — implementation plan
> Source: ./draft.md · Target: apps/qdirstat/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Chart image | `ghcr.io/jlesage/qdirstat:v26.11.3` (TrueCharts `charts/stable/qdirstat`, draft) |
| Upstream image Dockerfile | `jlesage/docker-qdirstat` tag v26.09.1 `Dockerfile`: `FROM jlesage/baseimage-gui:alpine-3.20-v4.14.0`; build stage `alpine:3.20 AS qdirstat` runs `/build/build.sh` with `QDIRSTAT_URL`; final stage copies `/tmp/qdirstat-install/usr/bin/qdirstat`; `add-pkg` installs `qt6-qtbase-x11 qt6-qt5compat adwaita-qt mesa-gl font-croscore file git make xterm`; `VOLUME ["/storage"]`; no `EXPOSE`, `USER` or `ENTRYPOINT`. |
| Latest upstream software release | `2.0.1`, published 2026-11-22 (`gh api repos/shundhammer/qdirstat/releases/latest`). The upstream Dockerfile at v26.09.1 defaults `QDIRSTAT_VERSION=2.0`. Use `2.0.1` as `VERSION` only after the build confirms it compiles. |
| Renovate | `datasource=github-releases depName=shundhammer/qdirstat versioning=loose` (tags are not strict semver in the repo list; `versioning=loose` per the bake rule). |
| License | GPL-2.0 (`gh api repos/shundhammer/qdirstat license.spdx_id`). Put `LICENSE = "GPL-2.0"` in bake. |
| Source URL | https://github.com/shundhammer/qdirstat (draft) |
| Per-arch download | apt package `qdirstat` (draft, UNVERIFIED on ubuntu 26.04 for amd64 and arm64). Alternative: source archive `https://github.com/shundhammer/qdirstat/archive/<tag>.tar.gz`, as the upstream image does. |
| Checksum source | None in the upstream Dockerfile. GitHub archive checksums are not published as release assets (UNVERIFIED). |
| Ports | Not declared upstream. The noVNC (5800/http) and VNC (5900/tcp) ports come from the jlesage GUI base convention (UNVERIFIED for this image). |
| Env | Upstream sets `QDIRSTAT_STARTUP_SCAN_FOLDER` (empty default), `APP_NAME`, `APP_VERSION`, `DOCKER_IMAGE_VERSION`. |
| Data path | `/storage` (`VOLUME` in upstream; chart PVC `storage`). Read-only scan target, not a write path. |
| arm64 | UNVERIFIED for the upstream image (multi-arch via `xx` is likely, not confirmed). Apt `qdirstat` arm64 availability is UNVERIFIED. |
| Dependencies | None. |

## 2. Target layout

- `apps/qdirstat/Dockerfile`
- `apps/qdirstat/docker-bake.hcl`
- `apps/qdirstat/settings.yaml`
- `apps/qdirstat/container-test.yaml`
- `apps/qdirstat/start.sh`

No `defaults/` or `etc/` unless the GUI needs a config file (reason: UNVERIFIED). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Why: the app is a Qt desktop tool installed from apt (draft). The upstream jlesage Alpine base is not reused. Closest sibling: the same GUI-over-VNC pattern as `apps/putty` (this plan's sibling in the batch); `apps/kasmvnc` (ubuntu 26.04, noVNC on 3000/3001) is the only existing VNC precedent in `apps/`; reuse its setup where it fits.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends qdirstat xvfb x11vnc novnc websockify` (package names UNVERIFIED for ubuntu 26.04; `qdirstat` pins to the Ubuntu package version, check against `VERSION`).
3. Optional: if the apt package is absent or too old, build from the source archive in a build stage with Qt6 dev packages, then `COPY --from=build` (UNVERIFIED path). Source archive needs a checksum check against the tag.
4. `rm -rf /var/lib/apt/lists/*`.
5. `COPY --chmod=0755 start.sh /start.sh`, `USER apps`, `COPY --chmod=0755 . /`.
6. `ENV HOME=/config`.
7. `EXPOSE 5800 5900`, `VOLUME /config`.

The upstream `VOLUME /storage` is not reproduced as a write path. Scanning needs read access to the mounted storage (see section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "qdirstat"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=shundhammer/qdirstat versioning=loose
  default = "2.0.1" // UNVERIFIED: 2.0.1 is the upstream GitHub release; the Ubuntu apt package may differ
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/shundhammer/qdirstat"
}
```

Keep the four standard targets and default group as in `apps/adguardhome-sync`. If the image is built from the apt package, `VERSION` must match the package version that `apt` installs (see section 4 step 2). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/shundhammer/qdirstat"
ports:
  - port: 5800
    protocol: tcp
    required: false
  - port: 5900
    protocol: tcp
    required: false
env:
  - name: QDIRSTAT_STARTUP_SCAN_FOLDER
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /storage
    required: false
```

`QDIRSTAT_STARTUP_SCAN_FOLDER` is read by upstream's start logic (UNVERIFIED that it is read here). Remove it if `start.sh` does not use it. `/storage` is listed only as a documented read-only mount.

## 7. start.sh

- Create `/config` subpaths only when missing (QDirStat settings under `/config/.config`).
- Start `Xvfb :0`, `x11vnc` on 5900, `websockify` on 5800 to noVNC.
- If `QDIRSTAT_STARTUP_SCAN_FOLDER` is set, pass it as the scan path to `qdirstat` (UNVERIFIED argument syntax).
- `exec qdirstat` (or a wrapper), bind to `0.0.0.0`.
- No writes to `/app`. X sockets and scratch in `/tmp`.

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
- /usr/bin/qdirstat
```

Each port in `settings.yaml` has a probe. The `http` path is UNVERIFIED until noVNC runs.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| QDirStat settings (`~/.config`) | `HOME=/config` |
| X11 socket, Xvfb lock, VNC logs | `/tmp` |
| Scan target `/storage` (read) | Mounted read-only by the user; the container user (`apps`, UID 568) must be able to read it (draft caveat). |
| Chart `runAsUser: 0`, caps `NET_BIND_SERVICE`, `KILL` | Not needed: ports are above 1024 and the image runs as `apps`. |

## 10. Risks, caveats and open questions

- Hard: GUI only, reached through VNC or noVNC (draft, inferred).
- Hard: Qt6 stack (qt6-qtbase, adwaita) and X11 libraries on ubuntu are UNVERIFIED package names for 26.04.
- Scanning large trees reads everything under `/storage` and uses significant RAM (draft, inferred). Mounts must be readable by UID 568.
- The `qdirstat` apt package version may differ from the upstream source `2.0.1`. Decide and document which one is built.
- arm64: UNVERIFIED for both the upstream image and the apt package.
- No blocker is confirmed. Difficulty stays hard because of the desktop stack.

## 11. Build and test steps

```sh
cd apps/qdirstat
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name qdirstat-probe --read-only --tmpfs /tmp \
  -v qdirstat-probe-config:/config qdirstat:<version>
docker logs -f qdirstat-probe
forgetool containers test --image qdirstat:<version> --config ./apps/qdirstat/container-test.yaml
docker rm -f qdirstat-probe; docker volume rm qdirstat-probe-config
```

Readiness signal: VNC port 5900 open and noVNC port 5800 answers HTTP (log line UNVERIFIED until run).

## 12. PR checklist

- Branch `feat/add-qdirstat`, commit and PR title `feat(qdirstat): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it; `license/cla` shows status.
- Untested to state honestly: the build, apt package availability on 26.04, the source build if used, VNC and noVNC on `--read-only`, scanning `/storage`, arm64.
- Do not check "Built container locally" unless a build ran.
