# trueforge-org/truecharts charts/stable/cadquery-server values.yaml

Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cadquery-server/values.yaml (raw variant; fetched 2026-11-26)

- Image: docker.io/cadquery/cadquery-server, tag latest pinned by digest (d0aed7996...), IfNotPresent
- Main service disabled; no port; no env
- Persistence: none (empty map)
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false
- Probes disabled

## Chart.yaml (added 2026-11-26)
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cadquery-server/Chart.yaml
- name cadquery-server; version 11.0.0; appVersion `latest`; type application; deprecated false
- description: CadQuery parametric 3D CAD Python module ... web server rendering
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- sources: roipoussiere/cadquery, truecharts chart folder, hub cadquery/cadquery-server
