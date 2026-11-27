# TrueCharts chart: whoogle

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/whoogle/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `whoogle` v17.0.0, appVersion 1.2.4. Description: self-hosted, ad-free, privacy-respecting metasearch engine. Category media.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Image (values.yaml)
- repository: `ghcr.io/benbusby/whoogle-search`
- tag: `1.2.4@sha256:6ae072238642b7e5860c8fa7f68cf06be797eb4e2278fc41d17d3b5e8a051eea`
- pullPolicy: IfNotPresent

## Runtime security
- runAsUser 0, runAsGroup 0, runAsNonRoot false (overrides image USER whoogle uid 927)
- readOnlyRootFilesystem: false

## Ports
| name | port | targetPort |
| --- | --- | --- |
| main | 10052 | 5000 |

## Persistence
| name | mountPath |
| --- | --- |
| config | /config |

## Env vars (chart values)
| Env | Value |
| --- | --- |
| WHOOGLE_CONFIG_COUNTRY | "" |
| WHOOGLE_CONFIG_THEME | "dark" |
| WHOOGLE_CONFIG_SAFE | true |
| WHOOGLE_CONFIG_ALTS | false |
| WHOOGLE_CONFIG_TOR | false |
| WHOOGLE_CONFIG_NEW_TAB | false |
| WHOOGLE_CONFIG_GET_ONLY | false |
| WHOOGLE_CONFIG_URL | https://<your url>/ (placeholder, must be set by user) |
| WHOOGLE_CONFIG_STYLE | "" |

## Gotchas
- WHOOGLE_CONFIG_URL is a placeholder string shipped in values.yaml.
- No probes defined in values.yaml (image HEALTHCHECK curls /healthz on EXPOSE_PORT).
- Container listens on 5000 internally (EXPOSE_PORT default 5000); chart targetPort 5000 matches.
