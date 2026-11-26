# TrueCharts chart: go-playground
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/go-playground (raw values.yaml + Chart.yaml fetched 2026-11-26)

## Chart.yaml
- name: go-playground, version 11.0.0, appVersion: latest
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- kubeVersion >=1.33.0-0; train: stable; category Tools-Utilities
- sources: GitHub trueforge chart path, hub.docker.com/r/x1unix/go-playground

## values.yaml (image/ports/env)
| Key | Value |
| --- | --- |
| image.repository | docker.io/x1unix/go-playground |
| image.tag | latest@sha256:4c4a9bcbc0413faaacc8eb0a425922858a55b73ab03f5359082217d5b93cc000 |
| image.pullPolicy | IfNotPresent |
| persistence | {} (none) |
| securityContext.container | readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 |
| service.main.ports.main | port 8888 -> targetPort 8000 (tcp) |
| env APP_CLEAN_INTERVAL | 10m |
| env APP_DEBUG | "false" |

## Notes
- Chart runs as root (UID 0) and does not use read-only rootfs.
- Chart does not set APP_PLAYGROUND_URL or APP_GTAG_ID (Dockerfile defaults apply).
