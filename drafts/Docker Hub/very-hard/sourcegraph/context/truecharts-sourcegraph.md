# TrueCharts chart: sourcegraph

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sourcegraph/Chart.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sourcegraph/values.yaml (2026-11-27)

## What it is
- Chart `sourcegraph` v12.0.0, `appVersion: 6.12.5040`, category Backup, train stable.
- Description: "Sourcegraph Chart." (no further detail in chart).
- Library dep: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; Helm 3.14 to 4.1; Kubernetes max 1.35.0.

## Image
- `docker.io/sourcegraph/server`
- tag `6.12.5040@sha256:57a5802dfb3fbe368a4bf720ef3dc854286344267ce6e2bac80072e51810fee7`
- pullPolicy IfNotPresent

## Ports
| Service | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main | 7080 | http | 7080 |
| adminconsolepo | 2633 | tcp | 2633 (enabled) |
| grafanaport | 3370 | tcp | 3370 (enabled) |

## Volumes / paths
| Persistence | mountPath |
| --- | --- |
| applicationdatastoragepath | /var/opt/sourcegraph |
| configstoragepath | /etc/sourcegraph |

## Env vars
- None in values.yaml.

## Security context
- `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Gotchas
- No dependency (Postgres/Redis) declared in the chart; no env, no probes configured in values.
