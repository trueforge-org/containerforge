# TrueCharts chart: pretend-youre-xyzzy

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pretend-youre-xyzzy/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pretend-youre-xyzzy/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `pretend-youre-xyzzy`, chart version 20.0.0, appVersion `on-demand-2.1.1`.
- Library dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
| Key | Value |
| --- | --- |
| repository | docker.io/cyb3rjak3/dockeryourxyzzy |
| tag | on-demand-v2.1.1@sha256:8c25e08714170685ae286b01d6a25de2b1042e6dc0704acf93b976689e3fd5cc |
| pullPolicy | IfNotPresent |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 10094 | 8080 |

## Env vars
- None defined.

## Volumes/paths
- None defined.

## User/UID
- Container: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- None defined.

## Gotchas
- Chart runs as root; no env, no persistence in chart values.
- Chart image is the Cyb3r-Jak3 packaging image (on-demand variant), not upstream ajanata.
