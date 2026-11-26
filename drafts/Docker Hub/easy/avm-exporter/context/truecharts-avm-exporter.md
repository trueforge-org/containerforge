# TrueCharts chart: avm-exporter

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/avm-exporter (listed in draft)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/avm-exporter/values.yaml (fetched 2026-11-26)

**Config (values.yaml)**
- Image `docker.io/pdreker/fritz_exporter` tag `4.0.3@sha256:abe49b0f6b9d6e951c2b926ad030c5a771011abddb8a2018416ba6f7fbcafd4c`, pullPolicy `IfNotPresent`.
- Service `main` and port `main`: 9787 (targetPort 9787). The exporter config also sets `exporter_port: 9787`.
- Persistence `configfile`: type `configmap`, read-only at `/exporter/config.yaml` (subPath `config.yaml`), source configmap `exporter-configfile`.
- securityContext: not set (no runAsUser, runAsNonRoot, readOnlyRootFilesystem or privileged overrides).
- Env: none. The container gets an extra arg `--config=/exporter/config.yaml`.
- Config keys (chart): `exporter` with `exporter_port`, `listen_address`, `devices`; per device `name`, `hostname`, `username`, `password`.
- Probes: liveness, readiness and startup are all tcp.
- Metrics: ServiceMonitor enabled, port `main`, path `/metrics`, interval 1m, scrapeTimeout 15s.

**Gotchas**
- The chart mounts the config at `/exporter/config.yaml` and passes `--config`. The draft's `/exporter/config.yaml` note matches. plan.md's `/config/config.yaml` remap would need `FRITZ_CONFIG_FILE` or a change of the chart path.
- The chart's device config is the only source of credentials; env mode is not used by the chart.
