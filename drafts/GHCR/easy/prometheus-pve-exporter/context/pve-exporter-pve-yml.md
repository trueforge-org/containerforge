# prometheus-pve-exporter pve.yml (main branch, sample config)

## Source URL(s) + date
- https://raw.githubusercontent.com/prometheus-pve/prometheus-pve-exporter/main/pve.yml (fetched 2026-11-27)
- Same as https://github.com/prometheus-pve/prometheus-pve-exporter/blob/main/pve.yml

## Content
```
default:
  user: prometheus@pve
  token_name: prompve-scraper
  token_value: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

## Notes
- Config file format for pve_exporter (`default` section with user, token_name, token_value). Chart uses env vars (PVE_USER, PVE_TOKEN_NAME, PVE_TOKEN_VALUE) instead of this file, as listed in `truecharts-prometheus-pve-exporter.md`.
