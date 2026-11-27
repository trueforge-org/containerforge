# TrueCharts chart: send

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/send/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/send/values.yaml (fetched 2026-11-27)

## What it is
- Chart `send` version 15.0.0, appVersion `latest`, category Cloud.
- Fork of Mozilla Firefox Send (file sharing). Depends on `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`) and valkey (enabled).
- kubeVersion `>=1.33.0-0`.

## Image
- `registry.gitlab.com/timvisee/send` tag `latest@sha256:f902393380dc205b5b0a45c90f2666c167a5be0b6e4d0c54ab19ddbe36f3dce4`, pullPolicy IfNotPresent.

## Ports
- `service.main.ports.main`: port 1443, protocol http (targetPort not set; upstream listens on 1443).

## Security context
- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Persistence
- `persistence.uploadpath`: enabled, mountPath `/uploads`.

## Env (main container)
| Name | Value in chart |
| --- | --- |
| FILE_DIR | `{{ .Values.persistence.uploadpath.mountPath }}` (/uploads) |
| PORT | `{{ .Values.service.main.ports.main.port }}` (1443) |
| BASE_URL | `http://192.168.0.100:1443` (placeholder) |
| MAX_DOWNLOADS | "100" |
| MAX_EXPIRE_SECONDS | "604800" |
| MAX_FILE_SIZE | "2147483648" |
| NODE_ENV | `production` |
| REDIS_HOST | secretKeyRef `<release>-valkeycreds` / `plainhost` |
| REDIS_PASSWORD | secretKeyRef `<release>-valkeycreds` / `valkey-password` |
| REDIS_USER | "default" |
| REDIS_PORT | "6379" |

## Probes / healthcheck
- None defined.

## Gotchas
- `BASE_URL` is a LAN placeholder (`192.168.0.100`); must be replaced for real use.
- Chart runs as root (uid/gid 0); upstream image runs as `app` uid 1000.
- Redis/Valkey is the metadata DB; chart sets REDIS_* from valkey secret.
- MAX_FILE_SIZE chart value 2147483648 matches docs; upstream config.js default is 2.5 GiB (see gitlab-send-docs.md).
