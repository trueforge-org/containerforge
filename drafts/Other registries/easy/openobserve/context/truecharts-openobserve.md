# TrueCharts chart: openobserve

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/openobserve/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/openobserve/values.yaml (fetched 2026-11-27)

## What it is
- Chart `openobserve` version 5.0.0, appVersion 1.1.2, category `inventory`.
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; min helm 3.14, max helm 4.1.
- Keywords: logs, metrics, traces, observability.

## Image
- `public.ecr.aws/zinclabs/openobserve` tag `v1.1.2@sha256:4a154849432f75c4fb024de32fe34163c02406c905dab22bf8d213d2e3386392`, pullPolicy IfNotPresent.

## Ports
- `service.main.ports.main.port: 5080` (upstream ZO_HTTP_PORT default 5080).

## Persistence
- `persistence.data`: enabled, mountPath `/data`.

## Env (workload.main.podSpec.containers.main.env)
| Name | Value in chart |
| --- | --- |
| ZO_ROOT_USER_EMAIL | `admin@example.com` |
| ZO_ROOT_USER_PASSWORD | secretKeyRef `env-secrets` / `ZO_ROOT_USER_PASSWORD` |
| ZO_DATA_DIR | `/data` |
| ZO_WEB_URL | `https://logs.example.com` |
| ZO_TELEMETRY | `"false"` |

## Secret
- `secret.env-secrets` enabled, key `ZO_ROOT_USER_PASSWORD` with a placeholder value (must be replaced; values.yaml contains a literal example password).

## Probes
- liveness, readiness, startup all `path: "/healthz"` (no port set; uses service port 5080 by default).

## Gotchas
- Chart carries placeholder credentials (`admin@example.com`, example password) and `logs.example.com` URL.
- `ZO_DATA_DIR=/data` must match the `/data` persistence mountPath.
