# TrueCharts chart: intel-gpu-plugin

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/intel-gpu-plugin (README rendered); https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/intel-gpu-plugin/values.yaml. Fetched 2026-11-26.

## Files
- Chart.yaml, README.md, values.yaml, values.schema.json, templates/, icons

## Chart values
- Image: `docker.io/intel/intel-gpu-plugin`, tag `0.37.2`, pinned by digest `sha256:d8c5d202e53a5ca4ea4105f0b2729b3108ac4304aba948e956f80f5f38ae119b`, IfNotPresent
- Workload: DaemonSet; main args `-shared-dev-num 5`
- Service disabled; no ports; probes disabled; env none
- securityContext / podSecurityContext: not set in values
- Persistence:
  - devfs: device, `/dev/dri` -> `/dev/dri`, readOnly
  - sysfs: device, `/sys/class/drm` -> `/sys/class/drm`, readOnly
  - kubeletsockets: hostPath, `/var/lib/kubelet/device-plugins`, rw

## Notes
- Chart builds on `charts/library/common`; README says not upstream-maintained.
- Chart.yaml and templates/ not fetched (follow-ups not needed for build).
