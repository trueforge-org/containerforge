# TrueCharts chart: ddns-go

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ddns-go/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ddns-go/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `ddns-go` version 16.0.0, appVersion 6.18.0, category cloud, train stable.
- Description: automatically obtain public IPv4 or IPv6 address and resolve it to DNS.
- Chart sources: `https://ghcr.io/jeessy2/ddns-go`, https://github.com/jeessy2/ddns-go.
- Dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
| Key | Value |
| --- | --- |
| repository | `ghcr.io/jeessy2/ddns-go` (GHCR) |
| tag | `v6.18.0@sha256:3dd66ffc7490487e02f9d94e414786c79e9b80c046792f612a1033eca872af12` |
| pullPolicy | IfNotPresent |

## Runtime
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- workload.main env: `{}` (none set by chart).

## Ports
| Name | Port | targetPort | Protocol |
| --- | --- | --- | --- |
| main | 10168 | 9876 | http |

## Volumes
| Persistence | mountPath |
| --- | --- |
| data (enabled) | /root |

## Probes
- liveness, readiness, startup: `type: http`, `path: /` (targets container port 9876).

## Gotchas
- Chart service port 10168 maps to container 9876. Upstream image listens on 9876 by default.
- Config file lives under `/root` (upstream uses `-c` default under home); chart mounts the whole `/root`.
- Image is GHCR only in the chart; upstream README also lists `jeessy/ddns-go` on Docker Hub (not fetched).
