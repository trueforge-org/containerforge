# TrueCharts chart: ipfs

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ipfs (read via raw files)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ipfs/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ipfs/values.yaml
- Fetched 2026-11-26

## What it is
Chart `ipfs` version `16.0.1`, `appVersion: 0.43.2`. Description: "IPFS is a global, versioned, peer-to-peer Interplanetary Filesystem." Category storage. Depends on `common` `32.8.5`.

## Container
- `docker.io/ipfs/kubo`, tag `v0.43.2@sha256:31b965f24ee47e3cb3832a5e3973f5102dd643932a9621a8c2fd7dbe5a0a799b`, pullPolicy `IfNotPresent`.

## Security context
- container: `runAsNonRoot: false`, `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`. No podSecurityContext.

## Env
- `IPFS_PROFILE: "server"`.
- `IPFS_SWARM_KEY` from secretKeyRef `env-secrets` key `IPFS_SWARM_KEY`; secret `env-secrets` enabled with `IPFS_SWARM_KEY: ""`.
- `IPFS_SWARM_KEY_FILE: ""`.

## Persistence
- `data` enabled, mountPath `/data/ipfs`.
- `staging` enabled, mountPath `/export`.
- `ipfs` enabled, mountPath `/ipfs`.
- `ipns` enabled, mountPath `/ipns`.

## Service / ports
- `main` service port 10125 -> targetPort 5001 (RPC API).
- `peer-tcp` enabled 4001 -> 4001; `peer-udp` enabled 4001/udp -> 4001.
- `gateway` enabled ClusterIP port 10147 -> targetPort 8080.

## Probes
- liveness, readiness and startup all use path `/webui` (nested under `workload.main.podSpec.containers.main`).

## Gotchas
- Chart probes hit `/webui` HTTP path; ContainerForge plan uses `diag healthy`/TCP instead (plan section 8). Difference, not a plan error.
- Chart mounts `/ipfs` and `/ipns` (FUSE); plan drops those, per its own section 6 note.
- Chart sets `IPFS_PROFILE: server`; plan leaves profile empty by default.
