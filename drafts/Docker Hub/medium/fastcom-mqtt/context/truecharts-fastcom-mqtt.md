# TrueCharts chart: charts/stable/fastcom-mqtt

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fastcom-mqtt ; raw: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fastcom-mqtt/{Chart.yaml,values.yaml}
Date: fetched 2026-11-26

- Files: templates/, .helmignore, CHANGELOG.md, Chart.yaml, README.md, icon(-small).webp, values.schema.json, values.yaml.
- Install: `helm install mychart oci://oci.trueforge.org/truecharts/fastcom-mqtt`. Not maintained by upstream.
- Chart.yaml: name `fastcom-mqtt`, version `11.0.0`, appVersion `latest`. Train: stable. Category: home-automation. Min helm 3.14, max helm 4.1, max k8s 1.35.0.
- Image: `docker.io/simonjenny/fastcom-mqtt`, tag `latest@sha256:1687c72cc75372e8786a0e401d545c8b47588b7f33d99bf6af724f125453a234`, pullPolicy IfNotPresent.
- Env: `SLEEP` = "3600"; `MQTT_SERVER`, `MQTT_DOWN`, `MQTT_UP` = "" (empty).
- Ports: service and main port both `enabled: false`; none defined.
- Probes: liveness, readiness, startup all disabled.
- Persistence: `{}` (none).
- Security: container runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
- Gotcha: chart runs root with writable rootfs; ContainerForge plan uses non-root and read-only rootfs.
