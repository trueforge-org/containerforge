# TrueCharts chart: webnut

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/webnut (values.yaml via raw.githubusercontent.com) · fetched 2026-11-26

## Image
- repository `docker.io/edgd1er/webnut`, tag `latest@sha256:bb41f38d...` (truncated), pullPolicy `IfNotPresent`.

## Security context
- `runAsUser 0`, `runAsGroup 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`.

## Env vars
- `UPS_HOST` `127.0.0.1`; `UPS_PORT` `3493`; `UPS_USER` `monuser`; `UPS_PASSWORD` from secret `env-secrets` key `UPS_PASSWORD` (placeholder value `secret`).

## Ports
- Service main, port 10585 (http), targetPort 6543.

## Persistence
- `config` enabled at `/config`.

## Probes, args, command
- None defined.

## Gotchas
- Chart runs as root with a writable rootfs; plan.md runs as `apps` with a read-only rootfs and a static `config.py` built into the image.
