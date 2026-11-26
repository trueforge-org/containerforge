# TrueCharts chart: godaddy-ddns

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/godaddy-ddns/values.yaml
- Fetched 2026-11-26 (chart directory listing not fetched in this run)

**What it is**
TrueCharts chart `godaddy-ddns` (main image `jwater7/godaddy-publicip-updater`).

**Container image (values.yaml)**
- repository: `docker.io/jwater7/godaddy-publicip-updater`
- tag: `latest@sha256:fd454790cf528241a1599da8374a0330ecfa1b49179d4aa8582526949ebb0180`
- pullPolicy: `IfNotPresent`

**Security**
- securityContext: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

**Ports**
Main service and port disabled. No ports.

**Persistence**
None (`persistence: {}`).

**Env**
- `GODADDY_API_KEY`: from secret `env-secrets`, key `GODADDY_API_KEY`.
- `GODADDY_API_SECRET`: from secret `env-secrets`, key `GODADDY_API_SECRET`.
- `GODADDY_DOMAINS`: empty string.
- Secret `env-secrets` is enabled; both keys are empty in the chart.

**Probes**
Liveness, readiness and startup disabled.

**Contradictions with plan.md**
- plan.md section 9 says the chart runs as UID 0 with writable rootfs and no persistence. Matches.
- plan.md section 6 lists the three required env vars and no ports. Matches the chart's env names.
