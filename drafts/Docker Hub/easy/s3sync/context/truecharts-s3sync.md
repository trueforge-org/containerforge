# TrueCharts s3sync chart (values.yaml)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/s3sync/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart `s3sync` (charts/stable/s3sync). Single `main` workload.

## Image used by chart
`docker.io/whatname/docker-s3sync` tag `latest@sha256:dbfa5eff4d67ac54dded4434a73c036c11a54dda3ade152bb9ecc53431eed9d0`, pullPolicy IfNotPresent.

## Env vars set by chart
- `ACCESS_KEY` and `SECRET_KEY`: from secret `env-secrets` (secretKeyRef).
- `CRON_SCHEDULE`: `0 * * * *`
- `REGION`: `bucket_region_here` (placeholder)
- `S3PATH`: `s3://your_bucket_name` (placeholder)
- `S3SYNCPARAMS`: `""`

## Persistence
`backupsourceexample`: enabled, mountPath `/data/example`, readOnly true.

## Security
securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Service/probes
service.main disabled (no ports). Liveness, readiness, startup probes all disabled.

## Secret
`env-secrets` enabled with placeholder ACCESS_KEY and SECRET_KEY.

## Contradictions with plan.md
- Matches plan.md: runAsUser/runAsGroup 0, readOnlyRootFilesystem false, `/data/example` read-only mount.
- The chart uses the `latest` tag pinned by digest; plan.md's draft says `docker.io/whatname/docker-s3sync:latest` (consistent, digest omitted in plan).
