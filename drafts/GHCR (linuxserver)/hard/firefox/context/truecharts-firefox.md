# TrueCharts chart: firefox

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/firefox/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/firefox/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `firefox`, version 48.0.0, `appVersion: 1160.0.1`, type application, category browser.
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Chart sources: ghcr.io/linuxserver/firefox, github linuxserver/docker-firefox.

## Image
- `image.repository: ghcr.io/linuxserver/firefox`
- `image.tag: 1160.0.1@sha256:fabb762a6cc7c3594700450750d4ae47dede96ed329d330d769f523ae654059d`
- Tag `1160.0.1` equals chart appVersion in Chart.yaml. Chart pins a digest.

## Runtime config (values.yaml)
| Key | Value |
| --- | --- |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.runAsNonRoot | false |
| securityContext.container.runAsUser / runAsGroup | 0 / 0 |
| service.main.ports.main | protocol http, port 10131 |
| probes | liveness, readiness, startup all `type: http` |
| env FM_HOME | /config |
| env CUSTOM_PORT | `{{ .Values.service.main.ports.main.port }}` (10131) |
| env TITLE | "TrueChartVNC Client" |
| persistence.config | enabled, mountPath /config |
| persistence.varrun | enabled false |

## Gotchas
- Chart runs as root (runAsUser 0) and non-read-only rootfs. Differs from the containerforge target (rootless, read-only rootfs).
- Chart port 10131 differs from linuxserver upstream port 3001.
