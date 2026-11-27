# TrueCharts chart: crafty-4

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/crafty-4/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/crafty-4/values.yaml (fetched 2026-11-27)

## What it is
- Chart `crafty-4` version 13.0.0, appVersion 4.11.1, category GameServers.
- Depends on `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`). kubeVersion `>=1.33.0-0`; min helm 3.14, max helm 4.1.

## Image
- `registry.gitlab.com/crafty-controller/crafty-4` tag `4.11.1@sha256:e40accbeeb3e66dea0842c0673484e459eccf021825fb33ad1cd0ef6111ce365`, pullPolicy IfNotPresent.

## Security context
- `readOnlyRootFilesystem: false`, `runAsUser: 1000`, `runAsGroup: 1000`.

## Ports
| Service | Port (svc) | Protocol | targetPort |
| --- | --- | --- | --- |
| main | 10586 | https | 8443 |
| redirects (enabled) | 10587 | https | 8000 |
| minecraft (enabled) | 25565 | tcp (default) | 25565 |
| bedrock (enabled) | 19132 | udp | 19132 |

## Persistence
| Name | Mount |
| --- | --- |
| config | `/crafty/app/config` |
| servers | `/crafty/servers` |
| logs | `/crafty/logs` |
| import | `/crafty/import` |
| backups | `/crafty/backups` |

## Probes
- liveness/readiness/startup: type https, path `/`.

## Env
- `env: {}` (none set).

## Gotchas
- Chart runs as uid/gid 1000 (non-root); upstream container entrypoint uses sudo/root logic only when started as root.
- Redirects port 8000 is exposed by the upstream Dockerfile but is absent from the upstream Docker install docs run command (which publishes 8443, 8123, 19132/udp, 25500-25600).
- Upstream Dockerfile does not EXPOSE 25565 (chart maps it); EXPOSE lists 5520-5550, 8000, 8123, 8443, 19132, 25500-25600.
- Persistence paths match upstream docs `-v` mounts (backups, logs, servers, config, import).
