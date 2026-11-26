# TrueCharts chart: nightscout

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nightscout/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nightscout/Chart.yaml (2026-11-26)

## What it is
Chart for Nightscout, a remote CGM monitoring web app. Chart version 11.0.0, `appVersion: latest`, library dep `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
- repository: `docker.io/nightscout/cgm-remote-monitor-travis`
- tag: `latest@sha256:3ace874753e834b9c9b8a242df67f86329b04a3a48584452ae45207bfbfdb271`

## Ports
| Name | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main | 1337 | tcp | 1337 |

## Env vars (workload main, container main)
| Name | Value in chart | Notes |
| --- | --- | --- |
| API_SECRET | secretKeyRef env-secrets/API_SECRET | |
| MONGO_CONNECTION | secretKeyRef env-secrets/MONGO_CONNECTION | |
| BASE_URL | "" | |
| BG_HIGH, BG_LOW, BG_TARGET_BOTTOM, BG_TARGET_TOP | "" | |
| DISPLAY_UNITS | "" | |
| ENABLE | `delta direction upbat timeago devicestatus errorcodes ar2 simplealarms profile` | |
| INSECURE_USE_http | "true" | |
| THEME | colors | |
| TIME_FORMAT | "24" | |

## Secrets
- secret `env-secrets` (enabled): `API_SECRET: ""`, `MONGO_CONNECTION: "mongodb://db-user:db-password@mongodb-instance:port/db-name"` (placeholder).

## Persistence / probes / security
- persistence: `{}` (none)
- securityContext.container: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`
- No probe overrides in values.yaml.

## Gotchas
- Chart runs as root (uid 0) and disables read-only rootfs, which differs from the upstream image's `USER node`. Container-side reproduction needs upstream behaviour in mind.
- Chart requires an external MongoDB (no bundled DB in values).
