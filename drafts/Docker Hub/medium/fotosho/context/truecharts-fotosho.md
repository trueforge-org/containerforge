# TrueCharts chart: charts/stable/fotosho

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fotosho ; raw: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fotosho/{Chart.yaml,values.yaml}
Date: fetched 2026-11-26

- Chart.yaml: name `fotosho`, version `11.0.0`, appVersion `latest`.
- Image: `advplyr/fotosho`, tag `latest@sha256:49dc426c6bdaf99927df571a7084eb6d7f593ea76ab8a99c5c7e1c9fccc77e12`, pullPolicy IfNotPresent.
- Env: none.
- Ports: service main, port main 13377/tcp -> targetPort 80.
- Persistence (enabled): `config` -> `/config`; `photos` -> `/photos`; `thumbs` -> `/thumbnails`.
- Probes: none defined.
- Security: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
