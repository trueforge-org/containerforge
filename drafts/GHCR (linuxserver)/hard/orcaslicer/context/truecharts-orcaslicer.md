# TrueCharts chart: orcaslicer

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/orcaslicer/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/orcaslicer/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `orcaslicer`, version 5.0.0, `appVersion: 2.5.2`, category media.
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Description: open source slicer for FDM printers.
- Chart sources: ghcr.io/linuxserver/orcaslicer, github SoftFever/OrcaSlicer (chart metadata, older repo URL).

## Image
- `image.repository: ghcr.io/linuxserver/orcaslicer`
- `image.tag: 2.5.2@sha256:92bce97be0359dde848b4f5e88ed6780aaabfa49e67157fd3014797458d8b765`

## Runtime config (values.yaml)
| Key | Value |
| --- | --- |
| service.main.ports.main | port 3000 (no protocol set) |
| env | none set |
| persistence.config | enabled, mountPath /config |
| securityContext.container.runAsUser / runAsGroup | 0 / 0 |
| securityContext.container.runAsNonRoot | false |
| securityContext.container.readOnlyRootFilesystem | false |

## Gotchas
- Chart port 3000 differs from linuxserver upstream EXPOSE 3001.
- Chart runs as root, not read-only rootfs. Differs from containerforge target.
