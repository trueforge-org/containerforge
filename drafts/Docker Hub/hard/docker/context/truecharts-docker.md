# TrueCharts chart: docker

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/docker
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/docker/values.yaml
- Fetched 2026-11-26

## Container image (values.yaml)
- Repository `docker`, tag `29.10.1-dind@sha256:fbbc96e0af32cdc190aff92ba97a1281a115351a723afe21af78879cc55126b0`, pullPolicy IfNotPresent. (Chart uses 29.10.1, not 29.10.0 as in the draft.)

## Service
- Service `main` ClusterIP, port `main` = 2376.

## Persistence (all enabled, no type)
- `docker-certs-ca` mounted at `/config`.
- `docker-certs-client` mounted at `/certs/client`.
- `docker` mounted at `/var/lib/docker`.
- Note: draft lists only `/var/lib/docker` and `/certs/client` as extra persistence; `/config` (docker-certs-ca) is also in the chart.

## Security context
- Container: privileged true; readOnlyRootFilesystem false; allowPrivilegeEscalation true; runAsNonRoot false; runAsUser 0; runAsGroup 0.
- Pod: fsGroup 0. `podOptions.hostNetwork: true`.

## Env vars
- `DOCKER_TLS_CERTDIR: /certs`.

## Probes
- liveness, readiness, startup all `type: tcp`, initialDelaySeconds 30.

## Workload
- StatefulSet, replicas 1, RollingUpdate. No command/args.
