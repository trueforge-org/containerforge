# TrueCharts chart: dispatch

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dispatch (directory; content read from raw `charts/stable/dispatch/values.yaml`) · 2026-11-26

## Values (as of fetch)
- Image: `docker.io/khlieng/dispatch`, tag `latest@sha256:ce0742333e09ff22a4377f741621274010010138e2a33dfb535fe0be2304495d`, pullPolicy `IfNotPresent`.
- Env: none.
- Service `https`: port `https` listens 4596/tcp, targetPort 443.
- Service `main`: port `main` listens 8000 (http), targetPort 80.
- Persistence: `data` mounted at `/data`.
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
- Probes: none. Args/command: none.

## Notes vs plan.md
- Chart uses `latest` (matches draft/plan). Chart mounts `/data`. Plan.md uses `/config` (documented in plan section 9).
- Chart uses 443 as the HTTPS port; plan.md disables HTTPS in its seeded config, which would change the chart mapping (plan section 9 says to target 8080 in the chart service mapping).
