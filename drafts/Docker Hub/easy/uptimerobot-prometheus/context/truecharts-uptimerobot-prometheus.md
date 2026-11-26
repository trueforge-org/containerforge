# TrueCharts uptimerobot-prometheus chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/uptimerobot-prometheus (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/uptimerobot-prometheus/values.yaml (fetched 2026-11-26)

**What it is**
The chart that uses the old `billimek/prometheus-uptimerobot-exporter:0.0.1` image as its main container.

**Image (values.yaml)**
- repository `docker.io/billimek/prometheus-uptimerobot-exporter`
- tag `0.0.1@sha256:f14ccd7aad0e0ef19dc5c5c359b0921030a769e2505acec5b913d749281327be`
- pullPolicy `IfNotPresent`

**Security context**
- readOnlyRootFilesystem `false`. runAsUser, runAsGroup and privileged not set.

**Env**
- `UPTIMEROBOT_API_KEY` from secretKeyRef `env-secrets` / `UPTIMEROBOT_API_KEY`, which is an empty value in the chart's secret.
- `TZ` set (value not captured).

**Persistence**
None.

**Service/ports**
- `main` http disabled. `metrics` enabled, protocol TCP, port `9705`.

**Gotchas**
- The chart runs the outdated billimek image. Our build replaces it with the upstream exporter source (see GitHub file).
- Chart env uses `UPTIMEROBOT_API_KEY` only; the remaining `UPTIMEROBOT_*` variables take their defaults.
