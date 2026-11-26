# TrueCharts steam-headless chart (reference only)

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/steam-headless (values.yaml raw, fetched 2026-11-26).

## values.yaml facts
- Image: `docker.io/josh5/steam-headless`, tag `latest@sha256:c60f4d7243a4d94515f722441fff90b752413bf6a45bb221c9a4ed55bc4d9108`, pullPolicy IfNotPresent
- Security: `privileged: true`, `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`
- Service main port 8083 (http) (PORT_NOVNC_WEB = service port)
- env overrides: MODE primary, WEB_UI_MODE vnc, ENABLE_VNC_AUDIO false, ENABLE_SUNSHINE false, ENABLE_EVDEV_INPUTS false (USER_PASSWORD, SUNSHINE_* commented out)
- Persistence: `/home/default`, `/mnt/games`, `/var/lib/flatpak` (enabled)
