# TrueCharts chart: remmina

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/remmina/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/remmina/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `remmina`, version 16.0.1, `appVersion: 1.4.43`, category media.
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Description: a remote desktop client written in GTK.
- Chart sources: ghcr.io/linuxserver/remmina, github linuxserver/docker-remmina, remmina.org.

## Image
- `image.repository: ghcr.io/linuxserver/remmina`
- `image.tag: 1.4.43@sha256:76447b2995a6f078b6f9d6ef229e14ff9b40f93e9043ced6b57ab9ed2c7b9a42`

## Runtime config (values.yaml)
| Key | Value |
| --- | --- |
| service.main.ports.main | port 10042, targetPort 3000 |
| env | none set |
| persistence.config | enabled, mountPath /config |
| persistence.varrun | enabled true |
| securityContext.container.runAsUser / runAsGroup | 0 / 0 |
| securityContext.container.runAsNonRoot | false |
| securityContext.container.readOnlyRootFilesystem | false |

## Gotchas
- Chart targetPort 3000 differs from linuxserver upstream EXPOSE 3001.
- Chart runs as root, not read-only rootfs.
