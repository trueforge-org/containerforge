# TrueCharts chart: pingvin-share (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pingvin-share/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pingvin-share/Chart.yaml (2026-11-27)

What it is: "Pingvin Share is self-hosted file sharing platform and an alternative for WeTransfer." Chart `version: 7.0.0`, `appVersion: 1.13.0`. Category files. Depends on `common` (version in Chart.yaml, not re-read here).

Image (values.yaml):
- repository `ghcr.io/stonith404/pingvin-share`
- tag `v1.13.0@sha256:6bf2bcd3043ee68cb61264f0857511ccf7f212fdb984382b7f2d491635184ad6`
- pullPolicy IfNotPresent

Ports (service main): protocol http, port 3333, targetPort 3333.

Volumes/paths:
| Persistence | mountPath |
| --- | --- |
| data | `/opt/app/backend/data` |
| image | `/opt/app/frontend/public/img` |

User/UID: `securityContext.container` runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false (runs as root; the image's create-user.sh drops to PUID/PGID, default 1000).

Env vars: none set in values.yaml.

Healthcheck: none in chart values. Upstream Dockerfile HEALTHCHECK is `curl -fs http://localhost:3000/api/health` (or BACKEND_PORT when CADDY_DISABLED).

Gotchas:
- Chart port 3333 is the frontend port started by entrypoint (`PORT=3333`), not the upstream EXPOSE 3000.
- Image tag in chart is `v1.13.0` (with `v` prefix).
