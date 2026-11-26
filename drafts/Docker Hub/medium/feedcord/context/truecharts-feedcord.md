# TrueCharts chart: charts/stable/feedcord

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/feedcord ; raw: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/feedcord/{Chart.yaml,values.yaml}
Date: fetched 2026-11-26

- Files: templates/, .helmignore, CHANGELOG.md, Chart.yaml, README.md, icon(-small).webp, values.schema.json, values.yaml.
- Install: `helm install mychart oci://oci.trueforge.org/truecharts/feedcord`. Not maintained by upstream.
- Chart.yaml: name `feedcord`, version `4.0.0`, appVersion `latest`.
- Image: `qolors/feedcord`, tag `latest@sha256:909b3b25943add888fb46d958484fe0126846ca4ec6163fa81632dfcaf87e67d`, pullPolicy IfNotPresent.
- Env: none.
- Ports: service and main port disabled; none defined.
- Probes: liveness, readiness, startup all disabled.
- Persistence: configmap `feedcord-config` (enabled), mounted at `/app/config/appsettings.json` via subPath `appsettings.json`, readOnly. Config rendered from chart values (`feedcord.ConcurrentRequests` 40; one instance example).
- Security: runAsUser/runAsGroup not set; readOnlyRootFilesystem false.
