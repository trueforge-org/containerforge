# TrueCharts chart: nullserv (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nullserv/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nullserv/Chart.yaml (2026-11-27)

What it is: "A simple null file http and https server". Chart `version: 19.0.0`, `appVersion: 1.3.0`. Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0. Category: media.

Image (values.yaml):
- repository `ghcr.io/k8s-at-home/nullserv` (legacy namespace, not the upstream repo)
- tag `v1.3.0@sha256:0792c7e6d814bf292455da3f40aa5d56c465f2b5024e786ac3bf3dc3b16cc757`
- pullPolicy IfNotPresent

Ports (service):
| Service | Port | targetPort | Enabled |
| --- | --- | --- | --- |
| main | 10004 | 80 (http) | yes |
| https | 10005 | 443 (https) | yes |

Volumes/paths: persistence `config`, enabled, mountPath `/config`.

User/UID: chart sets `securityContext.container.runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false` (runs as root).

Healthcheck: readiness `type: http`, `path: /welcome.txt`, `port: 80`. No liveness/startup set in values.

Workload: `replicas: 2`.

Config files: none in chart values (no env vars set).

Gotchas:
- Chart maps 80/443 to 10004/10005 host-side service ports; the image itself listens on 80/443 by default.
- Chart uses root; upstream README documents running as non-root only via OS-level low-port tweak.
