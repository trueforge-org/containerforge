# TrueCharts solidping values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/solidping/values.yaml
- Fetched 2026-11-27

## Image
- repository: `ghcr.io/fclairamb/solidping`
- tag: `0.56.0@sha256:24e5bea5f99a94753a18e9a6eabfb6ec39993e64cdee6494e497756366aac3b3`
- pullPolicy: IfNotPresent

## Ports
- service main: port `10541` → targetPort `4000` (http)

## Env vars (main container)
- SP_SERVER_LISTEN: `":4000"` (from targetPort)
- SP_DB_TYPE: `postgres`
- SP_DB_URL: secretKeyRef `<release>-postgresqlcreds` key `url`
- SP_FILESTORAGE_LOCAL_ROOT: `/data/files`

## Volumes/paths
- data → `/data`

## Probes
- liveness, readiness, startup: http `/api/mgmt/health`

## User/UID, securityContext
- not specified in values (no runAsUser/fsGroup/readOnlyRootFilesystem)

## Dependencies
- postgresql enabled, username `solidping`, database `solidping`

## Gotchas
- Chart runs on PostgreSQL; ContainerForge plan defaults to SQLite.
