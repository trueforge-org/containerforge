# TrueCharts opengl-desktop-g3 chart values.yaml

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/opengl-desktop-g3 (raw values.yaml fetched) · fetched 2026-11-26

- Image: `docker.io/accetto/ubuntu-vnc-xfce-opengl-g3`, tag latest, digest sha256:fa64c529…; IfNotPresent.
- Ports: main 6901 (http); webuivnc 5901 (tcp).
- Env: VNC_PW from secret env-secrets (secret default "unraid"; change it); VNC_RESOLUTION "1360x768".
- Persistence: internalshare at /UNRAID_SHARE.
- securityContext: uid/gid 0; readOnlyRootFilesystem false.
- Probes: none. Command/args: none.
