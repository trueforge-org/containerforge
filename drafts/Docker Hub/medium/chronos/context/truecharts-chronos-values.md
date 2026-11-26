# trueforge-org/truecharts charts/stable/chronos values.yaml

Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chronos/values.yaml (raw variant; fetched 2026-11-26)

- Image: docker.io/simsemand/chronos, tag 0.2 pinned by digest (b86be79b...), IfNotPresent
- Service main: port 10305 -> container 5000, http
- Env: none
- Persistence: `chronos` volume at /chronos
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
- Probes: HTTP on "/" (liveness, readiness, startup)

## Chart.yaml (added 2026-11-26)
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chronos/Chart.yaml
- name chronos; version 14.0.0; appVersion 0.2.0; type application; deprecated false
- description: small container to run and schedule Python 3.7 scripts (virtualenvs, pip deps, logs, web UI)
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- sources: simse/chronos, truecharts chart folder, hub simsemand/chronos
