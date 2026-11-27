# TrueCharts chart: homepage

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homepage/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homepage/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `homepage` version 15.0.0, `appVersion: 2.8.0`. Self-hosted services landing page (gethomepage).

## Image
- `repository: ghcr.io/gethomepage/homepage`
- `tag: v2.8.0@sha256:019d8f063a7299e7c1c51ee4a70b692291809af3244894fbec2c2ac7d1f71b18`
- `pullPolicy: IfNotPresent`

## Env vars (chart)
| Name | Chart value |
| --- | --- |
| HOMEPAGE_ALLOWED_HOSTS | `localhost` |

## Init container
- `init-config` (imageSelector `ubuntuImage`, type init): `mkdir -p /app/config`; copies dummy files from `/dummy-config/` into `/app/config/` when missing: `bookmarks.yaml`, `services.yaml`, `settings.yaml`, `widgets.yaml`, `custom.css`, `custom.js`.

## Ports
- Service `main`: port 10352 -> targetPort 3000, protocol http.

## Probes
- Liveness, readiness, startup: HTTP GET `/api/healthcheck` with header `Host: localhost:3000`.

## Volumes/paths
- `config` -> `/app/config` (mounted in main and init-config).
- `kubernetes-config` -> `/app/config/kubernetes.yaml` (configmap `config`, subPath kubernetes.yaml, readOnly).
- Config files from configmap `config` (subPath each): `bookmarks.yaml`, `settings.yaml`, `services.yaml`, `widgets.yaml`, `custom.css`, `custom.js`. Mounted at `/dummy-config/*` (copied by init) unless `forceConfigFromValues` is true, in which case mounted at `/app/config/*` (readOnly).

## Config files
- configmap `config` keys (see values `configmap.config`, not expanded here): bookmarks.yaml, settings.yaml, services.yaml, widgets.yaml, custom.css, custom.js, kubernetes.yaml.
- Chart toggle `forceConfigFromValues` switches between copy-from-dummy and direct mount.

## User/UID
- Not set in values. Upstream runs root default then `su-exec` to PUID/PGID (see GitHub file).

## Other
- ServiceAccount `main` primary; `automountServiceAccountToken: true`.
- podOptions dnsConfig `ndots: "3"`.

## Healthcheck
- Probes above. Upstream HEALTHCHECK: `wget ... http://127.0.0.1:$PORT/api/healthcheck` every 10s.

## Gotchas
- Next.js host check: `HOMEPAGE_ALLOWED_HOSTS` must include the Host header used by the probes and clients (`localhost` in chart).
- Chart init container requires dummy configs to exist in the configmap.
