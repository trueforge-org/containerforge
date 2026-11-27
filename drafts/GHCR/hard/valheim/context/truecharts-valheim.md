# TrueCharts chart: valheim

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/valheim/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts chart for `ghcr.io/lloesche/valheim-server` (Valheim dedicated server, auto-update, backups).
- Chart `version: 16.0.0`, `appVersion: latest`, category media, train stable.

## Runtime deps
- Helm library `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Image
- `repository: ghcr.io/lloesche/valheim-server`, `tag: latest@sha256:fde7829b...`, pullPolicy IfNotPresent.

## Ports
| Service | Port | Target | Protocol | Note |
| --- | --- | --- | --- | --- |
| main | 9010 | | tcp | STATUS_HTTP |
| supervisor | 9011 | | tcp | SUPERVISOR_HTTP (ingress disabled by default) |
| valheim (LoadBalancer) | 2456 | | udp | valheim1, SERVER_PORT |
| valheim (LoadBalancer) | 2457 | | udp | valheim2 |

## Env vars (chart)
| Var | Value |
| --- | --- |
| STATUS_HTTP | true |
| STATUS_HTTP_PORT | {{ service.main.ports.main.port }} (9010) |
| SUPERVISOR_HTTP | true |
| SUPERVISOR_HTTP_PORT | {{ service.supervisor.ports.supervisor.port }} (9011) |
| SUPERVISOR_HTTP_USER | admin |
| SUPERVISOR_HTTP_PASS | secret `env-secrets` (default "secret") |
| SERVER_NAME | My Server |
| SERVER_PORT | {{ valheim1 port }} (2456) |
| SERVER_PASS | secret `env-secrets` (default "secret") |
| WORLD_NAME | Dedicated |
| SERVER_PUBLIC | true |
| UPDATE_INTERVAL | 10800 |
| BACKUPS | true |
| BACKUPS_INTERVAL | 43200 |
| BACKUPS_DIRECTORY | /backups |
| BACKUPS_MAX_AGE | 3 |

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| config | /config | enabled |
| backups | /backups | enabled |
| varrun | (none) | enabled: false |

## Probes
- liveness, readiness, startup: all `type: tcp`.

## User/UID
- `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Gotchas
- Default secret values "secret" in chart values.yaml; override required.
- Chart runs as root with writable rootfs.
