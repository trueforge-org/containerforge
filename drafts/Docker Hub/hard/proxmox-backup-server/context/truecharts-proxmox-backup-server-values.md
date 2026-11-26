# TrueCharts proxmox-backup-server values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/proxmox-backup-server (raw values.yaml), fetched 2026-11-26

## Values (chart reference)
- image: docker.io/ayufan/proxmox-backup-server, tag `v4.2.0@sha256:01f685a0...` (pinned digest)
- securityContext: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0
- service main: port 8007, protocol https, targetPort 8007
- hostname: `pbs` (cert CN limit 64 chars, per comment)
- probes: liveness https, readiness https, startup tcp
- persistence: config -> /etc/proxmox-backup (PVC); lib -> /var/lib/proxmox-backup (emptyDir); log -> /var/log/proxmox-backup (emptyDir); run -> /run (emptyDir)

## Gotchas
- Chart runs as root; /run emptyDir mounted (matches README tmpfs note).
