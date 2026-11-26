# TrueCharts chart: charts/stable/fenrus

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fenrus ; raw: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fenrus/{Chart.yaml,values.yaml}
Date: fetched 2026-11-26

- Files: templates/, .helmignore, CHANGELOG.md, Chart.yaml, README.md, icon(-small).webp, values.schema.json, values.yaml.
- Install: `helm install mychart oci://oci.trueforge.org/truecharts/fenrus`. Not maintained by upstream.
- Chart.yaml: name `fenrus`, version `11.0.0`, appVersion `latest`.
- Image: `revenz/fenrus`, tag `latest@sha256:7728749bb98c3b0862c853ebf9f741d7e43fddcd84a1ddb8ac73d03ae9741f99`, pullPolicy IfNotPresent.
- Env: none.
- Ports: service `main`, port `main` 3000/tcp (target 3000).
- Persistence: `data` -> `/app/data`; `images` -> `/app/wwwroot/images` (both enabled).
- Probes: none defined.
- Security: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
