# TrueCharts chart: charts/stable/filestash

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/filestash ; raw: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/filestash/{Chart.yaml,values.yaml}
Date: fetched 2026-11-26

- Files: templates/, .helmignore, CHANGELOG.md, Chart.yaml, README.md, icon(-small).webp, values.schema.json, values.yaml.
- Install: `helm install mychart oci://oci.trueforge.org/truecharts/filestash`. Not maintained by upstream.
- Chart.yaml: name `filestash`, version `12.0.0`, appVersion `latest`.
- Image: `machines/filestash`, tag `latest@sha256:b0979f5f527298439aad5c5a099a6e4b68b5aeaa2ba49f93e8351c463a4f339e`, pullPolicy IfNotPresent.
- Env: `APPLICATION_URL` = `http://localhost:8334`; `GDRIVE_CLIENT_ID`, `DROPBOX_CLIENT_ID`, `ONLYOFFICE_URL` = "" (empty); `GDRIVE_CLIENT_SECRET` from secret `env-secrets`.
- Ports: main `http` 8334 (target 8334).
- Persistence: `data` -> `/app/data/state` (enabled).
- Probes: none defined.
- Security: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- Gotcha: chart runs as root with writable rootfs; ContainerForge plan runs as `apps` (568) with read-only rootfs and moves state under /config.
