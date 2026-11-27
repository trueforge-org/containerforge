# TrueCharts chart: bentopdf

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bentopdf/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `bentopdf` v3.0.0, `appVersion: 2.8.12`, category `productivity`, train `stable`.
- Description: "BentoPDF is a lightweight, browser-based PDF toolkit for editing, converting and signing PDFs, with all processing done locally in the browser."
- Library dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Sources: `ghcr.io/alam00000/bentopdf-simple`, github alam00000/bentopdf, trueforge chart path.

## Image (values.yaml)
- Repository: `ghcr.io/alam00000/bentopdf-simple`
- Tag: `2.8.12@sha256:f96da8c4a347880b891d66aa2ebfa6b63f76277dafcfcdfa40c8e6b92c59ef44`
- pullPolicy: IfNotPresent

## Ports
| Name | Service port | Protocol | Target |
| --- | --- | --- | --- |
| main | 8080 | http | 8080 |

## Probes / Env
- No probes, no env set in values.yaml.

## Persistence (emptyDir, comment: nginx needs writable pid and temp dirs; root FS read-only by default)
| Name | Mount |
| --- | --- |
| nginx-cache | /var/cache/nginx (emptyDir) |
| nginx-tmp | /etc/nginx/tmp (emptyDir) |

## Gotchas
- Chart mounts an emptyDir at `/etc/nginx/tmp` (upstream pid location) and `/var/cache/nginx`.
- Chart image is the `bentopdf-simple` variant (`SIMPLE_MODE`), not the full `dist` variant.
