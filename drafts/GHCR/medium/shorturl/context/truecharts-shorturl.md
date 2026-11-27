# TrueCharts chart: shorturl (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shorturl/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `shorturl` v16.0.0, appVersion 0.1.0, category media, depends on `common` 32.8.5.
- Description: self-hosted web app for shortening URLs.
- Sources: https://ghcr.io/nicholaswilde/shorturl , https://github.com/nicholaswilde/docker-shorturl , https://github.com/prologic/shorturl (404, see README)

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/nicholaswilde/shorturl |
| tag | version-v0.1.0@sha256:75fc450af5d2d07e5caebc6a01863a0aacdc15c1fbe57b3db46e3bd548226420 |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | targetPort |
| --- | --- | --- |
| main | 10076 | 8000 |

## Persistence
- `data`: enabled, mountPath `/data`
- `varrun`: enabled (no mountPath given)

## Security context (chart override)
- container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Env / probes
- No env or probes set in values.yaml.
