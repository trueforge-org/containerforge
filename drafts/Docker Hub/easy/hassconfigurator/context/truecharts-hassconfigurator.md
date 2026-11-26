# TrueCharts chart: hassconfigurator

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hassconfigurator/values.yaml
- Fetched 2026-11-26 (chart directory listing not fetched)

**What it is**
TrueCharts chart `hassconfigurator` (main image `causticlab/hass-configurator-docker`).

**Container image (values.yaml)**
- repository: `docker.io/causticlab/hass-configurator-docker`
- tag: `x86_64@sha256:45a5a0527ca10da5744bbcf3a7909a0b77ae583e97fe0d28d0e5a8d50aa37689`
- pullPolicy: `IfNotPresent`

**Security**
- securityContext: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

**Ports**
- Service `main`, port `main`: `3218`, tcp.

**Persistence**
- `config` at `/config`.
- `hass-config` at `/hass-config`.

**Env**
None defined; no secrets.

**Contradictions with plan.md**
- plan.md section 9 and 10 say the chart runs as root and has writable rootfs, and mounts `/config` and `/hass-config`. Matches.
- plan.md section 10 says the image tag is the fixed `x86_64` build. The chart pins that tag by digest. Matches.
