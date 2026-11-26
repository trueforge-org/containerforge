# TrueCharts chart: s3backup

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/s3backup (tree, not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/s3backup/values.yaml (fetched)

## Image
- repository `docker.io/joch/s3backup`, tag `latest@sha256:f81c2bb5de6ee13413f4e63bd720d2221605956344833df086e14554b44b2776`, pullPolicy IfNotPresent.

## Ports
- Main service and port both `enabled: false`.

## Persistence
- `persistence: {}` (none).

## securityContext (container)
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Env vars
- ACCESS_KEY and SECRET_KEY from secret `env-secrets` (keys of the same name).
- CRON_SCHEDULE `0 * * * *`.
- S3PATH `s3://mybucket/`.
- S3CMDPARAMS `""`.
- Secret `env-secrets` enabled with placeholder values ('Your AWS Access key', 'Your AWS Access secret').

## Probes
- liveness, readiness and startup all disabled.
