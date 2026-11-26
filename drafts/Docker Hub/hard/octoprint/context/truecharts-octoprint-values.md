# TrueCharts octoprint chart values.yaml

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/octoprint (raw values.yaml fetched) · fetched 2026-11-26

- Image: `docker.io/octoprint/octoprint`, tag 1.11.8, pinned digest (5ea0181e…); IfNotPresent.
- Port: service main 10021 -> container 80.
- Env: ENABLE_MJPG_STREAMER "true"; MJPG_STREAMER_INPUT and CAMERA_DEV empty (comments suggest "-y -n -r 640x480" and "/dev/video0").
- Persistence: data at /octoprint; varrun enabled (default mount).
- securityContext: uid/gid 0, runAsNonRoot false.
- Probes and command/args: none defined.
