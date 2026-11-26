# TrueCharts chart: dispatcharr

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dispatcharr (directory; content read from raw `values.yaml`) · 2026-11-26
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dispatcharr/README.md (fetched; no mode/requirement/env content) · 2026-11-26

## Values (as of fetch)
- Main image: `ghcr.io/dispatcharr/dispatcharr` tag `0.34.1@sha256:3716ebb0aba133fe8b3d311505dc49966b7fddff742d9ab710ccd19d04658195`, pullPolicy `IfNotPresent`.
- `alpineImage`: `docker.io/library/alpine` tag `3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf`.
- Init container `setup-postgres-dirs` (type init, alpineImage): creates `/var/run/postgresql` (999:999, mode 2775); on `/data/db` recursively chowns to 999:999 (dirs 0700, files 0600) or creates it.
- Sidecars: none.
- Env (main): `DISPATCHARR_ENV = aio` (comment: only currently supported mode). `DISPATCHARR_LOG_LEVEL` commented out.
- Service `main`, port `main` 9191 (http), targetPort 9191.
- Persistence: `data` at `/data` (main and init); `postgres-run` at `/var/run/postgresql`.
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
- Probes: none. Dependencies: none (embedded PostgreSQL via aio).

## README
- Only says: install via OCI Helm chart, chart not maintained upstream, values in values.yaml, uses the common library chart. No deployment-mode or requirement info.

## Contradictions / notes vs plan.md
- The "only aio is supported" statement is in `values.yaml` (comment), NOT the chart README. plan.md section 1 says "the chart README line". Corrected in plan.md.
