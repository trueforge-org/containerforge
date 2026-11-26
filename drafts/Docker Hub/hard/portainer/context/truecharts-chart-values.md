# TrueCharts portainer chart values

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/portainer/values.yaml (fetched)
Chart page: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/portainer (not fetched)

- CE image: docker.io/portainer/portainer-ce:2.45.4 (sha256 pinned), pullPolicy IfNotPresent
- EE (beImage): docker.io/portainer/portainer-ee:3.1.0 (sha256 pinned)
- Main service 10400 (https) -> targetPort 9443; Edge service enabled 10401 -> 10401
- No env vars; `portainer` block: logo "", edge_compute false, snapshot_interval 5m, hide_labels commented
- Persistence: data -> /data; cache -> /.cache (emptyDir)
- Probes: liveness/readiness/startup https on 9443
- securityContext/user: not specified
- Service account main enabled; RBAC clusterWide with all verbs on all resources; automountServiceAccountToken true
- Deps: none
