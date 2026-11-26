# TrueCharts storj-node chart (values.yaml)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/storj-node/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart `storj-node`. Main workload on the official `storjlabs/storagenode` image.

## Image used by chart
`docker.io/storjlabs/storagenode` tag `latest@sha256:c7ac8eaae9f072f0f32b77d1437968191ed277b7095d33211a72e1ca598f04bb`, pullPolicy IfNotPresent.

## Env vars set by chart
`SETUP: true`, `EMAIL: ""`, `ADDRESS: ""`, `STORAGE: "500GB"`, `WALLET: "walletaddress"` (placeholder).

## Ports / service
- main: port 14002 (dashboard).
- coretcp: tcp 28967 (enabled).
- coreudp: udp 28967 (enabled).

## Persistence
- `identity`: mountPath `/app/identity`, enabled.
- `storage`: mountPath `/app/config`, enabled.

## Security
securityContext.container: runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Probes
None defined.

## Contradictions with plan.md
- Chart sets `SETUP: true` (runs setup on each start in the upstream entrypoint); plan.md's start.sh runs setup only when config.yaml is absent. The difference is intentional in plan.md (section 7).
- Chart mounts identity at `/app/identity` and config at `/app/config`; plan.md merges them into `/config`. Plan notes the volume move (section 9).
