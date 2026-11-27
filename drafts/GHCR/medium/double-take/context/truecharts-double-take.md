# TrueCharts double-take chart

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/double-take/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/double-take/values.yaml
- Fetched 2026-11-27

## What it is
- Chart `double-take` v16.0.0, appVersion `1.13.11`, type application, keywords ai, double-take.
- Description: unified UI and API for processing and training images for facial recognition.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; min helm 3.14; max helm 4.1; max k8s 1.35.0.
- Chart sources: `ghcr.io/skrashevich/double-take` (fork), github.com/jakowenko/double-take (upstream).

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/skrashevich/double-take` |
| tag | `v1.13.11@sha256:e91d1d4c144bcf9574cab0f37675cc525e78799706b47fdbee3eb1efa6f7b815` |
| pullPolicy | IfNotPresent |

## Ports
- Service `main`, port `main`: `port: 10200`, `targetPort: 3000` (protocol not set, default TCP).

## Probes
- liveness, readiness, startup: `type: http`, `path: /`.

## Env
- `env: {}` (none set in chart).

## Persistence
| Name | Mount path |
| --- | --- |
| data | `/.storage` (enabled) |

## Security context
- Not set in values (chart defaults).

## Gotchas
- Chart runs the fork image at tag v1.13.11 with digest pin, not upstream jakowenko.
- Storage path `/.storage` is the upstream/fork hardcoded data path.
- Probes are HTTP on `/` for liveness, readiness and startup.
