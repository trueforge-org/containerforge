# TrueCharts dispatcharr values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dispatcharr/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/dispatcharr/dispatcharr`
- tag: `0.34.1@sha256:3716ebb0aba133fe8b3d311505dc49966b7fddff742d9ab710ccd19d04658195`
- pullPolicy: IfNotPresent

## Init helper image (alpineImage)
- repository: `docker.io/library/alpine`, tag `3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf`

## Security context (chart)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Ports
- service.main: port 9191, targetPort 9191, protocol http

## Init container `setup-postgres-dirs` (alpine, runs as root)
- `mkdir -p /var/run/postgresql`; `chown 999:999`; `chmod 2775`
- `/data/db`: if exists, `chown -R 999:999`, dirs 0700, files 0600; else create, chown 999:999, chmod 0700
- Writes under /data and /var/run/postgresql (shared mounts)

## Env (set by chart)
| Name | Value |
| --- | --- |
| DISPATCHARR_ENV | aio (all-in-one with embedded PostgreSQL; only aio supported) |
| DISPATCHARR_LOG_LEVEL | commented out (default) |

## Persistence
| Name | mountPath |
| --- | --- |
| data | /data (main and setup-postgres-dirs) |
| postgres-run | /var/run/postgresql |

## Gotchas
- Chart relies on embedded PostgreSQL in aio mode (postgres data at /data/db, socket dir /var/run/postgresql, uid 999).
- Init script is hard-wired to uid/gid 999.
