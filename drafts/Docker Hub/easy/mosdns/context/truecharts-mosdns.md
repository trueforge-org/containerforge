# TrueCharts chart: mosdns

**Source URL(s) + fetch date:** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/mosdns (values read from https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mosdns/values.yaml) · fetched 2026-11-26

## What it is
TrueCharts Helm chart values for mosdns (main container).

## Image
- `docker.io/601096721/mosdns:v5.3.4@sha256:58b5a34a868210b6317d8915b687d7758e1d7061f3598845522d02e3f0d72042`, pullPolicy IfNotPresent.

## Ports
- `main`: 53 -> 53 (protocol not set).
- `dns-upd`: enabled, udp, 53 -> 53.

## Security (container)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false. No capabilities or podSecurityContext set.

## Persistence
- `data`: mounted at `/etc/mosdns`.

## Env vars
None defined.

## Probes
Liveness, readiness and startup all `tcp`.

## Gotchas
- Chart runs as root and needs port 53 (matches draft.md). Plan.md reconciles this with uid 568, read-only rootfs and port 5353.
- Chart uses `/etc/mosdns` as data path; ContainerForge plan uses `/config`.
