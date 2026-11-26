# TrueCharts chart: charts/stable/flame

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flame ; raw: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/flame/{Chart.yaml,values.yaml}
Date: fetched 2026-11-26

- Install: `helm install mychart oci://oci.trueforge.org/truecharts/flame`. Not maintained by upstream.
- Chart.yaml: name `flame`, version `11.0.0`, appVersion `2.4.0`.
- Image: `pawelmalak/flame`, tag `2.4.0@sha256:7a5edc859235486a82871eb624f03048e44f603cba42ea3f60dc7cfe60ca6b3f`, pullPolicy IfNotPresent.
- Env: `PASSWORD` from secret `env-secrets` (secret value `flame_password`); `enable_integration` = "true".
- Ports: service main, port 10291 (chart) -> targetPort 5005, protocol http.
- Persistence: `data` -> `/app/data` (enabled).
- Probes: none defined.
- RBAC: clusterWide get/list/watch on ingresses (networking.k8s.io); serviceAccount enabled; automountServiceAccountToken true.
- Security: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
