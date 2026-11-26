# TrueCharts obs-ndi chart values.yaml

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/obs-ndi (raw values.yaml fetched) · fetched 2026-11-26

- Image: `docker.io/patrickstigler/obs-ndi`, tag `latest`, digest sha256:b29e0e5d…; IfNotPresent.
- Ports: main 6901 (http); websocket 4455; vnc 5901.
- Env: `VNC_PW` from secret env-secrets (default "headless").
- Persistence: configpath mounted at /config/obs-studio.
- securityContext: uid/gid 0; readOnlyRootFilesystem false; runAsNonRoot false; caps NET_BIND_SERVICE, KILL.
- Probes: tcp for liveness/readiness/startup. No command/args.
