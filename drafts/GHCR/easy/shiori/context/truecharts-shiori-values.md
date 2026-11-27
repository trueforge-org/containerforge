# TrueCharts shiori values.yaml

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shiori/values.yaml
- Fetched 2026-11-27

## Image
- repository: `ghcr.io/go-shiori/shiori`
- tag: `v1.8.0@sha256:d3bdfc1b68b8f267a04cf74d73b8a0e1d99ac71c3a9047375e97202f079eb1f6`
- pullPolicy: IfNotPresent

## Ports
- service main, port `10098` → targetPort `8080` (protocol not stated)

## Env vars (main container)
- SHIORI_DIR: `{{ .Values.persistence.data.mountPath }}` (resolves to `/data`)
- SHIORI_DBMS: `postgresql`
- SHIORI_PG_PORT: `5432`
- SHIORI_PG_USER / SHIORI_PG_NAME: from postgresql dependency values (`shiori` user)
- SHIORI_PG_HOST / SHIORI_PG_PASS: secretKeyRef `<release>-postgresqlcreds` keys `plainhost` / `postgresql-password`

## Volumes/paths
- data enabled, mountPath `/data`

## Dependencies
- postgresql enabled, username `shiori`, password `shiori` (chart defaults; postgresqlDatabase referenced but not set here)

## User/UID, probes, securityContext
- Not specified in values (no runAsUser/fsGroup/readOnlyRootFilesystem). No probes.

## Gotchas
- Chart runs Shiori on PostgreSQL; the ContainerForge plan uses SQLite. TrueCharts data mount is `/data`, not `/config`.
