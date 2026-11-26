# TrueCharts chart: guacd

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/guacd/values.yaml
- Fetched 2026-11-26 (chart directory listing not fetched)

**What it is**
TrueCharts chart `guacd` (main image `guacamole/guacd`).

**Container image (values.yaml)**
- repository: `docker.io/guacamole/guacd`
- tag: `1.6.0@sha256:8974eaa9ba32f713daf311e7cc8cd7e4cdfba1edea39eed75524e78ef4b08f4f`
- pullPolicy: `IfNotPresent`

**Security**
- securityContext: `runAsUser: 1000`, `runAsGroup: 1000`, `readOnlyRootFilesystem: false`. `privileged` not specified.

**Ports**
- Service `main`, port `main`: `4822` (target `4822`).

**Persistence and env**
- No persistence entries. No env vars.

**Probes**
Liveness, readiness and startup are `tcp` probes.

**Contradictions with plan.md**
- plan.md section 9 says the chart uses `runAsGroup 1001`. The chart sets `runAsGroup: 1000`. plan.md corrected (see README).
- plan.md section 9 says the chart uses `readOnlyRootFilesystem: false`. Matches.
- plan.md section 1 says the chart mounts recordings and drive at `/var/lib/guacamole/recordings` and `/var/lib/guacamole/drive`. This guacd values file defines no persistence, so that claim is not confirmed here (it may belong to the `guacamole` web chart). Unverified.
