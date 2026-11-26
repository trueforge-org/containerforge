# TrueCharts chart: hetzner-ddns
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hetzner-ddns (raw values.yaml + Chart.yaml fetched 2026-11-26)

## Chart.yaml
- version 11.0.0, appVersion latest; common 32.8.5; train stable

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/kutzilla/hetzner-ddns |
| image.tag | latest@sha256:b827c9203391994382e4a08927fc15c04d3a023bacc15b22480bc8250e787387 |
| persistence | {} (none) |
| securityContext.container | runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false |
| service.main | enabled false (no port) |
| probes | all disabled |
| env API_TOKEN | secretKeyRef env-secrets/API_TOKEN (secret default "my-secret-api-token") |
| env RECORD_TYPE | A |
| env ZONE_NAME | example.com |

## Notes
- No ports, no volumes, no probes. Runs as root.
- RECORD_NAME, CRON_EXPRESSION, TTL not set by chart (upstream defaults apply).
- Upstream calls dns.hetzner.com which Hetzner shut down in May 2026 (see hetzner-dns-endpoint.md).
