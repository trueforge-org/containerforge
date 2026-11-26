# Docker Hub adguard/adguardhome and TrueCharts adguard-home chart

## Source URL(s) + date
- https://hub.docker.com/r/adguard/adguardhome (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/adguard-home/Chart.yaml (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/adguard-home/values.yaml (fetched 2026-11-26)
- Tree page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/adguard-home not parsed.

## Docker Hub
- Title: "adguard/adguardhome - Docker Image"
- Meta description: "Network-wide ads & trackers blocking DNS server"
- JS-rendered; tags (`beta`, `edge` per README) not extractable from HTML.

## Chart (reference only)
- `adguard-home` chart version 16.0.0, appVersion 1.0.0.
- Depends on `common` 32.8.5.
- Image `docker.io/adguard/adguardhome`, tag `v1.0.0@sha256:f00a586f0d1caa74f149340bfb225014960310488ffa838406b89256900a96c2`.
- Security: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
- Command: `/opt/adguardhome/AdGuardHome` with args `--no-check-update`, `--config /opt/adguardhome/conf/AdGuardHome.yaml`, `--work-dir /opt/adguardhome/work`, `--web-addr 0.0.0.0:<main port>`.
- Probes: HTTP `/` (liveness, readiness, startup).
- Services: main HTTP 10232; dns-tcp/udp 53; dns-https 10234 -> 443 (tcp and udp); dns-crypt 5443 (tcp and udp); dns-quic 784, 853, 8853 (udp).
- Persistence: `config` -> `/opt/adguardhome/conf`; `data` -> `/opt/adguardhome/work`.
- Ingress integration: homepage widget type `adguard`.

## Gotchas
- Chart paths (`/opt/adguardhome/conf`, `/opt/adguardhome/work`) match upstream Dockerfile; plan.md uses `/config` instead.
