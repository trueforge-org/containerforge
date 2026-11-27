# TrueCharts chart: batnoter

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/batnoter/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `batnoter` v11.0.0, `appVersion: latest`, category `notes`, train `stable`.
- Description: "BatNoter is a web application that allows users to store notes in their git repository."
- Library dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Sources: `ghcr.io/batnoter/batnoter/batnoter-ui`, github batnoter/batnoter, trueforge chart path.

## Image (values.yaml)
- Repository: `ghcr.io/batnoter/batnoter/batnoter-ui`
- Tag: `latest@sha256:9916463b41965035cc695b27bc8f3bf0fdc5923f5046d8fbd857d206b2d120a4`
- pullPolicy: IfNotPresent

## Security context
- `readOnlyRootFilesystem: false`, `runAsGroup: 0`, `runAsUser: 0`.

## Ports
| Name | Service port | Protocol | Target port |
| --- | --- | --- | --- |
| main | 10351 | http | 3000 |

## Probes / Env / Persistence
- No probes set. No env set. No persistence block in values.yaml.

## Gotchas
- Container listens on 3000 (chart targetPort), not 80/8080.
- Chart runs as root.
