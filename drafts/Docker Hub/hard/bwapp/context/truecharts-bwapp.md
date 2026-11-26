# TrueCharts chart bwapp (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bwapp (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bwapp/values.yaml) · fetched 2026-11-26

## Image
- `docker.io/raesene/bwapp`, tag `latest`, pinned by sha256 digest starting `2f41183ea9f9e8fb36678d7a2a0c8a9db9a59f4569cee02fe6664b419b2600ee`, pullPolicy IfNotPresent.

## Ports
Main service and main port both disabled (`enabled: false`); no port numbers set in values.

## Env
None defined.

## Persistence
Empty map (`{}`): no volumes configured.

## Security context
- `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Probes
Liveness, readiness and startup all disabled.

## Gotchas
- Chart values confirm root and writable rootfs; the plan's non-root rework remains a rebuild.
- Chart does not expose port 80, though the image runs Apache on 80 (per Docker Hub README). plan.md's 8080 is a new port.
