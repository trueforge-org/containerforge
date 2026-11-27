# Exporter wiki and Grafana dashboard 10347

## Source URL(s) + date
- https://github.com/prometheus-pve/prometheus-pve-exporter/wiki (fetched 2026-11-27, home page only)
- https://grafana.com/grafana/dashboards/10347-proxmox-via-prometheus (fetched 2026-11-27)

## Wiki
- Home page lists two pages: "PVE Exporter on Proxmox VE Node in a venv" and "PVE Exporter with a custom CA". Sub-pages not fetched (budget; not needed for the container build).
- Relevant for custom CA setups if the chart needs them. Not verified.

## Grafana dashboard
- Title: "Proxmox via Prometheus" (Grafana Labs dashboard 10347). Page returned title and generic site text only; no panel or variable details extracted.
- Chart ships its own `dashboard.json` via configmap; dashboard facts not verified against it.
