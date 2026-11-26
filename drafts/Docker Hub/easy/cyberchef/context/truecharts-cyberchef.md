# TrueCharts chart: cyberchef

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/cyberchef (directory; content read from raw `charts/stable/cyberchef/values.yaml`) · 2026-11-26

## Values (as of fetch)
- Image: `docker.io/mpepping/cyberchef`, tag `v11.6.0@sha256:591c43b64738b9d056d0d7e644d49df0a78acab1bc4e4e40b9781fd1551435c7`, pullPolicy `IfNotPresent`.
- Service `main`, port `main` = 10219 (http), targetPort 8000.
- Env: none (empty map). Persistence: none.
- securityContext (container): readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0 (runs as root).
- Probes: liveness, readiness and startup all `http` on path `/`.

## Contradictions with plan.md / draft.md
- plan.md section 1 says the chart uses `mpepping/cyberchef:v11.5.0`. The chart now uses `v11.6.0`. plan.md corrected (see README).
- Chart runs as root on port 8000 (target) with a writable rootfs. Plan.md's rootless/read-only plan (UID 568, port 8080, service mapping must target 8080) still stands for ContainerForge.
