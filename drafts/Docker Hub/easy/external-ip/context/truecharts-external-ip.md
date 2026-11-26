# TrueCharts chart: external-ip

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/external-ip (directory listing)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/external-ip/values.yaml
- Fetched 2026-11-26

**What it is**
TrueCharts chart `external-ip` (`oci://oci.trueforge.org/truecharts/external-ip`). Chart README states it is not maintained by the upstream project. Uses `charts/library/common`.

**Container image (values.yaml)**
- repository: `docker.io/xavierh/external-ip`
- tag: `latest@sha256:eae953728e95a9536d0c85b941bbc55b66c64f62713402bd8f1d182073b921a8`
- pullPolicy: `IfNotPresent`

**Env vars set by the chart (main container)**
- `DELAY`: `5m`
- `NOTIFICATION_TYPE`, `PROVIDER`, `PUSHOVER_TITLE`, `PUSHOVER_USER`, `RECOVERY_ALERT`: empty
- `PUSHOVER_TOKEN`: from secret `env-secrets`, key `PUSHOVER_TOKEN` (default empty)

**Security/runtime settings**
- container securityContext: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. `privileged` not set in the fetched content.
- Persistence: `persistence: {}` (no volumes).
- Main service and main port: `enabled: false`.
- Liveness, readiness, startup probes: all `enabled: false`.

**Other**
- Chart directory also holds `values.schema.json`, `CHANGELOG.md`, `README.md`, icons, `templates/`.

**Contradictions with plan.md**
- plan.md section 9 says the draft expectations are UID 0 and writable rootfs; this matches the chart. No contradiction.
- The chart pins a digest that is not the same as the commit SHA in plan.md; the digest cannot be mapped to a commit from these sources (unverified).
