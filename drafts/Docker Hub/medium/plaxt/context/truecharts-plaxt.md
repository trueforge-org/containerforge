# TrueCharts chart: plaxt

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plaxt/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plaxt/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `plaxt`, chart version 14.0.0, appVersion `latest`.
- Library dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
| Key | Value |
| --- | --- |
| repository | docker.io/xanderstrike/goplaxt |
| tag | latest@sha256:ab060da4503395162c38068ea9ac604834c19acc495b435f3027303de2cc2edc |
| pullPolicy | IfNotPresent |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 8000 | 8000 |

## Env vars (main container)
| Name | Value / source |
| --- | --- |
| TRAKT_ID | empty string |
| TRAKT_SECRET | secretKeyRef `env-secrets`, key `TRAKT_SECRET` (chart default empty) |

## Volumes/paths
| Persistence | Mount |
| --- | --- |
| config | /app/keystore |

## User/UID
- Container: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- None defined.

## Gotchas
- Chart runs as root.
- Chart values do not set ALLOWED_HOSTNAMES (upstream docs list it as required; see dockerhub-plaxt.md).
