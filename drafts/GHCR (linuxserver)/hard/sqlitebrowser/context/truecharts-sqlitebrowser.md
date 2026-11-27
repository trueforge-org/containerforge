# TrueCharts chart: sqlitebrowser
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sqlitebrowser/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart name sqlitebrowser, chart version 16.0.0, appVersion 18.04.1
- Home: https://truecharts.org/charts/stable/sqlitebrowser
- Sources listed: https://ghcr.io/linuxserver/sqlitebrowser, https://github.com/linuxserver/docker-sqlitebrowser, https://sqlitebrowser.org/

## Dependencies
- common 32.8.5 from oci://oci.trueforge.org/truecharts

## Image
- Repository ghcr.io/linuxserver/sqlitebrowser
- Tag 18.04.1, pinned by sha256 digest
- pullPolicy IfNotPresent

## Ports
- Service port 10137 -> container targetPort 3000

## Env vars
- None defined

## Volumes/paths
| Name | Enabled | mountPath |
|---|---|---|
| config | yes | /config |
| varrun | yes | chart default (not set) |

## Probes
- None defined (chart defaults)

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false

## Gotchas
- Chart runs as root with writable rootfs; does not match a rootless/read-only-rootfs image policy.
