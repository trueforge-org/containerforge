# trueforge-org/truecharts charts/stable/breitbandmessung-de values.yaml

Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/breitbandmessung-de/values.yaml (raw variant of listed chart folder; fetched 2026-11-26)

- Image: docker.io/shneezin/breitbandmessung-node, tag latest pinned by digest (IfNotPresent)
- Main service disabled; no ports; no env vars
- Persistence: config -> /usr/src/app/config; messurementlogs -> /export/
- securityContext: runAsUser 0, runAsGroup 0; readOnlyRootFilesystem false
- Liveness/readiness/startup probes disabled

## Chart.yaml (added 2026-11-26)
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/breitbandmessung-de/Chart.yaml
- name breitbandmessung-de; version 11.0.0; appVersion `latest`; type application; deprecated false
- description: A script to enable customers of lazy ISPs to perform measurement campaigns of the connection speed ... automated way.
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- sources: shneezin/breitbandmessung-node, truecharts chart folder, hub shneezin/breitbandmessung-node
