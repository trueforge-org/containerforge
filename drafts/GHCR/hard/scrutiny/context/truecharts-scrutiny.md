# TrueCharts chart: scrutiny

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/scrutiny/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/scrutiny/values.yaml (fetched 2026-11-27)

## What it is
- Chart v16.0.0, appVersion 0.10.0. Category utilities.
- "Scrutiny WebUI for smartd S.M.A.R.T monitoring". Hard drive health dashboard.
- Sources: ghcr.io/analogj/scrutiny.
- Deps: common 32.8.5 (oci://oci.trueforge.org/truecharts)

## Image (values.yaml)
- `ghcr.io/analogj/scrutiny`, tag `v0.10.0-omnibus@sha256:90062edac57a2bd891d641344184f5f730f19394b1124f6fc53904a3d8cb21c2`

## Ports
| name | port | targetPort |
| --- | --- | --- |
| main | 10151 | 8080 |

## Persistence
| name | type | mountPath |
| --- | --- | --- |
| varrun | default | (chart default) |
| config | default | /opt/scrutiny/config |
| influxdb | default | /opt/scrutiny/influxdb |
| udev | hostPath /run/udev | /run/udev (readOnly) |

## Security context (chart)
- privileged true, allowPrivilegeEscalation true
- capabilities add: SYS_RAWIO (HDDs), SYS_ADMIN (NVMe)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false

## Env (container main, set by chart)
| key | value |
| --- | --- |
| COLLECTOR_CRON_SCHEDULE | "0 0 * * *" |
| COLLECTOR_HOST_ID | "TrueNAS" |

## Probes
- liveness, readiness, startup: HTTP path `/api/health`

## Gotchas
- Chart requires host device access (privileged, hostPath /run/udev) for SMART data.

---
