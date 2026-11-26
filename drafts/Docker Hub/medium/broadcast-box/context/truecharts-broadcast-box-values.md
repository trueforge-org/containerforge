# trueforge-org/truecharts charts/stable/broadcast-box values.yaml

Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/broadcast-box/values.yaml (raw variant of listed chart folder; fetched 2026-11-26)

- Image: docker.io/seaduboi/broadcast-box, tag latest pinned by digest (fad7abf9c...), IfNotPresent
- Service main: TCP 8080 (http)
- Service webrtc: UDP 60006 (enabled)
- Env: NETWORK_TEST_ON_START=false; INCLUDE_PUBLIC_IP_IN_NAT_1_TO_1_IP=true; UDP_MUX_PORT=60006 (templated from webrtc port)
- Persistence: none defined
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Chart.yaml (added 2026-11-26)
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/broadcast-box/Chart.yaml
- name broadcast-box; version 6.0.0; appVersion `latest`; type application; deprecated false
- description: Easily broadcast/stream to others with sub-second latency
- kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- sources: Glimesh/broadcast-box, truecharts chart folder, hub seaduboi/broadcast-box
