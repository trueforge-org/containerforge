# TrueCharts omada-controller chart values.yaml

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/omada-controller (raw values.yaml fetched) · fetched 2026-11-26

- Image: `docker.io/mbentley/omada-controller`, tag 6.3, pinned digest (d5d688dc…); IfNotPresent.
- Services: main https 8043; comm https 8843; omada-tcp 29811-29814; omada-udp 29810. Ingress comm disabled.
- Env: MANAGE_HTTPS_PORT (=8043), PORTAL_HTTPS_PORT (=8843) only.
- Persistence: data at /opt/tplink/EAPController/data; work at /opt/tplink/EAPController/work.
- securityContext: uid/gid 0; runAsNonRoot false; readOnlyRootFilesystem false.
- Probes (startup/liveness/readiness): HTTP GET /api/info, Host header kube.internal.health.
- No command/args.
