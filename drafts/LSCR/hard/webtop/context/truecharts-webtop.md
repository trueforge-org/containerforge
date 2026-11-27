# TrueCharts chart: webtop

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/webtop/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/webtop/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `webtop` version 15.0.8, appVersion `latest`, type application, category Tools-Utilities.
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; min helm 3.14, max helm 4.1.
- Sources listed: fleet.linuxserver.io, linuxserver/docker-webtop, linuxserver/gclient, GHCR package page.

## Image (values.yaml)
- Default: `lscr.io/linuxserver/webtop` tag `latest@sha256:621767192198030719863ab92651e22b45224a40143b6ca618ef89fe2bd70767`, pullPolicy IfNotPresent.
- Flavor images (all `lscr.io/linuxserver/webtop`, pullPolicy Always, pinned digests):
  - ubuntu-xfce, fedora-xfce, arch-xfce, alpine-kde, ubuntu-kde, fedora-kde, arch-kde
  - alpine-mate, ubuntu-mate, fedora-mate, arch-mate
  - alpine-i3, ubuntu-i3, fedora-i3, arch-i3
  - alpine-openbox, ubuntu-openbox, fedora-openbox, arch-openbox
  - alpine-icewm, ubuntu-icewm, fedora-icewm, arch-icewm
- Note: values.yaml still lists openbox and icewm tags; upstream docs (see linuxserver-webtop-docs.md) say openbox and icewm were dropped in the 17.06.25 rebase.

## Ports
- `service.main.ports.main.port: 33000`, protocol `http`.
- Env `CUSTOM_PORT` = `{{ .Values.service.main.ports.main.port }}` (33000).
- Upstream image listens on 3000 (HTTP) and 3001 (HTTPS). Dockerfile `EXPOSE 3000`.

## Persistence
- `persistence.config`: enabled, mountPath `/config`.

## Security context
- `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsGroup: 0`, `runAsUser: 0`.
- Chart runs the container as root (uid 0 / gid 0).

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| KEYBOARD | `en-us-qwerty` |
| CUSTOM_PORT | `{{ .Values.service.main.ports.main.port }}` (33000) |

## Probes / healthcheck
- None defined in values.yaml.

## Gotchas
- Chart pins root and writable rootfs; conflicts with the repo's rootless / read-only-rootfs rules unless the image is rebuilt to match.
- `CUSTOM_PORT` drives the internal listener in upstream images; values.yaml port 33000 is the chart Service port.
- Image tags use `<distro>-<desktop>` naming; `latest` is documented upstream as transitioning to ubuntu/Selkies.
