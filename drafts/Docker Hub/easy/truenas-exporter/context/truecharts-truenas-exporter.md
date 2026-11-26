# TrueCharts truenas-exporter chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/truenas-exporter (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/truenas-exporter/values.yaml (fetched 2026-11-26)

**What it is**
The chart that runs `prom/graphite-exporter` as its main container, with the TrueNAS mapping file mounted in.

**Image (values.yaml)**
- repository `docker.io/prom/graphite-exporter`
- tag `v0.17.0@sha256:c1a266f63a84fd11048ab6ad1552a4c497b14522d02823925247698e41eeac2b`
- pullPolicy `IfNotPresent`

**Security context / env**
Not set. No env.

**Command/args**
- command: not set
- args: `--graphite.mapping-config=/config/graphite_mapping.conf`

**Persistence**
- `config`: type `configmap`, objectName `config`, mountPath `/config/graphite_mapping.conf`, subPath `graphite_mapping.conf`, readOnly `true`.
- No PVC.

**Service/ports**
- `main` tcp `9109`.
- `main-udp` udp `9109` (enabled).
- `metrics` http `9108` (enabled; a `metrics.main` scrape entry targets it).

**Other**
- Two configmaps: `dashboard` (Grafana dashboard `truenasexporter.json`, labelled `grafana_dashboard: "1"`) and `config` (`graphite_mapping.conf`, regex mappings for TrueNAS metrics).
- Probes not shown as disabled in the fetched content.

**Gotchas**
- The chart mounts the mapping file as a read-only configmap subPath at `/config/graphite_mapping.conf`. The plan's `start.sh` copies only when the file is missing (`cp -n`), so a mounted file is left alone.
- The chart uses `v0.17.0` (upstream exporter), not the Supporterino wrapper.
