# TrueCharts firefox-syncserver values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/firefox-syncserver/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/crazy-max/firefox-syncserver`
- tag: `1.8.0@sha256:ab1a959d8105c478f0f1523c8c3bbdc53bb8d44f325501b93297bc80cf627da6`
- pullPolicy: IfNotPresent

## Ports
- service.main.ports.main: port 10051, targetPort 5000

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false, allowPrivilegeEscalation true

## Probes
- liveness, readiness, startup: type tcp

## Env (set by chart)
| Name | Value |
| --- | --- |
| FF_SYNCSERVER_PUBLIC_URL | firefox-syncserver.192.168.1.189.nip.io (example IP, chart default) |
| FF_SYNCSERVER_FORCE_WSGI_ENVIRON | true |
| FF_SYNCSERVER_ACCESSLOG | false |
| FF_SYNCSERVER_LOGLEVEL | info |
| FF_SYNCSERVER_ALLOW_NEW_USERS | true |
| FF_SYNCSERVER_FORWARDED_ALLOW_IPS | * |
| FF_SYNCSERVER_SQLURI | secretKeyRef from `{Release.Name}-postgresqlcreds` key `url` |
| FF_SYNCSERVER_SECRET | secretKeyRef `env-secrets` key `FF_SYNCSERVER_SECRET` (default "changeme" in secret) |

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config |

## Dependencies
- postgresql (enabled), database and user `firefox-syncserver`

## Gotchas
- Chart stores data in /config while the upstream image declares VOLUME /data.
- Chart's SQLURI points at a PostgreSQL dependency, not the default SQLite in /data.
