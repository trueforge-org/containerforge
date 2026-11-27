# TrueCharts chart: mysql-workbench

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mysql-workbench/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mysql-workbench/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `mysql-workbench`, version 15.0.0, `appVersion: 8.0.47`, category incubator.
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Description: MySQL Workbench, unified visual tool for database architects, developers and DBAs.
- Chart sources: ghcr.io/linuxserver/mysql-workbench, github trueforge-org/truecharts chart path.

## Image
- `image.repository: ghcr.io/linuxserver/mysql-workbench`
- `image.tag: 8.0.47@sha256:32ff69c9d098c0b56b33885d3afc6a78a79b4a1b4032cf9d022db9fcc9e0f5f8`

## Runtime config (values.yaml)
| Key | Value |
| --- | --- |
| service.main.ports.main | protocol http, port 10134, targetPort 3000 |
| env | none set |
| persistence.config | enabled, mountPath /config |
| persistence.varrun | enabled true |
| securityContext.container.runAsUser / runAsGroup | 0 / 0 |
| securityContext.container.runAsNonRoot | false |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.capabilities.add | IPC_LOCK |

## Gotchas
- Chart targetPort 3000 differs from linuxserver upstream EXPOSE 3001.
- Chart runs as root with IPC_LOCK, not rootless. Differs from the containerforge target.
