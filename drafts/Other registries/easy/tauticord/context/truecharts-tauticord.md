# TrueCharts chart: tauticord

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tauticord/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tauticord/values.yaml (fetched 2026-11-27)

## What it is
- Chart `tauticord` version 13.0.0, appVersion 6.2.0, category `discord`.
- Discord bot showing live data from Tautulli. Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; min helm 3.14, max helm 4.1.

## Image
- `codeberg.org/nwithan8/tauticord` tag `6.2.0@sha256:085be70cc7599d15ae7046247e527beed67102f72f71c6cd0cf47a1e5024d031`, pullPolicy IfNotPresent.

## Ports
- `service.main.ports.main`: port 8283, protocol http, targetPort 8283. Comment in values: used for webhook; can be disabled.

## Persistence
| Name | Mount |
| --- | --- |
| config | `/config` (enabled) |
| logs | `/logs` (enabled) |
| monitor | `/monitor` (enabled; media libraries) |

## Security context
- `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`.

## Probes
- liveness, readiness, startup: path `/ping`, enabled only when `service.main.enabled`.

## Env
- `env: {}` (none set in chart).

## Gotchas
- Chart runs as root and with writable rootfs.
- Chart mounts `/monitor` (not in upstream Dockerfile VOLUME list); Dockerfile declares VOLUME `/config` and `/logs` only.
