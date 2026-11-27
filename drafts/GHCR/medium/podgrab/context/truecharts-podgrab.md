# TrueCharts chart: podgrab (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/podgrab/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/podgrab/Chart.yaml (2026-11-27)

What it is: "A self-hosted podcast manager to download episodes as soon as they become live." Chart `version: 23.0.0`, `appVersion: 1.0.0`. Category written as `mutlimedia` in Chart.yaml (typo in source).

Image (values.yaml):
- repository `ghcr.io/akhilrex/podgrab`
- tag `1.0.0@sha256:bce133f3f5111381f63d9341313fa7ce7e16209068e8a06e6db2c4ed33972b87`
- pullPolicy Always

Ports:
| Service | Port | targetPort | Enabled |
| --- | --- | --- | --- |
| main | 10093 | 8080 | yes |
| tcp | 51080 | 51080 | yes |

Volumes/paths: persistence `config`, enabled, mountPath `/config`. (Upstream also declares `/assets` as the data volume; the chart does not mount it in these values.)

Env vars (workload main):
| Name | Value |
| --- | --- |
| CHECK_FREQUENCY | 240 |
| PASSWORD | secretKeyRef `env-secrets` key `PASSWORD` |

Secret: `env-secrets` with `PASSWORD: "secretpasswordgoeshere"` (placeholder in values, must be changed).

Probes: liveness, readiness, startup all disabled.

User/UID: `securityContext` not set in values, so chart defaults apply. Upstream Dockerfile sets `ENV UID=998`, `PID=100` (app-level variables, not Linux user).

Gotchas:
- Chart's `tcp` service on 51080 has no matching upstream EXPOSE or port documented in the fetched Dockerfile (Dockerfile exposes 8080 only).
- Placeholder password in values.
