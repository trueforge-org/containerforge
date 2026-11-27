# TrueCharts chart: tsmuxer

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tsmuxer/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts chart for `ghcr.io/jlesage/tsmuxer` (tsMuxeR in GUI/VNC via jlesage baseimage-gui).
- Chart `version: 17.1.1`, `appVersion: 26.11.2`, category media, train stable.

## Runtime deps
- Helm library `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Image
- `image.repository: ghcr.io/jlesage/tsmuxer`, `tag: v26.11.2@sha256:c4b9ae1e...`, pullPolicy IfNotPresent.

## Ports
| Service | Port | Target | Note |
| --- | --- | --- | --- |
| main | 10274 | 5800 | web VNC UI |
| vnc (enabled) | 10275 | 5900 | raw VNC |

## Env vars (via configmap `tsmuxer` envFrom, plus secret)
| Var | Default | Note |
| --- | --- | --- |
| KEEP_APP_RUNNING | "0" (false) | ternary of bool |
| DISPLAY_WIDTH | 1280 | |
| DISPLAY_HEIGHT | 768 | |
| SECURE_CONNECTION | "0" (false) | ternary of bool |
| ENABLE_CJK_FONT | "0" (false) | ternary of bool |
| VNC_PASSWORD | "" | from secret `env-secrets`, key `VNC_PASSWORD` |

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| config | /config | enabled |
| storage | /storage | enabled |

## Probes
- liveness, readiness, startup: all `type: tcp`.

## User/UID
- `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`.
- Container capabilities added: NET_BIND_SERVICE, KILL.

## Upstream Dockerfile (jlesage/docker-tsmuxer, tag v26.09.1)
Source URL: https://raw.githubusercontent.com/jlesage/docker-tsmuxer/v26.09.1/Dockerfile (fetched 2026-11-27)
- Build args: `DOCKER_IMAGE_VERSION` (empty default), `TSMUXER_VERSION=2.7.0`, `TSMUXER_URL=https://github.com/justdan96/tsMuxer/archive/refs/tags/${TSMUXER_VERSION}.tar.gz`.
- Stage 1: `tonistiigi/xx` cross helpers; stage 2 `alpine:3.20` runs `src/tsmuxer/build.sh "$TSMUXER_VERSION" "$TSMUXER_URL"` (build.sh not fetched); `xx-verify` on `tsmuxer` and `tsMuxerGUI`.
- Final base: `jlesage/baseimage-gui:alpine-3.20-v4.14.0`.
- `add-pkg qt5-qtbase-x11 qt5-qtmultimedia adwaita-qt font-croscore`.
- Icon: `install_app_icon.sh` from jlesage/docker-templates tsmuxer-icon.png.
- `COPY rootfs/ /`; binaries to `/usr/bin/`.
- `set-cont-env APP_NAME "tsMuxeR"`, `APP_VERSION`, `DOCKER_IMAGE_VERSION`.
- `VOLUME ["/storage"]`; WORKDIR /tmp.
- Labels: org.label-schema.* (name, description, version from DOCKER_IMAGE_VERSION, vcs-url).

## Gotchas
- Upstream Dockerfile in plan URL is tag v26.09.1 while chart appVersion is 26.11.2; the image tag differs.
- Chart runs as root with writable rootfs.
