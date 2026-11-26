# TrueCharts chart: charts/stable/goaccess

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/goaccess ; raw: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/goaccess/{Chart.yaml,values.yaml}
Date: fetched 2026-11-26

- Chart.yaml: name `goaccess`, version `11.0.0`, appVersion `latest`.
- Image: `gregyankovoy/goaccess`, tag `latest@sha256:157fc99be09f0b0d680ed0f7be716c81288ea9fe40a4435fab05356b35121421`, pullPolicy IfNotPresent.
- Env: none.
- Ports: service main, port main 7889/tcp (target 7889).
- Persistence: `goaccess` -> `/opt/log` (enabled).
- Probes: none defined.
- Security: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
