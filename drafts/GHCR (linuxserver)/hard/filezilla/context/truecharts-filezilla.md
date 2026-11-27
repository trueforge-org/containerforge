# TrueCharts filezilla (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/filezilla/values.yaml ; .../Chart.yaml (fetched 2026-11-27)

## What it is
FileZilla FTP/FTPS/SFTP client (GUI via Selkies). Chart version 17.0.1, appVersion 3.69.6, category media, train stable.

## Image
- repository: `ghcr.io/linuxserver/filezilla`
- tag: `3.69.6@sha256:1705ca009dd10d07977324da9c46de7e4895136e990c0aeaf526cf4971e68991`
- pullPolicy: IfNotPresent

## Service / ports
- service.main.ports.main: port 10035, protocol http, targetPort 3000

## Persistence
| name | enabled | mountPath |
| --- | --- | --- |
| config | true | /config |
| varrun | false | - |

## Security context
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0
- No env, probes or workload sections

## Chart deps
- `common` 32.8.5 from oci://oci.trueforge.org/truecharts; kubeVersion >=1.33.0-0

## Gotchas
- Targets port 3000; upstream Dockerfile EXPOSE 3001 (see Dockerfile file).
