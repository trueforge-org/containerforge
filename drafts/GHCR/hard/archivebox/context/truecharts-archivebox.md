# TrueCharts archivebox (chart 8.0.0)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/archivebox/{values.yaml,Chart.yaml} (fetched 2026-11-27)

## What it is
- Chart `archivebox`, version 8.0.0, appVersion 0.9.77, train stable, common 32.8.5 dependency.
- Sources: ghcr.io/archivebox/archivebox, github ArchiveBox/ArchiveBox.

## Image
- repository: `ghcr.io/archivebox/archivebox`
- tag: `0.9.77@sha256:f63170551ec48d7aa087c71e2d093156dbf4b4ed8680e2f97f22483e3bc71e55`
- pullPolicy: IfNotPresent

## Security context
- readOnlyRootFilesystem: false, runAsNonRoot: false, runAsUser: 0, runAsGroup: 0

## Ports
| Name | Protocol | Port (service) | targetPort |
| --- | --- | --- | --- |
| main | http | 9598 | 5797 |

## Workload command (chart)
- command: `/bin/bash -c`
- args: `chown "${PUID}:${PGID}" /data` then `exec dumb-init -- /app/bin/docker_entrypoint.sh archivebox server --init 0.0.0.0:5797`
- Chart chowns /data using PUID/PGID; these are not set in values.yaml (source of their default not read).

## Env (chart)
| Env | Value |
| --- | --- |
| ADMIN_USERNAME | `admin` (from config.admin_username) |
| ADMIN_PASSWORD | secretKeyRef `env-secrets`/`ADMIN_PASSWORD` (default `changeme`) |
| DATA_DIR | `/data` |

## Probes
- liveness: http, path `/health/`.

## Persistence
| Name | mountPath |
| --- | --- |
| data | /data |
| config | /opt/archivebox |
| home | /home/archivebox |

## Gotchas
- Chart default admin password is `changeme` (secret).
- Chart runs as root (UID 0) and chowns /data on start.
