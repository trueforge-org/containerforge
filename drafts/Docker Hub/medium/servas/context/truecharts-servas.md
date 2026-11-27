# TrueCharts chart: servas

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/servas/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `servas`, category bookmarks. Chart version 14.0.0, appVersion 1.2.0.
- Description: self-hosted bookmark management tool.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`.
- Chart `sources:` list: github beromir/Servas, truecharts chart path, hub.docker.com/r/beromir/servas.

## Image (values.yaml)
- repository `docker.io/beromir/servas`, tag `1.2.0@sha256:662b0d8f37e67addc0448eb0fecb87c9a1314e2ef51dd8eb3ba222e8a2b726e3`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: port 11080, protocol http, targetPort 80.

## Chart config (`servas:` block)
- appKey: "PLACEHOLDERAPPKEYXXXXXXXXXXXXXXX" (Laravel APP_KEY, must be changed, exactly 32 chars per comment). Consumed via secret `servas-secrets` key `APP_KEY`.

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| APP_NAME | Servas |
| APP_KEY | secretKeyRef servas-secrets/APP_KEY |
| APP_ENV | production |
| APP_DEBUG | false |
| APP_URL | commented out (template `http://localhost:<port>`) |
| SERVAS_ENABLE_REGISTRATION | true |
| DB_CONNECTION | mysql |
| DB_HOST | secretKeyRef `<release>-mariadbcreds` key `plainhost` |
| DB_PORT | 3306 |
| DB_DATABASE | dependencies.mariadb.depconfig.mariadbDatabase (servas) |
| DB_USERNAME | dependencies.mariadb.depconfig.mariadbUsername (servas) |
| DB_PASSWORD | secretKeyRef `<release>-mariadbcreds` key `mariadb-password` |

## Probes
- liveness, readiness, startup: HTTP GET `/`.

## Persistence
- persistence.nginx: enabled, mountPath `/var/run/nginx`, type emptyDir.

## Dependencies
- `mariadb` enabled, depconfig: user `servas`, database `servas`.

## Security
- securityContext.container: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Gotchas
- Chart expects a MariaDB dependency; DB_CONNECTION is fixed to mysql.
- Chart mounts an emptyDir at `/var/run/nginx` (chart assumes nginx; upstream image is FrankenPHP/Caddy, not nginx).
