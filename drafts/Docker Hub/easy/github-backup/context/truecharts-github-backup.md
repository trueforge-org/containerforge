# TrueCharts chart: github-backup

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/github-backup (directory listing; the first fetch returned a DNS error, the retry succeeded)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/github-backup/values.yaml
- Fetched 2026-11-26

**What it is**
TrueCharts chart `github-backup` (`oci://oci.trueforge.org/truecharts/github-backup`). Uses the common library. Chart files: templates, CHANGELOG.md, Chart.yaml, README.md, values.schema.json, values.yaml.

**Container image (values.yaml)**
- repository: `docker.io/lnxd/github-backup`
- tag: `latest@sha256:029a39d990316e7df10ed5c29fcd722f9736b35d801773955b095492d6e1ff36`
- pullPolicy: `IfNotPresent`

**Security**
- container securityContext: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

**Ports**
Main service and main port disabled. No ports.

**Persistence**
- `backuplocation` at `/home/docker/backups`
- `config` at `/home/docker/github-backup/config/`

**Env (main container)**
- `SCHEDULE`: `3600`
- `TOKEN`: from secret `env-secrets`, key `TOKEN`. The secret's default value in values.yaml is a placeholder-looking string; not recorded here.

**Probes**
Liveness, readiness and startup disabled.

**Contradictions with plan.md**
- plan.md section 1 says lnxd uses `SCHEDULE` in seconds. The chart sets `SCHEDULE` to `3600`, consistent with seconds (not confirmed from backup.sh).
- plan.md section 9 says the chart's backup paths do not match the draft's `/config` layout. Confirmed: the chart uses `/home/docker/backups` and `/home/docker/github-backup/config/`.
- plan.md section 9 says the chart runs as UID 0 with writable rootfs. Matches.
